// SPDX-License-Identifier: WTFPL
pragma solidity 0.8.21;

import {BaseTest} from "./BaseTest.sol";
import {CreateX} from "../src/CreateX.sol";

contract RequireSuccessfulContractCreation_2Args_Internal_Test is BaseTest {
    modifier whenTheSuccessBooleanIsFalse() {
        _;
    }

    function test_WhenTheSuccessBooleanIsFalse(address newContract) external whenTheSuccessBooleanIsFalse {
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedContractCreation.selector,
            address(createXHarness)
        );
        vm.expectRevert(expectedErr);
        createXHarness.exposed_requireSuccessfulContractCreation(false, newContract);
    }

    modifier whenTheNewContractAddressHasNoCode(address newContract) {
        assumeAddressIsNot(newContract, AddressType.ForgeAddress);
        // If the new contract address has code, remove the code. This is faster than `vm.assume`.
        if (newContract.code.length > 0) vm.etch(newContract, "");
        _;
    }

    function test_WhenTheNewContractAddressHasNoCode(
        bool success,
        address newContract
    ) external whenTheNewContractAddressHasNoCode(newContract) {
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedContractCreation.selector,
            address(createXHarness)
        );
        vm.expectRevert(expectedErr);
        createXHarness.exposed_requireSuccessfulContractCreation(success, newContract);
    }

    modifier whenTheSuccessBooleanIsTrueAndTheNewContractAddressHasCode(address newContract) {
        assumeAddressIsNot(newContract, AddressType.ForgeAddress, AddressType.Precompile);
        // If the new contract address has no code, etch some. This is faster than `vm.assume`.
        if (newContract.code.length == 0) vm.etch(newContract, "01");
        _;
    }

    function test_WhenTheSuccessBooleanIsTrueAndTheNewContractAddressHasCode(
        address newContract
    ) external whenTheSuccessBooleanIsTrueAndTheNewContractAddressHasCode(newContract) {
        // It should never revert. We do not need any assertions to test this.
        createXHarness.exposed_requireSuccessfulContractCreation(true, newContract);
    }
}
