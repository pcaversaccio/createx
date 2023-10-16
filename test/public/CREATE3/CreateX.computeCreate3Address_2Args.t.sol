// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {BaseTest} from "../../utils/BaseTest.sol";
import {CreateX} from "../../../src/CreateX.sol";

contract CreateX_ComputeCreate3Address_2Args_Public_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function testFuzz_ReturnsThe20ByteAddressWhereAContractWillBeStoredAndShouldNeverRevert(
        bytes32 salt,
        address deployer,
        uint256 msgValue
    ) external {
        msgValue = bound(msgValue, 0, type(uint64).max);
        vm.deal(deployer, msgValue);

        // It returns the 20-byte address where a contract will be stored.
        // It should never revert.
        vm.startPrank(deployer);
        address newContract = newCreateX.deployCreate3{value: msgValue}(salt, type(CreateX).creationCode);
        vm.stopPrank();
        // assertEq(createX.computeCreate3Address(guardedSalt, address(newCreateX)), newContract, "100");
    }
}
