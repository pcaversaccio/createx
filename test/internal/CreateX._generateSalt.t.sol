// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTest} from "../utils/BaseTest.sol";

contract CreateX_GenerateSalt_Internal_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER FUNCTIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * @dev Generates a 32-byte entropy value using the `keccak256` hashing algorithm.
     * @param seed The 32-byte seed value to generate the entropy value.
     * @param i The 32-byte increment value to further increase the randomness.
     * @return randomness The generated 32-byte entropy value.
     */
    function entropy(uint256 seed, uint256 i) internal pure returns (uint256 randomness) {
        randomness = uint256(keccak256(abi.encodePacked(seed, i)));
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function testFuzz_ShouldBeAFunctionOfMultipleBlockPropertiesAndTheCaller(
        uint256 increment,
        address coinbase,
        string calldata prevrandao,
        uint64 chainId,
        address msgSender
    ) external {
        // It should be a function of multiple block properties and the caller.
        // The full set of dependencies is:
        //    - blockhash(block.number - 32),
        //    - block.coinbase,
        //    - block.number,
        //    - block.timestamp,
        //    - block.prevrandao,
        //    - block.chainid,
        //    - msg.sender.
        // We test their dependencies by determining the current salt, changing any of those
        // values, and verifying that the salt changes.
        increment = bound(increment, 1, type(uint128).max);
        vm.assume(
            coinbase != zeroAddress && chainId != block.chainid && chainId != 0 && msgSender != createXHarnessAddr
        );
        uint256 snapshotId = vm.snapshot();
        bytes32 originalSalt = createXHarness.exposed_generateSalt();

        // Change block. Block number and hash are coupled, so we can't isolate this.
        vm.roll(block.number + increment);
        assertNotEq(originalSalt, createXHarness.exposed_generateSalt(), "100");

        // Change coinbase.
        vm.revertTo(snapshotId);
        assertEq(createXHarness.exposed_generateSalt(), originalSalt, "200");

        vm.coinbase(coinbase);
        assertNotEq(originalSalt, createXHarness.exposed_generateSalt(), "300");

        // Change timestamp.
        vm.revertTo(snapshotId);
        assertEq(createXHarness.exposed_generateSalt(), originalSalt, "400");

        vm.warp(block.timestamp + increment);
        assertNotEq(originalSalt, createXHarness.exposed_generateSalt(), "500");

        // Change prevrandao.
        vm.revertTo(snapshotId);
        assertEq(createXHarness.exposed_generateSalt(), originalSalt, "600");

        vm.prevrandao(keccak256(abi.encode(prevrandao)));
        assertNotEq(originalSalt, createXHarness.exposed_generateSalt(), "700");

        // Change chain ID.
        vm.revertTo(snapshotId);
        assertEq(createXHarness.exposed_generateSalt(), originalSalt, "800");

        vm.chainId(chainId);
        assertNotEq(originalSalt, createXHarness.exposed_generateSalt(), "900");

        // Change sender.
        vm.revertTo(snapshotId);
        assertEq(createXHarness.exposed_generateSalt(), originalSalt, "1000");

        vm.startPrank(msgSender);
        assertNotEq(originalSalt, createXHarness.exposed_generateSalt(), "1100");
        vm.stopPrank();
    }

    function testFuzz_NeverReverts(uint256 seed) external {
        // It should never revert.
        // We derive all our salt properties from the seed and ensure that it never reverts.
        // First, we generate all the entropy.
        uint256 entropy1 = entropy(seed, 1);
        uint256 entropy2 = entropy(seed, 2);
        uint256 entropy3 = entropy(seed, 3);
        uint256 entropy4 = entropy(seed, 4);
        uint256 entropy5 = entropy(seed, 5);
        uint256 entropy6 = entropy(seed, 6);

        // Second, we set the block properties.
        vm.roll(bound(entropy1, block.number, 1e18));
        vm.coinbase(address(uint160(entropy2)));
        vm.warp(bound(entropy3, block.timestamp, 52e4 weeks));
        vm.prevrandao(bytes32(entropy4));
        vm.chainId(bound(entropy5, 0, type(uint64).max));

        // Third, we verify that it doesn't revert by calling it.
        vm.startPrank(address(uint160(entropy6)));
        createXHarness.exposed_generateSalt();
        vm.stopPrank();
    }
}
