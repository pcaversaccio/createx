// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTest} from "../../utils/BaseTest.sol";
import {CreateX} from "../../../src/CreateX.sol";

contract CreateX_ComputeCreateAddress_2Args_Public_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    uint256 internal cachedNonce;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    modifier whenTheNonceValueDoesNotExceed18446744073709551614(address deployer, uint64 nonce) {
        vm.assume(nonce < type(uint64).max);
        if (deployer.code.length != 0) {
            vm.assume(nonce != 0);
        }
        vm.setNonce(deployer, nonce);
        _;
    }

    function testFuzz_WhenTheNonceValueDoesNotExceed18446744073709551614(
        address deployer,
        uint64 nonce
    ) external whenTheNonceValueDoesNotExceed18446744073709551614(deployer, nonce) {
        vm.startPrank(deployer);
        address createAddressComputedOnChain = address(new CreateX());
        vm.stopPrank();
        // It returns the 20-byte address where a contract will be stored.
        assertEq(createX.computeCreateAddress(deployer, nonce), createAddressComputedOnChain, "100");
    }

    modifier whenTheNonceValueExceeds18446744073709551614(uint256 nonce) {
        cachedNonce = bound(nonce, type(uint64).max, type(uint256).max);
        _;
    }

    function testFuzz_WhenTheNonceValueExceeds18446744073709551614(
        address deployer,
        uint256 nonce
    ) external whenTheNonceValueExceeds18446744073709551614(nonce) {
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidNonceValue.selector, createXAddr);
        vm.expectRevert(expectedErr);
        // It should revert.
        createX.computeCreateAddress(deployer, cachedNonce);
    }
}
