// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {BaseTest} from "../utils/BaseTest.sol";

contract CreateX_DeployCreate_External_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    bytes internal cachedInitCode;
    bytes internal cachedInitCodePayable;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    modifier givenReenteringCallsAreAllowed() {
        _;
    }

    modifier whenTheInitCodeCreatesAValidRuntimeBytecode() {
        string memory arg1 = "MyToken";
        string memory arg2 = "MTKN";
        address arg3 = makeAddr({name: "initialAccount"});
        uint256 arg4 = 100;
        bytes memory args = abi.encode(arg1, arg2, arg3, arg4);
        bytes memory bytecode = abi.encodePacked(vm.getCode({artifactPath: "ERC20Mock.sol:ERC20Mock"}), args);
        bytes memory bytecodePayable = abi.encodePacked(
            vm.getCode({artifactPath: "ERC20MockPayable.sol:ERC20MockPayable"}),
            args
        );
        cachedInitCode = bytecode;
        cachedInitCodePayable = bytecodePayable;
        _;
    }

    modifier whenTheCreatedRuntimeBytecodeHasANonZeroLength() {
        _;
    }

    modifier whenTheInitCodeHasANonpayableConstructor() {
        _;
    }

    modifier whenTheCallvalueIsZero() {
        _;
    }

    function testFuzz_WhenTheCallvalueIsZeroAndHasANonpayableConstructor()
        external
        givenReenteringCallsAreAllowed
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasANonpayableConstructor
        whenTheCallvalueIsZero
    {
        // It returns a contract address with a non-zero bytecode length and a zero ether balance.
        // It emits the event ContractCreation with the contract address as indexed argument.
    }

    modifier whenTheCallvalueIsNonZero() {
        _;
    }

    function testFuzz_WhenTheCallvalueIsNonZeroAndHasANonpayableConstructor()
        external
        givenReenteringCallsAreAllowed
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasANonpayableConstructor
        whenTheCallvalueIsNonZero
    {
        // It should revert.
    }

    modifier whenTheInitCodeHasAPayableConstructor() {
        _;
    }

    function testFuzz_WhenTheCallvalueIsZeroAndHasAPayableConstructor()
        external
        givenReenteringCallsAreAllowed
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasAPayableConstructor
        whenTheCallvalueIsZero
    {
        // It returns a contract address with a non-zero bytecode length and a zero ether balance.
        // It emits the event ContractCreation with the contract address as indexed argument.
    }

    function testFuzz_WhenTheCallvalueIsNonZeroAndHasAPayableConstructor()
        external
        givenReenteringCallsAreAllowed
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasANonZeroLength
        whenTheInitCodeHasAPayableConstructor
        whenTheCallvalueIsNonZero
    {
        // It returns a contract address with a non-zero bytecode length and a potential non-zero ether balance.
        // It emits the event ContractCreation with the contract address as indexed argument.
    }

    modifier whenTheCreatedRuntimeBytecodeHasAZeroLength() {
        _;
    }

    function testFuzz_WhenTheCreatedRuntimeBytecodeHasAZeroLength()
        external
        givenReenteringCallsAreAllowed
        whenTheInitCodeCreatesAValidRuntimeBytecode
        whenTheCreatedRuntimeBytecodeHasAZeroLength
    {
        // It should revert.
    }

    modifier whenTheInitCodeCreatesAnInvalidRuntimeBytecode() {
        _;
    }

    function testFuzz_WhenTheInitCodeCreatesAnInvalidRuntimeBytecode()
        external
        givenReenteringCallsAreAllowed
        whenTheInitCodeCreatesAnInvalidRuntimeBytecode
    {
        // It should revert.
    }
}
