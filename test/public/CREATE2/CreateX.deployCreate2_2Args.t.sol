// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTest} from "../../utils/BaseTest.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {ERC20MockPayable} from "../../mocks/ERC20MockPayable.sol";
import {CreateX} from "../../../src/CreateX.sol";

contract CreateX_DeployCreate2_2Args_Public_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // To avoid any stack-too-deep errors, we use an `internal` state variable for the snapshot ID.
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

    function testFuzz_WhenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLength(
        address originalDeployer,
        uint256 msgValue,
        bytes32 salt,
        uint64 chainId,
        address msgSender
    ) external whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLength {
        msgValue = bound(msgValue, 0, type(uint64).max);
        vm.deal(originalDeployer, 2 * msgValue);
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
            createX.deployCreate2{value: msgValue}(salt, cachedInitCode);
            vm.stopPrank();
        } else {
            // We calculate the address beforehand where the contract is to be deployed.
            address computedAddress = createX.computeCreate2Address(guardedSalt, initCodeHash, createXAddr);
            vm.assume(originalDeployer != computedAddress);

            // We also check for the ERC-20 standard `Transfer` event.
            vm.expectEmit(true, true, true, true, computedAddress);
            emit IERC20.Transfer(zeroAddress, arg3, arg4);
            // It returns a contract address with a non-zero bytecode length and a potential non-zero ether balance.
            // It emits the event `ContractCreation` with the contract address and the salt as indexed arguments.
            vm.expectEmit(true, true, true, true, createXAddr);
            emit CreateX.ContractCreation(computedAddress, guardedSalt);
            vm.startPrank(originalDeployer);
            address newContract = createX.deployCreate2{value: msgValue}(salt, cachedInitCode);
            vm.stopPrank();

            assertEq(newContract, computedAddress, "100");
            assertNotEq(newContract, zeroAddress, "200");
            assertNotEq(newContract.code.length, 0, "300");
            assertEq(newContract.balance, msgValue, "400");
            assertEq(createXAddr.balance, 0, "500");
            assertEq(ERC20MockPayable(computedAddress).name(), arg1, "600");
            assertEq(ERC20MockPayable(computedAddress).symbol(), arg2, "700");
            assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), arg4, "800");

            if (permissionedDeployProtection && xChainRedeployProtection) {
                vm.chainId(chainId);
                vm.startPrank(originalDeployer);
                address newContractOriginalDeployer = createX.deployCreate2{value: msgValue}(salt, cachedInitCode);
                vm.stopPrank();
                vm.assume(originalDeployer != newContractOriginalDeployer);

                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractOriginalDeployer, computedAddress, "900");
                assertNotEq(newContractOriginalDeployer, zeroAddress, "1000");
                assertNotEq(newContractOriginalDeployer.code.length, 0, "1100");
                assertEq(newContractOriginalDeployer.balance, msgValue, "1200");
                assertEq(createXAddr.balance, 0, "1300");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "1400");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "1500");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), arg4, "1600");
            } else if (permissionedDeployProtection) {
                vm.chainId(chainId);
                // We mock a potential frontrunner address.
                vm.deal(msgSender, msgValue);
                vm.startPrank(msgSender);
                address newContractMsgSender = createX.deployCreate2{value: msgValue}(salt, cachedInitCode);
                vm.stopPrank();
                vm.assume(msgSender != newContractMsgSender);

                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractMsgSender, computedAddress, "1700");
                assertNotEq(newContractMsgSender, zeroAddress, "1800");
                assertNotEq(newContractMsgSender.code.length, 0, "1900");
                assertEq(newContractMsgSender.balance, msgValue, "2000");
                assertEq(createXAddr.balance, 0, "2100");
                assertEq(ERC20MockPayable(newContractMsgSender).name(), arg1, "2200");
                assertEq(ERC20MockPayable(newContractMsgSender).symbol(), arg2, "2300");
                assertEq(ERC20MockPayable(newContractMsgSender).balanceOf(arg3), arg4, "2400");

                // Foundry does not create a new, clean EVM environment when the `chainId` is changed, and
                // a deployment of a contract to the same address therefore fails (see issue: https://github.com/foundry-rs/foundry/issues/6008).
                // To solve this problem, we return to the original snapshot state.
                vm.revertTo(snapshotId);
                // We mock the original caller.
                vm.startPrank(originalDeployer);
                address newContractOriginalDeployer = createX.deployCreate2{value: msgValue}(salt, cachedInitCode);
                vm.stopPrank();
                vm.assume(originalDeployer != newContractOriginalDeployer);

                // The newly created contract on chain `chainId` must be the same as the previously created contract
                // at the `computedAddress` address.
                assertEq(newContractOriginalDeployer, computedAddress, "2500");
                assertNotEq(newContractOriginalDeployer, newContractMsgSender, "2600");
                assertNotEq(newContractOriginalDeployer, zeroAddress, "2700");
                assertNotEq(newContractOriginalDeployer.code.length, 0, "2800");
                assertEq(newContractOriginalDeployer.balance, msgValue, "2900");
                assertEq(createXAddr.balance, 0, "3000");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "3100");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "3200");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), arg4, "3300");
            } else if (xChainRedeployProtection) {
                vm.chainId(chainId);
                vm.startPrank(originalDeployer);
                address newContractOriginalDeployer = createX.deployCreate2{value: msgValue}(salt, cachedInitCode);
                vm.stopPrank();
                vm.assume(originalDeployer != newContractOriginalDeployer);

                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractOriginalDeployer, computedAddress, "3400");
                assertNotEq(newContractOriginalDeployer, zeroAddress, "3500");
                assertNotEq(newContractOriginalDeployer.code.length, 0, "3600");
                assertEq(newContractOriginalDeployer.balance, msgValue, "3700");
                assertEq(createXAddr.balance, 0, "3800");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "3900");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "4000");
                assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), arg4, "4100");
            }
        }
    }

    modifier whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithAZeroLength() {
        _;
    }

    function testFuzz_WhenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithAZeroLength(
        address originalDeployer,
        bytes32 salt,
        uint64 chainId,
        uint256 msgValue
    ) external whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithAZeroLength {
        msgValue = bound(msgValue, 0, type(uint64).max);
        vm.deal(originalDeployer, msgValue);
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
            createX.deployCreate2{value: msgValue}(salt, new bytes(0));
            vm.stopPrank();
        } else {
            vm.startPrank(originalDeployer);
            // It should revert.
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2{value: msgValue}(salt, new bytes(0));
            vm.stopPrank();
        }
    }

    modifier whenTheInitCodeFailsToDeployARuntimeBytecode() {
        _;
    }

    function testFuzz_WhenTheInitCodeFailsToDeployARuntimeBytecode(
        address originalDeployer,
        bytes32 salt,
        uint64 chainId,
        uint256 msgValue
    ) external whenTheInitCodeFailsToDeployARuntimeBytecode {
        msgValue = bound(msgValue, 0, type(uint64).max);
        vm.deal(originalDeployer, msgValue);
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
            createX.deployCreate2{value: msgValue}(salt, invalidInitCode);
            vm.stopPrank();
        } else {
            vm.startPrank(originalDeployer);
            // It should revert.
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2{value: msgValue}(salt, invalidInitCode);
            vm.stopPrank();
        }
    }
}
