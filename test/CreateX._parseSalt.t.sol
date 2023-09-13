// SPDX-License-Identifier: WTFPL
pragma solidity 0.8.21;

import {BaseTest} from "./BaseTest.sol";
import {CreateX} from "../src/CreateX.sol";

contract CreateX_ParseSalt_Internal_Test is BaseTest {
    bytes32 internal cachedSalt;

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
        // It should return the `SenderBytes.MsgSender` `enum` as first return value.
        // It should return the `RedeployProtectionFlag.True` `enum` as second return value.
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(cachedSalt);
        // The `enum` type is treated as a `uint8` type by the Solidity compiler.
        assertEq(uint8(senderBytes), uint8(CreateX.SenderBytes.MsgSender));
        assertEq(uint8(redeployProtectionFlag), uint8(CreateX.RedeployProtectionFlag.True));

        // Reset the `cachedSalt` parameter to the default value.
        delete cachedSalt;
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
        // It should return the `SenderBytes.MsgSender` `enum` as first return value.
        // It should return the `RedeployProtectionFlag.False` `enum` as second return value.
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(cachedSalt);
        // The `enum` type is treated as a `uint8` type by the Solidity compiler.
        assertEq(uint8(senderBytes), uint8(CreateX.SenderBytes.MsgSender));
        assertEq(uint8(redeployProtectionFlag), uint8(CreateX.RedeployProtectionFlag.False));

        // Reset the `cachedSalt` parameter to the default value.
        delete cachedSalt;
        vm.stopPrank();
    }

    modifier whenThe21stByteOfTheSaltDoesNotEqual0x00Or0x01() {
        // Set the 21st byte of the `salt` equal to `0xc5`.
        if (uint8(cachedSalt[20]) <= uint8(1)) {
            cachedSalt = bytes32(
                abi.encodePacked(
                    bytes20(cachedSalt),
                    bytes1(keccak256(new bytes(0))),
                    bytes11(uint88(uint256(cachedSalt)))
                )
            );
        }
        _;
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltEqualsTheCallerAndWhenThe21stByteOfTheSaltDoesNotEqual0x00Or0x01(
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltEqualsTheCaller(salt) whenThe21stByteOfTheSaltDoesNotEqual0x00Or0x01 {
        vm.startPrank(msg.sender);
        // It should return the `SenderBytes.MsgSender` `enum` as first return value.
        // It should return the `RedeployProtectionFlag.Unspecified` `enum` as second return value.
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(cachedSalt);
        // The `enum` type is treated as a `uint8` type by the Solidity compiler.
        assertEq(uint8(senderBytes), uint8(CreateX.SenderBytes.MsgSender));
        assertEq(uint8(redeployProtectionFlag), uint8(CreateX.RedeployProtectionFlag.Unspecified));

        // Reset the `cachedSalt` parameter to the default value.
        delete cachedSalt;
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
        // It should return the `SenderBytes.ZeroAddress` `enum` as first return value.
        // It should return the `RedeployProtectionFlag.True` `enum` as second return value.
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(cachedSalt);
        // The `enum` type is treated as a `uint8` type by the Solidity compiler.
        assertEq(uint8(senderBytes), uint8(CreateX.SenderBytes.ZeroAddress));
        assertEq(uint8(redeployProtectionFlag), uint8(CreateX.RedeployProtectionFlag.True));

        // Reset the `cachedSalt` parameter to the default value.
        delete cachedSalt;
        vm.stopPrank();
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltEqualsTheZeroAddressAndWhenThe21stByteOfTheSaltEquals0x00(
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltEqualsTheZeroAddress(salt) whenThe21stByteOfTheSaltEquals0x00 {
        vm.startPrank(msg.sender);
        // It should return the `SenderBytes.ZeroAddress` `enum` as first return value.
        // It should return the `RedeployProtectionFlag.False` `enum` as second return value.
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(cachedSalt);
        // The `enum` type is treated as a `uint8` type by the Solidity compiler.
        assertEq(uint8(senderBytes), uint8(CreateX.SenderBytes.ZeroAddress));
        assertEq(uint8(redeployProtectionFlag), uint8(CreateX.RedeployProtectionFlag.False));

        // Reset the `cachedSalt` parameter to the default value.
        delete cachedSalt;
        vm.stopPrank();
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltEqualsTheZeroAddressAndWhenThe21stByteOfTheSaltDoesNotEqual0x00Or0x01(
        bytes32 salt
    ) external whenTheFirst20BytesOfTheSaltEqualsTheZeroAddress(salt) whenThe21stByteOfTheSaltDoesNotEqual0x00Or0x01 {
        vm.startPrank(msg.sender);
        // It should return the `SenderBytes.ZeroAddress` `enum` as first return value.
        // It should return the `RedeployProtectionFlag.Unspecified` `enum` as second return value.
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(cachedSalt);
        // The `enum` type is treated as a `uint8` type by the Solidity compiler.
        assertEq(uint8(senderBytes), uint8(CreateX.SenderBytes.ZeroAddress));
        assertEq(uint8(redeployProtectionFlag), uint8(CreateX.RedeployProtectionFlag.Unspecified));

        // Reset the `cachedSalt` parameter to the default value.
        delete cachedSalt;
        vm.stopPrank();
    }

    modifier whenTheFirst20BytesOfTheSaltDoesNotEqualTheCallerOrTheZeroAddress(bytes32 salt) {
        vm.assume(address(bytes20(salt)) != msg.sender && address(bytes20(salt)) != zeroAddress);
        cachedSalt = salt;
        _;
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltDoesNotEqualTheCallerOrTheZeroAddressAndWhenThe21stByteOfTheSaltEquals0x01(
        bytes32 salt
    )
        external
        whenTheFirst20BytesOfTheSaltDoesNotEqualTheCallerOrTheZeroAddress(salt)
        whenThe21stByteOfTheSaltEquals0x01
    {
        vm.startPrank(msg.sender);
        // It should return the `SenderBytes.Random` `enum` as first return value.
        // It should return the `RedeployProtectionFlag.True` `enum` as second return value.
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(cachedSalt);
        // The `enum` type is treated as a `uint8` type by the Solidity compiler.
        assertEq(uint8(senderBytes), uint8(CreateX.SenderBytes.Random));
        assertEq(uint8(redeployProtectionFlag), uint8(CreateX.RedeployProtectionFlag.True));

        // Reset the `cachedSalt` parameter to the default value.
        delete cachedSalt;
        vm.stopPrank();
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltDoesNotEqualTheCallerOrTheZeroAddressAndWhenThe21stByteOfTheSaltEquals0x00(
        bytes32 salt
    )
        external
        whenTheFirst20BytesOfTheSaltDoesNotEqualTheCallerOrTheZeroAddress(salt)
        whenThe21stByteOfTheSaltEquals0x00
    {
        vm.startPrank(msg.sender);
        // It should return the `SenderBytes.Random` `enum` as first return value.
        // It should return the `RedeployProtectionFlag.False` `enum` as second return value.
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(cachedSalt);
        // The `enum` type is treated as a `uint8` type by the Solidity compiler.
        assertEq(uint8(senderBytes), uint8(CreateX.SenderBytes.Random));
        assertEq(uint8(redeployProtectionFlag), uint8(CreateX.RedeployProtectionFlag.False));

        // Reset the `cachedSalt` parameter to the default value.
        delete cachedSalt;
        vm.stopPrank();
    }

    function testFuzz_WhenTheFirst20BytesOfTheSaltDoesNotEqualTheCallerOrTheZeroAddressAndWhenThe21stByteOfTheSaltDoesNotEqual0x00Or0x0(
        bytes32 salt
    )
        external
        whenTheFirst20BytesOfTheSaltDoesNotEqualTheCallerOrTheZeroAddress(salt)
        whenThe21stByteOfTheSaltDoesNotEqual0x00Or0x01
    {
        vm.startPrank(msg.sender);
        // It should return the `SenderBytes.Random` `enum` as first return value.
        // It should return the `RedeployProtectionFlag.Unspecified` `enum` as second return value.
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(cachedSalt);
        // The `enum` type is treated as a `uint8` type by the Solidity compiler.
        assertEq(uint8(senderBytes), uint8(CreateX.SenderBytes.Random));
        assertEq(uint8(redeployProtectionFlag), uint8(CreateX.RedeployProtectionFlag.Unspecified));

        // Reset the `cachedSalt` parameter to the default value.
        delete cachedSalt;
        vm.stopPrank();
    }
}
