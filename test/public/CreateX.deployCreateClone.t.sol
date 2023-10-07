// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {BaseTest} from "../utils/BaseTest.sol";
import {ImplementationContract} from "../mocks/ImplementationContract.sol";
import {CreateX} from "../../src/CreateX.sol";

contract CreateX_DeployCreateClone_Public_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    ImplementationContract internal implementationContract = new ImplementationContract();
    address internal implementation = address(implementationContract);

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           EVENTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // Solidity version `0.8.21` raises an ICE (Internal Compiler Error)
    // when an event is emitted from another contract: https://github.com/ethereum/solidity/issues/14430.

    /**
     * @dev Event that is emitted when a contract is successfully created.
     * @param newContract The address of the new contract.
     */
    event ContractCreation(address indexed newContract);

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    modifier whenTheEIP1167MinimalProxyContractIsSuccessfullyCreated() {
        _;
    }

    modifier whenTheEIP1167MinimalProxyInitialisationCallIsSuccessful() {
        _;
    }

    function testFuzz_WhenTheEIP1167MinimalProxyContractIsSuccessfullyCreatedAndWhenTheEIP1167MinimalProxyInitialisationCallIsSuccessful(
        uint64 nonce,
        uint256 msgValue
    )
        external
        whenTheEIP1167MinimalProxyContractIsSuccessfullyCreated
        whenTheEIP1167MinimalProxyInitialisationCallIsSuccessful
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        msgValue = bound(msgValue, 0, type(uint64).max);
        // We calculate the address beforehand where the contract is to be deployed.
        address computedAddress = createX.computeCreateAddress(createXAddr, nonce);
        // It emits the event `ContractCreation` with the EIP-1167 minimal proxy address as indexed argument.
        // It returns the EIP-1167 minimal proxy address.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit ContractCreation(computedAddress);
        address proxy = createX.deployCreateClone{value: msgValue}(
            implementation,
            abi.encodeCall(implementationContract.initialiser, ())
        );
        assertEq(
            proxy.codehash,
            keccak256(abi.encodePacked(hex"363d3d373d3d3d363d73", implementation, hex"5af43d82803e903d91602b57fd5bf3"))
        );
        assertTrue(!implementationContract.isInitialised());
        assertTrue(ImplementationContract(proxy).isInitialised());
        assertEq(proxy.balance, msgValue);
        assertEq(implementation.balance, 0);
    }

    modifier whenTheEIP1167MinimalProxyInitialisationCallIsUnsuccessful() {
        _;
    }

    function testFuzz_WhenTheEIP1167MinimalProxyInitialisationCallIsUnsuccessful(
        uint64 nonce,
        uint256 msgValue
    )
        external
        whenTheEIP1167MinimalProxyContractIsSuccessfullyCreated
        whenTheEIP1167MinimalProxyInitialisationCallIsUnsuccessful
    {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        msgValue = bound(msgValue, 0, type(uint64).max);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedContractInitialisation.selector,
            createXAddr,
            new bytes(0)
        );
        vm.expectRevert(expectedErr);
        createX.deployCreateClone{value: msgValue}(
            makeAddr("initialAccount"),
            abi.encodeCall(implementationContract.initialiser, ())
        );
    }

    modifier whenTheEIP1167MinimalProxyContractCreationFails() {
        _;
    }

    function testFuzz_WhenTheEIP1167MinimalProxyContractCreationFails(
        uint64 nonce,
        uint256 msgValue
    ) external whenTheEIP1167MinimalProxyContractCreationFails {
        vm.assume(nonce != 0 && nonce < type(uint64).max);
        vm.setNonce(createXAddr, nonce);
        msgValue = bound(msgValue, 0, type(uint64).max);
        // We calculate the address beforehand where the contract is to be deployed.
        address computedAddress = createX.computeCreateAddress(createXAddr, nonce);
        // To enforce a deployment failure, we add code to the destination address `proxy`.
        vm.etch(computedAddress, hex"01");
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
        vm.expectRevert(expectedErr);
        createX.deployCreateClone{value: msgValue}(
            implementation,
            abi.encodeCall(implementationContract.initialiser, ())
        );
    }
}
