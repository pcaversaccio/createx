// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTest} from "../utils/BaseTest.sol";
import {CreateX} from "../../src/CreateX.sol";

contract CreateX_RequireSuccessfulContractInitialisation_Internal_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    modifier whenTheSuccessBooleanIsFalse() {
        _;
    }

    function testFuzz_WhenTheSuccessBooleanIsFalse(
        bytes memory returnData,
        address implementation
    ) external whenTheSuccessBooleanIsFalse {
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedContractInitialisation.selector,
            createXHarnessAddr,
            returnData
        );
        vm.expectRevert(expectedErr);
        createXHarness.exposed_requireSuccessfulContractInitialisation(false, returnData, implementation);
    }

    modifier whenTheSuccessBooleanIsTrue() {
        _;
    }

    modifier whenTheImplementationAddressHasNoCode(address implementation) {
        vm.assume(implementation != createXHarnessAddr); // Avoid removing the code of the contract under test.
        assumeAddressIsNot(implementation, AddressType.ForgeAddress);

        // If the new contract address has code, remove the code. This is faster than `vm.assume`.
        if (implementation.code.length != 0) {
            vm.etch(implementation, "");
        }
        _;
    }

    function testFuzz_WhenTheImplementationAddressHasNoCode(
        bytes memory returnData,
        address implementation
    ) external whenTheSuccessBooleanIsTrue whenTheImplementationAddressHasNoCode(implementation) {
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedContractInitialisation.selector,
            createXHarnessAddr,
            returnData
        );
        vm.expectRevert(expectedErr);
        createXHarness.exposed_requireSuccessfulContractInitialisation(true, returnData, implementation);
    }

    modifier whenTheImplementationAddressHasCode(address implementation) {
        assumeAddressIsNot(implementation, AddressType.ForgeAddress, AddressType.Precompile);

        // If the new contract address has no code, etch some. This is faster than `vm.assume`.
        if (implementation.code.length == 0) {
            vm.etch(implementation, "01");
        }
        _;
    }

    function testFuzz_WhenTheImplementationAddressHasCode(
        bytes memory returnData,
        address implementation
    ) external whenTheSuccessBooleanIsTrue whenTheImplementationAddressHasCode(implementation) {
        // It should never revert.
        createXHarness.exposed_requireSuccessfulContractInitialisation(true, returnData, implementation);
    }
}
