// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTest} from "../utils/BaseTest.sol";

contract CreateX_EfficientHash_Internal_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function testFuzz_MatchesTheOutputOfAHighLevelHashAndShouldNeverRevert(bytes32 a, bytes32 b) external {
        // It should match the output of a high-level hash.
        // It should never revert.
        bytes32 expected = keccak256(abi.encodePacked(a, b));
        bytes32 actual = createXHarness.exposed_efficientHash(a, b);
        assertEq(actual, expected, "100");
    }
}
