// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {BaseTest} from "../utils/BaseTest.sol";
import {ERC20MockPayable} from "../mocks/ERC20MockPayable.sol";
import {CreateX} from "../../src/CreateX.sol";

contract CreateX_DeployCreateAndInit_4Args_Public_Test is BaseTest {
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
    uint256 internal cachedBalance;

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
        uint64 nonce,
        CreateX.Values memory values
    )
        external
        whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLength
        whenTheInitialisationCallIsSuccessful
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        values.constructorAmount = bound(values.constructorAmount, 0, type(uint64).max);
        values.initCallAmount = bound(values.initCallAmount, 0, type(uint64).max);
        // We calculate the address beforehand where the contract is to be deployed.
        address computedAddress = createX.computeCreateAddress(createXAddr, nonce);

        // We also check for the ERC-20 standard `Transfer` event.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        // It returns a contract address with a non-zero bytecode length and a potential non-zero ether balance.
        // It emits the event `ContractCreation` with the contract address as indexed argument.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit ContractCreation(computedAddress);
        address newContract = createX.deployCreateAndInit{value: values.constructorAmount + values.initCallAmount}(
            cachedInitCode,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values,
            arg3
        );

        assertEq(newContract, computedAddress);
        assertNotEq(newContract, zeroAddress);
        assertNotEq(newContract.code.length, 0);
        assertEq(newContract.balance, values.constructorAmount + values.initCallAmount);
        assertEq(createXAddr.balance, 0);
        assertEq(ERC20MockPayable(computedAddress).name(), arg1);
        assertEq(ERC20MockPayable(computedAddress).symbol(), arg2);
        assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), 2 * arg4);
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
        uint64 nonce,
        CreateX.Values memory values,
        uint256 amount
    )
        external
        whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLength
        whenTheInitialisationCallIsSuccessful
        whenTheCreateXContractHasANonZeroBalance(amount)
        whenTheRefundTransactionIsSuccessful
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        values.constructorAmount = bound(values.constructorAmount, 0, type(uint64).max);
        values.initCallAmount = bound(values.initCallAmount, 0, type(uint64).max);
        // We calculate the address beforehand where the contract is to be deployed.
        address computedAddress = createX.computeCreateAddress(createXAddr, nonce);

        // We also check for the ERC-20 standard `Transfer` event.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        // It returns a contract address with a non-zero bytecode length and a potential non-zero ether balance.
        // It emits the event `ContractCreation` with the contract address as indexed argument.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit ContractCreation(computedAddress);
        address newContract = createX.deployCreateAndInit{value: values.constructorAmount + values.initCallAmount}(
            cachedInitCode,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values,
            arg3
        );

        assertEq(newContract, computedAddress);
        assertNotEq(newContract, zeroAddress);
        assertNotEq(newContract.code.length, 0);
        assertEq(newContract.balance, values.constructorAmount + values.initCallAmount);
        assertEq(createXAddr.balance, 0);
        // It returns the non-zero balance to the `refundAddress` address.
        assertEq(arg3.balance, cachedBalance);
        assertEq(ERC20MockPayable(computedAddress).name(), arg1);
        assertEq(ERC20MockPayable(computedAddress).symbol(), arg2);
        assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), 2 * arg4);
    }

    modifier whenTheRefundTransactionIsUnsuccessful() {
        _;
    }

    function testFuzz_WhenTheRefundTransactionIsUnsuccessful(
        uint64 nonce,
        CreateX.Values memory values,
        uint256 amount
    )
        external
        whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLength
        whenTheInitialisationCallIsSuccessful
        whenTheCreateXContractHasANonZeroBalance(amount)
        whenTheRefundTransactionIsUnsuccessful
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        values.constructorAmount = bound(values.constructorAmount, 0, type(uint64).max);
        values.initCallAmount = bound(values.initCallAmount, 0, type(uint64).max);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedEtherTransfer.selector,
            createXAddr,
            new bytes(0)
        );
        vm.expectRevert(expectedErr);
        createX.deployCreateAndInit{value: values.constructorAmount + values.initCallAmount}(
            cachedInitCode,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values,
            SELF
        );
    }

    modifier whenTheInitialisationCallIsUnsuccessful() {
        _;
    }

    function testFuzz_WhenTheInitialisationCallIsUnsuccessful(
        uint64 nonce,
        CreateX.Values memory values
    )
        external
        whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLength
        whenTheInitialisationCallIsUnsuccessful
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        values.constructorAmount = bound(values.constructorAmount, 0, type(uint64).max);
        values.initCallAmount = bound(values.initCallAmount, 0, type(uint64).max);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedContractInitialisation.selector,
            createXAddr,
            new bytes(0)
        );
        vm.expectRevert(expectedErr);
        createX.deployCreateAndInit{value: values.constructorAmount + values.initCallAmount}(
            cachedInitCode,
            abi.encodeWithSignature("wagmi"),
            values,
            arg3
        );
    }

    modifier whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithAZeroLength() {
        _;
    }

    function testFuzz_WhenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithAZeroLength(
        uint64 nonce,
        CreateX.Values memory values
    ) external whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithAZeroLength {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        values.constructorAmount = bound(values.constructorAmount, 0, type(uint64).max);
        values.initCallAmount = bound(values.initCallAmount, 0, type(uint64).max);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
        vm.expectRevert(expectedErr);
        createX.deployCreateAndInit{value: values.constructorAmount + values.initCallAmount}(
            new bytes(0),
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values,
            arg3
        );
    }

    modifier whenTheInitCodeFailsToDeployARuntimeBytecode() {
        _;
    }

    function testFuzz_WhenTheInitCodeFailsToDeployARuntimeBytecode(
        uint64 nonce,
        CreateX.Values memory values
    ) external whenTheInitCodeFailsToDeployARuntimeBytecode {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        values.constructorAmount = bound(values.constructorAmount, 0, type(uint64).max);
        values.initCallAmount = bound(values.initCallAmount, 0, type(uint64).max);
        // The following contract creation code contains the invalid opcode `PUSH0` (`0x5F`) and `CREATE` must therefore
        // return the zero address (technically zero bytes `0x`), as the deployment fails. This test also ensures that if
        // we ever accidentally change the EVM version in Foundry and Hardhat, we will always have a corresponding failed test.
        bytes memory invalidInitCode = bytes("0x5f8060093d393df3");
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
        vm.expectRevert(expectedErr);
        createX.deployCreateAndInit{value: values.constructorAmount + values.initCallAmount}(
            invalidInitCode,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values,
            arg3
        );
    }
}
