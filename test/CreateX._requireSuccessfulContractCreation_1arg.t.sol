// SPDX-License-Identifier: WTFPL
pragma solidity 0.8.21;

import {BaseTest} from "./BaseTest.sol";
import {CreateX} from "../src/CreateX.sol";

contract RequireSuccessfulContractCreation_1Arg_Internal_Test is BaseTest {
    modifier whenTheNewContractAddressHasNoCode(address newContract) {
        assumeAddressIsNot(newContract, AddressType.ForgeAddress);
        // If the new contract address has code, remove the code. This is faster than `vm.assume`.
        if (newContract.code.length > 0) vm.etch(newContract, "");
        _;
    }

    function test_WhenTheNewContractAddressHasNoCode(
        address newContract
    ) external whenTheNewContractAddressHasNoCode(newContract) {
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedContractCreation.selector,
            address(createXHarness)
        );
        vm.expectRevert(expectedErr);
        createXHarness.exposed_requireSuccessfulContractCreation(newContract);
    }

    modifier whenTheNewContractAddressHasCode(address newContract) {
        assumeAddressIsNot(newContract, AddressType.ForgeAddress, AddressType.Precompile);
        // If the new contract address has no code, etch some. This is faster than `vm.assume`.
        if (newContract.code.length == 0) vm.etch(newContract, "01");
        _;
    }

    function test_WhenTheNewContractAddressHasCode(
        address newContract
    ) external whenTheNewContractAddressHasCode(newContract) {
        // It should never revert. We do not need any assertions to test this.
        createXHarness.exposed_requireSuccessfulContractCreation(newContract);
    }
}
