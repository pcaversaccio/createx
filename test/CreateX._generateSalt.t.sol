// SPDX-License-Identifier: WTFPL
pragma solidity 0.8.21;

import {BaseTest} from "./BaseTest.sol";

contract CreateX_GenerateSalt_Test is BaseTest {
    function test_ShouldBeAFunctionOfAllBlockPropertiesAndTheCaller() external {
        // It should be a function of all block properties and the caller.
        // The full set of dependencies is:
        //   - blockhash(block.number - 1),
        //   - block.coinbase,
        //   - block.number,
        //   - block.timestamp,
        //   - block.prevrandao
        //   - block.chainid,
        //   - msg.sender
        // We test their dependencies by getting the current salt, changing any of those values, and
        // verifying that the salt changes.
        uint256 snapshotId = vm.snapshot();
        bytes32 originalSalt = createXHarness.exposed_generateSalt();

        // Change block. Block number and hash are coupled so we can't isolate this.
        vm.roll(block.number + 1);
        assertNotEq(originalSalt, createXHarness.exposed_generateSalt());

        // Change coinbase.
        vm.revertTo(snapshotId);
        assertEq(createXHarness.exposed_generateSalt(), originalSalt);

        vm.coinbase(makeAddr("new coinbase"));
        assertNotEq(originalSalt, createXHarness.exposed_generateSalt());

        // Change timestamp.
        vm.revertTo(snapshotId);
        assertEq(createXHarness.exposed_generateSalt(), originalSalt);

        vm.warp(block.timestamp + 1);
        assertNotEq(originalSalt, createXHarness.exposed_generateSalt());

        // Change prevrandao.
        vm.revertTo(snapshotId);
        assertEq(createXHarness.exposed_generateSalt(), originalSalt);

        vm.prevrandao("new prevrandao");
        assertNotEq(originalSalt, createXHarness.exposed_generateSalt());

        // Change chain ID.
        vm.revertTo(snapshotId);
        assertEq(createXHarness.exposed_generateSalt(), originalSalt);

        vm.chainId(111222333);
        assertNotEq(originalSalt, createXHarness.exposed_generateSalt());

        // Change sender.
        vm.revertTo(snapshotId);
        assertEq(createXHarness.exposed_generateSalt(), originalSalt);

        vm.prank(makeAddr("new sender"));
        assertNotEq(originalSalt, createXHarness.exposed_generateSalt());
    }
}
