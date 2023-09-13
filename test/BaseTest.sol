// SPDX-License-Identifier: WTFPL
pragma solidity 0.8.21;

import {Test} from "forge-std/Test.sol";
import {CreateX} from "../src/CreateX.sol";

/**
 * @dev Harness contract that exposes internal functions for testing.
 */
contract CreateXHarness is CreateX {
    function exposed_parseSalt(
        bytes32 salt
    ) external view returns (SenderBytes senderBytes, RedeployProtectionFlag redeployProtectionFlag) {
        (senderBytes, redeployProtectionFlag) = _parseSalt(salt);
    }

    function exposed_efficientHash(bytes32 a, bytes32 b) external pure returns (bytes32 hash) {
        hash = _efficientHash(a, b);
    }

    function exposed_generateSalt() external view returns (bytes32 salt) {
        salt = _generateSalt();
    }

    function exposed_requireSuccessfulContractCreation(bool success, address newContract) external view {
        _requireSuccessfulContractCreation(success, newContract);
    }

    function exposed_requireSuccessfulContractCreation(address newContract) external view {
        _requireSuccessfulContractCreation(newContract);
    }

    function exposed_requireSuccessfulContractInitialisation(
        bool success,
        bytes memory returnData,
        address implementation
    ) external view {
        _requireSuccessfulContractInitialisation(success, returnData, implementation);
    }
}

/**
 * @dev Base test contract that deploys `CreateX` and `CreateXHarness`, and defines
 * events and helper methods.
 */
contract BaseTest is Test {
    CreateX internal createX;
    address internal createXAddr;

    CreateXHarness internal createXHarness;
    address internal createXHarnessAddr;

    // solhint-disable-next-line const-name-snakecase
    address internal constant zeroAddress = address(0);

    event ContractCreation(address indexed newContract);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        // Note that the main contract `CreateX` does `block.number - 32` when generating
        // it's own salt, so we start at block 100 here to prevent a (negative) overflow.
        vm.roll(100);

        // Deploy contracts.
        createX = new CreateX();
        createXAddr = address(createX);

        createXHarness = new CreateXHarness();
        createXHarnessAddr = address(createXHarness);
    }
}
