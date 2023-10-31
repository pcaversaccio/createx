// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {Vm} from "forge-std/Vm.sol";
import {BaseTest} from "../../utils/BaseTest.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {ERC20MockPayable} from "../../mocks/ERC20MockPayable.sol";
import {CreateX} from "../../../src/CreateX.sol";

contract CreateX_DeployCreate3_1Arg_Public_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // The `keccak256`-hashed `CREATE3` proxy contract creation bytecode.
    bytes32 internal proxyInitCodeHash =
        keccak256(abi.encodePacked(hex"67_36_3d_3d_37_36_3d_34_f0_3d_52_60_08_60_18_f3"));

    // To avoid any stack-too-deep errors, we use `internal` state variables for the precomputed `CREATE3` address
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
        vm.deal(originalDeployer, msgValue);
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
        computedAddress = createX.computeCreate3Address(guardedSalt, createXAddr);
        vm.assume(originalDeployer != computedAddress);
        // We calculate the address beforehand where the proxy is to be deployed.
        address proxyAddress = createX.computeCreate2Address(guardedSalt, proxyInitCodeHash, createXAddr);
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
        address newContract = createX.deployCreate3{value: msgValue}(cachedInitCode);
        vm.stopPrank();

        Vm.Log[] memory entries = vm.getRecordedLogs();
        assertEq(entries[0].topics[1], bytes32(uint256(uint160(proxyAddress))), "200");
        assertEq(newContract, computedAddress, "300");
        assertNotEq(newContract, zeroAddress, "400");
        assertNotEq(newContract.code.length, 0, "500");
        assertEq(newContract.balance, msgValue, "600");
        assertEq(createXAddr.balance, 0, "700");
        assertEq(ERC20MockPayable(computedAddress).name(), arg1, "800");
        assertEq(ERC20MockPayable(computedAddress).symbol(), arg2, "900");
        assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), arg4, "1000");

        vm.chainId(chainId);
        vm.startPrank(msgSender);
        salt = createXHarness.exposed_generateSalt();
        vm.stopPrank();
        (, , , guardedSalt) = parseFuzzerSalt(msgSender, salt);
        proxyAddress = createX.computeCreate2Address(guardedSalt, proxyInitCodeHash, createXAddr);
        vm.assume(msgSender != proxyAddress);
        // We record the emitted events to later assert the proxy contract address.
        vm.recordLogs();
        vm.expectEmit(true, true, true, true, createXAddr);
        emit CreateX.Create3ProxyContractCreation(proxyAddress, guardedSalt);
        // We mock a potential frontrunner address.
        vm.deal(msgSender, msgValue);
        vm.startPrank(msgSender);
        newContractMsgSender = createX.deployCreate3{value: msgValue}(cachedInitCode);
        vm.stopPrank();
        vm.assume(msgSender != newContractMsgSender);

        entries = vm.getRecordedLogs();
        assertEq(entries[0].topics[1], bytes32(uint256(uint160(proxyAddress))), "1100");
        // The newly created contract on chain `chainId` must not be the same as the previously created
        // contract at the `computedAddress` address.
        assertNotEq(newContractMsgSender, computedAddress, "1200");
        assertNotEq(newContractMsgSender, zeroAddress, "1300");
        assertNotEq(newContractMsgSender.code.length, 0, "1400");
        assertEq(newContractMsgSender.balance, msgValue, "1500");
        assertEq(createXAddr.balance, 0, "1600");
        assertEq(ERC20MockPayable(newContractMsgSender).name(), arg1, "1700");
        assertEq(ERC20MockPayable(newContractMsgSender).symbol(), arg2, "1800");
        assertEq(ERC20MockPayable(newContractMsgSender).balanceOf(arg3), arg4, "1900");

        // Foundry does not create a new, clean EVM environment when the `chainId` is changed, and
        // a deployment of a contract to the same address therefore fails (see issue: https://github.com/foundry-rs/foundry/issues/6008).
        // To solve this problem, we return to the original snapshot state.
        vm.revertTo(snapshotId);
        // We record the emitted events to later assert the proxy contract address.
        vm.recordLogs();
        vm.startPrank(originalDeployer);
        salt = createXHarness.exposed_generateSalt();
        vm.stopPrank();
        (, , , guardedSalt) = parseFuzzerSalt(originalDeployer, salt);
        proxyAddress = createX.computeCreate2Address(guardedSalt, proxyInitCodeHash, createXAddr);
        vm.assume(originalDeployer != proxyAddress);
        vm.expectEmit(true, true, true, true, createXAddr);
        emit CreateX.Create3ProxyContractCreation(proxyAddress, guardedSalt);
        // We mock the original caller.
        vm.startPrank(originalDeployer);
        newContractOriginalDeployer = createX.deployCreate3{value: msgValue}(cachedInitCode);
        vm.stopPrank();
        vm.assume(originalDeployer != newContractOriginalDeployer);

        entries = vm.getRecordedLogs();
        assertEq(entries[0].topics[1], bytes32(uint256(uint160(proxyAddress))), "2000");
        // The newly created contract on chain `chainId` must be the same as the previously created contract
        // at the `computedAddress` address. As we return to the original snapshot state, we have to recalculate
        // the address.
        assertEq(newContractOriginalDeployer, createX.computeCreate3Address(guardedSalt, createXAddr), "2100");
        assertNotEq(newContractOriginalDeployer, newContractMsgSender, "2200");
        assertNotEq(newContractOriginalDeployer, zeroAddress, "2300");
        assertNotEq(newContractOriginalDeployer.code.length, 0, "2400");
        assertEq(newContractOriginalDeployer.balance, msgValue, "2500");
        assertEq(createXAddr.balance, 0, "2600");
        assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "2700");
        assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "2800");
        assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), arg4, "2900");
    }

    modifier whenTheProxyContractCreationFails() {
        _;
    }

    function testFuzz_WhenTheProxyContractCreationFails(
        address originalDeployer,
        uint256 msgValue
    ) external whenTheProxyContractCreationFails {
        msgValue = bound(msgValue, 0, type(uint64).max);
        vm.deal(originalDeployer, msgValue);
        vm.assume(originalDeployer != createXAddr && originalDeployer != zeroAddress);
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
        computedAddress = createX.computeCreate2Address(guardedSalt, proxyInitCodeHash, createXAddr);
        // To enforce a deployment failure, we add code to the destination address `proxy`.
        vm.etch(computedAddress, hex"01");
        vm.startPrank(originalDeployer);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
        vm.expectRevert(expectedErr);
        createX.deployCreate3{value: msgValue}(cachedInitCode);
        vm.stopPrank();
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
        createX.deployCreate3{value: msgValue}(new bytes(0));
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
        createX.deployCreate3{value: msgValue}(invalidInitCode);
        vm.stopPrank();
    }
}
