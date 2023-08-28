// SPDX-License-Identifier: WTFPL
pragma solidity 0.8.21;

import {Test} from "forge-std/Test.sol";
import {CreateX} from "../src/CreateX.sol";

contract BaseTest is Test {
    CreateX internal createX;
    address internal createXAddr;

    address internal constant zeroAddress = address(0);

    event ContractCreation(address indexed newContract);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        createX = new CreateX();
        createXAddr = address(createX);
    }
}
