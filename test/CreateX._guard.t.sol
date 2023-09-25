// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {BaseTest} from "./BaseTest.sol";
import {CreateX} from "../src/CreateX.sol";

contract CreateX_Guard_Internal_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    bytes32 internal cachedSalt;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    modifier whenTheFirst20BytesOfTheSaltEqualsTheCaller(bytes32 salt) {
        // Set the first 20 bytes of the `salt` equal to `msg.sender`.
        cachedSalt = bytes32(abi.encodePacked(msg.sender, bytes12(uint96(uint256(salt)))));
        _;
    }

    modifier whenThe21stByteOfTheSaltEquals0x01() {
        // Set the 21st byte of the `salt` equal to `0x01`.
        cachedSalt = bytes32(abi.encodePacked(bytes20(cachedSalt), hex"01", bytes11(uint88(uint256(cachedSalt)))));
        _;
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltEqualsTheCallerAndWhenThe21stByteOfTheSaltEquals0x01(
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltEqualsTheCaller(salt) whenThe21stByteOfTheSaltEquals0x01 {
        vm.startPrank(msg.sender);
        // It should return the `keccak256` hash of the ABI-encoded values `msg.sender`, `block.chainid`, and the `salt`.
        bytes32 guardedSalt = createXHarness.exposed_guard(cachedSalt);
        assertEq(guardedSalt, keccak256(abi.encode(msg.sender, block.chainid, cachedSalt)));
        vm.stopPrank();
    }

    modifier whenThe21stByteOfTheSaltEquals0x00() {
        // Set the 21st byte of the `salt` equal to `0x00`.
        cachedSalt = bytes32(abi.encodePacked(bytes20(cachedSalt), hex"00", bytes11(uint88(uint256(cachedSalt)))));
        _;
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltEqualsTheCallerAndWhenThe21stByteOfTheSaltEquals0x00(
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltEqualsTheCaller(salt) whenThe21stByteOfTheSaltEquals0x00 {
        vm.startPrank(msg.sender);
        // It should return the `keccak256` hash of the ABI-encoded values `msg.sender` and the `salt`.
        bytes32 guardedSalt = createXHarness.exposed_guard(cachedSalt);
        assertEq(guardedSalt, keccak256(abi.encode(msg.sender, cachedSalt)));
        vm.stopPrank();
    }

    modifier whenThe21stByteOfTheSaltIsGreaterThan0x01() {
        // Set the 21st byte of the `salt` to a value greater than `0x01`.
        if (uint8(cachedSalt[20]) <= uint8(1)) {
            bytes1 newByte = bytes1(keccak256(abi.encode(cachedSalt[20])));
            while (uint8(newByte) <= uint8(1)) {
                newByte = bytes1(keccak256(abi.encode(newByte)));
            }
            cachedSalt = bytes32(abi.encodePacked(bytes20(cachedSalt), newByte, bytes11(uint88(uint256(cachedSalt)))));
        }
        _;
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltEqualsTheCallerAndWhenThe21stByteOfTheSaltIsGreaterThan0x01(
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltEqualsTheCaller(salt) whenThe21stByteOfTheSaltIsGreaterThan0x01 {
        vm.startPrank(msg.sender);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXHarnessAddr);
        vm.expectRevert(expectedErr);
        createXHarness.exposed_guard(cachedSalt);
        vm.stopPrank();
    }

    modifier whenTheFirst20BytesOfTheSaltEqualsTheZeroAddress(bytes32 salt) {
        // Set the first 20 bytes of the `salt` equal to `0x0000000000000000000000000000000000000000`.
        cachedSalt = bytes32(abi.encodePacked(bytes20(0), bytes12(uint96(uint256(salt)))));
        _;
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltEqualsTheZeroAddressAndWhenThe21stByteOfTheSaltEquals0x01(
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltEqualsTheZeroAddress(salt) whenThe21stByteOfTheSaltEquals0x01 {
        vm.startPrank(msg.sender);
        // It should return the `keccak256` hash of the ABI-encoded values `block.chainid` and the `salt`.
        bytes32 guardedSalt = createXHarness.exposed_guard(cachedSalt);
        assertEq(guardedSalt, keccak256(abi.encode(block.chainid, cachedSalt)));
        vm.stopPrank();
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltEqualsTheZeroAddressAndWhenThe21stByteOfTheSaltEquals0x00(
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltEqualsTheZeroAddress(salt) whenThe21stByteOfTheSaltEquals0x00 {
        vm.startPrank(msg.sender);
        // It should return the unmodified salt value.
        bytes32 guardedSalt = createXHarness.exposed_guard(cachedSalt);
        assertEq(guardedSalt, cachedSalt);
        vm.stopPrank();
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltEqualsTheZeroAddressAndWhenThe21stByteOfTheSaltIsGreaterThan0x01(
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltEqualsTheZeroAddress(salt) whenThe21stByteOfTheSaltIsGreaterThan0x01 {
        vm.startPrank(msg.sender);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXHarnessAddr);
        vm.expectRevert(expectedErr);
        createXHarness.exposed_guard(cachedSalt);
        vm.stopPrank();
    }

    modifier whenTheFirst20BytesOfTheSaltDoNotEqualTheCallerOrTheZeroAddress(bytes32 salt) {
        vm.assume(address(bytes20(salt)) != msg.sender && address(bytes20(salt)) != zeroAddress);
        cachedSalt = salt;
        _;
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltDoNotEqualTheCallerOrTheZeroAddress(
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltDoNotEqualTheCallerOrTheZeroAddress(salt) {
        vm.startPrank(msg.sender);
        // It should return the unmodified salt value.
        bytes32 guardedSalt = createXHarness.exposed_guard(cachedSalt);
        assertEq(guardedSalt, cachedSalt);
        vm.stopPrank();
    }
}
