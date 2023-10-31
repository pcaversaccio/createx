// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {BaseTest} from "../../utils/BaseTest.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {ERC20MockPayable} from "../../mocks/ERC20MockPayable.sol";
import {CreateX} from "../../../src/CreateX.sol";

contract CreateX_DeployCreate2AndInit_4Args_CustomiseRefundAddress_Public_Test is BaseTest {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // To avoid any stack-too-deep errors, we use `internal` state variables for the precomputed `CREATE2` address
    // and some further contract deployment addresses.
    address internal computedAddress;
    address internal newContractOriginalDeployer;
    address internal newContractMsgSender;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TESTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function setUp() public override {
        BaseTest.setUp();
        arg1 = "MyToken";
        arg2 = "MTKN";
        arg3 = makeAddr("initialAccount");
        arg4 = 100;
        args = abi.encode(arg1, arg2, arg3, arg4);
        cachedInitCode = abi.encodePacked(type(ERC20MockPayable).creationCode, args);
        initCodeHash = keccak256(cachedInitCode);
    }

    modifier whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLength() {
        if (cachedInitCode.length == 0) {
            revert ZeroByteInitCode(SELF);
        }
        _;
    }

    modifier whenTheInitialisationCallIsSuccessful() {
        _;
    }

    function testFuzz_WhenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLengthAndWhenTheInitialisationCallIsSuccessful(
        address originalDeployer,
        CreateX.Values memory values,
        uint64 chainId,
        address msgSender
    )
        external
        whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLength
        whenTheInitialisationCallIsSuccessful
    {
        values.constructorAmount = bound(values.constructorAmount, 0, type(uint64).max);
        values.initCallAmount = bound(values.initCallAmount, 0, type(uint64).max);
        vm.deal(originalDeployer, 2 * (values.constructorAmount + values.initCallAmount));
        vm.assume(
            chainId != block.chainid &&
                chainId != 0 &&
                originalDeployer != msgSender &&
                originalDeployer != createXAddr &&
                originalDeployer != zeroAddress &&
                msgSender != createXAddr &&
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
        computedAddress = createX.computeCreate2Address(guardedSalt, initCodeHash, createXAddr);
        vm.assume(originalDeployer != computedAddress);

        // We also check for the ERC-20 standard `Transfer` event.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit IERC20.Transfer(zeroAddress, arg3, arg4);
        // It returns a contract address with a non-zero bytecode length and a potential non-zero ether balance.
        // It emits the event `ContractCreation` with the contract address and the salt as indexed arguments.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit CreateX.ContractCreation(computedAddress, guardedSalt);
        vm.startPrank(originalDeployer);
        address newContract = createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
            cachedInitCode,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values,
            arg3
        );
        vm.stopPrank();

        assertEq(newContract, computedAddress, "200");
        assertNotEq(newContract, zeroAddress, "300");
        assertNotEq(newContract.code.length, 0, "400");
        assertEq(newContract.balance, values.constructorAmount + values.initCallAmount, "500");
        assertEq(createXAddr.balance, 0, "600");
        assertEq(ERC20MockPayable(computedAddress).name(), arg1, "700");
        assertEq(ERC20MockPayable(computedAddress).symbol(), arg2, "800");
        assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), 2 * arg4, "900");

        vm.chainId(chainId);
        // We mock a potential frontrunner address.
        vm.deal(msgSender, values.constructorAmount + values.initCallAmount);
        vm.startPrank(msgSender);
        newContractMsgSender = createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
            cachedInitCode,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values,
            arg3
        );
        vm.stopPrank();
        vm.assume(msgSender != newContractMsgSender);

        // The newly created contract on chain `chainId` must not be the same as the previously created
        // contract at the `computedAddress` address.
        assertNotEq(newContractMsgSender, computedAddress, "1000");
        assertNotEq(newContractMsgSender, zeroAddress, "1100");
        assertNotEq(newContractMsgSender.code.length, 0, "1200");
        assertEq(newContractMsgSender.balance, values.constructorAmount + values.initCallAmount, "1300");
        assertEq(createXAddr.balance, 0, "1400");
        assertEq(ERC20MockPayable(newContractMsgSender).name(), arg1, "1500");
        assertEq(ERC20MockPayable(newContractMsgSender).symbol(), arg2, "1600");
        assertEq(ERC20MockPayable(newContractMsgSender).balanceOf(arg3), 2 * arg4, "1700");

        // We mock the original caller.
        vm.startPrank(originalDeployer);
        newContractOriginalDeployer = createX.deployCreate2AndInit{
            value: values.constructorAmount + values.initCallAmount
        }(cachedInitCode, abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)), values, arg3);
        vm.stopPrank();
        vm.assume(originalDeployer != newContractOriginalDeployer);

        // The newly created contract on chain `chainId` must not be the same as the previously created
        // contract at the `computedAddress` address as well as at the `newContractMsgSender` address.
        assertNotEq(newContractOriginalDeployer, computedAddress, "1800");
        assertNotEq(newContractOriginalDeployer, newContractMsgSender, "1900");
        assertNotEq(newContractOriginalDeployer, zeroAddress, "2000");
        assertNotEq(newContractOriginalDeployer.code.length, 0, "2100");
        assertEq(newContractOriginalDeployer.balance, values.constructorAmount + values.initCallAmount, "2200");
        assertEq(createXAddr.balance, 0, "2300");
        assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "2400");
        assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "2500");
        assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), 2 * arg4, "2600");
    }

    modifier whenTheCreateXContractHasANonZeroBalance(uint256 amount) {
        cachedBalance = bound(amount, 1, type(uint64).max);
        vm.deal(createXAddr, cachedBalance);
        _;
    }

    modifier whenTheRefundTransactionIsSuccessful() {
        _;
    }

    function testFuzz_WhenTheCreateXContractHasANonZeroBalanceAndWhenTheRefundTransactionIsSuccessful(
        address originalDeployer,
        CreateX.Values memory values,
        uint64 chainId,
        address msgSender,
        uint256 amount
    )
        external
        whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLength
        whenTheInitialisationCallIsSuccessful
        whenTheCreateXContractHasANonZeroBalance(amount)
        whenTheRefundTransactionIsSuccessful
    {
        values.constructorAmount = bound(values.constructorAmount, 0, type(uint64).max);
        values.initCallAmount = bound(values.initCallAmount, 0, type(uint64).max);
        vm.deal(originalDeployer, 2 * (values.constructorAmount + values.initCallAmount));
        vm.assume(
            chainId != block.chainid &&
                chainId != 0 &&
                originalDeployer != msgSender &&
                originalDeployer != createXAddr &&
                originalDeployer != zeroAddress &&
                msgSender != createXAddr &&
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
        computedAddress = createX.computeCreate2Address(guardedSalt, initCodeHash, createXAddr);
        vm.assume(originalDeployer != computedAddress);

        // We also check for the ERC-20 standard `Transfer` event.
        vm.expectEmit(true, true, true, true, computedAddress);
        emit IERC20.Transfer(zeroAddress, arg3, arg4);
        // It returns a contract address with a non-zero bytecode length and a potential non-zero ether balance.
        // It emits the event `ContractCreation` with the contract address and the salt as indexed arguments.
        vm.expectEmit(true, true, true, true, createXAddr);
        emit CreateX.ContractCreation(computedAddress, guardedSalt);
        vm.startPrank(originalDeployer);
        address newContract = createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
            cachedInitCode,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values,
            arg3
        );
        vm.stopPrank();

        assertEq(newContract, computedAddress, "200");
        assertNotEq(newContract, zeroAddress, "300");
        assertNotEq(newContract.code.length, 0, "400");
        assertEq(newContract.balance, values.constructorAmount + values.initCallAmount, "500");
        assertEq(createXAddr.balance, 0, "600");
        // It returns the non-zero balance to the `refundAddress` address.
        assertEq(arg3.balance, cachedBalance, "700");
        assertEq(ERC20MockPayable(computedAddress).name(), arg1, "800");
        assertEq(ERC20MockPayable(computedAddress).symbol(), arg2, "900");
        assertEq(ERC20MockPayable(computedAddress).balanceOf(arg3), 2 * arg4, "1000");

        vm.chainId(chainId);
        // We mock a potential frontrunner address.
        vm.deal(msgSender, values.constructorAmount + values.initCallAmount);
        vm.startPrank(msgSender);
        newContractMsgSender = createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
            cachedInitCode,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values,
            arg3
        );
        vm.stopPrank();
        vm.assume(msgSender != newContractMsgSender);

        // The newly created contract on chain `chainId` must not be the same as the previously created
        // contract at the `computedAddress` address.
        assertNotEq(newContractMsgSender, computedAddress, "1000");
        assertNotEq(newContractMsgSender, zeroAddress, "1100");
        assertNotEq(newContractMsgSender.code.length, 0, "1200");
        assertEq(newContractMsgSender.balance, values.constructorAmount + values.initCallAmount, "1300");
        assertEq(createXAddr.balance, 0, "1400");
        // Since everything was returned in the previous call, the balance must be equal to the original
        // refund amount.
        assertEq(arg3.balance, cachedBalance, "1500");
        assertEq(ERC20MockPayable(newContractMsgSender).name(), arg1, "1600");
        assertEq(ERC20MockPayable(newContractMsgSender).symbol(), arg2, "1700");
        assertEq(ERC20MockPayable(newContractMsgSender).balanceOf(arg3), 2 * arg4, "1800");

        // We mock the original caller.
        vm.startPrank(originalDeployer);
        newContractOriginalDeployer = createX.deployCreate2AndInit{
            value: values.constructorAmount + values.initCallAmount
        }(cachedInitCode, abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)), values, arg3);
        vm.stopPrank();
        vm.assume(originalDeployer != newContractOriginalDeployer);
        // The newly created contract on chain `chainId` must not be the same as the previously created
        // contract at the `computedAddress` address as well as at the `newContractMsgSender` address.
        assertNotEq(newContractOriginalDeployer, computedAddress, "1900");
        assertNotEq(newContractOriginalDeployer, newContractMsgSender, "2000");
        assertNotEq(newContractOriginalDeployer, zeroAddress, "2100");
        assertNotEq(newContractOriginalDeployer.code.length, 0, "2200");
        assertEq(newContractOriginalDeployer.balance, values.constructorAmount + values.initCallAmount, "2300");
        assertEq(createXAddr.balance, 0, "2400");
        // Since everything was returned in the previous call, the balance must be equal to the original
        // refund amount.
        assertEq(arg3.balance, cachedBalance, "2500");
        assertEq(ERC20MockPayable(newContractOriginalDeployer).name(), arg1, "2600");
        assertEq(ERC20MockPayable(newContractOriginalDeployer).symbol(), arg2, "2700");
        assertEq(ERC20MockPayable(newContractOriginalDeployer).balanceOf(arg3), 2 * arg4, "2800");
    }

    modifier whenTheRefundTransactionIsUnsuccessful() {
        _;
    }

    function testFuzz_WhenTheRefundTransactionIsUnsuccessful(
        CreateX.Values memory values,
        uint256 amount
    )
        external
        whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLength
        whenTheInitialisationCallIsSuccessful
        whenTheCreateXContractHasANonZeroBalance(amount)
        whenTheRefundTransactionIsUnsuccessful
    {
        values.constructorAmount = bound(values.constructorAmount, 0, type(uint64).max);
        values.initCallAmount = bound(values.initCallAmount, 0, type(uint64).max);
        vm.deal(SELF, values.constructorAmount + values.initCallAmount);
        vm.startPrank(SELF);
        bytes32 salt = createXHarness.exposed_generateSalt();
        vm.stopPrank();
        (bool permissionedDeployProtection, bool xChainRedeployProtection, bool mustRevert, ) = parseFuzzerSalt(
            SELF,
            salt
        );
        // When we pseudo-randomly calculate the salt value `salt`, we must never have configured a permissioned
        // deploy protection or a cross-chain redeploy protection, and it must never revert.
        assertTrue(!permissionedDeployProtection && !xChainRedeployProtection && !mustRevert, "100");
        vm.startPrank(SELF);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedEtherTransfer.selector,
            createXAddr,
            new bytes(0)
        );
        vm.expectRevert(expectedErr);
        createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
            cachedInitCode,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values,
            SELF
        );
        vm.stopPrank();
    }

    modifier whenTheInitialisationCallIsUnsuccessful() {
        _;
    }

    function testFuzz_WhenTheInitialisationCallIsUnsuccessful(
        address originalDeployer,
        CreateX.Values memory values
    )
        external
        whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithANonZeroLength
        whenTheInitialisationCallIsUnsuccessful
    {
        values.constructorAmount = bound(values.constructorAmount, 0, type(uint64).max);
        values.initCallAmount = bound(values.initCallAmount, 0, type(uint64).max);
        vm.deal(originalDeployer, values.constructorAmount + values.initCallAmount);
        vm.assume(originalDeployer != createXAddr && originalDeployer != zeroAddress);
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
        vm.startPrank(originalDeployer);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(
            CreateX.FailedContractInitialisation.selector,
            createXAddr,
            new bytes(0)
        );
        vm.expectRevert(expectedErr);
        createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
            cachedInitCode,
            abi.encodeWithSignature("wagmi"),
            values,
            arg3
        );
        vm.stopPrank();
    }

    modifier whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithAZeroLength() {
        _;
    }

    function testFuzz_WhenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithAZeroLength(
        address originalDeployer,
        CreateX.Values memory values
    ) external whenTheInitCodeSuccessfullyCreatesARuntimeBytecodeWithAZeroLength {
        values.constructorAmount = bound(values.constructorAmount, 0, type(uint64).max);
        values.initCallAmount = bound(values.initCallAmount, 0, type(uint64).max);
        vm.deal(originalDeployer, values.constructorAmount + values.initCallAmount);
        vm.assume(originalDeployer != createXAddr && originalDeployer != zeroAddress);
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
        vm.startPrank(originalDeployer);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
        vm.expectRevert(expectedErr);
        createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
            new bytes(0),
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values,
            arg3
        );
        vm.stopPrank();
    }

    modifier whenTheInitCodeFailsToDeployARuntimeBytecode() {
        _;
    }

    function testFuzz_WhenTheInitCodeFailsToDeployARuntimeBytecode(
        address originalDeployer,
        CreateX.Values memory values
    ) external whenTheInitCodeFailsToDeployARuntimeBytecode {
        values.constructorAmount = bound(values.constructorAmount, 0, type(uint64).max);
        values.initCallAmount = bound(values.initCallAmount, 0, type(uint64).max);
        vm.deal(originalDeployer, values.constructorAmount + values.initCallAmount);
        vm.assume(originalDeployer != createXAddr && originalDeployer != zeroAddress);
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
        // The following contract creation code contains the invalid opcode `PUSH0` (`0x5F`) and `CREATE` must therefore
        // return the zero address (technically zero bytes `0x`), as the deployment fails. This test also ensures that if
        // we ever accidentally change the EVM version in Foundry and Hardhat, we will always have a corresponding failed test.
        bytes memory invalidInitCode = hex"5f_80_60_09_3d_39_3d_f3";
        vm.startPrank(originalDeployer);
        // It should revert.
        bytes memory expectedErr = abi.encodeWithSelector(CreateX.FailedContractCreation.selector, createXAddr);
        vm.expectRevert(expectedErr);
        createX.deployCreate2AndInit{value: values.constructorAmount + values.initCallAmount}(
            invalidInitCode,
            abi.encodeCall(ERC20MockPayable.mint, (arg3, arg4)),
            values,
            arg3
        );
        vm.stopPrank();
    }
}
