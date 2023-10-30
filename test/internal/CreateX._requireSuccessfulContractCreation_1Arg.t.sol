// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTest} from "../utils/BaseTest.sol";
import {CreateX} from "../../src/CreateX.sol";

contract CreateX_RequireSuccessfulContractCreation_1Arg_Internal_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    modifier whenTheNewContractAddressIsTheZeroAddress() {
        _;
    }

    function test_WhenTheNewContractAddressIsTheZeroAddress() external whenTheNewContractAddressIsTheZeroAddress {
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXHarnessAddr);
        vm.expectRevert(expectedErr);
        createXHarness.exposed_requireSuccessfulContractCreation(zeroAddress);
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
        address newContract
    )
        external
        whenTheNewContractAddressIsNotTheZeroAddress(newContract)
        whenTheNewContractAddressHasNoCode(newContract)
    {
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXHarnessAddr);
        vm.expectRevert(expectedErr);
        createXHarness.exposed_requireSuccessfulContractCreation(newContract);
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
    ) external whenTheNewContractAddressIsNotTheZeroAddress(newContract) whenTheNewContractAddressHasCode(newContract) {
        // It should never revert. We do not need any assertions to test this.
        createXHarness.exposed_requireSuccessfulContractCreation(newContract);
    }
}
