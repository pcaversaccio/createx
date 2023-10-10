// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import {BaseTest} from "../../utils/BaseTest.sol";
import {ImplementationContract} from "../../mocks/ImplementationContract.sol";
import {CreateX} from "../../../src/CreateX.sol";

contract CreateX_DeployCreate2Clone_3Args_Public_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    ImplementationContract internal implementationContract = new ImplementationContract();
    address internal implementation = address(implementationContract);
    bytes32 internal initCodeHash =
        keccak256(
            abi.encodePacked(
                hex"3d602d80600a3d3981f3363d3d373d3d3d363d73",
                implementation,
                hex"5af43d82803e903d91602b57fd5bf3"
            )
        );
    bytes32 internal codeHash =
        keccak256(abi.encodePacked(hex"363d3d373d3d3d363d73", implementation, hex"5af43d82803e903d91602b57fd5bf3"));

    // To avoid any stack-too-deep errors, we use an `internal` state variable for the snapshot ID.
    uint256 internal snapshotId;

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
        address originalDeployer,
        uint256 msgValue,
        bytes32 salt,
        uint64 chainId,
        address msgSender
    )
        external
        whenTheEIP1167MinimalProxyContractIsSuccessfullyCreated
        whenTheEIP1167MinimalProxyInitialisationCallIsSuccessful
    {
        msgValue = bound(msgValue, 0, type(uint64).max);
        vm.deal(originalDeployer, 2 * msgValue);
        vm.assume(
            chainId != block.chainid &&
                chainId != 0 &&
                originalDeployer != msgSender &&
                originalDeployer != createXAddr &&
                originalDeployer != implementation &&
                originalDeployer != zeroAddress &&
                msgSender != createXAddr &&
                msgSender != implementation &&
                msgSender != zeroAddress
        );
        snapshotId = vm.snapshot();

        // Helper logic to increase the probability of matching a permissioned deploy protection during fuzzing.
        if (chainId % 2 == 0) {
            salt = bytes32(abi.encodePacked(originalDeployer, bytes12(uint96(uint256(salt)))));
        }
        // Helper logic to increase the probability of matching a cross-chain redeploy protection during fuzzing.
        if (chainId % 3 == 0) {
            salt = bytes32(abi.encodePacked(bytes20(salt), hex"01", bytes11(uint88(uint256(salt)))));
        }
        (
            bool permissionedDeployProtection,
            bool xChainRedeployProtection,
            bool mustRevert,
            bytes32 guardedSalt
        ) = parseFuzzerSalt(originalDeployer, salt);

        if (mustRevert) {
            vm.startPrank(originalDeployer);
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2Clone{value: msgValue}(
                salt,
                implementation,
                abi.encodeCall(implementationContract.initialiser, ())
            );
            vm.stopPrank();
        } else {
            // We calculate the address beforehand where the contract is to be deployed.
            address computedAddress = createX.computeCreate2Address(guardedSalt, initCodeHash, createXAddr);
            vm.assume(originalDeployer != computedAddress);

            // It emits the event `ContractCreation` with the EIP-1167 minimal proxy address as indexed argument.
            // It returns the EIP-1167 minimal proxy address.
            vm.expectEmit(true, true, true, true, createXAddr);
            emit ContractCreation(computedAddress);
            vm.startPrank(originalDeployer);
            address proxy = createX.deployCreate2Clone{value: msgValue}(
                salt,
                implementation,
                abi.encodeCall(implementationContract.initialiser, ())
            );
            vm.stopPrank();

            assertEq(proxy, computedAddress);
            assertEq(proxy.codehash, codeHash);
            assertTrue(!implementationContract.isInitialised());
            assertTrue(ImplementationContract(proxy).isInitialised());
            assertEq(proxy.balance, msgValue);
            assertEq(implementation.balance, 0);

            if (permissionedDeployProtection && xChainRedeployProtection) {
                vm.chainId(chainId);
                vm.startPrank(originalDeployer);
                address newContractOriginalDeployer = createX.deployCreate2Clone{value: msgValue}(
                    salt,
                    implementation,
                    abi.encodeCall(implementationContract.initialiser, ())
                );
                vm.stopPrank();
                vm.assume(originalDeployer != newContractOriginalDeployer);

                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractOriginalDeployer, computedAddress);
                assertEq(newContractOriginalDeployer.codehash, codeHash);
                assertTrue(!implementationContract.isInitialised());
                assertTrue(ImplementationContract(newContractOriginalDeployer).isInitialised());
                assertEq(newContractOriginalDeployer.balance, msgValue);
                assertEq(implementation.balance, 0);
            } else if (permissionedDeployProtection) {
                vm.chainId(chainId);
                // We mock a potential frontrunner address.
                vm.deal(msgSender, msgValue);
                vm.startPrank(msgSender);
                address newContractMsgSender = createX.deployCreate2Clone{value: msgValue}(
                    salt,
                    implementation,
                    abi.encodeCall(implementationContract.initialiser, ())
                );
                vm.stopPrank();
                vm.assume(msgSender != newContractMsgSender);

                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractMsgSender, computedAddress);
                assertEq(newContractMsgSender.codehash, codeHash);
                assertTrue(!implementationContract.isInitialised());
                assertTrue(ImplementationContract(newContractMsgSender).isInitialised());
                assertEq(newContractMsgSender.balance, msgValue);
                assertEq(implementation.balance, 0);

                // Foundry does not create a new, clean EVM environment when the `chainId` is changed, and
                // a deployment of a contract to the same address therefore fails (see issue: https://github.com/foundry-rs/foundry/issues/6008).
                // To solve this problem, we return to the original snapshot state.
                vm.revertTo(snapshotId);
                // We mock the original caller.
                vm.startPrank(originalDeployer);
                address newContractOriginalDeployer = createX.deployCreate2Clone{value: msgValue}(
                    salt,
                    implementation,
                    abi.encodeCall(implementationContract.initialiser, ())
                );
                vm.stopPrank();
                vm.assume(originalDeployer != newContractOriginalDeployer);
                // The newly created contract on chain `chainId` must be the same as the previously created contract
                // at the `computedAddress` address.
                assertEq(newContractOriginalDeployer, computedAddress);
                assertEq(newContractOriginalDeployer.codehash, codeHash);
                assertTrue(!implementationContract.isInitialised());
                assertTrue(ImplementationContract(newContractOriginalDeployer).isInitialised());
                assertEq(newContractOriginalDeployer.balance, msgValue);
                assertEq(implementation.balance, 0);
            } else if (xChainRedeployProtection) {
                vm.chainId(chainId);
                vm.startPrank(originalDeployer);
                address newContractOriginalDeployer = createX.deployCreate2Clone{value: msgValue}(
                    salt,
                    implementation,
                    abi.encodeCall(implementationContract.initialiser, ())
                );
                vm.stopPrank();
                vm.assume(originalDeployer != newContractOriginalDeployer);

                // The newly created contract on chain `chainId` must not be the same as the previously created
                // contract at the `computedAddress` address.
                assertNotEq(newContractOriginalDeployer, computedAddress);
                assertEq(newContractOriginalDeployer.codehash, codeHash);
                assertTrue(!implementationContract.isInitialised());
                assertTrue(ImplementationContract(newContractOriginalDeployer).isInitialised());
                assertEq(newContractOriginalDeployer.balance, msgValue);
                assertEq(implementation.balance, 0);
            }
        }
    }

    modifier whenTheEIP1167MinimalProxyInitialisationCallIsUnsuccessful() {
        _;
    }

    function testFuzz_WhenTheEIP1167MinimalProxyInitialisationCallIsUnsuccessful(
        address originalDeployer,
        uint256 msgValue,
        bytes32 salt,
        uint64 chainId
    )
        external
        whenTheEIP1167MinimalProxyContractIsSuccessfullyCreated
        whenTheEIP1167MinimalProxyInitialisationCallIsUnsuccessful
    {
        msgValue = bound(msgValue, 0, type(uint64).max);
        vm.deal(originalDeployer, msgValue);
        vm.assume(
            chainId != block.chainid &&
                chainId != 0 &&
                originalDeployer != createXAddr &&
                originalDeployer != implementation &&
                originalDeployer != zeroAddress
        );
        // Helper logic to increase the probability of matching a permissioned deploy protection during fuzzing.
        if (chainId % 2 == 0) {
            salt = bytes32(abi.encodePacked(originalDeployer, bytes12(uint96(uint256(salt)))));
        }
        // Helper logic to increase the probability of matching a cross-chain redeploy protection during fuzzing.
        if (chainId % 3 == 0) {
            salt = bytes32(abi.encodePacked(bytes20(salt), hex"01", bytes11(uint88(uint256(salt)))));
        }
        (, , bool mustRevert, ) = parseFuzzerSalt(originalDeployer, salt);
        if (mustRevert) {
            vm.startPrank(originalDeployer);
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2Clone{value: msgValue}(salt, implementation, abi.encodeWithSignature("wagmi"));
            vm.stopPrank();
        } else {
            vm.startPrank(originalDeployer);
            // It should revert.
            bytes memory expectedErr = abi.encodeWithSelector(
                CreateX.FailedContractInitialisation.selector,
                createXAddr,
                new bytes(0)
            );
            vm.expectRevert(expectedErr);
            createX.deployCreate2Clone{value: msgValue}(salt, implementation, abi.encodeWithSignature("wagmi"));
            vm.stopPrank();
        }
    }

    modifier whenTheEIP1167MinimalProxyContractCreationFails() {
        _;
    }

    function testFuzz_WhenTheEIP1167MinimalProxyContractCreationFails(
        address originalDeployer,
        uint256 msgValue,
        bytes32 salt,
        uint64 chainId
    ) external whenTheEIP1167MinimalProxyContractCreationFails {
        msgValue = bound(msgValue, 0, type(uint64).max);
        vm.deal(originalDeployer, msgValue);
        vm.assume(
            chainId != block.chainid &&
                chainId != 0 &&
                originalDeployer != createXAddr &&
                originalDeployer != implementation &&
                originalDeployer != zeroAddress
        );
        // Helper logic to increase the probability of matching a permissioned deploy protection during fuzzing.
        if (chainId % 2 == 0) {
            salt = bytes32(abi.encodePacked(originalDeployer, bytes12(uint96(uint256(salt)))));
        }
        // Helper logic to increase the probability of matching a cross-chain redeploy protection during fuzzing.
        if (chainId % 3 == 0) {
            salt = bytes32(abi.encodePacked(bytes20(salt), hex"01", bytes11(uint88(uint256(salt)))));
        }
        (, , bool mustRevert, bytes32 guardedSalt) = parseFuzzerSalt(originalDeployer, salt);
        // We calculate the address beforehand where the contract is to be deployed.
        address computedAddress = createX.computeCreate2Address(guardedSalt, initCodeHash, createXAddr);
        // To enforce a deployment failure, we add code to the destination address `proxy`.
        vm.etch(computedAddress, hex"01");
        if (mustRevert) {
            vm.startPrank(originalDeployer);
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2Clone{value: msgValue}(
                salt,
                implementation,
                abi.encodeCall(implementationContract.initialiser, ())
            );
            vm.stopPrank();
        } else {
            vm.startPrank(originalDeployer);
            // It should revert.
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2Clone{value: msgValue}(
                salt,
                implementation,
                abi.encodeCall(implementationContract.initialiser, ())
            );
            vm.stopPrank();
        }
    }
}
