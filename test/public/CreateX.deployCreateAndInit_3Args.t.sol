// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {BaseTest} from "../utils/BaseTest.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {ERC20MockPayable} from "../mocks/ERC20MockPayable.sol";
import {CreateX} from "../../src/CreateX.sol";

contract CreateX_DeployCreateAndInit_3Args_Public_Test is BaseTest {
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
    bytes internal cachedInitCodePayable;

    uint256 internal msgValue;
    CreateX.Values internal values;

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

    modifier whenTheInitCodeCreatesAValidRuntimeBytecode() {
        if (cachedInitCode.length == 0 || cachedInitCodePayable.length == 0) {
            revert ZeroByteInitCode(SELF);
        }
        _;
    }

    modifier whenTheCreatedRuntimeBytecodeHasANonZeroLength() {
        if (cachedInitCode.length == 0 || cachedInitCodePayable.length == 0) {
            revert ZeroByteInitCode(SELF);
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

    modifier whenTheConstructorAmountValueIsZero() {
        values.constructorAmount = 0;
        _;
    }

    modifier whenTheInitCallAmountValueIsZero() {
        values.initCallAmount = 0;
        _;
    }

    modifier whenTheNonpayableInitialisationCallIsSuccessful() {
        _;
    }

    modifier whenTheCreateXBalanceIsZeroAfterTheNonpayableContractCreationAndNonpayableInitialisationCall() {
        _;
    }

    function testFuzz_WhenTheCreateXBalanceIsZeroAfterTheNonpayableContractCreationAndNonpayableInitialisationCallAndHasANonpayableConstructorAndTheCallvalueIsZero(
        uint64 nonce
    )
        external
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasANonpayableConstructor
        whenTheCallvalueIsZero
        whenTheConstructorAmountValueIsZero
        whenTheInitCallAmountValueIsZero
        whenTheNonpayableInitialisationCallIsSuccessful
        whenTheCreateXBalanceIsZeroAfterTheNonpayableContractCreationAndNonpayableInitialisationCall
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // We calculate the address beforehand where the contract is to be deployed.
        address computedAddress = createX.computeCreateAddress(createXAddr, nonce);

        // We also check for the ERC-20 standard `Transfer` event.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        // It returns a contract address with a non-zero bytecode length and a zero ether balance.
        // It emits the event ContractCreation with the contract address as indexed argument.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit ContractCreation(computedAddress);
        // We also check for the ERC-20 standard `Transfer` event triggered by the initialisation call.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        vm.deal(arg3, msgValue);
        vm.prank(arg3);
        address newContract = createX.deployCreateAndInit{value: msgValue}(
            cachedInitCode,
            abi.encodeCall(ERC20Mock.mint, (arg3, arg4)),
            values
        );

        assertEq(newContract, computedAddress);
        assertNotEq(newContract, zeroAddress);
        assertNotEq(newContract.code.length, 0);
        assertEq(newContract.balance, 0);
        assertEq(arg3.balance, 0);
        assertEq(ERC20Mock(computedAddress).name(), arg1);
        assertEq(ERC20Mock(computedAddress).symbol(), arg2);
        assertEq(ERC20Mock(computedAddress).balanceOf(arg3), 2 * arg4);
    }

    modifier whenTheCreateXBalanceIsNonZeroAfterTheNonpayableContractCreationAndNonpayableInitialisationCall(
        uint256 amount
    ) {
        vm.deal(createXAddr, bound(amount, 1, type(uint64).max));
        _;
    }

    function testFuzz_WhenTheCreateXBalanceIsNonZeroAfterTheNonpayableContractCreationAndNonpayableInitialisationCallAndHasANonpayableConstructorAndTheCallvalueIsZero(
        uint64 nonce,
        uint256 amount
    )
        external
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasANonpayableConstructor
        whenTheCallvalueIsZero
        whenTheConstructorAmountValueIsZero
        whenTheInitCallAmountValueIsZero
        whenTheNonpayableInitialisationCallIsSuccessful
        whenTheCreateXBalanceIsNonZeroAfterTheNonpayableContractCreationAndNonpayableInitialisationCall(amount)
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // We calculate the address beforehand where the contract is to be deployed.
        address computedAddress = createX.computeCreateAddress(createXAddr, nonce);
        // We cache the `CreateX` balance for the refund check later.
        uint256 bal = createXAddr.balance;
        // The balance of `arg3` is verified for correctness before `deployCreateAndInit` is called.
        assertEq(arg3.balance, 0);

        // We also check for the ERC-20 standard `Transfer` event.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        // It returns a contract address with a non-zero bytecode length and a zero ether balance.
        // It emits the event ContractCreation with the contract address as indexed argument.
        // It returns the non-zero balance to the `refundAddress` address.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit ContractCreation(computedAddress);
        // We also check for the ERC-20 standard `Transfer` event triggered by the initialisation call.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        vm.deal(arg3, msgValue);
        vm.prank(arg3);
        address newContract = createX.deployCreateAndInit{value: msgValue}(
            cachedInitCode,
            abi.encodeCall(ERC20Mock.mint, (arg3, arg4)),
            values
        );

        assertEq(newContract, computedAddress);
        assertNotEq(newContract, zeroAddress);
        assertNotEq(newContract.code.length, 0);
        assertEq(newContract.balance, 0);
        assertEq(arg3.balance, bal);
        assertEq(ERC20Mock(computedAddress).name(), arg1);
        assertEq(ERC20Mock(computedAddress).symbol(), arg2);
        assertEq(ERC20Mock(computedAddress).balanceOf(arg3), 2 * arg4);
    }

    modifier whenTheNonpayableInitialisationCallIsUnsuccessful() {
        _;
    }

    function testFuzz_WhenTheNonpayableInitialisationCallIsUnsuccessfulAndHasANonpayableConstructorAndTheCallvalueIsZero(
        uint64 nonce
    )
        external
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasANonpayableConstructor
        whenTheCallvalueIsZero
        whenTheConstructorAmountValueIsZero
        whenTheInitCallAmountValueIsZero
        whenTheNonpayableInitialisationCallIsUnsuccessful
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedContractInitialisation.selector,
            createXAddr,
            new bytes(0)
        );
        vm.deal(arg3, msgValue);
        vm.prank(arg3);
        vm.expectRevert(expectedErr);
        createX.deployCreateAndInit{value: msgValue}(cachedInitCode, abi.encodeWithSignature("wagmi"), values);
    }

    modifier whenTheCallvalueIsNonZero(uint256 amount) {
        msgValue = bound(amount, 1, type(uint64).max);
        _;
    }

    modifier whenTheConstructorAmountValueIsNonZero(uint256 constructorAmount) {
        values.constructorAmount = bound(constructorAmount, 1, type(uint64).max);
        _;
    }

    function testFuzz_WhenTheConstructorAmountValueIsNonZeroAndHasANonpayableConstructorAndTheCallvalueIsNonZero(
        uint64 nonce,
        uint256 constructorAmount
    )
        external
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasANonpayableConstructor
        whenTheCallvalueIsNonZero(constructorAmount)
        whenTheConstructorAmountValueIsNonZero(constructorAmount)
        whenTheInitCallAmountValueIsZero
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
        vm.deal(arg3, msgValue);
        vm.prank(arg3);
        vm.expectRevert(expectedErr);
        createX.deployCreateAndInit{value: msgValue}(
            cachedInitCode,
            abi.encodeCall(ERC20Mock.mint, (arg3, arg4)),
            values
        );
    }

    modifier whenTheInitCallAmountValueIsNonZero(uint256 initCallAmount) {
        values.initCallAmount = bound(initCallAmount, 1, type(uint64).max);
        _;
    }

    function testFuzz_WhenTheInitCallAmountValueIsNonZeroAndHasANonpayableConstructorAndTheCallvalueIsNonZero(
        uint64 nonce,
        uint256 initCallAmount
    )
        external
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasANonpayableConstructor
        whenTheCallvalueIsNonZero(initCallAmount)
        whenTheConstructorAmountValueIsZero
        whenTheInitCallAmountValueIsNonZero(initCallAmount)
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedContractInitialisation.selector,
            createXAddr,
            new bytes(0)
        );
        vm.deal(arg3, msgValue);
        vm.prank(arg3);
        vm.expectRevert(expectedErr);
        createX.deployCreateAndInit{value: msgValue}(
            cachedInitCode,
            abi.encodeCall(ERC20Mock.mint, (arg3, arg4)),
            values
        );
    }

    modifier whenTheRefundTransactionIsUnsuccessful() {
        _;
    }

    function testFuzz_WhenTheRefundTransactionIsUnsuccessfulAndHasANonpayableConstructorAndTheCallvalueIsZero(
        uint64 nonce,
        uint256 amount
    )
        external
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasANonpayableConstructor
        whenTheCallvalueIsZero
        whenTheConstructorAmountValueIsZero
        whenTheInitCallAmountValueIsZero
        whenTheNonpayableInitialisationCallIsSuccessful
        whenTheCreateXBalanceIsNonZeroAfterTheNonpayableContractCreationAndNonpayableInitialisationCall(amount)
        whenTheRefundTransactionIsUnsuccessful
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedEtherTransfer.selector,
            createXAddr,
            new bytes(0)
        );
        vm.prank(SELF);
        vm.expectRevert(expectedErr);
        createX.deployCreateAndInit{value: msgValue}(
            cachedInitCode,
            abi.encodeCall(ERC20Mock.mint, (arg3, arg4)),
            values
        );
    }

    modifier whenTheInitCodeHasAPayableConstructor() {
        _;
    }

    modifier whenThePayableInitialisationCallIsSuccessful() {
        _;
    }

    modifier whenTheCreateXBalanceIsZeroAfterThePayableContractCreationAndPayableInitialisationCall() {
        _;
    }

    function testFuzz_WhenTheCreateXBalanceIsZeroAfterThePayableContractCreationAndPayableInitialisationCallAndHasAPayableConstructorAndTheCallvalueIsZero(
        uint64 nonce
    )
        external
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasAPayableConstructor
        whenTheCallvalueIsZero
        whenTheConstructorAmountValueIsZero
        whenTheInitCallAmountValueIsZero
        whenThePayableInitialisationCallIsSuccessful
        whenTheCreateXBalanceIsZeroAfterThePayableContractCreationAndPayableInitialisationCall
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // We calculate the address beforehand where the contract is to be deployed.
        address computedAddress = createX.computeCreateAddress(createXAddr, nonce);

        // We also check for the ERC-20 standard `Transfer` event.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        // It returns a contract address with a non-zero bytecode length and a zero ether balance.
        // It emits the event ContractCreation with the contract address as indexed argument.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit ContractCreation(computedAddress);
        // We also check for the ERC-20 standard `Transfer` event triggered by the initialisation call.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        vm.deal(arg3, msgValue);
        vm.prank(arg3);
        address newContract = createX.deployCreateAndInit{value: msgValue}(
            cachedInitCodePayable,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values
        );

        assertEq(newContract, computedAddress);
        assertNotEq(newContract, zeroAddress);
        assertNotEq(newContract.code.length, 0);
        assertEq(newContract.balance, 0);
        assertEq(arg3.balance, 0);
        assertEq(ERC20MockPayable(computedAddress).name(), arg1);
        assertEq(ERC20MockPayable(computedAddress).symbol(), arg2);
        assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), 2 * arg4);
    }

    modifier whenTheCreateXBalanceIsNonZeroAfterThePayableContractCreationAndPayableInitialisationCall(uint256 amount) {
        vm.deal(createXAddr, bound(amount, 1, type(uint64).max));
        _;
    }

    function testFuzz_WhenTheCreateXBalanceIsNonZeroAfterThePayableContractCreationAndPayableInitialisationCallAndHasAPayableConstructorAndTheCallvalueIsZero(
        uint64 nonce,
        uint256 amount
    )
        external
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasAPayableConstructor
        whenTheCallvalueIsZero
        whenTheConstructorAmountValueIsZero
        whenTheInitCallAmountValueIsZero
        whenThePayableInitialisationCallIsSuccessful
        whenTheCreateXBalanceIsNonZeroAfterThePayableContractCreationAndPayableInitialisationCall(amount)
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // We calculate the address beforehand where the contract is to be deployed.
        address computedAddress = createX.computeCreateAddress(createXAddr, nonce);
        // We cache the `CreateX` balance for the refund check later.
        uint256 bal = createXAddr.balance;
        // The balance of `arg3` is verified for correctness before `deployCreateAndInit` is called.
        assertEq(arg3.balance, 0);

        // We also check for the ERC-20 standard `Transfer` event.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        // It returns a contract address with a non-zero bytecode length and a zero ether balance.
        // It emits the event ContractCreation with the contract address as indexed argument.
        // It returns the non-zero balance to the `refundAddress` address.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit ContractCreation(computedAddress);
        // We also check for the ERC-20 standard `Transfer` event triggered by the initialisation call.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        vm.deal(arg3, msgValue);
        vm.prank(arg3);
        address newContract = createX.deployCreateAndInit{value: msgValue}(
            cachedInitCodePayable,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values
        );

        assertEq(newContract, computedAddress);
        assertNotEq(newContract, zeroAddress);
        assertNotEq(newContract.code.length, 0);
        assertEq(newContract.balance, 0);
        assertEq(arg3.balance, bal);
        assertEq(ERC20MockPayable(computedAddress).name(), arg1);
        assertEq(ERC20MockPayable(computedAddress).symbol(), arg2);
        assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), 2 * arg4);
    }

    modifier whenThePayableInitialisationCallIsUnsuccessful() {
        _;
    }

    function testFuzz_WhenThePayableInitialisationCallIsUnsuccessfulAndHasAPayableConstructorAndTheCallvalueIsZero(
        uint64 nonce
    )
        external
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasAPayableConstructor
        whenTheCallvalueIsZero
        whenTheConstructorAmountValueIsZero
        whenTheInitCallAmountValueIsZero
        whenThePayableInitialisationCallIsUnsuccessful
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedContractInitialisation.selector,
            createXAddr,
            new bytes(0)
        );
        vm.deal(arg3, msgValue);
        vm.prank(arg3);
        vm.expectRevert(expectedErr);
        createX.deployCreateAndInit{value: msgValue}(cachedInitCodePayable, abi.encodeWithSignature("wagmi"), values);
    }

    function testFuzz_WhenTheRefundTransactionIsUnsuccessfulAndHasAPayableConstructorAndTheCallvalueIsZero(
        uint64 nonce,
        uint256 amount
    )
        external
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasAPayableConstructor
        whenTheCallvalueIsZero
        whenTheConstructorAmountValueIsZero
        whenTheInitCallAmountValueIsZero
        whenThePayableInitialisationCallIsSuccessful
        whenTheCreateXBalanceIsNonZeroAfterThePayableContractCreationAndPayableInitialisationCall(amount)
        whenTheRefundTransactionIsUnsuccessful
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedEtherTransfer.selector,
            createXAddr,
            new bytes(0)
        );
        vm.prank(SELF);
        vm.expectRevert(expectedErr);
        createX.deployCreateAndInit{value: msgValue}(
            cachedInitCodePayable,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values
        );
    }

    function testFuzz_WhenTheCreateXBalanceIsZeroAfterThePayableContractCreationAndPayableInitialisationCallAndHasAPayableConstructorAndTheCallvalueIsNonZero(
        uint64 nonce,
        uint256 constructorAmount
    )
        external
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasAPayableConstructor
        whenTheCallvalueIsNonZero(constructorAmount)
        whenTheConstructorAmountValueIsNonZero(constructorAmount)
        whenTheInitCallAmountValueIsZero
        whenThePayableInitialisationCallIsSuccessful
        whenTheCreateXBalanceIsZeroAfterThePayableContractCreationAndPayableInitialisationCall
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // We calculate the address beforehand where the contract is to be deployed.
        address computedAddress = createX.computeCreateAddress(createXAddr, nonce);

        // We also check for the ERC-20 standard `Transfer` event.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        // It returns a contract address with a non-zero bytecode length and a zero ether balance.
        // It emits the event ContractCreation with the contract address as indexed argument.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit ContractCreation(computedAddress);
        // We also check for the ERC-20 standard `Transfer` event triggered by the initialisation call.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        vm.deal(arg3, msgValue);
        vm.prank(arg3);
        address newContract = createX.deployCreateAndInit{value: msgValue}(
            cachedInitCodePayable,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values
        );

        assertEq(newContract, computedAddress);
        assertNotEq(newContract, zeroAddress);
        assertNotEq(newContract.code.length, 0);
        assertEq(newContract.balance, values.constructorAmount);
        assertEq(arg3.balance, 0);
        assertEq(ERC20MockPayable(computedAddress).name(), arg1);
        assertEq(ERC20MockPayable(computedAddress).symbol(), arg2);
        assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), 2 * arg4);
    }

    function testFuzz_WhenTheCreateXBalanceIsNonZeroAfterThePayableContractCreationAndPayableInitialisationCallAndHasAPayableConstructorAndTheCallvalueIsNonZero(
        uint64 nonce,
        uint256 constructorAmount,
        uint256 amount
    )
        external
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasAPayableConstructor
        whenTheCallvalueIsNonZero(constructorAmount)
        whenTheConstructorAmountValueIsNonZero(constructorAmount)
        whenTheInitCallAmountValueIsZero
        whenThePayableInitialisationCallIsSuccessful
        whenTheCreateXBalanceIsNonZeroAfterThePayableContractCreationAndPayableInitialisationCall(amount)
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // We calculate the address beforehand where the contract is to be deployed.
        address computedAddress = createX.computeCreateAddress(createXAddr, nonce);
        // We cache the `CreateX` balance for the refund check later.
        uint256 bal = createXAddr.balance;
        // The balance of `arg3` is verified for correctness before `deployCreateAndInit` is called.
        assertEq(arg3.balance, 0);

        // We also check for the ERC-20 standard `Transfer` event.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        // It returns a contract address with a non-zero bytecode length and a zero ether balance.
        // It emits the event ContractCreation with the contract address as indexed argument.
        // It returns the non-zero balance to the `refundAddress` address.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit ContractCreation(computedAddress);
        // We also check for the ERC-20 standard `Transfer` event triggered by the initialisation call.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        vm.deal(arg3, msgValue);
        vm.prank(arg3);
        address newContract = createX.deployCreateAndInit{value: msgValue}(
            cachedInitCodePayable,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values
        );

        assertEq(newContract, computedAddress);
        assertNotEq(newContract, zeroAddress);
        assertNotEq(newContract.code.length, 0);
        assertEq(newContract.balance, values.constructorAmount);
        assertEq(arg3.balance, bal);
        assertEq(ERC20MockPayable(computedAddress).name(), arg1);
        assertEq(ERC20MockPayable(computedAddress).symbol(), arg2);
        assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), 2 * arg4);
    }

    function testFuzz_WhenThePayableInitialisationCallIsUnsuccessfulAndHasAPayableConstructorAndTheCallvalueIsNonZero(
        uint64 nonce,
        uint256 constructorAmount
    )
        external
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasAPayableConstructor
        whenTheCallvalueIsNonZero(constructorAmount)
        whenTheConstructorAmountValueIsNonZero(constructorAmount)
        whenTheInitCallAmountValueIsZero
        whenThePayableInitialisationCallIsUnsuccessful
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedContractInitialisation.selector,
            createXAddr,
            new bytes(0)
        );
        vm.deal(arg3, msgValue);
        vm.prank(arg3);
        vm.expectRevert(expectedErr);
        createX.deployCreateAndInit{value: msgValue}(cachedInitCodePayable, abi.encodeWithSignature("wagmi"), values);
    }

    function testFuzz_WhenTheRefundTransactionIsUnsuccessfulAndHasAPayableConstructorAndTheCallvalueIsNonZero(
        uint64 nonce,
        uint256 constructorAmount,
        uint256 amount
    )
        external
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasAPayableConstructor
        whenTheCallvalueIsNonZero(constructorAmount)
        whenTheConstructorAmountValueIsNonZero(constructorAmount)
        whenTheInitCallAmountValueIsZero
        whenThePayableInitialisationCallIsSuccessful
        whenTheCreateXBalanceIsNonZeroAfterThePayableContractCreationAndPayableInitialisationCall(amount)
        whenTheRefundTransactionIsUnsuccessful
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedEtherTransfer.selector,
            createXAddr,
            new bytes(0)
        );
        vm.prank(SELF);
        vm.expectRevert(expectedErr);
        createX.deployCreateAndInit{value: msgValue}(
            cachedInitCodePayable,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values
        );
    }

    function testFuzz_WhenTheCreateXBalanceIsZeroAfterThePayableContractCreationAndPayableInitialisationCallAndHasAPayableConstructorAndTheCallvalueIsNonZeroAndTheInitCallAmountValueIsNonZero(
        uint64 nonce,
        uint256 initCallAmount
    )
        external
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasAPayableConstructor
        whenTheCallvalueIsNonZero(initCallAmount)
        whenTheConstructorAmountValueIsZero
        whenTheInitCallAmountValueIsNonZero(initCallAmount)
        whenThePayableInitialisationCallIsSuccessful
        whenTheCreateXBalanceIsZeroAfterThePayableContractCreationAndPayableInitialisationCall
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // We calculate the address beforehand where the contract is to be deployed.
        address computedAddress = createX.computeCreateAddress(createXAddr, nonce);

        // We also check for the ERC-20 standard `Transfer` event.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        // It returns a contract address with a non-zero bytecode length and a zero ether balance.
        // It emits the event ContractCreation with the contract address as indexed argument.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit ContractCreation(computedAddress);
        // We also check for the ERC-20 standard `Transfer` event triggered by the initialisation call.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        vm.deal(arg3, msgValue);
        vm.prank(arg3);
        address newContract = createX.deployCreateAndInit{value: msgValue}(
            cachedInitCodePayable,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values
        );

        assertEq(newContract, computedAddress);
        assertNotEq(newContract, zeroAddress);
        assertNotEq(newContract.code.length, 0);
        assertEq(newContract.balance, values.initCallAmount);
        assertEq(arg3.balance, 0);
        assertEq(ERC20MockPayable(computedAddress).name(), arg1);
        assertEq(ERC20MockPayable(computedAddress).symbol(), arg2);
        assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), 2 * arg4);
    }

    function testFuzz_WhenTheCreateXBalanceIsNonZeroAfterThePayableContractCreationAndPayableInitialisationCallAndHasAPayableConstructorAndTheCallvalueIsNonZeroAndTheInitCallAmountValueIsNonZero(
        uint64 nonce,
        uint256 initCallAmount,
        uint256 amount
    )
        external
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasAPayableConstructor
        whenTheCallvalueIsNonZero(initCallAmount)
        whenTheConstructorAmountValueIsZero
        whenTheInitCallAmountValueIsNonZero(initCallAmount)
        whenThePayableInitialisationCallIsSuccessful
        whenTheCreateXBalanceIsNonZeroAfterThePayableContractCreationAndPayableInitialisationCall(amount)
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // We calculate the address beforehand where the contract is to be deployed.
        address computedAddress = createX.computeCreateAddress(createXAddr, nonce);
        // We cache the `CreateX` balance for the refund check later.
        uint256 bal = createXAddr.balance;
        // The balance of `arg3` is verified for correctness before `deployCreateAndInit` is called.
        assertEq(arg3.balance, 0);

        // We also check for the ERC-20 standard `Transfer` event.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        // It returns a contract address with a non-zero bytecode length and a zero ether balance.
        // It emits the event ContractCreation with the contract address as indexed argument.
        // It returns the non-zero balance to the `refundAddress` address.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit ContractCreation(computedAddress);
        // We also check for the ERC-20 standard `Transfer` event triggered by the initialisation call.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        vm.deal(arg3, msgValue);
        vm.prank(arg3);
        address newContract = createX.deployCreateAndInit{value: msgValue}(
            cachedInitCodePayable,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values
        );

        assertEq(newContract, computedAddress);
        assertNotEq(newContract, zeroAddress);
        assertNotEq(newContract.code.length, 0);
        assertEq(newContract.balance, values.initCallAmount);
        assertEq(arg3.balance, bal);
        assertEq(ERC20MockPayable(computedAddress).name(), arg1);
        assertEq(ERC20MockPayable(computedAddress).symbol(), arg2);
        assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), 2 * arg4);
    }

    function testFuzz_WhenThePayableInitialisationCallIsUnsuccessfulAndHasAPayableConstructorAndTheCallvalueIsNonZeroTheInitCallAmountValueIsNonZero(
        uint64 nonce,
        uint256 initCallAmount
    )
        external
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasAPayableConstructor
        whenTheCallvalueIsNonZero(initCallAmount)
        whenTheConstructorAmountValueIsZero
        whenTheInitCallAmountValueIsNonZero(initCallAmount)
        whenThePayableInitialisationCallIsUnsuccessful
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedContractInitialisation.selector,
            createXAddr,
            new bytes(0)
        );
        vm.deal(arg3, msgValue);
        vm.prank(arg3);
        vm.expectRevert(expectedErr);
        createX.deployCreateAndInit{value: msgValue}(cachedInitCodePayable, abi.encodeWithSignature("wagmi"), values);
    }

    function testFuzz_WhenTheRefundTransactionIsUnsuccessfulAndHasAPayableConstructorAndTheCallvalueIsNonZeroTheInitCallAmountValueIsNonZero(
        uint64 nonce,
        uint256 initCallAmount,
        uint256 amount
    )
        external
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasAPayableConstructor
        whenTheCallvalueIsNonZero(initCallAmount)
        whenTheConstructorAmountValueIsZero
        whenTheInitCallAmountValueIsNonZero(initCallAmount)
        whenThePayableInitialisationCallIsSuccessful
        whenTheCreateXBalanceIsNonZeroAfterThePayableContractCreationAndPayableInitialisationCall(amount)
        whenTheRefundTransactionIsUnsuccessful
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedEtherTransfer.selector,
            createXAddr,
            new bytes(0)
        );
        vm.prank(SELF);
        vm.expectRevert(expectedErr);
        createX.deployCreateAndInit{value: msgValue}(
            cachedInitCodePayable,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values
        );
    }

    modifier whenTheCreatedRuntimeBytecodeHasAZeroLength() {
        _;
    }

    function testFuzz_WhenTheCreatedRuntimeBytecodeHasAZeroLength(
        uint64 nonce
    ) external whenTheInitCodeCreatesAValidRuntimeBytecode whenTheCreatedRuntimeBytecodeHasAZeroLength {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
        vm.deal(arg3, msgValue);
        vm.prank(arg3);
        vm.expectRevert(expectedErr);
        createX.deployCreateAndInit{value: msgValue}(new bytes(0), new bytes(0), values);
    }

    modifier whenTheContractCreationFails() {
        _;
    }

    function testFuzz_WhenTheContractCreationFails(uint64 nonce) external whenTheContractCreationFails {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);

        // The following contract creation code contains the invalid opcode `PUSH0` (`0x5F`) and `CREATE` must therefore
        // return the zero address (technically zero bytes `0x`), as the deployment fails. This test also ensures that if
        // we ever accidentally change the EVM version in Foundry and Hardhat, we will always have a corresponding failed test.
        bytes memory invalidInitCode = bytes("0x5f8060093d393df3");
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
        vm.deal(arg3, msgValue);
        vm.deal(arg3, msgValue);
        vm.prank(arg3);
        vm.expectRevert(expectedErr);
        createX.deployCreateAndInit{value: msgValue}(invalidInitCode, new bytes(0), values);
    }
}
