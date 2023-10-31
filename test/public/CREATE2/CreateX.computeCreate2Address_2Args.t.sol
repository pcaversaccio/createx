// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTest} from "../../utils/BaseTest.sol";
import {CreateX} from "../../../src/CreateX.sol";

contract CreateX_ComputeCreate2Address_2Args_Public_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function testFuzz_ReturnsThe20ByteAddressWhereAContractWillBeStoredAndShouldNeverRevert(bytes32 salt) external {
        vm.startPrank(createXAddr);
        address create2AddressComputedOnChain = address(new CreateX{salt: salt}());
        vm.stopPrank();
        // It returns the 20-byte address where a contract will be stored.
        // It should never revert.
        assertEq(
            createX.computeCreate2Address(salt, keccak256(type(CreateX).creationCode)),
            create2AddressComputedOnChain,
            "100"
        );
    }
}
