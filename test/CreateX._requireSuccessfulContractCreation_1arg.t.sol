// SPDX-License-Identifier: WTFPL
pragma solidity 0.8.21;

import {BaseTest} from "./BaseTest.sol";
import {CreateX} from "../src/CreateX.sol";

contract RequireSuccessfulContractCreation_1Arg_Internal_Test is BaseTest {
    modifier whenTheNewContractAddressHasNoCode(address newContract) {
        vm.assume(newContract != createXHarnessAddr); // Avoid removing the code of the contract under test.
        assumeAddressIsNot(newContract, AddressType.ForgeAddress);
        // If the new contract address has code, remove the code. This is faster than `vm.assume`.
        if (newContract.code.length != 0) {
            vm.etch(newContract, "");
        }
        _;
    }

    modifier whenTheNewContractAddressHasCode(address newContract) {
        assumeAddressIsNot(newContract, AddressType.ForgeAddress, AddressType.Precompile);
        // The zero address is explicitly not allowed by this method, so we must reject it.
        vm.assume(newContract != zeroAddress);
        // If the new contract address has no code, etch some. This is faster than `vm.assume`.
        if (newContract.code.length == 0) {
            vm.etch(newContract, "01");
        }
        _;
    }

    function test_WhenTheNewContractAddressIsTheZeroAddress() external {
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXHarnessAddr);
        vm.expectRevert(expectedErr);
        createXHarness.exposed_requireSuccessfulContractCreation(zeroAddress);
    }

    function testFuzz_WhenTheNewContractAddressHasNoCode(
        address newContract
    ) external whenTheNewContractAddressHasNoCode(newContract) {
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXHarnessAddr);
        vm.expectRevert(expectedErr);
        createXHarness.exposed_requireSuccessfulContractCreation(newContract);
    }

    function testFuzz_WhenTheNewContractAddressHasCode(
        address newContract
    ) external whenTheNewContractAddressHasCode(newContract) {
        // It should never revert. We do not need any assertions to test this.
        createXHarness.exposed_requireSuccessfulContractCreation(newContract);
    }
}
