// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTest} from "../utils/BaseTest.sol";
import {CreateX} from "../../src/CreateX.sol";

contract CreateX_RequireSuccessfulContractCreation_2Args_Internal_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    modifier whenTheSuccessBooleanIsFalse() {
        _;
    }

    function testFuzz_WhenTheSuccessBooleanIsFalse(address newContract) external whenTheSuccessBooleanIsFalse {
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXHarnessAddr);
        vm.expectRevert(expectedErr);
        createXHarness.exposed_requireSuccessfulContractCreation(false, newContract);
    }

    modifier whenTheSuccessBooleanIsTrue() {
        _;
    }

    modifier whenTheNewContractAddressIsTheZeroAddress() {
        _;
    }

    function test_WhenTheNewContractAddressIsTheZeroAddress()
        external
        whenTheSuccessBooleanIsTrue
        whenTheNewContractAddressIsTheZeroAddress
    {
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXHarnessAddr);
        vm.expectRevert(expectedErr);
        createXHarness.exposed_requireSuccessfulContractCreation(true, zeroAddress);
    }

    modifier whenTheNewContractAddressIsNotTheZeroAddress(address newContract) {
        vm.assume(newContract != zeroAddress);
        _;
    }

    modifier whenTheNewContractAddressHasNoCode(address newContract) {
        vm.assume(newContract != createXHarnessAddr); // Avoid removing the code of the contract under test.
        assumeAddressIsNot(newContract, AddressType.ForgeAddress);

        // If the new contract address has code, remove the code. This is faster than `vm.assume`.
        if (newContract.code.length != 0) {
            vm.etch(newContract, "");
        }
        _;
    }

    function testFuzz_WhenTheNewContractAddressHasNoCode(
        bool success,
        address newContract
    )
        external
        whenTheSuccessBooleanIsTrue
        whenTheNewContractAddressIsNotTheZeroAddress(newContract)
        whenTheNewContractAddressHasNoCode(newContract)
    {
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXHarnessAddr);
        vm.expectRevert(expectedErr);
        createXHarness.exposed_requireSuccessfulContractCreation(success, newContract);
    }

    modifier whenTheNewContractAddressHasCode(address newContract) {
        assumeAddressIsNot(newContract, AddressType.ForgeAddress, AddressType.Precompile);

        // If the new contract address has no code, etch some. This is faster than `vm.assume`.
        if (newContract.code.length == 0) {
            vm.etch(newContract, "01");
        }
        _;
    }

    function testFuzz_WhenTheNewContractAddressHasCode(
        address newContract
    )
        external
        whenTheSuccessBooleanIsTrue
        whenTheNewContractAddressIsNotTheZeroAddress(newContract)
        whenTheNewContractAddressHasCode(newContract)
    {
        // It should never revert.
        createXHarness.exposed_requireSuccessfulContractCreation(true, newContract);
    }
}
