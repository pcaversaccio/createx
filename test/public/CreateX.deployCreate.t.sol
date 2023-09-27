// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {BaseTest} from "../utils/BaseTest.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {ERC20MockPayable} from "../mocks/ERC20MockPayable.sol";
import {CreateX} from "../../src/CreateX.sol";

contract CreateX_DeployCreate_External_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/
    string internal arg1;
    string internal arg2;
    address internal arg3;
    uint256 internal arg4;
    bytes internal args;

    bytes internal cachedInitCode;
    bytes internal cachedInitCodePayable;

    uint256 internal msgValue;

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
        cachedInitCode = abi.encodePacked(type(ERC20Mock).creationCode, args);
        cachedInitCodePayable = abi.encodePacked(type(ERC20MockPayable).creationCode, args);
    }

    modifier givenReenteringCallsAreAllowed() {
        _;
    }

    modifier whenTheInitCodeCreatesAValidRuntimeBytecode() {
        if (cachedInitCode.length == 0) {
            revert ZeroByteInitCode(address(this));
        }
        if (cachedInitCodePayable.length == 0) {
            revert ZeroByteInitCode(address(this));
        }
        _;
    }

    modifier whenTheCreatedRuntimeBytecodeHasANonZeroLength() {
        if (cachedInitCode.length == 0) {
            revert ZeroByteInitCode(address(this));
        }
        if (cachedInitCodePayable.length == 0) {
            revert ZeroByteInitCode(address(this));
        }
        _;
    }

    modifier whenTheInitCodeHasANonpayableConstructor() {
        _;
    }

    modifier whenTheCallvalueIsZero() {
        msgValue = 0;
        _;
    }

    function testFuzz_WhenTheCallvalueIsZeroAndHasANonpayableConstructor(
        uint64 nonce
    )
        external
        givenReenteringCallsAreAllowed
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasANonpayableConstructor
        whenTheCallvalueIsZero
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // We calculate the address beforehand where the contract is to be deployed.
        address computedAddress = createX.computeCreateAddress(createXAddr, nonce);

        // We also check for the ERC-20 standard `Transfer` event.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        // It returns a contract address with a non-zero bytecode length and a zero ether balance.
        // It emits the event `ContractCreation` with the contract address as indexed argument.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit ContractCreation(computedAddress);
        address newContract = createX.deployCreate{value: msgValue}(cachedInitCode);
        assertEq(newContract, computedAddress);
        assertNotEq(newContract, zeroAddress);
        assertNotEq(newContract.code.length, 0);
        assertEq(newContract.balance, 0);
        assertEq(ERC20Mock(computedAddress).name(), arg1);
        assertEq(ERC20Mock(computedAddress).symbol(), arg2);
        assertEq(ERC20Mock(computedAddress).balanceOf(arg3), arg4);
    }

    modifier whenTheCallvalueIsNonZero(uint256 value) {
        value = bound(value, 1, type(uint64).max);
        msgValue = value;
        _;
    }

    function testFuzz_WhenTheCallvalueIsNonZeroAndHasANonpayableConstructor(
        uint64 nonce,
        uint256 value
    )
        external
        givenReenteringCallsAreAllowed
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasANonpayableConstructor
        whenTheCallvalueIsNonZero(value)
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
        vm.expectRevert(expectedErr);
        createX.deployCreate{value: msgValue}(cachedInitCode);
    }

    modifier whenTheInitCodeHasAPayableConstructor() {
        _;
    }

    function testFuzz_WhenTheCallvalueIsZeroAndHasAPayableConstructor(
        uint64 nonce
    )
        external
        givenReenteringCallsAreAllowed
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasAPayableConstructor
        whenTheCallvalueIsZero
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // We calculate the address beforehand where the contract is to be deployed.
        address computedAddress = createX.computeCreateAddress(createXAddr, nonce);

        // We also check for the ERC-20 standard `Transfer` event.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        // It returns a contract address with a non-zero bytecode length and a zero ether balance.
        // It emits the event `ContractCreation` with the contract address as indexed argument.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit ContractCreation(computedAddress);
        address newContract = createX.deployCreate{value: msgValue}(cachedInitCodePayable);
        assertEq(newContract, computedAddress);
        assertNotEq(newContract, zeroAddress);
        assertNotEq(newContract.code.length, 0);
        assertEq(newContract.balance, 0);
        assertEq(ERC20Mock(computedAddress).name(), arg1);
        assertEq(ERC20Mock(computedAddress).symbol(), arg2);
        assertEq(ERC20Mock(computedAddress).balanceOf(arg3), arg4);
    }

    function testFuzz_WhenTheCallvalueIsNonZeroAndHasAPayableConstructor(
        uint64 nonce,
        uint256 value
    )
        external
        givenReenteringCallsAreAllowed
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasAPayableConstructor
        whenTheCallvalueIsNonZero(value)
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // We calculate the address beforehand where the contract is to be deployed.
        address computedAddress = createX.computeCreateAddress(createXAddr, nonce);

        // We also check for the ERC-20 standard `Transfer` event.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        // It returns a contract address with a non-zero bytecode length and a potential non-zero ether balance.
        // It emits the event `ContractCreation` with the contract address as indexed argument.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit ContractCreation(computedAddress);
        address newContract = createX.deployCreate{value: msgValue}(cachedInitCodePayable);
        assertEq(newContract, computedAddress);
        assertNotEq(newContract, zeroAddress);
        assertNotEq(newContract.code.length, 0);
        assertEq(newContract.balance, msgValue);
        assertEq(ERC20Mock(computedAddress).name(), arg1);
        assertEq(ERC20Mock(computedAddress).symbol(), arg2);
        assertEq(ERC20Mock(computedAddress).balanceOf(arg3), arg4);
    }

    modifier whenTheCreatedRuntimeBytecodeHasAZeroLength() {
        _;
    }

    function testFuzz_WhenTheCreatedRuntimeBytecodeHasAZeroLength(
        uint64 nonce
    )
        external
        givenReenteringCallsAreAllowed
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasAZeroLength
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
        vm.expectRevert(expectedErr);
        createX.deployCreate{value: msgValue}(new bytes(0));
    }

    modifier whenTheInitCodeCreatesAnInvalidRuntimeBytecode() {
        _;
    }

    function testFuzz_WhenTheInitCodeCreatesAnInvalidRuntimeBytecode(
        uint64 nonce
    ) external givenReenteringCallsAreAllowed whenTheInitCodeCreatesAnInvalidRuntimeBytecode {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);

        // The following contract creation code returns a runtime bytecode containing the invalid opcode `PUSH0` (`0x5F`).
        // This test also ensures that if we ever accidentally change the EVM version in Foundry and Hardhat, we will
        // always have a corresponding failed test.
        bytes memory invalidRuntimeBytecode = bytes(
            "0x61004061000f6000396100406000f36003361161000c5761002d565b5f3560e01c6385384240811861002b573461002f574760405260206040f35b505b005b5f80fda165767970657283000309000b"
        );
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
        vm.expectRevert(expectedErr);
        createX.deployCreate{value: msgValue}(invalidRuntimeBytecode);
    }
}
