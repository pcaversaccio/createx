// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTest} from "../../utils/BaseTest.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {ERC20MockPayable} from "../../mocks/ERC20MockPayable.sol";
import {CreateX} from "../../../src/CreateX.sol";

contract CreateX_DeployCreateAndInit_4Args_Public_Test is BaseTest {
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
        emit IERC20.Transfer(zeroAddress, arg3, arg4);
        // It returns a contract address with a non-zero bytecode length and a potential non-zero ether balance.
        // It emits the event `ContractCreation` with the contract address as indexed argument.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit CreateX.ContractCreation(computedAddress);
        address newContract = createX.deployCreateAndInit{value: values.constructorAmount + values.initCallAmount}(
            cachedInitCode,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values,
            arg3
        );

        assertEq(newContract, computedAddress, "100");
        assertNotEq(newContract, zeroAddress, "200");
        assertNotEq(newContract.code.length, 0, "300");
        assertEq(newContract.balance, values.constructorAmount + values.initCallAmount, "400");
        assertEq(createXAddr.balance, 0, "500");
        assertEq(ERC20MockPayable(computedAddress).name(), arg1, "600");
        assertEq(ERC20MockPayable(computedAddress).symbol(), arg2, "700");
        assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), 2 * arg4, "800");
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
        emit IERC20.Transfer(zeroAddress, arg3, arg4);
        // It returns a contract address with a non-zero bytecode length and a potential non-zero ether balance.
        // It emits the event `ContractCreation` with the contract address as indexed argument.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit CreateX.ContractCreation(computedAddress);
        address newContract = createX.deployCreateAndInit{value: values.constructorAmount + values.initCallAmount}(
            cachedInitCode,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values,
            arg3
        );

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
        bytes memory invalidInitCode = hex"5f_80_60_09_3d_39_3d_f3";
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
