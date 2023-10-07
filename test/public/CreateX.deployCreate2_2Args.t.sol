// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {BaseTest} from "../utils/BaseTest.sol";
import {ERC20MockPayable} from "../mocks/ERC20MockPayable.sol";
import {CreateX} from "../../src/CreateX.sol";

contract CreateX_DeployCreate2_2Args_Public_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/
    address internal immutable SELF = address(this);

    string internal arg1;
    string internal arg2;
    address internal arg3;
    uint256 internal arg4;
    bytes internal args;

    bytes internal cachedInitCode;
    bytes32 internal initCodeHash;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER FUNCTIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * @dev Indicates whether a permissioned deploy protection and/or a cross-chain redeploy protection
     * has been configured via `salt` or whether it must revert.
     * @param salt The 32-byte random value used to create the contract address.
     * @return permissionedDeployProtection The Boolean variable that specifies whether a permissioned redeploy
     * protection has been configured.
     * @return xChainRedeployProtection The Boolean variable that specifies whether a cross-chain deploy
     * protection has been configured.
     * @return mustRevert The Boolean variable that specifies whether it must revert.
     * @return guardedSalt The guarded 32-byte random value used to create the contract address.
     */
    function parseFuzzerSalt(
        bytes32 salt
    )
        internal
        view
        returns (bool permissionedDeployProtection, bool xChainRedeployProtection, bool mustRevert, bytes32 guardedSalt)
    {
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(salt);

        if (
            senderBytes == CreateX.SenderBytes.MsgSender &&
            redeployProtectionFlag == CreateX.RedeployProtectionFlag.True
        ) {
            // Configures a permissioned deploy protection as well as a cross-chain redeploy protection.
            guardedSalt = createXHarness.exposed_guard(salt);
            permissionedDeployProtection = true;
            xChainRedeployProtection = true;
        } else if (
            senderBytes == CreateX.SenderBytes.MsgSender &&
            redeployProtectionFlag == CreateX.RedeployProtectionFlag.False
        ) {
            // Configures solely a permissioned deploy protection.
            guardedSalt = createXHarness.exposed_guard(salt);
            permissionedDeployProtection = true;
        } else if (senderBytes == CreateX.SenderBytes.MsgSender) {
            // Reverts if the 21st byte is greater than `0x01` in order to enforce developer explicitness.
            mustRevert = true;
        } else if (
            senderBytes == CreateX.SenderBytes.ZeroAddress &&
            redeployProtectionFlag == CreateX.RedeployProtectionFlag.True
        ) {
            // Configures solely a cross-chain redeploy protection.
            guardedSalt = createXHarness.exposed_guard(salt);
            xChainRedeployProtection = true;
        } else if (
            senderBytes == CreateX.SenderBytes.ZeroAddress &&
            redeployProtectionFlag == CreateX.RedeployProtectionFlag.Unspecified
        ) {
            // Reverts if the 21st byte is greater than `0x01` in order to enforce developer explicitness.
            mustRevert = true;
        } else {
            // In all other cases, the salt value `salt` is not modified.
            guardedSalt = salt;
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           EVENTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Solidity version `0.8.21` raises an ICE (Internal Compiler Error)
    // when an event is emitted from another contract: https://github.com/ethereum/solidity/issues/14430.

    /**
     * @dev Event that is emitted when `amount` ERC-20 tokens are moved from one
     * account (`owner`) to another (`to`).
     * @param owner The 20-byte owner address.
     * @param to The 20-byte receiver address.
     * @param amount The 32-byte token amount to be transferred.
     */
    event Transfer(address indexed owner, address indexed to, uint256 amount);

    /**
     * @dev Event that is emitted when a contract is successfully created.
     * @param newContract The address of the new contract.
     */
    event ContractCreation(address indexed newContract);

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * @dev Error that occurs when the contract creation code has zero-byte length.
     * @param emitter The contract that emits the error.
     */
    error ZeroByteInitCode(address emitter);

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

    function testFuzz_whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLength(
        uint256 msgValue,
        bytes32 salt,
        uint64 chainId,
        address msgSender
    ) external whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLength {
        msgValue = bound(msgValue, 0, type(uint64).max);
        vm.assume(chainId != block.chainid && chainId != 0);
        assumeAddressIsNot(msgSender, AddressType.ForgeAddress);
        (
            bool permissionedDeployProtection,
            bool xChainRedeployProtection,
            bool mustRevert,
            bytes32 guardedSalt
        ) = parseFuzzerSalt(salt);

        if (mustRevert) {
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2{value: msgValue}(salt, cachedInitCode);
        } else {
            // We calculate the address beforehand where the contract is to be deployed.
            address computedAddress = createX.computeCreate2Address(guardedSalt, initCodeHash, createXAddr);

            // We also check for the ERC-20 standard `Transfer` event.
            vm.expectEmit(true, true, true, true, computedAddress);
            emit Transfer(zeroAddress, arg3, arg4);
            // It returns a contract address with a non-zero bytecode length and a potential non-zero ether balance.
            // It emits the event `ContractCreation` with the contract address as indexed argument.
            vm.expectEmit(true, true, true, true, createXAddr);
            emit ContractCreation(computedAddress);
            address newContract = createX.deployCreate2{value: msgValue}(salt, cachedInitCode);

            assertEq(newContract, computedAddress);
            assertNotEq(newContract, zeroAddress);
            assertNotEq(newContract.code.length, 0);
            assertEq(newContract.balance, msgValue);
            assertEq(createXAddr.balance, 0);
            assertEq(ERC20MockPayable(computedAddress).name(), arg1);
            assertEq(ERC20MockPayable(computedAddress).symbol(), arg2);
            assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), arg4);

            if (permissionedDeployProtection && xChainRedeployProtection) {
                vm.chainId(chainId);
                address newContractOriginalCaller = createX.deployCreate2{value: msgValue}(salt, cachedInitCode);

                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractOriginalCaller, computedAddress);
                assertNotEq(newContractOriginalCaller, zeroAddress);
                assertNotEq(newContractOriginalCaller.code.length, 0);
                assertEq(newContractOriginalCaller.balance, msgValue);
                assertEq(createXAddr.balance, 0);
                assertEq(ERC20MockPayable(newContractOriginalCaller).name(), arg1);
                assertEq(ERC20MockPayable(newContractOriginalCaller).symbol(), arg2);
                assertEq(ERC20MockPayable(newContractOriginalCaller).balanceOf(arg3), arg4);
            } else if (permissionedDeployProtection) {
                vm.chainId(chainId);
                // We mock a potential frontrunner address.
                vm.startPrank(msgSender);
                address newContractMsgSender = createX.deployCreate2{value: msgValue}(salt, cachedInitCode);
                vm.stopPrank();

                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractMsgSender, computedAddress);
                assertNotEq(newContractMsgSender, zeroAddress);
                assertNotEq(newContractMsgSender.code.length, 0);
                assertEq(newContractMsgSender.balance, msgValue);
                assertEq(createXAddr.balance, 0);
                assertEq(ERC20MockPayable(newContractMsgSender).name(), arg1);
                assertEq(ERC20MockPayable(newContractMsgSender).symbol(), arg2);
                assertEq(ERC20MockPayable(newContractMsgSender).balanceOf(arg3), arg4);

                // We mock the original caller.
                address newContractOriginalCaller = createX.deployCreate2{value: msgValue}(salt, cachedInitCode);
                // The newly created contract on chain `chainId` must be the same as the previously created contract
                // at the `computedAddress` address.
                assertEq(newContractOriginalCaller, computedAddress);
                assertNotEq(newContractOriginalCaller, zeroAddress);
                assertNotEq(newContractOriginalCaller.code.length, 0);
                assertEq(newContractOriginalCaller.balance, msgValue);
                assertEq(newContractOriginalCaller.balance, 0);
                assertEq(ERC20MockPayable(newContractOriginalCaller).name(), arg1);
                assertEq(ERC20MockPayable(newContractOriginalCaller).symbol(), arg2);
                assertEq(ERC20MockPayable(newContractOriginalCaller).balanceOf(arg3), arg4);
            } else if (xChainRedeployProtection) {
                vm.chainId(chainId);
                address newContractOriginalCaller = createX.deployCreate2{value: msgValue}(salt, cachedInitCode);

                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractOriginalCaller, computedAddress);
                assertNotEq(newContractOriginalCaller, zeroAddress);
                assertNotEq(newContractOriginalCaller.code.length, 0);
                assertEq(newContractOriginalCaller.balance, msgValue);
                assertEq(createXAddr.balance, 0);
                assertEq(ERC20MockPayable(newContractOriginalCaller).name(), arg1);
                assertEq(ERC20MockPayable(newContractOriginalCaller).symbol(), arg2);
                assertEq(ERC20MockPayable(newContractOriginalCaller).balanceOf(arg3), arg4);
            }
        }
    }

    modifier whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithAZeroLength() {
        _;
    }

    function testFuzz_WhenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithAZeroLength(
        bytes32 salt,
        uint256 msgValue
    ) external whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithAZeroLength {
        msgValue = bound(msgValue, 0, type(uint64).max);
        (, , bool mustRevert, ) = parseFuzzerSalt(salt);

        if (mustRevert) {
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2{value: msgValue}(salt, new bytes(0));
        } else {
            // It should revert.
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2{value: msgValue}(salt, new bytes(0));
        }
    }

    modifier whenTheInitCodeFailsToDeployARuntimeBytecode() {
        _;
    }

    function testFuzz_WhenTheInitCodeFailsToDeployARuntimeBytecode(
        bytes32 salt,
        uint256 msgValue
    ) external whenTheInitCodeFailsToDeployARuntimeBytecode {
        msgValue = bound(msgValue, 0, type(uint64).max);
        (, , bool mustRevert, ) = parseFuzzerSalt(salt);

        // The following contract creation code contains the invalid opcode `PUSH0` (`0x5F`) and `CREATE` must therefore
        // return the zero address (technically zero bytes `0x`), as the deployment fails. This test also ensures that if
        // we ever accidentally change the EVM version in Foundry and Hardhat, we will always have a corresponding failed test.
        bytes memory invalidInitCode = bytes("0x5f8060093d393df3");
        if (mustRevert) {
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2{value: msgValue}(salt, invalidInitCode);
        } else {
            // It should revert.
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2{value: msgValue}(salt, invalidInitCode);
        }
    }
}
