// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTest} from "../utils/BaseTest.sol";
import {CreateX} from "../../src/CreateX.sol";

contract CreateX_ParseSalt_Internal_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    bytes32 internal cachedSalt;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER FUNCTIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * @dev Asserts the equality of `CreateX.SenderBytes` types.
     * @param a The first 1-byte `CreateX.SenderBytes` value.
     * @param b The second 1-byte `CreateX.SenderBytes` value.
     * @param err The error message string.
     */
    function assertEq(CreateX.SenderBytes a, CreateX.SenderBytes b, string memory err) internal {
        // The `enum` type is treated as a `uint8` type by the Solidity compiler.
        if (a != b) {
            emit log_named_string("Error", err);
            emit log("Error: a == b not satisfied [CreateX.SenderBytes]");
            emit log_named_uint("      Left", uint8(a));
            emit log_named_uint("     Right", uint8(b));
            fail();
        }
    }

    /**
     * @dev Asserts the equality of `CreateX.RedeployProtectionFlag` types.
     * @param a The first 1-byte `CreateX.RedeployProtectionFlag` value.
     * @param b The second 1-byte `CreateX.RedeployProtectionFlag` value.
     * @param err The error message string.
     */
    function assertEq(CreateX.RedeployProtectionFlag a, CreateX.RedeployProtectionFlag b, string memory err) internal {
        // The `enum` type is treated as a `uint8` type by the Solidity compiler.
        if (a != b) {
            emit log_named_string("Error", err);
            emit log("Error: a == b not satisfied [CreateX.RedeployProtectionFlag]");
            emit log_named_uint("      Left", uint8(a));
            emit log_named_uint("     Right", uint8(b));
            fail();
        }
    }

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
        // It should return the `SenderBytes.MsgSender` `enum` as first return value.
        // It should return the `RedeployProtectionFlag.True` `enum` as second return value.
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(cachedSalt);
        vm.stopPrank();
        assertEq(senderBytes, CreateX.SenderBytes.MsgSender, "100");
        assertEq(redeployProtectionFlag, CreateX.RedeployProtectionFlag.True, "200");
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
        // It should return the `SenderBytes.MsgSender` `enum` as first return value.
        // It should return the `RedeployProtectionFlag.False` `enum` as second return value.
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(cachedSalt);
        vm.stopPrank();
        assertEq(senderBytes, CreateX.SenderBytes.MsgSender, "100");
        assertEq(redeployProtectionFlag, CreateX.RedeployProtectionFlag.False, "200");
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
        // It should return the `SenderBytes.MsgSender` `enum` as first return value.
        // It should return the `RedeployProtectionFlag.Unspecified` `enum` as second return value.
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(cachedSalt);
        vm.stopPrank();
        assertEq(senderBytes, CreateX.SenderBytes.MsgSender, "100");
        assertEq(redeployProtectionFlag, CreateX.RedeployProtectionFlag.Unspecified, "200");
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
        // It should return the `SenderBytes.ZeroAddress` `enum` as first return value.
        // It should return the `RedeployProtectionFlag.True` `enum` as second return value.
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(cachedSalt);
        vm.stopPrank();
        assertEq(senderBytes, CreateX.SenderBytes.ZeroAddress, "100");
        assertEq(redeployProtectionFlag, CreateX.RedeployProtectionFlag.True, "200");
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltEqualsTheZeroAddressAndWhenThe21stByteOfTheSaltEquals0x00(
        address caller,
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltEqualsTheZeroAddress(salt) whenThe21stByteOfTheSaltEquals0x00 {
        vm.assume(caller != zeroAddress);
        vm.startPrank(caller);
        // It should return the `SenderBytes.ZeroAddress` `enum` as first return value.
        // It should return the `RedeployProtectionFlag.False` `enum` as second return value.
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(cachedSalt);
        vm.stopPrank();
        assertEq(senderBytes, CreateX.SenderBytes.ZeroAddress, "100");
        assertEq(redeployProtectionFlag, CreateX.RedeployProtectionFlag.False, "200");
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltEqualsTheZeroAddressAndWhenThe21stByteOfTheSaltIsGreaterThan0x01(
        address caller,
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltEqualsTheZeroAddress(salt) whenThe21stByteOfTheSaltIsGreaterThan0x01 {
        vm.assume(caller != zeroAddress);
        vm.startPrank(caller);
        // It should return the `SenderBytes.ZeroAddress` `enum` as first return value.
        // It should return the `RedeployProtectionFlag.Unspecified` `enum` as second return value.
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(cachedSalt);
        vm.stopPrank();
        assertEq(senderBytes, CreateX.SenderBytes.ZeroAddress, "100");
        assertEq(redeployProtectionFlag, CreateX.RedeployProtectionFlag.Unspecified, "200");
    }

    modifier whenTheFirst20BytesOfTheSaltDoNotEqualTheCallerOrTheZeroAddress(address caller, bytes32 salt) {
        vm.assume(address(bytes20(salt)) != caller && address(bytes20(salt)) != zeroAddress);
        cachedSalt = salt;
        _;
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltDoNotEqualTheCallerOrTheZeroAddressAndWhenThe21stByteOfTheSaltEquals0x01(
        address caller,
        bytes32 salt
    )
        external
        whenTheFirst20BytesOfTheSaltDoNotEqualTheCallerOrTheZeroAddress(caller, salt)
        whenThe21stByteOfTheSaltEquals0x01
    {
        vm.startPrank(caller);
        // It should return the `SenderBytes.Random` `enum` as first return value.
        // It should return the `RedeployProtectionFlag.True` `enum` as second return value.
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(cachedSalt);
        vm.stopPrank();
        assertEq(senderBytes, CreateX.SenderBytes.Random, "100");
        assertEq(redeployProtectionFlag, CreateX.RedeployProtectionFlag.True, "200");
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltDoNotEqualTheCallerOrTheZeroAddressAndWhenThe21stByteOfTheSaltEquals0x00(
        address caller,
        bytes32 salt
    )
        external
        whenTheFirst20BytesOfTheSaltDoNotEqualTheCallerOrTheZeroAddress(caller, salt)
        whenThe21stByteOfTheSaltEquals0x00
    {
        vm.startPrank(caller);
        // It should return the `SenderBytes.Random` `enum` as first return value.
        // It should return the `RedeployProtectionFlag.False` `enum` as second return value.
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(cachedSalt);
        vm.stopPrank();
        assertEq(senderBytes, CreateX.SenderBytes.Random, "100");
        assertEq(redeployProtectionFlag, CreateX.RedeployProtectionFlag.False, "200");
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltDoNotEqualTheCallerOrTheZeroAddressAndWhenThe21stByteOfTheSaltIsGreaterThan0x01(
        address caller,
        bytes32 salt
    )
        external
        whenTheFirst20BytesOfTheSaltDoNotEqualTheCallerOrTheZeroAddress(caller, salt)
        whenThe21stByteOfTheSaltIsGreaterThan0x01
    {
        vm.startPrank(caller);
        // It should return the `SenderBytes.Random` `enum` as first return value.
        // It should return the `RedeployProtectionFlag.Unspecified` `enum` as second return value.
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(cachedSalt);
        vm.stopPrank();
        assertEq(senderBytes, CreateX.SenderBytes.Random, "100");
        assertEq(redeployProtectionFlag, CreateX.RedeployProtectionFlag.Unspecified, "200");
    }
}
