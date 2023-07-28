// SPDX-License-Identifier: WTFPL
pragma solidity 0.8.21;

import {Test} from "forge-std/Test.sol";

import {CreateXDeployer} from "../src/CreateXDeployer.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";

contract CreateXDeployerTest is Test {
    CreateXDeployer private createXDeployer;
    address private createXDeployerAddr;

    address private zeroAddress = address(0);

    event ContractCreation(address indexed newContract);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        createXDeployer = new CreateXDeployer();
        createXDeployerAddr = address(createXDeployer);
    }

    function testDeployCreateNonPayable() public {
        string memory arg1 = "MyToken";
        string memory arg2 = "MTKN";
        address arg3 = makeAddr("initialAccount");
        uint256 arg4 = 100;
        bytes memory args = abi.encode(arg1, arg2, arg3, arg4);
        bytes memory bytecode = abi.encodePacked(vm.getCode("ERC20Mock.sol:ERC20Mock"), args);

        address computedAddress = createXDeployer.computeCreateAddress(createXDeployerAddr, 1);
        vm.expectEmit(true, true, false, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        vm.expectEmit(true, false, false, false, createXDeployerAddr);
        emit ContractCreation(computedAddress);
        createXDeployer.deployCreate(bytecode);

        assertTrue(computedAddress.code.length != 0);
        assertEq(ERC20Mock(computedAddress).name(), arg1);
        assertEq(ERC20Mock(computedAddress).symbol(), arg2);
        assertEq(ERC20Mock(computedAddress).balanceOf(arg3), arg4);
    }

    function testDeployCreatePayable() public {
        string memory arg1 = "MyToken";
        string memory arg2 = "MTKN";
        address arg3 = makeAddr("initialAccount");
        uint256 arg4 = 100;
        bytes memory args = abi.encode(arg1, arg2, arg3, arg4);
        bytes memory bytecode = abi.encodePacked(vm.getCode("ERC20Mock.sol:ERC20Mock"), args);

        address computedAddress = createXDeployer.computeCreateAddress(createXDeployerAddr, 1);
        vm.expectEmit(true, true, false, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        vm.expectEmit(true, false, false, false, createXDeployerAddr);
        emit ContractCreation(computedAddress);
        createXDeployer.deployCreate{value: 1 ether}(bytecode);

        assertTrue(computedAddress.code.length != 0);
        assertEq(ERC20Mock(computedAddress).name(), arg1);
        assertEq(ERC20Mock(computedAddress).symbol(), arg2);
        assertEq(ERC20Mock(computedAddress).balanceOf(arg3), arg4);
        assertEq(computedAddress.balance, 1 ether);
    }

    function testDeployCreateZeroBytesNonPayable() public {
        address computedAddress = createXDeployer.computeCreateAddress(createXDeployerAddr, 1);
        vm.expectEmit(true, false, false, false, createXDeployerAddr);
        emit ContractCreation(computedAddress);
        createXDeployer.deployCreate(new bytes(0));
        assertEq(computedAddress.code.length, 0);
    }

    /**
     * @dev If you deploy a zero-byte contract, it gets treated like an EOA
     * in the sense that it can receive Ether without having a `payable` constructor or
     * `receive`/`payable fallback` function.
     */
    function testDeployCreateZeroBytesPayable() public {
        address computedAddress = createXDeployer.computeCreateAddress(createXDeployerAddr, 1);
        vm.expectEmit(true, false, false, false, createXDeployerAddr);
        emit ContractCreation(computedAddress);
        createXDeployer.deployCreate{value: 1 wei}(new bytes(0));
        assertEq(computedAddress.code.length, 0);
        assertEq(computedAddress.balance, 1 wei);
    }

    function testDeployCreateRevertNonPayable() public {
        vm.expectRevert(abi.encodeWithSelector(CreateXDeployer.FailedContractCreation.selector, createXDeployerAddr));
        createXDeployer.deployCreate(bytes.concat(keccak256(abi.encode("wagmi"))));
    }

    function testDeployCreateRevertPayable() public {
        vm.expectRevert(abi.encodeWithSelector(CreateXDeployer.FailedContractCreation.selector, createXDeployerAddr));
        createXDeployer.deployCreate{value: 1 wei}(bytes.concat(keccak256(abi.encode("wagmi"))));
    }

    function testFuzzDeployCreateNonPayable(uint64 nonce) public {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXDeployerAddr, nonce);

        string memory arg1 = "MyToken";
        string memory arg2 = "MTKN";
        address arg3 = makeAddr("initialAccount");
        uint256 arg4 = 100;
        bytes memory args = abi.encode(arg1, arg2, arg3, arg4);
        bytes memory bytecode = abi.encodePacked(vm.getCode("ERC20Mock.sol:ERC20Mock"), args);

        address computedAddress = createXDeployer.computeCreateAddress(createXDeployerAddr, nonce);
        vm.expectEmit(true, true, false, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        vm.expectEmit(true, false, false, false, createXDeployerAddr);
        emit ContractCreation(computedAddress);
        createXDeployer.deployCreate(bytecode);

        assertTrue(computedAddress.code.length != 0);
        assertEq(ERC20Mock(computedAddress).name(), arg1);
        assertEq(ERC20Mock(computedAddress).symbol(), arg2);
        assertEq(ERC20Mock(computedAddress).balanceOf(arg3), arg4);
    }

    function testFuzzDeployCreatePayable(uint64 nonce, uint64 value) public {
        vm.assume(nonce != 0 && nonce < type(uint64).max && value != 0);
        vm.setNonce(createXDeployerAddr, nonce);
        vm.deal(address(this), value);

        string memory arg1 = "MyToken";
        string memory arg2 = "MTKN";
        address arg3 = makeAddr("initialAccount");
        uint256 arg4 = 100;
        bytes memory args = abi.encode(arg1, arg2, arg3, arg4);
        bytes memory bytecode = abi.encodePacked(vm.getCode("ERC20Mock.sol:ERC20Mock"), args);

        address computedAddress = createXDeployer.computeCreateAddress(createXDeployerAddr, nonce);
        vm.expectEmit(true, true, false, true, computedAddress);
        emit Transfer(zeroAddress, arg3, arg4);
        vm.expectEmit(true, false, false, false, createXDeployerAddr);
        emit ContractCreation(computedAddress);
        createXDeployer.deployCreate{value: value}(bytecode);

        assertTrue(computedAddress.code.length != 0);
        assertEq(ERC20Mock(computedAddress).name(), arg1);
        assertEq(ERC20Mock(computedAddress).symbol(), arg2);
        assertEq(ERC20Mock(computedAddress).balanceOf(arg3), arg4);
        assertEq(computedAddress.balance, value);
    }
}
