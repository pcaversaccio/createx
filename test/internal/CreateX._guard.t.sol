// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTest} from "../utils/BaseTest.sol";
import {CreateX} from "../../src/CreateX.sol";

contract CreateX_Guard_Internal_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    bytes32 internal cachedSalt;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    modifier whenTheFirst20BytesOfTheSaltEqualsTheCaller(address caller, bytes32 salt) {
        // Set the first 20 bytes of the `salt` equal to `caller` (a.k.a. `msg.sender`).
        cachedSalt = bytes32(abi.encodePacked(caller, bytes12(uint96(uint256(salt)))));
        _;
    }

    /**
     * @custom:security To ensure a proper test coverage, please use this modifier only subsequent
     * to a modifier that updates the value of `cachedSalt`. Otherwise, it might be possible that
     * `cachedSalt` has never changed its default value.
     */
    modifier whenThe21stByteOfTheSaltEquals0x01() {
        // Set the 21st byte of the `salt` equal to `0x01`.
        cachedSalt = bytes32(abi.encodePacked(bytes20(cachedSalt), hex"01", bytes11(uint88(uint256(cachedSalt)))));
        _;
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltEqualsTheCallerAndWhenThe21stByteOfTheSaltEquals0x01(
        address caller,
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltEqualsTheCaller(caller, salt) whenThe21stByteOfTheSaltEquals0x01 {
        vm.startPrank(caller);
        // It should return the `keccak256` hash of the ABI-encoded values `msg.sender`, `block.chainid`, and the `salt`.
        bytes32 guardedSalt = createXHarness.exposed_guard(cachedSalt);
        vm.stopPrank();
        assertEq(guardedSalt, keccak256(abi.encode(caller, block.chainid, cachedSalt)), "100");
    }

    /**
     * @custom:security To ensure a proper test coverage, please use this modifier only subsequent
     * to a modifier that updates the value of `cachedSalt`. Otherwise, it might be possible that
     * `cachedSalt` has never changed its default value.
     */
    modifier whenThe21stByteOfTheSaltEquals0x00() {
        // Set the 21st byte of the `salt` equal to `0x00`.
        cachedSalt = bytes32(abi.encodePacked(bytes20(cachedSalt), hex"00", bytes11(uint88(uint256(cachedSalt)))));
        _;
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltEqualsTheCallerAndWhenThe21stByteOfTheSaltEquals0x00(
        address caller,
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltEqualsTheCaller(caller, salt) whenThe21stByteOfTheSaltEquals0x00 {
        vm.startPrank(caller);
        // It should return the `keccak256` hash of the ABI-encoded values `msg.sender` and the `salt`.
        bytes32 guardedSalt = createXHarness.exposed_guard(cachedSalt);
        vm.stopPrank();
        assertEq(guardedSalt, keccak256(abi.encode(caller, cachedSalt)), "100");
    }

    /**
     * @custom:security To ensure a proper test coverage, please use this modifier only subsequent
     * to a modifier that updates the value of `cachedSalt`. Otherwise, it might be possible that
     * `cachedSalt` has never changed its default value.
     */
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
        address caller,
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltEqualsTheCaller(caller, salt) whenThe21stByteOfTheSaltIsGreaterThan0x01 {
        vm.startPrank(caller);
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
        address caller,
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltEqualsTheZeroAddress(salt) whenThe21stByteOfTheSaltEquals0x01 {
        vm.assume(caller != zeroAddress);
        vm.startPrank(caller);
        // It should return the `keccak256` hash of the ABI-encoded values `block.chainid` and the `salt`.
        bytes32 guardedSalt = createXHarness.exposed_guard(cachedSalt);
        vm.stopPrank();
        assertEq(guardedSalt, keccak256(abi.encode(block.chainid, cachedSalt)), "100");
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltEqualsTheZeroAddressAndWhenThe21stByteOfTheSaltEquals0x00(
        address caller,
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltEqualsTheZeroAddress(salt) whenThe21stByteOfTheSaltEquals0x00 {
        vm.assume(caller != zeroAddress);
        vm.startPrank(caller);
        // It should return the unmodified salt value.
        bytes32 guardedSalt = createXHarness.exposed_guard(cachedSalt);
        vm.stopPrank();
        assertEq(guardedSalt, cachedSalt, "100");
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltEqualsTheZeroAddressAndWhenThe21stByteOfTheSaltIsGreaterThan0x01(
        address caller,
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltEqualsTheZeroAddress(salt) whenThe21stByteOfTheSaltIsGreaterThan0x01 {
        vm.startPrank(caller);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXHarnessAddr);
        vm.expectRevert(expectedErr);
        createXHarness.exposed_guard(cachedSalt);
        vm.stopPrank();
    }

    modifier whenTheFirst20BytesOfTheSaltDoNotEqualTheCallerOrTheZeroAddress(address caller, bytes32 salt) {
        vm.assume(address(bytes20(salt)) != caller && address(bytes20(salt)) != zeroAddress);
        cachedSalt = salt;
        _;
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltDoNotEqualTheCallerOrTheZeroAddress(
        address caller,
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltDoNotEqualTheCallerOrTheZeroAddress(caller, salt) {
        vm.startPrank(caller);
        // It should return the unmodified salt value.
        bytes32 guardedSalt = createXHarness.exposed_guard(cachedSalt);
        vm.stopPrank();
        assertEq(guardedSalt, cachedSalt, "100");
    }
}
