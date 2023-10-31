// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTest} from "../../utils/BaseTest.sol";
import {CreateX} from "../../../src/CreateX.sol";
import {CREATE3} from "solady/utils/CREATE3.sol";

contract CreateX_ComputeCreate3Address_2Args_Public_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function testFuzz_ReturnsThe20ByteAddressWhereAContractWillBeStoredAndShouldNeverRevert(
        bytes32 salt,
        address deployer
    ) external {
        vm.startPrank(deployer);
        // We test our implementation against Solady's implementation. We have tested our own `CREATE3`
        // implementation extensively against `computeCreate3Address` as part of the other `CREATE3` tests.
        address create3AddressComputedOnChain = CREATE3.deploy(salt, type(CreateX).creationCode, 0);
        vm.stopPrank();
        // It returns the 20-byte address where a contract will be stored.
        // It should never revert.
        assertEq(createX.computeCreate3Address(salt, deployer), create3AddressComputedOnChain, "100");
    }
}
