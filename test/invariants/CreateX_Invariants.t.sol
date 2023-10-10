// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {Test} from "forge-std/Test.sol";
import {CreateX} from "../../src/CreateX.sol";

contract CreateX_Invariants is Test {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    CreateX internal createx;
    CreateXHandler internal createXHandler;

    address internal createxAddr;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            SETUP                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function setUp() public {
        uint256 initialBalance = 1 ether;
        createx = new CreateX();
        createxAddr = address(createx);
        createXHandler = new CreateXHandler(createx, initialBalance);
        // We prefund the `CreateX` contract with an initial amount.
        deal(createxAddr, initialBalance);
        targetContract(address(createXHandler));
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function statefulFuzz_EtherBalance() external {
        assertEq(createxAddr.balance, createXHandler.updatedBalance(), "100");
    }
}

contract CreateXHandler {
    uint256 public updatedBalance;
    CreateX internal createx;

    constructor(CreateX createx_, uint256 initialBalance_) {
        createx = createx_;
        updatedBalance = initialBalance_;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           CREATE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function deployCreate(bytes memory initCode) public payable returns (address newContract) {
        newContract = createx.deployCreate(initCode);
    }

    function deployCreateAndInit(
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values,
        address refundAddress
    ) public payable returns (address newContract) {
        updatedBalance = 0;
        newContract = createx.deployCreateAndInit(initCode, data, values, refundAddress);
    }

    function deployCreateAndInit(
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values
    ) public payable returns (address newContract) {
        updatedBalance = 0;
        newContract = createx.deployCreateAndInit(initCode, data, values);
    }

    function deployCreateClone(address implementation, bytes memory data) public payable returns (address proxy) {
        proxy = createx.deployCreateClone(implementation, data);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           CREATE2                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function deployCreate2(bytes32 salt, bytes memory initCode) public payable returns (address newContract) {
        newContract = deployCreate2(salt, initCode);
    }

    function deployCreate2(bytes memory initCode) public payable returns (address newContract) {
        newContract = deployCreate2(initCode);
    }

    function deployCreate2AndInit(
        bytes32 salt,
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values,
        address refundAddress
    ) public payable returns (address newContract) {
        updatedBalance = 0;
        newContract = deployCreate2AndInit(salt, initCode, data, values, refundAddress);
    }

    function deployCreate2AndInit(
        bytes32 salt,
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values
    ) public payable returns (address newContract) {
        updatedBalance = 0;
        newContract = deployCreate2AndInit(salt, initCode, data, values);
    }

    function deployCreate2AndInit(
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values,
        address refundAddress
    ) public payable returns (address newContract) {
        updatedBalance = 0;
        newContract = deployCreate2AndInit(initCode, data, values, refundAddress);
    }

    function deployCreate2AndInit(
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values
    ) public payable returns (address newContract) {
        updatedBalance = 0;
        newContract = deployCreate2AndInit(initCode, data, values);
    }

    function deployCreate2Clone(
        bytes32 salt,
        address implementation,
        bytes memory data
    ) public payable returns (address proxy) {
        proxy = deployCreate2Clone(salt, implementation, data);
    }

    function deployCreate2Clone(address implementation, bytes memory data) public payable returns (address proxy) {
        proxy = deployCreate2Clone(implementation, data);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           CREATE3                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function deployCreate3(bytes32 salt, bytes memory initCode) public payable returns (address newContract) {
        newContract = deployCreate3(salt, initCode);
    }

    function deployCreate3(bytes memory initCode) public payable returns (address newContract) {
        newContract = deployCreate3(initCode);
    }

    function deployCreate3AndInit(
        bytes32 salt,
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values,
        address refundAddress
    ) public payable returns (address newContract) {
        updatedBalance = 0;
        newContract = deployCreate3AndInit(salt, initCode, data, values, refundAddress);
    }

    function deployCreate3AndInit(
        bytes32 salt,
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values
    ) public payable returns (address newContract) {
        updatedBalance = 0;
        newContract = deployCreate3AndInit(salt, initCode, data, values);
    }

    function deployCreate3AndInit(
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values,
        address refundAddress
    ) public payable returns (address newContract) {
        updatedBalance = 0;
        newContract = deployCreate3AndInit(initCode, data, values, refundAddress);
    }

    function deployCreate3AndInit(
        bytes memory initCode,
        bytes memory data,
        CreateX.Values memory values
    ) public payable returns (address newContract) {
        updatedBalance = 0;
        newContract = deployCreate3AndInit(initCode, data, values);
    }
}
