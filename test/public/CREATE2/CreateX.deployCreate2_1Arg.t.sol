// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTest} from "../../utils/BaseTest.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {ERC20MockPayable} from "../../mocks/ERC20MockPayable.sol";
import {CreateX} from "../../../src/CreateX.sol";

contract CreateX_DeployCreate2_1Arg_Public_Test is BaseTest {
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

        vm.startPrank(originalDeployer);
        bytes32 salt = createXHarness.exposed_generateSalt();
        vm.stopPrank();
        (
            bool permissionedDeployProtection,
            bool xChainRedeployProtection,
            bool mustRevert,
            bytes32 guardedSalt
        ) = parseFuzzerSalt(originalDeployer, salt);
        // When we pseudo-randomly calculate the salt value `salt`, we must never have configured a permissioned
        // deploy protection or a cross-chain redeploy protection, and it must never revert.
        assertTrue(!permissionedDeployProtection && !xChainRedeployProtection && !mustRevert, "100");

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
        address newContract = createX.deployCreate2{value: msgValue}(cachedInitCode);
        vm.stopPrank();

        assertEq(newContract, computedAddress, "200");
        assertNotEq(newContract, zeroAddress, "300");
        assertNotEq(newContract.code.length, 0, "400");
        assertEq(newContract.balance, msgValue, "500");
        assertEq(createXAddr.balance, 0, "600");
        assertEq(ERC20MockPayable(computedAddress).name(), arg1, "700");
        assertEq(ERC20MockPayable(computedAddress).symbol(), arg2, "800");
        assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), arg4, "900");

        vm.chainId(chainId);
        // We mock a potential frontrunner address.
        vm.deal(msgSender, msgValue);
        vm.startPrank(msgSender);
        address newContractMsgSender = createX.deployCreate2{value: msgValue}(cachedInitCode);
        vm.stopPrank();
        vm.assume(msgSender != newContractMsgSender);

        // The newly created contract on chain `chainId` must not be the same as the previously created
        // contract at the `computedAddress` address.
        assertNotEq(newContractMsgSender, computedAddress, "1000");
        assertNotEq(newContractMsgSender, zeroAddress, "1100");
        assertNotEq(newContractMsgSender.code.length, 0, "1200");
        assertEq(newContractMsgSender.balance, msgValue, "1300");
        assertEq(createXAddr.balance, 0, "1400");
        assertEq(ERC20MockPayable(newContractMsgSender).name(), arg1, "1500");
        assertEq(ERC20MockPayable(newContractMsgSender).symbol(), arg2, "1600");
        assertEq(ERC20MockPayable(newContractMsgSender).balanceOf(arg3), arg4, "1700");

        // We mock the original caller.
        vm.startPrank(originalDeployer);
        address newContractOriginalDeployer = createX.deployCreate2{value: msgValue}(cachedInitCode);
        vm.stopPrank();
        vm.assume(originalDeployer != newContractOriginalDeployer);

        // The newly created contract on chain `chainId` must not be the same as the previously created
        // contract at the `computedAddress` address as well as at the `newContractMsgSender` address.
        assertNotEq(newContractOriginalDeployer, computedAddress, "1800");
        assertNotEq(newContractOriginalDeployer, newContractMsgSender, "1900");
        assertNotEq(newContractOriginalDeployer, zeroAddress, "2000");
        assertNotEq(newContractOriginalDeployer.code.length, 0, "2100");
        assertEq(newContractOriginalDeployer.balance, msgValue, "2200");
        assertEq(createXAddr.balance, 0, "2300");
        assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "2400");
        assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "2500");
        assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), arg4, "2600");
    }

    modifier whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithAZeroLength() {
        _;
    }

    function testFuzz_WhenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithAZeroLength(
        address originalDeployer,
        uint256 msgValue
    ) external whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithAZeroLength {
        msgValue = bound(msgValue, 0, type(uint64).max);
        vm.deal(originalDeployer, msgValue);
        vm.assume(originalDeployer != createXAddr && originalDeployer != zeroAddress);
        vm.startPrank(originalDeployer);
        bytes32 salt = createXHarness.exposed_generateSalt();
        vm.stopPrank();
        (bool permissionedDeployProtection, bool xChainRedeployProtection, bool mustRevert, ) = parseFuzzerSalt(
            originalDeployer,
            salt
        );
        // When we pseudo-randomly calculate the salt value `salt`, we must never have configured a permissioned
        // deploy protection or a cross-chain redeploy protection, and it must never revert.
        assertTrue(!permissionedDeployProtection && !xChainRedeployProtection && !mustRevert, "100");
        vm.startPrank(originalDeployer);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
        vm.expectRevert(expectedErr);
        createX.deployCreate2{value: msgValue}(new bytes(0));
        vm.stopPrank();
    }

    modifier whenTheInitCodeFailsToDeployARuntimeBytecode() {
        _;
    }

    function testFuzz_WhenTheInitCodeFailsToDeployARuntimeBytecode(
        address originalDeployer,
        uint256 msgValue
    ) external whenTheInitCodeFailsToDeployARuntimeBytecode {
        msgValue = bound(msgValue, 0, type(uint64).max);
        vm.deal(originalDeployer, msgValue);
        vm.assume(originalDeployer != createXAddr && originalDeployer != zeroAddress);
        vm.startPrank(originalDeployer);
        bytes32 salt = createXHarness.exposed_generateSalt();
        vm.stopPrank();
        (bool permissionedDeployProtection, bool xChainRedeployProtection, bool mustRevert, ) = parseFuzzerSalt(
            originalDeployer,
            salt
        );
        // When we pseudo-randomly calculate the salt value `salt`, we must never have configured a permissioned
        // deploy protection or a cross-chain redeploy protection, and it must never revert.
        assertTrue(!permissionedDeployProtection && !xChainRedeployProtection && !mustRevert, "100");
        // The following contract creation code contains the invalid opcode `PUSH0` (`0x5F`) and `CREATE` must therefore
        // return the zero address (technically zero bytes `0x`), as the deployment fails. This test also ensures that if
        // we ever accidentally change the EVM version in Foundry and Hardhat, we will always have a corresponding failed test.
        bytes memory invalidInitCode = hex"5f_80_60_09_3d_39_3d_f3";
        vm.startPrank(originalDeployer);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
        vm.expectRevert(expectedErr);
        createX.deployCreate2{value: msgValue}(invalidInitCode);
        vm.stopPrank();
    }
}
