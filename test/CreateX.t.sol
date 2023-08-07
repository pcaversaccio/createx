// SPDX-License-Identifier: WTFPL
pragma solidity 0.8.21;

import {Test} from "forge-std/Test.sol";

import {CreateX} from "../src/CreateX.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";

contract CreateXTest is Test {
    CreateX private createX;
    address private createXAddr;

    address private zeroAddress = address(0);

    event ContractCreation(address indexed newContract);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        createX = new CreateX();
        createXAddr = address(createX);
    }

    function testDeployCreateNonPayable() public {
        string memory arg1 = "MyToken";
        string memory arg2 = "MTKN";
        address arg3 = makeAddr({name: "initialAccount"});
        uint256 arg4 = 100;
        bytes memory args = abi.encode(arg1, arg2, arg3, arg4);
        bytes memory bytecode = abi.encodePacked(vm.getCode({artifactPath: "ERC20Mock.sol:ERC20Mock"}), args);

        address computedAddress = createX.computeCreateAddress({deployer: createXAddr, nonce: 1});
        vm.expectEmit({
            checkTopic1: true,
            checkTopic2: true,
            checkTopic3: true,
            checkData: true,
            emitter: computedAddress
        });
        emit Transfer({from: zeroAddress, to: arg3, value: arg4});
        vm.expectEmit({
            checkTopic1: true,
            checkTopic2: true,
            checkTopic3: true,
            checkData: true,
            emitter: createXAddr
        });
        emit ContractCreation({newContract: computedAddress});
        createX.deployCreate({initCode: bytecode});

        assertTrue({condition: computedAddress.code.length != 0});
        assertEq({a: ERC20Mock(computedAddress).name(), b: arg1});
        assertEq({a: ERC20Mock(computedAddress).symbol(), b: arg2});
        assertEq({a: ERC20Mock(computedAddress).balanceOf({account: arg3}), b: arg4});
    }

    function testDeployCreatePayable() public {
        string memory arg1 = "MyToken";
        string memory arg2 = "MTKN";
        address arg3 = makeAddr({name: "initialAccount"});
        uint256 arg4 = 100;
        bytes memory args = abi.encode(arg1, arg2, arg3, arg4);
        bytes memory bytecode = abi.encodePacked(vm.getCode({artifactPath: "ERC20Mock.sol:ERC20Mock"}), args);

        address computedAddress = createX.computeCreateAddress({deployer: createXAddr, nonce: 1});
        vm.expectEmit({
            checkTopic1: true,
            checkTopic2: true,
            checkTopic3: true,
            checkData: true,
            emitter: computedAddress
        });
        emit Transfer({from: zeroAddress, to: arg3, value: arg4});
        vm.expectEmit({
            checkTopic1: true,
            checkTopic2: true,
            checkTopic3: true,
            checkData: true,
            emitter: createXAddr
        });
        emit ContractCreation({newContract: computedAddress});
        createX.deployCreate{value: 1 ether}({initCode: bytecode});

        assertTrue({condition: computedAddress.code.length != 0});
        assertEq({a: ERC20Mock(computedAddress).name(), b: arg1});
        assertEq({a: ERC20Mock(computedAddress).symbol(), b: arg2});
        assertEq({a: ERC20Mock(computedAddress).balanceOf({account: arg3}), b: arg4});
        assertEq({a: computedAddress.balance, b: 1 ether});
    }

    function testDeployCreateZeroBytesNonPayable() public {
        address computedAddress = createX.computeCreateAddress({deployer: createXAddr, nonce: 1});
        vm.expectEmit({
            checkTopic1: true,
            checkTopic2: true,
            checkTopic3: true,
            checkData: true,
            emitter: createXAddr
        });
        emit ContractCreation({newContract: computedAddress});
        createX.deployCreate({initCode: new bytes(0)});
        assertEq({a: computedAddress.code.length, b: 0});
    }

    /**
     * @dev If you deploy a zero-byte contract, it gets treated like an EOA
     * in the sense that it can receive Ether without having a `payable` constructor or
     * `receive`/`payable fallback` function.
     */
    function testDeployCreateZeroBytesPayable() public {
        address computedAddress = createX.computeCreateAddress({deployer: createXAddr, nonce: 1});
        vm.expectEmit({
            checkTopic1: true,
            checkTopic2: true,
            checkTopic3: true,
            checkData: true,
            emitter: createXAddr
        });
        emit ContractCreation({newContract: computedAddress});
        createX.deployCreate{value: 1 wei}({initCode: new bytes(0)});
        assertEq({a: computedAddress.code.length, b: 0});
        assertEq({a: computedAddress.balance, b: 1 wei});
    }

    function testDeployCreateRevertNonPayable() public {
        vm.expectRevert({revertData: abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr)});
        createX.deployCreate({initCode: hex"01"});
    }

    function testDeployCreateRevertPayable() public {
        vm.expectRevert({revertData: abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr)});
        createX.deployCreate{value: 1 wei}({initCode: hex"01"});
    }

    function testFuzzDeployCreateNonPayable(uint64 nonce) public {
        vm.assume({condition: nonce != 0 && nonce < type(uint64).max});
        vm.setNonce({account: createXAddr, newNonce: nonce});

        string memory arg1 = "MyToken";
        string memory arg2 = "MTKN";
        address arg3 = makeAddr({name: "initialAccount"});
        uint256 arg4 = 100;
        bytes memory args = abi.encode(arg1, arg2, arg3, arg4);
        bytes memory bytecode = abi.encodePacked(vm.getCode({artifactPath: "ERC20Mock.sol:ERC20Mock"}), args);

        address computedAddress = createX.computeCreateAddress({deployer: createXAddr, nonce: nonce});
        vm.expectEmit({
            checkTopic1: true,
            checkTopic2: true,
            checkTopic3: true,
            checkData: true,
            emitter: computedAddress
        });
        emit Transfer({from: zeroAddress, to: arg3, value: arg4});
        vm.expectEmit({
            checkTopic1: true,
            checkTopic2: true,
            checkTopic3: true,
            checkData: true,
            emitter: createXAddr
        });
        emit ContractCreation({newContract: computedAddress});
        createX.deployCreate({initCode: bytecode});

        assertTrue({condition: computedAddress.code.length != 0});
        assertEq({a: ERC20Mock(computedAddress).name(), b: arg1});
        assertEq({a: ERC20Mock(computedAddress).symbol(), b: arg2});
        assertEq({a: ERC20Mock(computedAddress).balanceOf({account: arg3}), b: arg4});
    }

    function testFuzzDeployCreatePayable(uint64 nonce, uint64 value) public {
        vm.assume({condition: nonce != 0 && nonce < type(uint64).max && value != 0});
        vm.setNonce({account: createXAddr, newNonce: nonce});
        vm.deal({account: address(this), newBalance: value});

        string memory arg1 = "MyToken";
        string memory arg2 = "MTKN";
        address arg3 = makeAddr({name: "initialAccount"});
        uint256 arg4 = 100;
        bytes memory args = abi.encode(arg1, arg2, arg3, arg4);
        bytes memory bytecode = abi.encodePacked(vm.getCode({artifactPath: "ERC20Mock.sol:ERC20Mock"}), args);

        address computedAddress = createX.computeCreateAddress({deployer: createXAddr, nonce: nonce});
        vm.expectEmit({
            checkTopic1: true,
            checkTopic2: true,
            checkTopic3: true,
            checkData: true,
            emitter: computedAddress
        });
        emit Transfer({from: zeroAddress, to: arg3, value: arg4});
        vm.expectEmit({
            checkTopic1: true,
            checkTopic2: true,
            checkTopic3: true,
            checkData: true,
            emitter: createXAddr
        });
        emit ContractCreation({newContract: computedAddress});
        createX.deployCreate{value: value}({initCode: bytecode});

        assertTrue({condition: computedAddress.code.length != 0});
        assertEq({a: ERC20Mock(computedAddress).name(), b: arg1});
        assertEq({a: ERC20Mock(computedAddress).symbol(), b: arg2});
        assertEq({a: ERC20Mock(computedAddress).balanceOf({account: arg3}), b: arg4});
        assertEq({a: computedAddress.balance, b: value});
    }
}
