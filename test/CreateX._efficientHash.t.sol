// SPDX-License-Identifier: WTFPL
pragma solidity 0.8.21;

import {BaseTest} from "./BaseTest.sol";

contract CreateX_EfficientHash_Test is BaseTest {
    function test_Requirements(bytes32 a, bytes32 b) external {
        // It should match the output of a high-level hash.
        // It should not revert.
        bytes32 expected = keccak256(abi.encodePacked(a, b));
        bytes32 actual = createXHarness.exposed_efficientHash({a: a, b: b});
        assertEq({a: actual, b: expected, err: "hash mismatch"});
    }
}
