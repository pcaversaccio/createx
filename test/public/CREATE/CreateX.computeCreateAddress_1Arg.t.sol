// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTest} from "../../utils/BaseTest.sol";
import {CreateX} from "../../../src/CreateX.sol";

contract CreateX_ComputeCreateAddress_1Arg_Public_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    uint256 internal cachedNonce;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    modifier whenTheNonceValueDoesNotExceed18446744073709551614(uint64 nonce) {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        _;
    }

    function testFuzz_WhenTheNonceValueDoesNotExceed18446744073709551614(
        uint64 nonce
    ) external whenTheNonceValueDoesNotExceed18446744073709551614(nonce) {
        vm.startPrank(createXAddr);
        address createAddressComputedOnChain = address(new CreateX());
        vm.stopPrank();
        // It returns the 20-byte address where a contract will be stored.
        assertEq(createX.computeCreateAddress(nonce), createAddressComputedOnChain, "100");
    }

    modifier whenTheNonceValueExceeds18446744073709551614(uint256 nonce) {
        cachedNonce = bound(nonce, type(uint64).max, type(uint256).max);
        _;
    }

    function testFuzz_WhenTheNonceValueExceeds18446744073709551614(
        uint256 nonce
    ) external whenTheNonceValueExceeds18446744073709551614(nonce) {
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidNonceValue.selector, createXAddr);
        vm.expectRevert(expectedErr);
        // It should revert.
        createX.computeCreateAddress(cachedNonce);
    }
}
