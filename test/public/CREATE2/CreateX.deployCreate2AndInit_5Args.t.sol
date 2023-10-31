// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTest} from "../../utils/BaseTest.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {ERC20MockPayable} from "../../mocks/ERC20MockPayable.sol";
import {CreateX} from "../../../src/CreateX.sol";

contract CreateX_DeployCreate2AndInit_5Args_Public_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // To avoid any stack-too-deep errors, we use `internal` state variables for the precomputed `CREATE2` address
    // and some further contract deployment addresses and variables.
    address internal computedAddress;
    address internal newContractOriginalDeployer;
    address internal newContractMsgSender;
    uint256 internal snapshotId;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function setUp() public override {
        BaseTest.setUp();
        arg1 = "MyToken";
        arg2 = "MTKN";
        arg3 = makeAddr("initialAccount");
        arg4 = 100;
        args = abi.encode(arg1, arg2, arg3, arg4);
        cachedInitCode = abi.encodePacked(type(ERC20MockPayable).creationCode, args);
        initCodeHash = keccak256(cachedInitCode);
    }

    modifier whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLength() {
        if (cachedInitCode.length == 0) {
            revert ZeroByteInitCode(SELF);
        }
        _;
    }

    modifier whenTheInitialisationCallIsSuccessful() {
        _;
    }

    function testFuzz_WhenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLengthAndWhenTheInitialisationCallIsSuccessful(
        address originalDeployer,
        CreateX.Values memory values,
        bytes32 salt,
        uint64 chainId,
        address msgSender
    )
        external
        whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLength
        whenTheInitialisationCallIsSuccessful
    {
        values.constructorAmount = bound(values.constructorAmount, 0, type(uint64).max);
        values.initCallAmount = bound(values.initCallAmount, 0, type(uint64).max);
        vm.deal(originalDeployer, 2 * (values.constructorAmount + values.initCallAmount));
        vm.assume(
            chainId != block.chainid &&
                chainId != 0 &&
                originalDeployer != msgSender &&
                originalDeployer != createXAddr &&
                originalDeployer != zeroAddress &&
                msgSender != createXAddr &&
                msgSender != zeroAddress
        );
        snapshotId = vm.snapshot();

        // Helper logic to increase the probability of matching a permissioned deploy protection during fuzzing.
        if (chainId % 2 == 0) {
            salt = bytes32(abi.encodePacked(originalDeployer, bytes12(uint96(uint256(salt)))));
        }
        // Helper logic to increase the probability of matching a cross-chain redeploy protection during fuzzing.
        if (chainId % 3 == 0) {
            salt = bytes32(abi.encodePacked(bytes20(salt), hex"01", bytes11(uint88(uint256(salt)))));
        }
        (
            bool permissionedDeployProtection,
            bool xChainRedeployProtection,
            bool mustRevert,
            bytes32 guardedSalt
        ) = parseFuzzerSalt(originalDeployer, salt);

        if (mustRevert) {
            vm.startPrank(originalDeployer);
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                cachedInitCode,
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values,
                arg3
            );
            vm.stopPrank();
        } else {
            // We calculate the address beforehand where the contract is to be deployed.
            computedAddress = createX.computeCreate2Address(guardedSalt, initCodeHash, createXAddr);
            vm.assume(originalDeployer != computedAddress);

            // We also check for the ERC-20 standard `Transfer` event.
            vm.expectEmit(true, true, true, true, computedAddress);
            emit IERC20.Transfer(zeroAddress, arg3, arg4);
            // It returns a contract address with a non-zero bytecode length and a potential non-zero ether balance.
            // It emits the event `ContractCreation` with the contract address and the salt as indexed arguments.
            vm.expectEmit(true, true, true, true, createXAddr);
            emit CreateX.ContractCreation(computedAddress, guardedSalt);
            vm.startPrank(originalDeployer);
            address newContract = createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                cachedInitCode,
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values,
                arg3
            );
            vm.stopPrank();

            assertEq(newContract, computedAddress, "100");
            assertNotEq(newContract, zeroAddress, "200");
            assertNotEq(newContract.code.length, 0, "300");
            assertEq(newContract.balance, values.constructorAmount + values.initCallAmount, "400");
            assertEq(createXAddr.balance, 0, "500");
            assertEq(ERC20MockPayable(computedAddress).name(), arg1, "600");
            assertEq(ERC20MockPayable(computedAddress).symbol(), arg2, "700");
            assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), 2 * arg4, "800");

            if (permissionedDeployProtection && xChainRedeployProtection) {
                vm.chainId(chainId);
                vm.startPrank(originalDeployer);
                newContractOriginalDeployer = createX.deployCreate2AndInit{
                    value: values.constructorAmount + values.initCallAmount
                }(salt, cachedInitCode, abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)), values, arg3);
                vm.stopPrank();
                vm.assume(originalDeployer != newContractOriginalDeployer);

                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractOriginalDeployer, computedAddress, "900");
                assertNotEq(newContractOriginalDeployer, zeroAddress, "1000");
                assertNotEq(newContractOriginalDeployer.code.length, 0, "1100");
                assertEq(newContractOriginalDeployer.balance, values.constructorAmount + values.initCallAmount, "1200");
                assertEq(createXAddr.balance, 0, "1300");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "1400");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "1500");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), 2 * arg4, "1600");
            } else if (permissionedDeployProtection) {
                vm.chainId(chainId);
                // We mock a potential frontrunner address.
                vm.deal(msgSender, values.constructorAmount + values.initCallAmount);
                vm.startPrank(msgSender);
                newContractMsgSender = createX.deployCreate2AndInit{
                    value: values.constructorAmount + values.initCallAmount
                }(salt, cachedInitCode, abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)), values, arg3);
                vm.stopPrank();
                vm.assume(msgSender != newContractMsgSender);

                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractMsgSender, computedAddress, "1700");
                assertNotEq(newContractMsgSender, zeroAddress, "1800");
                assertNotEq(newContractMsgSender.code.length, 0, "1900");
                assertEq(newContractMsgSender.balance, values.constructorAmount + values.initCallAmount, "2000");
                assertEq(createXAddr.balance, 0, "2100");
                assertEq(ERC20MockPayable(newContractMsgSender).name(), arg1, "2200");
                assertEq(ERC20MockPayable(newContractMsgSender).symbol(), arg2, "2300");
                assertEq(ERC20MockPayable(newContractMsgSender).balanceOf(arg3), 2 * arg4, "2400");

                // Foundry does not create a new, clean EVM environment when the `chainId` is changed, and
                // a deployment of a contract to the same address therefore fails (see issue: https://github.com/foundry-rs/foundry/issues/6008).
                // To solve this problem, we return to the original snapshot state.
                vm.revertTo(snapshotId);
                // We mock the original caller.
                vm.startPrank(originalDeployer);
                newContractOriginalDeployer = createX.deployCreate2AndInit{
                    value: values.constructorAmount + values.initCallAmount
                }(salt, cachedInitCode, abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)), values, arg3);
                vm.stopPrank();
                vm.assume(originalDeployer != newContractOriginalDeployer);

                // The newly created contract on chain `chainId` must be the same as the previously created contract
                // at the `computedAddress` address. As we return to the original snapshot state, we have to recalculate
                // the address.
                assertEq(
                    newContractOriginalDeployer,
                    createX.computeCreate2Address(guardedSalt, initCodeHash, createXAddr),
                    "2500"
                );
                assertNotEq(newContractOriginalDeployer, newContractMsgSender, "2600");
                assertNotEq(newContractOriginalDeployer, zeroAddress, "2700");
                assertNotEq(newContractOriginalDeployer.code.length, 0, "2800");
                assertEq(newContractOriginalDeployer.balance, values.constructorAmount + values.initCallAmount, "2900");
                assertEq(createXAddr.balance, 0, "3000");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "3100");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "3200");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), 2 * arg4, "3300");
            } else if (xChainRedeployProtection) {
                vm.chainId(chainId);
                vm.startPrank(originalDeployer);
                newContractOriginalDeployer = createX.deployCreate2AndInit{
                    value: values.constructorAmount + values.initCallAmount
                }(salt, cachedInitCode, abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)), values, arg3);
                vm.stopPrank();
                vm.assume(originalDeployer != newContractOriginalDeployer);

                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractOriginalDeployer, computedAddress, "3400");
                assertNotEq(newContractOriginalDeployer, zeroAddress, "3500");
                assertNotEq(newContractOriginalDeployer.code.length, 0, "3600");
                assertEq(newContractOriginalDeployer.balance, values.constructorAmount + values.initCallAmount, "3700");
                assertEq(createXAddr.balance, 0, "3800");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "3900");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "4000");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), 2 * arg4, "4100");
            }
        }
    }

    modifier whenTheCreateXContractHasANonZeroBalance(uint256 amount) {
        cachedBalance = bound(amount, 1, type(uint64).max);
        vm.deal(createXAddr, cachedBalance);
        _;
    }

    modifier whenTheRefundTransactionIsSuccessful() {
        _;
    }

    function testFuzz_WhenTheCreateXContractHasANonZeroBalanceAndWhenTheRefundTransactionIsSuccessful(
        address originalDeployer,
        CreateX.Values memory values,
        bytes32 salt,
        uint64 chainId,
        address msgSender
    )
        external
        whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLength
        whenTheInitialisationCallIsSuccessful
        // To avoid any stack-too-deep errors, we use the `chainId` for the `CreateX` balance.
        whenTheCreateXContractHasANonZeroBalance(chainId)
        whenTheRefundTransactionIsSuccessful
    {
        values.constructorAmount = bound(values.constructorAmount, 0, type(uint64).max);
        values.initCallAmount = bound(values.initCallAmount, 0, type(uint64).max);
        vm.deal(originalDeployer, 2 * (values.constructorAmount + values.initCallAmount));
        vm.assume(
            chainId != block.chainid &&
                chainId != 0 &&
                originalDeployer != msgSender &&
                originalDeployer != createXAddr &&
                originalDeployer != zeroAddress &&
                msgSender != createXAddr &&
                msgSender != zeroAddress
        );
        snapshotId = vm.snapshot();

        // Helper logic to increase the probability of matching a permissioned deploy protection during fuzzing.
        if (chainId % 2 == 0) {
            salt = bytes32(abi.encodePacked(originalDeployer, bytes12(uint96(uint256(salt)))));
        }
        // Helper logic to increase the probability of matching a cross-chain redeploy protection during fuzzing.
        if (chainId % 3 == 0) {
            salt = bytes32(abi.encodePacked(bytes20(salt), hex"01", bytes11(uint88(uint256(salt)))));
        }
        (
            bool permissionedDeployProtection,
            bool xChainRedeployProtection,
            bool mustRevert,
            bytes32 guardedSalt
        ) = parseFuzzerSalt(originalDeployer, salt);

        if (mustRevert) {
            vm.startPrank(originalDeployer);
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                cachedInitCode,
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values,
                arg3
            );
            vm.stopPrank();
        } else {
            // We calculate the address beforehand where the contract is to be deployed.
            computedAddress = createX.computeCreate2Address(guardedSalt, initCodeHash, createXAddr);
            vm.assume(originalDeployer != computedAddress);

            // We also check for the ERC-20 standard `Transfer` event.
            vm.expectEmit(true, true, true, true, computedAddress);
            emit IERC20.Transfer(zeroAddress, arg3, arg4);
            // It returns a contract address with a non-zero bytecode length and a potential non-zero ether balance.
            // It emits the event `ContractCreation` with the contract address and the salt as indexed arguments.
            vm.expectEmit(true, true, true, true, createXAddr);
            emit CreateX.ContractCreation(computedAddress, guardedSalt);
            vm.startPrank(originalDeployer);
            address newContract = createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                cachedInitCode,
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values,
                arg3
            );
            vm.stopPrank();

            assertEq(newContract, computedAddress, "100");
            assertNotEq(newContract, zeroAddress, "200");
            assertNotEq(newContract.code.length, 0, "300");
            assertEq(newContract.balance, values.constructorAmount + values.initCallAmount, "400");
            assertEq(createXAddr.balance, 0, "500");
            // It returns the non-zero balance to the `refundAddress` address.
            assertEq(arg3.balance, cachedBalance, "600");
            assertEq(ERC20MockPayable(computedAddress).name(), arg1, "700");
            assertEq(ERC20MockPayable(computedAddress).symbol(), arg2, "800");
            assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), 2 * arg4, "900");

            if (permissionedDeployProtection && xChainRedeployProtection) {
                vm.chainId(chainId);
                vm.startPrank(originalDeployer);
                newContractOriginalDeployer = createX.deployCreate2AndInit{
                    value: values.constructorAmount + values.initCallAmount
                }(salt, cachedInitCode, abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)), values, arg3);
                vm.stopPrank();
                vm.assume(originalDeployer != newContractOriginalDeployer);

                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractOriginalDeployer, computedAddress, "1000");
                assertNotEq(newContractOriginalDeployer, zeroAddress, "1100");
                assertNotEq(newContractOriginalDeployer.code.length, 0, "1200");
                assertEq(newContractOriginalDeployer.balance, values.constructorAmount + values.initCallAmount, "1300");
                assertEq(createXAddr.balance, 0, "1400");
                // Since everything was returned in the previous call, the balance must be equal to the original
                // refund amount.
                assertEq(arg3.balance, cachedBalance, "1500");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "1600");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "1700");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), 2 * arg4, "1800");
            } else if (permissionedDeployProtection) {
                vm.chainId(chainId);
                // We mock a potential frontrunner address.
                vm.deal(msgSender, values.constructorAmount + values.initCallAmount);
                vm.startPrank(msgSender);
                newContractMsgSender = createX.deployCreate2AndInit{
                    value: values.constructorAmount + values.initCallAmount
                }(salt, cachedInitCode, abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)), values, arg3);
                vm.stopPrank();
                vm.assume(msgSender != newContractMsgSender);

                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractMsgSender, computedAddress, "1900");
                assertNotEq(newContractMsgSender, zeroAddress, "2000");
                assertNotEq(newContractMsgSender.code.length, 0, "2100");
                assertEq(newContractMsgSender.balance, values.constructorAmount + values.initCallAmount, "2200");
                assertEq(createXAddr.balance, 0, "2300");
                // Since everything was returned in the previous call, the balance must be equal to the original
                // refund amount.
                assertEq(arg3.balance, cachedBalance, "2400");
                assertEq(ERC20MockPayable(newContractMsgSender).name(), arg1, "2500");
                assertEq(ERC20MockPayable(newContractMsgSender).symbol(), arg2, "2600");
                assertEq(ERC20MockPayable(newContractMsgSender).balanceOf(arg3), 2 * arg4, "2700");

                // Foundry does not create a new, clean EVM environment when the `chainId` is changed, and
                // a deployment of a contract to the same address therefore fails (see issue: https://github.com/foundry-rs/foundry/issues/6008).
                // To solve this problem, we return to the original snapshot state.
                vm.revertTo(snapshotId);
                // We mock the original caller.
                vm.startPrank(originalDeployer);
                newContractOriginalDeployer = createX.deployCreate2AndInit{
                    value: values.constructorAmount + values.initCallAmount
                }(salt, cachedInitCode, abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)), values, arg3);
                vm.stopPrank();
                vm.assume(originalDeployer != newContractOriginalDeployer);

                // The newly created contract on chain `chainId` must be the same as the previously created contract
                // at the `computedAddress` address. As we return to the original snapshot state, we have to recalculate
                // the address.
                assertEq(
                    newContractOriginalDeployer,
                    createX.computeCreate2Address(guardedSalt, initCodeHash, createXAddr),
                    "2800"
                );
                assertNotEq(newContractOriginalDeployer, newContractMsgSender, "2900");
                assertNotEq(newContractOriginalDeployer, zeroAddress, "3000");
                assertNotEq(newContractOriginalDeployer.code.length, 0, "3100");
                assertEq(newContractOriginalDeployer.balance, values.constructorAmount + values.initCallAmount, "3200");
                assertEq(createXAddr.balance, 0, "3300");
                // It returns the non-zero balance to the `refundAddress` address.
                assertEq(arg3.balance, cachedBalance, "3400");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "3500");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "3600");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), 2 * arg4, "3700");
            } else if (xChainRedeployProtection) {
                vm.chainId(chainId);
                vm.startPrank(originalDeployer);
                newContractOriginalDeployer = createX.deployCreate2AndInit{
                    value: values.constructorAmount + values.initCallAmount
                }(salt, cachedInitCode, abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)), values, arg3);
                vm.stopPrank();
                vm.assume(originalDeployer != newContractOriginalDeployer);

                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractOriginalDeployer, computedAddress, "3800");
                assertNotEq(newContractOriginalDeployer, zeroAddress, "3900");
                assertNotEq(newContractOriginalDeployer.code.length, 0, "4000");
                assertEq(newContractOriginalDeployer.balance, values.constructorAmount + values.initCallAmount, "4100");
                assertEq(createXAddr.balance, 0, "4200");
                // Since everything was returned in the previous call, the balance must be equal to the original
                // refund amount.
                assertEq(arg3.balance, cachedBalance, "4300");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "4400");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "4500");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), 2 * arg4, "4600");
            }
        }
    }

    modifier whenTheRefundTransactionIsUnsuccessful() {
        _;
    }

    function testFuzz_WhenTheRefundTransactionIsUnsuccessful(
        CreateX.Values memory values,
        bytes32 salt,
        uint64 chainId
    )
        external
        whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLength
        whenTheInitialisationCallIsSuccessful
        // To avoid any stack-too-deep errors, we use the `chainId` for the `CreateX` balance.
        whenTheCreateXContractHasANonZeroBalance(chainId)
        whenTheRefundTransactionIsUnsuccessful
    {
        values.constructorAmount = bound(values.constructorAmount, 0, type(uint64).max);
        values.initCallAmount = bound(values.initCallAmount, 0, type(uint64).max);
        vm.deal(SELF, values.constructorAmount + values.initCallAmount);
        vm.assume(chainId != block.chainid && chainId != 0);
        // Helper logic to increase the probability of matching a permissioned deploy protection during fuzzing.
        if (chainId % 2 == 0) {
            salt = bytes32(abi.encodePacked(SELF, bytes12(uint96(uint256(salt)))));
        }
        // Helper logic to increase the probability of matching a cross-chain redeploy protection during fuzzing.
        if (chainId % 3 == 0) {
            salt = bytes32(abi.encodePacked(bytes20(salt), hex"01", bytes11(uint88(uint256(salt)))));
        }
        (, , bool mustRevert, ) = parseFuzzerSalt(SELF, salt);
        if (mustRevert) {
            vm.startPrank(SELF);
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                cachedInitCode,
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values,
                SELF
            );
            vm.stopPrank();
        } else {
            vm.startPrank(SELF);
            // It should revert.
            bytes memory expectedErr = abi.encodeWithSelector(
                CreateX.FailedEtherTransfer.selector,
                createXAddr,
                new bytes(0)
            );
            vm.expectRevert(expectedErr);
            createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                cachedInitCode,
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values,
                SELF
            );
            vm.stopPrank();
        }
    }

    modifier whenTheInitialisationCallIsUnsuccessful() {
        _;
    }

    function testFuzz_WhenTheInitialisationCallIsUnsuccessful(
        address originalDeployer,
        CreateX.Values memory values,
        bytes32 salt,
        uint64 chainId
    )
        external
        whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLength
        whenTheInitialisationCallIsUnsuccessful
    {
        values.constructorAmount = bound(values.constructorAmount, 0, type(uint64).max);
        values.initCallAmount = bound(values.initCallAmount, 0, type(uint64).max);
        vm.deal(originalDeployer, values.constructorAmount + values.initCallAmount);
        vm.assume(
            chainId != block.chainid &&
                chainId != 0 &&
                originalDeployer != createXAddr &&
                originalDeployer != zeroAddress
        );
        // Helper logic to increase the probability of matching a permissioned deploy protection during fuzzing.
        if (chainId % 2 == 0) {
            salt = bytes32(abi.encodePacked(originalDeployer, bytes12(uint96(uint256(salt)))));
        }
        // Helper logic to increase the probability of matching a cross-chain redeploy protection during fuzzing.
        if (chainId % 3 == 0) {
            salt = bytes32(abi.encodePacked(bytes20(salt), hex"01", bytes11(uint88(uint256(salt)))));
        }
        (, , bool mustRevert, ) = parseFuzzerSalt(originalDeployer, salt);
        if (mustRevert) {
            vm.startPrank(originalDeployer);
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                cachedInitCode,
                abi.encodeWithSignature("wagmi"),
                values,
                arg3
            );
            vm.stopPrank();
        } else {
            vm.startPrank(originalDeployer);
            // It should revert.
            bytes memory expectedErr = abi.encodeWithSelector(
                CreateX.FailedContractInitialisation.selector,
                createXAddr,
                new bytes(0)
            );
            vm.expectRevert(expectedErr);
            createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                cachedInitCode,
                abi.encodeWithSignature("wagmi"),
                values,
                arg3
            );
            vm.stopPrank();
        }
    }

    modifier whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithAZeroLength() {
        _;
    }

    function testFuzz_WhenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithAZeroLength(
        address originalDeployer,
        CreateX.Values memory values,
        bytes32 salt,
        uint64 chainId
    ) external whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithAZeroLength {
        values.constructorAmount = bound(values.constructorAmount, 0, type(uint64).max);
        values.initCallAmount = bound(values.initCallAmount, 0, type(uint64).max);
        vm.deal(originalDeployer, values.constructorAmount + values.initCallAmount);
        vm.assume(
            chainId != block.chainid &&
                chainId != 0 &&
                originalDeployer != createXAddr &&
                originalDeployer != zeroAddress
        );
        // Helper logic to increase the probability of matching a permissioned deploy protection during fuzzing.
        if (chainId % 2 == 0) {
            salt = bytes32(abi.encodePacked(originalDeployer, bytes12(uint96(uint256(salt)))));
        }
        // Helper logic to increase the probability of matching a cross-chain redeploy protection during fuzzing.
        if (chainId % 3 == 0) {
            salt = bytes32(abi.encodePacked(bytes20(salt), hex"01", bytes11(uint88(uint256(salt)))));
        }
        (, , bool mustRevert, ) = parseFuzzerSalt(originalDeployer, salt);
        if (mustRevert) {
            vm.startPrank(originalDeployer);
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                new bytes(0),
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values,
                arg3
            );
            vm.stopPrank();
        } else {
            vm.startPrank(originalDeployer);
            // It should revert.
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                new bytes(0),
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values,
                arg3
            );
            vm.stopPrank();
        }
    }

    modifier whenTheInitCodeFailsToDeployARuntimeBytecode() {
        _;
    }

    function testFuzz_WhenTheInitCodeFailsToDeployARuntimeBytecode(
        address originalDeployer,
        CreateX.Values memory values,
        bytes32 salt,
        uint64 chainId
    ) external whenTheInitCodeFailsToDeployARuntimeBytecode {
        values.constructorAmount = bound(values.constructorAmount, 0, type(uint64).max);
        values.initCallAmount = bound(values.initCallAmount, 0, type(uint64).max);
        vm.deal(originalDeployer, values.constructorAmount + values.initCallAmount);
        vm.assume(
            chainId != block.chainid &&
                chainId != 0 &&
                originalDeployer != createXAddr &&
                originalDeployer != zeroAddress
        );
        // Helper logic to increase the probability of matching a permissioned deploy protection during fuzzing.
        if (chainId % 2 == 0) {
            salt = bytes32(abi.encodePacked(originalDeployer, bytes12(uint96(uint256(salt)))));
        }
        // Helper logic to increase the probability of matching a cross-chain redeploy protection during fuzzing.
        if (chainId % 3 == 0) {
            salt = bytes32(abi.encodePacked(bytes20(salt), hex"01", bytes11(uint88(uint256(salt)))));
        }
        (, , bool mustRevert, ) = parseFuzzerSalt(originalDeployer, salt);
        // The following contract creation code contains the invalid opcode `PUSH0` (`0x5F`) and `CREATE` must therefore
        // return the zero address (technically zero bytes `0x`), as the deployment fails. This test also ensures that if
        // we ever accidentally change the EVM version in Foundry and Hardhat, we will always have a corresponding failed test.
        bytes memory invalidInitCode = hex"5f_80_60_09_3d_39_3d_f3";
        if (mustRevert) {
            vm.startPrank(originalDeployer);
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                invalidInitCode,
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values,
                arg3
            );
            vm.stopPrank();
        } else {
            vm.startPrank(originalDeployer);
            // It should revert.
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                invalidInitCode,
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values,
                arg3
            );
            vm.stopPrank();
        }
    }
}
