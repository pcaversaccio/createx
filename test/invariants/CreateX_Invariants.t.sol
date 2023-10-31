// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {Test} from "forge-std/Test.sol";
import {CreateX} from "../../src/CreateX.sol";

contract CreateX_Invariants is Test {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    CreateX internal createX;
    CreateXHandler internal createXHandler;

    address internal createXAddr;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            SETUP                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function setUp() public {
        uint256 initialBalance = 1 ether;
        createX = new CreateX();
        createXAddr = address(createX);
        createXHandler = new CreateXHandler(createX, initialBalance);
        // We prefund the `createX` contract with an initial amount.
        deal(createXAddr, initialBalance);
        targetContract(address(createXHandler));
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function statefulFuzz_EtherBalance() external {
        assertEq(createXAddr.balance, createXHandler.updatedBalance(), "100");
    }
}

contract CreateXHandler {
    uint256 public updatedBalance;
    CreateX internal createX;

    constructor(CreateX createX_, uint256 initialBalance_) {
        createX = createX_;
        updatedBalance = initialBalance_;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           CREATE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function deployCreate(bytes memory initCode) public payable returns (address newContract) {
        newContract = createX.deployCreate(initCode);
    }

    function deployCreateAndInit(
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values,
        address refundAddress
    ) public payable returns (address newContract) {
        newContract = createX.deployCreateAndInit(initCode, data, values, refundAddress);
        updatedBalance = 0;
    }

    function deployCreateAndInit(
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values
    ) public payable returns (address newContract) {
        newContract = createX.deployCreateAndInit(initCode, data, values);
        updatedBalance = 0;
    }

    function deployCreateClone(address implementation, bytes memory data) public payable returns (address proxy) {
        proxy = createX.deployCreateClone(implementation, data);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           CREATE2                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function deployCreate2(bytes32 salt, bytes memory initCode) public payable returns (address newContract) {
        newContract = createX.deployCreate2(salt, initCode);
    }

    function deployCreate2(bytes memory initCode) public payable returns (address newContract) {
        newContract = createX.deployCreate2(initCode);
    }

    function deployCreate2AndInit(
        bytes32 salt,
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values,
        address refundAddress
    ) public payable returns (address newContract) {
        newContract = createX.deployCreate2AndInit(salt, initCode, data, values, refundAddress);
        updatedBalance = 0;
    }

    function deployCreate2AndInit(
        bytes32 salt,
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values
    ) public payable returns (address newContract) {
        newContract = createX.deployCreate2AndInit(salt, initCode, data, values);
        updatedBalance = 0;
    }

    function deployCreate2AndInit(
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values,
        address refundAddress
    ) public payable returns (address newContract) {
        newContract = createX.deployCreate2AndInit(initCode, data, values, refundAddress);
        updatedBalance = 0;
    }

    function deployCreate2AndInit(
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values
    ) public payable returns (address newContract) {
        newContract = createX.deployCreate2AndInit(initCode, data, values);
        updatedBalance = 0;
    }

    function deployCreate2Clone(
        bytes32 salt,
        address implementation,
        bytes memory data
    ) public payable returns (address proxy) {
        proxy = createX.deployCreate2Clone(salt, implementation, data);
    }

    function deployCreate2Clone(address implementation, bytes memory data) public payable returns (address proxy) {
        proxy = createX.deployCreate2Clone(implementation, data);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           CREATE3                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function deployCreate3(bytes32 salt, bytes memory initCode) public payable returns (address newContract) {
        newContract = createX.deployCreate3(salt, initCode);
    }

    function deployCreate3(bytes memory initCode) public payable returns (address newContract) {
        newContract = createX.deployCreate3(initCode);
    }

    function deployCreate3AndInit(
        bytes32 salt,
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values,
        address refundAddress
    ) public payable returns (address newContract) {
        newContract = createX.deployCreate3AndInit(salt, initCode, data, values, refundAddress);
        updatedBalance = 0;
    }

    function deployCreate3AndInit(
        bytes32 salt,
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values
    ) public payable returns (address newContract) {
        newContract = createX.deployCreate3AndInit(salt, initCode, data, values);
        updatedBalance = 0;
    }

    function deployCreate3AndInit(
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values,
        address refundAddress
    ) public payable returns (address newContract) {
        newContract = createX.deployCreate3AndInit(initCode, data, values, refundAddress);
        updatedBalance = 0;
    }

    function deployCreate3AndInit(
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values
    ) public payable returns (address newContract) {
        newContract = createX.deployCreate3AndInit(initCode, data, values);
        updatedBalance = 0;
    }
}
