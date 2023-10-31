// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTest} from "../../utils/BaseTest.sol";
import {ImplementationContract} from "../../mocks/ImplementationContract.sol";
import {CreateX} from "../../../src/CreateX.sol";

contract CreateX_DeployCreateClone_Public_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    ImplementationContract internal implementationContract = new ImplementationContract();
    address internal implementation = address(implementationContract);

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
        emit CreateX.ContractCreation(computedAddress);
        address proxy = createX.deployCreateClone{value: msgValue}(
            implementation,
            abi.encodeCall(implementationContract.initialiser, ())
        );
        assertEq(proxy, computedAddress, "100");
        assertEq(
            proxy.codehash,
            keccak256(
                abi.encodePacked(
                    hex"36_3d_3d_37_3d_3d_3d_36_3d_73",
                    implementation,
                    hex"5a_f4_3d_82_80_3e_90_3d_91_60_2b_57_fd_5b_f3"
                )
            ),
            "200"
        );
        assertTrue(!implementationContract.isInitialised(), "300");
        assertTrue(ImplementationContract(proxy).isInitialised(), "400");
        assertEq(proxy.balance, msgValue, "500");
        assertEq(implementation.balance, 0, "600");
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
