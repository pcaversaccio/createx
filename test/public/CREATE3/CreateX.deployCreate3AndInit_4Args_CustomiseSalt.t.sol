// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {Vm} from "forge-std/Vm.sol";
import {BaseTest} from "../../utils/BaseTest.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {ERC20MockPayable} from "../../mocks/ERC20MockPayable.sol";
import {CreateX} from "../../../src/CreateX.sol";

contract CreateX_DeployCreate3AndInit_4Args_CustomiseSalt_Public_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // The `keccak256`-hashed `CREATE3` proxy contract creation bytecode.
    bytes32 internal proxyInitCodeHash =
        keccak256(abi.encodePacked(hex"67_36_3d_3d_37_36_3d_34_f0_3d_52_60_08_60_18_f3"));

    // To avoid any stack-too-deep errors, we use `internal` state variables for the precomputed `CREATE2` address
    // and some further contract deployment addresses and variables.
    address internal computedAddress;
    address internal proxyAddress;
    address internal newContractOriginalDeployer;
    address internal newContractMsgSender;
    uint256 internal snapshotId;
    bool internal permissionedDeployProtection;
    bool internal xChainRedeployProtection;
    bool internal mustRevert;
    bytes32 internal guardedSalt;

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
        (permissionedDeployProtection, xChainRedeployProtection, mustRevert, guardedSalt) = parseFuzzerSalt(
            originalDeployer,
            salt
        );

        if (mustRevert) {
            vm.startPrank(originalDeployer);
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate3AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                cachedInitCode,
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values
            );
            vm.stopPrank();
        } else {
            // We calculate the address beforehand where the contract is to be deployed.
            computedAddress = createX.computeCreate3Address(guardedSalt, createXAddr);
            vm.assume(originalDeployer != computedAddress);
            // We calculate the address beforehand where the proxy is to be deployed.
            proxyAddress = createX.computeCreate2Address(guardedSalt, proxyInitCodeHash, createXAddr);
            vm.assume(originalDeployer != proxyAddress);

            // It emits the event `Create3ProxyContractCreation` with the proxy address and the salt as indexed arguments.
            // We record the emitted events to later assert the proxy contract address.
            vm.recordLogs();
            vm.expectEmit(true, true, true, true, createXAddr);
            emit CreateX.Create3ProxyContractCreation(proxyAddress, guardedSalt);
            // We also check for the ERC-20 standard `Transfer` event.
            vm.expectEmit(true, true, true, true, computedAddress);
            emit IERC20.Transfer(zeroAddress, arg3, arg4);
            // It returns a contract address with a non-zero bytecode length and a potential non-zero ether balance.
            // It emits the event `ContractCreation` with the contract address as indexed argument.
            vm.expectEmit(true, true, true, true, createXAddr);
            emit CreateX.ContractCreation(computedAddress);
            vm.startPrank(originalDeployer);
            address newContract = createX.deployCreate3AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                cachedInitCode,
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values
            );
            vm.stopPrank();

            Vm.Log[] memory entries = vm.getRecordedLogs();
            assertEq(entries[0].topics[1], bytes32(uint256(uint160(proxyAddress))), "100");
            assertEq(newContract, computedAddress, "200");
            assertNotEq(newContract, zeroAddress, "300");
            assertNotEq(newContract.code.length, 0, "400");
            assertEq(newContract.balance, values.constructorAmount + values.initCallAmount, "500");
            assertEq(createXAddr.balance, 0, "600");
            assertEq(ERC20MockPayable(computedAddress).name(), arg1, "700");
            assertEq(ERC20MockPayable(computedAddress).symbol(), arg2, "800");
            assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), 2 * arg4, "900");

            if (permissionedDeployProtection && xChainRedeployProtection) {
                vm.chainId(chainId);
                (, , , guardedSalt) = parseFuzzerSalt(originalDeployer, salt);
                proxyAddress = createX.computeCreate2Address(guardedSalt, proxyInitCodeHash, createXAddr);
                vm.assume(originalDeployer != proxyAddress);
                // We record the emitted events to later assert the proxy contract address.
                vm.recordLogs();
                vm.expectEmit(true, true, true, true, createXAddr);
                emit CreateX.Create3ProxyContractCreation(proxyAddress, guardedSalt);
                vm.startPrank(originalDeployer);
                newContractOriginalDeployer = createX.deployCreate3AndInit{
                    value: values.constructorAmount + values.initCallAmount
                }(salt, cachedInitCode, abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)), values);
                vm.stopPrank();
                vm.assume(originalDeployer != newContractOriginalDeployer);

                entries = vm.getRecordedLogs();
                assertEq(entries[0].topics[1], bytes32(uint256(uint160(proxyAddress))), "1000");
                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractOriginalDeployer, computedAddress, "1100");
                assertNotEq(newContractOriginalDeployer, zeroAddress, "1200");
                assertNotEq(newContractOriginalDeployer.code.length, 0, "1300");
                assertEq(newContractOriginalDeployer.balance, values.constructorAmount + values.initCallAmount, "1400");
                assertEq(createXAddr.balance, 0, "1500");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "1600");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "1700");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), 2 * arg4, "1800");
            } else if (permissionedDeployProtection) {
                vm.chainId(chainId);
                (, , , guardedSalt) = parseFuzzerSalt(msgSender, salt);
                proxyAddress = createX.computeCreate2Address(guardedSalt, proxyInitCodeHash, createXAddr);
                vm.assume(msgSender != proxyAddress);
                // We record the emitted events to later assert the proxy contract address.
                vm.recordLogs();
                vm.expectEmit(true, true, true, true, createXAddr);
                emit CreateX.Create3ProxyContractCreation(proxyAddress, guardedSalt);
                // We mock a potential frontrunner address.
                vm.deal(msgSender, values.constructorAmount + values.initCallAmount);
                vm.startPrank(msgSender);
                newContractMsgSender = createX.deployCreate3AndInit{
                    value: values.constructorAmount + values.initCallAmount
                }(salt, cachedInitCode, abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)), values);
                vm.stopPrank();
                vm.assume(msgSender != newContractMsgSender);

                entries = vm.getRecordedLogs();
                assertEq(entries[0].topics[1], bytes32(uint256(uint160(proxyAddress))), "1900");
                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractMsgSender, computedAddress, "2000");
                assertNotEq(newContractMsgSender, zeroAddress, "2100");
                assertNotEq(newContractMsgSender.code.length, 0, "2200");
                assertEq(newContractMsgSender.balance, values.constructorAmount + values.initCallAmount, "2300");
                assertEq(createXAddr.balance, 0, "2400");
                assertEq(ERC20MockPayable(newContractMsgSender).name(), arg1, "2500");
                assertEq(ERC20MockPayable(newContractMsgSender).symbol(), arg2, "2600");
                assertEq(ERC20MockPayable(newContractMsgSender).balanceOf(arg3), 2 * arg4, "2700");

                // Foundry does not create a new, clean EVM environment when the `chainId` is changed, and
                // a deployment of a contract to the same address therefore fails (see issue: https://github.com/foundry-rs/foundry/issues/6008).
                // To solve this problem, we return to the original snapshot state.
                vm.revertTo(snapshotId);
                // We record the emitted events to later assert the proxy contract address.
                vm.recordLogs();
                (, , , guardedSalt) = parseFuzzerSalt(originalDeployer, salt);
                proxyAddress = createX.computeCreate2Address(guardedSalt, proxyInitCodeHash, createXAddr);
                vm.assume(originalDeployer != proxyAddress);
                vm.expectEmit(true, true, true, true, createXAddr);
                emit CreateX.Create3ProxyContractCreation(proxyAddress, guardedSalt);
                // We mock the original caller.
                vm.startPrank(originalDeployer);
                newContractOriginalDeployer = createX.deployCreate3AndInit{
                    value: values.constructorAmount + values.initCallAmount
                }(salt, cachedInitCode, abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)), values);
                vm.stopPrank();
                vm.assume(originalDeployer != newContractOriginalDeployer);

                entries = vm.getRecordedLogs();
                assertEq(entries[0].topics[1], bytes32(uint256(uint160(proxyAddress))), "2800");
                // The newly created contract on chain `chainId` must be the same as the previously created contract
                // at the `computedAddress` address. As we return to the original snapshot state, we have to recalculate
                // the address.
                assertEq(newContractOriginalDeployer, createX.computeCreate3Address(guardedSalt, createXAddr), "2900");
                assertNotEq(newContractOriginalDeployer, newContractMsgSender, "3000");
                assertNotEq(newContractOriginalDeployer, zeroAddress, "3100");
                assertNotEq(newContractOriginalDeployer.code.length, 0, "3200");
                assertEq(newContractOriginalDeployer.balance, values.constructorAmount + values.initCallAmount, "3300");
                assertEq(createXAddr.balance, 0, "3400");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "3500");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "3600");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), 2 * arg4, "3700");
            } else if (xChainRedeployProtection) {
                vm.chainId(chainId);
                (, , , guardedSalt) = parseFuzzerSalt(originalDeployer, salt);
                proxyAddress = createX.computeCreate2Address(guardedSalt, proxyInitCodeHash, createXAddr);
                vm.assume(originalDeployer != proxyAddress);
                // We record the emitted events to later assert the proxy contract address.
                vm.recordLogs();
                vm.expectEmit(true, true, true, true, createXAddr);
                emit CreateX.Create3ProxyContractCreation(proxyAddress, guardedSalt);
                vm.startPrank(originalDeployer);
                newContractOriginalDeployer = createX.deployCreate3AndInit{
                    value: values.constructorAmount + values.initCallAmount
                }(salt, cachedInitCode, abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)), values);
                vm.stopPrank();
                vm.assume(originalDeployer != newContractOriginalDeployer);

                entries = vm.getRecordedLogs();
                assertEq(entries[0].topics[1], bytes32(uint256(uint160(proxyAddress))), "3800");
                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractOriginalDeployer, computedAddress, "3900");
                assertNotEq(newContractOriginalDeployer, zeroAddress, "4000");
                assertNotEq(newContractOriginalDeployer.code.length, 0, "4100");
                assertEq(newContractOriginalDeployer.balance, values.constructorAmount + values.initCallAmount, "4200");
                assertEq(createXAddr.balance, 0, "4300");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "4400");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "4500");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), 2 * arg4, "4600");
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
        assumePayable(originalDeployer);
        snapshotId = vm.snapshot();

        // Helper logic to increase the probability of matching a permissioned deploy protection during fuzzing.
        if (chainId % 2 == 0) {
            salt = bytes32(abi.encodePacked(originalDeployer, bytes12(uint96(uint256(salt)))));
        }
        // Helper logic to increase the probability of matching a cross-chain redeploy protection during fuzzing.
        if (chainId % 3 == 0) {
            salt = bytes32(abi.encodePacked(bytes20(salt), hex"01", bytes11(uint88(uint256(salt)))));
        }
        (permissionedDeployProtection, xChainRedeployProtection, mustRevert, guardedSalt) = parseFuzzerSalt(
            originalDeployer,
            salt
        );

        if (mustRevert) {
            vm.startPrank(originalDeployer);
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate3AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                cachedInitCode,
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values
            );
            vm.stopPrank();
        } else {
            // We calculate the address beforehand where the contract is to be deployed.
            computedAddress = createX.computeCreate3Address(guardedSalt, createXAddr);
            vm.assume(originalDeployer != computedAddress);
            // We calculate the address beforehand where the proxy is to be deployed.
            proxyAddress = createX.computeCreate2Address(guardedSalt, proxyInitCodeHash, createXAddr);
            vm.assume(originalDeployer != proxyAddress);

            // It emits the event `Create3ProxyContractCreation` with the proxy address and the salt as indexed arguments.
            // We record the emitted events to later assert the proxy contract address.
            vm.recordLogs();
            vm.expectEmit(true, true, true, true, createXAddr);
            emit CreateX.Create3ProxyContractCreation(proxyAddress, guardedSalt);
            // We also check for the ERC-20 standard `Transfer` event.
            vm.expectEmit(true, true, true, true, computedAddress);
            emit IERC20.Transfer(zeroAddress, arg3, arg4);
            // It returns a contract address with a non-zero bytecode length and a potential non-zero ether balance.
            // It emits the event `ContractCreation` with the contract address as indexed argument.
            vm.expectEmit(true, true, true, true, createXAddr);
            emit CreateX.ContractCreation(computedAddress);
            vm.startPrank(originalDeployer);
            address newContract = createX.deployCreate3AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                cachedInitCode,
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values
            );
            vm.stopPrank();

            Vm.Log[] memory entries = vm.getRecordedLogs();
            assertEq(entries[0].topics[1], bytes32(uint256(uint160(proxyAddress))), "100");
            assertEq(newContract, computedAddress, "200");
            assertNotEq(newContract, zeroAddress, "300");
            assertNotEq(newContract.code.length, 0, "400");
            assertEq(newContract.balance, values.constructorAmount + values.initCallAmount, "500");
            assertEq(createXAddr.balance, 0, "600");
            // It returns the non-zero balance to the `msg.sender` address.
            assertEq(originalDeployer.balance, cachedBalance + values.constructorAmount + values.initCallAmount, "700");
            assertEq(ERC20MockPayable(computedAddress).name(), arg1, "800");
            assertEq(ERC20MockPayable(computedAddress).symbol(), arg2, "900");
            assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), 2 * arg4, "1000");

            if (permissionedDeployProtection && xChainRedeployProtection) {
                vm.chainId(chainId);
                (, , , guardedSalt) = parseFuzzerSalt(originalDeployer, salt);
                proxyAddress = createX.computeCreate2Address(guardedSalt, proxyInitCodeHash, createXAddr);
                vm.assume(originalDeployer != proxyAddress);
                // We record the emitted events to later assert the proxy contract address.
                vm.recordLogs();
                vm.expectEmit(true, true, true, true, createXAddr);
                emit CreateX.Create3ProxyContractCreation(proxyAddress, guardedSalt);
                vm.startPrank(originalDeployer);
                newContractOriginalDeployer = createX.deployCreate3AndInit{
                    value: values.constructorAmount + values.initCallAmount
                }(salt, cachedInitCode, abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)), values);
                vm.stopPrank();
                vm.assume(originalDeployer != newContractOriginalDeployer);

                entries = vm.getRecordedLogs();
                assertEq(entries[0].topics[1], bytes32(uint256(uint160(proxyAddress))), "1100");
                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractOriginalDeployer, computedAddress, "1200");
                assertNotEq(newContractOriginalDeployer, zeroAddress, "1300");
                assertNotEq(newContractOriginalDeployer.code.length, 0, "1400");
                assertEq(newContractOriginalDeployer.balance, values.constructorAmount + values.initCallAmount, "1500");
                assertEq(createXAddr.balance, 0, "1600");
                // Since everything was returned in the previous call, the balance must be equal to the original
                // refund amount.
                assertEq(originalDeployer.balance, cachedBalance, "1700");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "1800");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "1900");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), 2 * arg4, "2000");
            } else if (permissionedDeployProtection) {
                vm.chainId(chainId);
                (, , , guardedSalt) = parseFuzzerSalt(msgSender, salt);
                proxyAddress = createX.computeCreate2Address(guardedSalt, proxyInitCodeHash, createXAddr);
                vm.assume(msgSender != proxyAddress);
                // We record the emitted events to later assert the proxy contract address.
                vm.recordLogs();
                vm.expectEmit(true, true, true, true, createXAddr);
                emit CreateX.Create3ProxyContractCreation(proxyAddress, guardedSalt);
                // We mock a potential frontrunner address.
                vm.deal(msgSender, values.constructorAmount + values.initCallAmount);
                vm.startPrank(msgSender);
                newContractMsgSender = createX.deployCreate3AndInit{
                    value: values.constructorAmount + values.initCallAmount
                }(salt, cachedInitCode, abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)), values);
                vm.stopPrank();
                vm.assume(msgSender != newContractMsgSender);

                entries = vm.getRecordedLogs();
                assertEq(entries[0].topics[1], bytes32(uint256(uint160(proxyAddress))), "2100");
                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractMsgSender, computedAddress, "2200");
                assertNotEq(newContractMsgSender, zeroAddress, "2300");
                assertNotEq(newContractMsgSender.code.length, 0, "2400");
                assertEq(newContractMsgSender.balance, values.constructorAmount + values.initCallAmount, "2500");
                assertEq(createXAddr.balance, 0, "2600");
                // Since everything was returned in the previous call, the balance must be equal to the original
                // refund amount.
                assertEq(
                    originalDeployer.balance,
                    cachedBalance + values.constructorAmount + values.initCallAmount,
                    "2700"
                );
                assertEq(ERC20MockPayable(newContractMsgSender).name(), arg1, "2800");
                assertEq(ERC20MockPayable(newContractMsgSender).symbol(), arg2, "2900");
                assertEq(ERC20MockPayable(newContractMsgSender).balanceOf(arg3), 2 * arg4, "3000");

                // Foundry does not create a new, clean EVM environment when the `chainId` is changed, and
                // a deployment of a contract to the same address therefore fails (see issue: https://github.com/foundry-rs/foundry/issues/6008).
                // To solve this problem, we return to the original snapshot state.
                vm.revertTo(snapshotId);
                // We record the emitted events to later assert the proxy contract address.
                vm.recordLogs();
                (, , , guardedSalt) = parseFuzzerSalt(originalDeployer, salt);
                proxyAddress = createX.computeCreate2Address(guardedSalt, proxyInitCodeHash, createXAddr);
                vm.assume(originalDeployer != proxyAddress);
                vm.expectEmit(true, true, true, true, createXAddr);
                emit CreateX.Create3ProxyContractCreation(proxyAddress, guardedSalt);
                // We mock the original caller.
                vm.startPrank(originalDeployer);
                newContractOriginalDeployer = createX.deployCreate3AndInit{
                    value: values.constructorAmount + values.initCallAmount
                }(salt, cachedInitCode, abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)), values);
                vm.stopPrank();
                vm.assume(originalDeployer != newContractOriginalDeployer);

                entries = vm.getRecordedLogs();
                assertEq(entries[0].topics[1], bytes32(uint256(uint160(proxyAddress))), "3100");
                // The newly created contract on chain `chainId` must be the same as the previously created contract
                // at the `computedAddress` address. As we return to the original snapshot state, we have to recalculate
                // the address.
                assertEq(newContractOriginalDeployer, createX.computeCreate3Address(guardedSalt, createXAddr), "3200");
                assertNotEq(newContractOriginalDeployer, newContractMsgSender, "3300");
                assertNotEq(newContractOriginalDeployer, zeroAddress, "3400");
                assertNotEq(newContractOriginalDeployer.code.length, 0, "3500");
                assertEq(newContractOriginalDeployer.balance, values.constructorAmount + values.initCallAmount, "3600");
                assertEq(createXAddr.balance, 0, "3700");
                // It returns the non-zero balance to the `msg.sender` address.
                assertEq(
                    originalDeployer.balance,
                    cachedBalance + values.constructorAmount + values.initCallAmount,
                    "3800"
                );
                assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "3900");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "4000");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), 2 * arg4, "4100");
            } else if (xChainRedeployProtection) {
                vm.chainId(chainId);
                (, , , guardedSalt) = parseFuzzerSalt(originalDeployer, salt);
                proxyAddress = createX.computeCreate2Address(guardedSalt, proxyInitCodeHash, createXAddr);
                vm.assume(originalDeployer != proxyAddress);
                // We record the emitted events to later assert the proxy contract address.
                vm.recordLogs();
                vm.expectEmit(true, true, true, true, createXAddr);
                emit CreateX.Create3ProxyContractCreation(proxyAddress, guardedSalt);
                vm.startPrank(originalDeployer);
                newContractOriginalDeployer = createX.deployCreate3AndInit{
                    value: values.constructorAmount + values.initCallAmount
                }(salt, cachedInitCode, abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)), values);
                vm.stopPrank();
                vm.assume(originalDeployer != newContractOriginalDeployer);

                entries = vm.getRecordedLogs();
                assertEq(entries[0].topics[1], bytes32(uint256(uint160(proxyAddress))), "4200");
                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractOriginalDeployer, computedAddress, "4300");
                assertNotEq(newContractOriginalDeployer, zeroAddress, "4400");
                assertNotEq(newContractOriginalDeployer.code.length, 0, "4500");
                assertEq(newContractOriginalDeployer.balance, values.constructorAmount + values.initCallAmount, "4600");
                assertEq(createXAddr.balance, 0, "4700");
                // Since everything was returned in the previous call, the balance must be equal to the original
                // refund amount.
                assertEq(originalDeployer.balance, cachedBalance, "4800");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "4900");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "5000");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), 2 * arg4, "5100");
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
        (, , mustRevert, ) = parseFuzzerSalt(SELF, salt);
        if (mustRevert) {
            vm.startPrank(SELF);
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate3AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                cachedInitCode,
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values
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
            createX.deployCreate3AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                cachedInitCode,
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values
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
        (, , mustRevert, ) = parseFuzzerSalt(originalDeployer, salt);
        if (mustRevert) {
            vm.startPrank(originalDeployer);
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate3AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                cachedInitCode,
                abi.encodeWithSignature("wagmi"),
                values
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
            createX.deployCreate3AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                cachedInitCode,
                abi.encodeWithSignature("wagmi"),
                values
            );
            vm.stopPrank();
        }
    }

    modifier whenTheProxyContractCreationFails() {
        _;
    }

    function testFuzz_WhenTheProxyContractCreationFails(
        address originalDeployer,
        CreateX.Values memory values,
        bytes32 salt,
        uint64 chainId
    ) external whenTheProxyContractCreationFails {
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
        (, , mustRevert, guardedSalt) = parseFuzzerSalt(originalDeployer, salt);
        // We calculate the address beforehand where the contract is to be deployed.
        computedAddress = createX.computeCreate2Address(guardedSalt, proxyInitCodeHash, createXAddr);
        // To enforce a deployment failure, we add code to the destination address `proxy`.
        vm.etch(computedAddress, hex"01");
        if (mustRevert) {
            vm.startPrank(originalDeployer);
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate3AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                cachedInitCode,
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values
            );
            vm.stopPrank();
        } else {
            vm.startPrank(originalDeployer);
            // It should revert.
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate3AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                cachedInitCode,
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values
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
        (, , mustRevert, ) = parseFuzzerSalt(originalDeployer, salt);
        if (mustRevert) {
            vm.startPrank(originalDeployer);
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate3AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                new bytes(0),
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values
            );
            vm.stopPrank();
        } else {
            vm.startPrank(originalDeployer);
            // It should revert.
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate3AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                new bytes(0),
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values
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
        (, , mustRevert, ) = parseFuzzerSalt(originalDeployer, salt);
        // The following contract creation code contains the invalid opcode `PUSH0` (`0x5F`) and `CREATE` must therefore
        // return the zero address (technically zero bytes `0x`), as the deployment fails. This test also ensures that if
        // we ever accidentally change the EVM version in Foundry and Hardhat, we will always have a corresponding failed test.
        bytes memory invalidInitCode = hex"5f_80_60_09_3d_39_3d_f3";
        if (mustRevert) {
            vm.startPrank(originalDeployer);
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate3AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                invalidInitCode,
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values
            );
            vm.stopPrank();
        } else {
            vm.startPrank(originalDeployer);
            // It should revert.
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate3AndInit{value: values.constructorAmount + values.initCallAmount}(
                salt,
                invalidInitCode,
                abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
                values
            );
            vm.stopPrank();
        }
    }
}
