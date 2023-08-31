// SPDX-License-Identifier: WTFPL
pragma solidity 0.8.21;

import {Test} from "forge-std/Test.sol";
import {CreateX} from "../src/CreateX.sol";

// Harness contract that exposes internal functions for testing.
contract CreateXHarness is CreateX {
    function exposed_efficientHash(bytes32 a, bytes32 b) external pure returns (bytes32 hash) {
        return _efficientHash(a, b);
    }
}

// Base test contract that deploys CreateX and CreateXHarness and defines events and helper methods.
contract BaseTest is Test {
    CreateX internal createX;
    address internal createXAddr;

    CreateXHarness internal createXHarness;
    address internal createXHarnessAddr;

    address internal constant zeroAddress = address(0);

    event ContractCreation(address indexed newContract);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        createX = new CreateX();
        createXAddr = address(createX);

        createXHarness = new CreateXHarness();
        createXHarnessAddr = address(createXHarness);
    }
}
