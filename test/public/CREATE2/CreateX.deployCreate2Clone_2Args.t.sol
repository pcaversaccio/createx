// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTest} from "../../utils/BaseTest.sol";
import {ImplementationContract} from "../../mocks/ImplementationContract.sol";
import {CreateX} from "../../../src/CreateX.sol";

contract CreateX_DeployCreate2Clone_2Args_Public_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    ImplementationContract internal implementationContract = new ImplementationContract();
    address internal implementation = address(implementationContract);
    bytes32 internal codeHash =
        keccak256(
            abi.encodePacked(
                hex"36_3d_3d_37_3d_3d_3d_36_3d_73",
                implementation,
                hex"5a_f4_3d_82_80_3e_90_3d_91_60_2b_57_fd_5b_f3"
            )
        );

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function setUp() public override {
        BaseTest.setUp();
        initCodeHash = keccak256(
            abi.encodePacked(
                hex"3d_60_2d_80_60_0a_3d_39_81_f3_36_3d_3d_37_3d_3d_3d_36_3d_73",
                implementation,
                hex"5a_f4_3d_82_80_3e_90_3d_91_60_2b_57_fd_5b_f3"
            )
        );
    }

    modifier whenTheEIP1167MinimalProxyContractIsSuccessfullyCreated() {
        _;
    }

    modifier whenTheEIP1167MinimalProxyInitialisationCallIsSuccessful() {
        _;
    }

    function testFuzz_WhenTheEIP1167MinimalProxyContractIsSuccessfullyCreatedAndWhenTheEIP1167MinimalProxyInitialisationCallIsSuccessful(
        address originalDeployer,
        uint256 msgValue,
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

        vm.startPrank(originalDeployer);
        bytes32 salt = createXHarness.exposed_generateSalt();
        vm.stopPrank();
        (
            bool permissionedDeployProtection,
            bool xChainRedeployProtection,
            bool mustRevert,
            bytes32 guardedSalt
        ) = parseFuzzerSalt(originalDeployer, salt);
        // When we pseudo-randomly calculate the salt value `salt`, we must never have configured a permissioned
        // deploy protection or a cross-chain redeploy protection, and it must never revert.
        assertTrue(!permissionedDeployProtection && !xChainRedeployProtection && !mustRevert, "100");

        // We calculate the address beforehand where the contract is to be deployed.
        address computedAddress = createX.computeCreate2Address(guardedSalt, initCodeHash, createXAddr);
        vm.assume(originalDeployer != computedAddress);

        // It emits the event `ContractCreation` with the EIP-1167 minimal proxy address and the salt as indexed arguments.
        // It returns the EIP-1167 minimal proxy address.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit CreateX.ContractCreation(computedAddress, guardedSalt);
        vm.startPrank(originalDeployer);
        address proxy = createX.deployCreate2Clone{value: msgValue}(
            salt,
            implementation,
            abi.encodeCall(implementationContract.initialiser, ())
        );
        vm.stopPrank();

        assertEq(proxy, computedAddress, "200");
        assertEq(proxy.codehash, codeHash, "300");
        assertTrue(!implementationContract.isInitialised(), "400");
        assertTrue(ImplementationContract(proxy).isInitialised(), "500");
        assertEq(proxy.balance, msgValue, "600");
        assertEq(implementation.balance, 0, "700");

        vm.chainId(chainId);
        // We mock a potential frontrunner address.
        vm.deal(msgSender, msgValue);
        vm.startPrank(msgSender);
        address newContractMsgSender = createX.deployCreate2Clone{value: msgValue}(
            implementation,
            abi.encodeCall(implementationContract.initialiser, ())
        );
        vm.stopPrank();
        vm.assume(msgSender != newContractMsgSender);

        // The newly created contract on chain `chainId` must not be the same as the previously created
        // contract at the `computedAddress` address.
        assertNotEq(newContractMsgSender, computedAddress, "800");
        assertEq(newContractMsgSender.codehash, codeHash, "900");
        assertTrue(!implementationContract.isInitialised(), "1000");
        assertTrue(ImplementationContract(newContractMsgSender).isInitialised(), "1100");
        assertEq(newContractMsgSender.balance, msgValue, "1200");
        assertEq(implementation.balance, 0, "1300");

        // We mock the original caller.
        vm.startPrank(originalDeployer);
        address newContractOriginalDeployer = createX.deployCreate2Clone{value: msgValue}(
            implementation,
            abi.encodeCall(implementationContract.initialiser, ())
        );
        vm.stopPrank();
        vm.assume(originalDeployer != newContractOriginalDeployer);

        // The newly created contract on chain `chainId` must not be the same as the previously created
        // contract at the `computedAddress` address as well as at the `newContractMsgSender` address.
        assertNotEq(newContractOriginalDeployer, computedAddress, "1400");
        assertEq(newContractOriginalDeployer.codehash, codeHash, "1500");
        assertTrue(!implementationContract.isInitialised(), "1600");
        assertTrue(ImplementationContract(newContractOriginalDeployer).isInitialised(), "1700");
        assertEq(newContractOriginalDeployer.balance, msgValue, "1800");
        assertEq(implementation.balance, 0, "1900");
    }

    modifier whenTheEIP1167MinimalProxyInitialisationCallIsUnsuccessful() {
        _;
    }

    function testFuzz_WhenTheEIP1167MinimalProxyInitialisationCallIsUnsuccessful(
        address originalDeployer,
        uint256 msgValue,
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
        vm.startPrank(originalDeployer);
        bytes32 salt = createXHarness.exposed_generateSalt();
        vm.stopPrank();
        (bool permissionedDeployProtection, bool xChainRedeployProtection, bool mustRevert, ) = parseFuzzerSalt(
            originalDeployer,
            salt
        );
        // When we pseudo-randomly calculate the salt value `salt`, we must never have configured a permissioned
        // deploy protection or a cross-chain redeploy protection, and it must never revert.
        assertTrue(!permissionedDeployProtection && !xChainRedeployProtection && !mustRevert, "100");
        if (mustRevert) {
            vm.startPrank(originalDeployer);
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2Clone{value: msgValue}(implementation, abi.encodeWithSignature("wagmi"));
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
            createX.deployCreate2Clone{value: msgValue}(implementation, abi.encodeWithSignature("wagmi"));
            vm.stopPrank();
        }
    }

    modifier whenTheEIP1167MinimalProxyContractCreationFails() {
        _;
    }

    function testFuzz_WhenTheEIP1167MinimalProxyContractCreationFails(
        address originalDeployer,
        uint256 msgValue,
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
        vm.startPrank(originalDeployer);
        bytes32 salt = createXHarness.exposed_generateSalt();
        vm.stopPrank();
        (
            bool permissionedDeployProtection,
            bool xChainRedeployProtection,
            bool mustRevert,
            bytes32 guardedSalt
        ) = parseFuzzerSalt(originalDeployer, salt);
        // When we pseudo-randomly calculate the salt value `salt`, we must never have configured a permissioned
        // deploy protection or a cross-chain redeploy protection, and it must never revert.
        assertTrue(!permissionedDeployProtection && !xChainRedeployProtection && !mustRevert, "100");
        // We calculate the address beforehand where the contract is to be deployed.
        address computedAddress = createX.computeCreate2Address(guardedSalt, initCodeHash, createXAddr);
        // To enforce a deployment failure, we add code to the destination address `proxy`.
        vm.etch(computedAddress, hex"01");
        if (mustRevert) {
            vm.startPrank(originalDeployer);
            bytes memory expectedErr = abi.encodeWithSelector(CreateX.InvalidSalt.selector, createXAddr);
            vm.expectRevert(expectedErr);
            createX.deployCreate2Clone{value: msgValue}(
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
                implementation,
                abi.encodeCall(implementationContract.initialiser, ())
            );
            vm.stopPrank();
        }
    }
}
