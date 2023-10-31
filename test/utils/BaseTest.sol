// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {Test} from "forge-std/Test.sol";
import {CreateX} from "../../src/CreateX.sol";

/**
 * @dev Harness contract that exposes `internal` functions for testing.
 */
contract CreateXHarness is CreateX {
    function exposed_guard(bytes32 salt) external view returns (bytes32 guardedSalt) {
        guardedSalt = _guard(salt);
    }

    function exposed_parseSalt(
        bytes32 salt
    ) external view returns (SenderBytes senderBytes, RedeployProtectionFlag redeployProtectionFlag) {
        (senderBytes, redeployProtectionFlag) = _parseSalt(salt);
    }

    function exposed_efficientHash(bytes32 a, bytes32 b) external pure returns (bytes32 hash) {
        hash = _efficientHash(a, b);
    }

    function exposed_generateSalt() external view returns (bytes32 salt) {
        salt = _generateSalt();
    }

    function exposed_requireSuccessfulContractCreation(bool success, address newContract) external view {
        _requireSuccessfulContractCreation(success, newContract);
    }

    function exposed_requireSuccessfulContractCreation(address newContract) external view {
        _requireSuccessfulContractCreation(newContract);
    }

    function exposed_requireSuccessfulContractInitialisation(
        bool success,
        bytes memory returnData,
        address implementation
    ) external view {
        _requireSuccessfulContractInitialisation(success, returnData, implementation);
    }
}

/**
 * @dev Base test contract that deploys `CreateX` and `CreateXHarness`, and defines
 * events and helper methods.
 */
contract BaseTest is Test {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER VARIABLES                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    CreateX internal createX;
    address internal createXAddr;

    CreateXHarness internal createXHarness;
    address internal createXHarnessAddr;

    // solhint-disable-next-line const-name-snakecase
    address internal constant zeroAddress = address(0);
    address internal immutable SELF = address(this);

    // Constructor arguments for the `ERC20MockPayable` contract.
    string internal arg1;
    string internal arg2;
    address internal arg3;
    uint256 internal arg4;
    bytes internal args;

    // Caching and helper variables used in numerous tests.
    bytes internal cachedInitCode;
    uint256 internal cachedBalance;
    bytes32 internal initCodeHash;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * @dev Error that occurs when the contract creation code has zero-byte length.
     * @param emitter The contract that emits the error.
     */
    error ZeroByteInitCode(address emitter);

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            SETUP                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function setUp() public virtual {
        // Note that the main contract `CreateX` does `block.number - 32` when generating
        // it's own salt, so we start at block 100 here to prevent a (negative) overflow.
        vm.roll(100);

        // Deploy contracts.
        createX = new CreateX();
        createXAddr = address(createX);

        createXHarness = new CreateXHarness();
        createXHarnessAddr = address(createXHarness);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER FUNCTIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * @dev Indicates whether a permissioned deploy protection and/or a cross-chain redeploy protection
     * has been configured via `salt` or whether it must revert.
     * @param originalDeployer The 20-byte original deployer address.
     * @param salt The 32-byte random value used to create the contract address.
     * @return permissionedDeployProtection The Boolean variable that specifies whether a permissioned redeploy
     * protection has been configured.
     * @return xChainRedeployProtection The Boolean variable that specifies whether a cross-chain deploy
     * protection has been configured.
     * @return mustRevert The Boolean variable that specifies whether it must revert.
     * @return guardedSalt The guarded 32-byte random value used to create the contract address.
     */
    function parseFuzzerSalt(
        address originalDeployer,
        bytes32 salt
    )
        internal
        returns (bool permissionedDeployProtection, bool xChainRedeployProtection, bool mustRevert, bytes32 guardedSalt)
    {
        vm.startPrank(originalDeployer);
        (CreateX.SenderBytes senderBytes, CreateX.RedeployProtectionFlag redeployProtectionFlag) = createXHarness
            .exposed_parseSalt(salt);
        vm.stopPrank();

        if (
            senderBytes == CreateX.SenderBytes.MsgSender &&
            redeployProtectionFlag == CreateX.RedeployProtectionFlag.True
        ) {
            vm.startPrank(originalDeployer);
            // Configures a permissioned deploy protection as well as a cross-chain redeploy protection.
            guardedSalt = createXHarness.exposed_guard(salt);
            vm.stopPrank();
            permissionedDeployProtection = true;
            xChainRedeployProtection = true;
        } else if (
            senderBytes == CreateX.SenderBytes.MsgSender &&
            redeployProtectionFlag == CreateX.RedeployProtectionFlag.False
        ) {
            vm.startPrank(originalDeployer);
            // Configures solely a permissioned deploy protection.
            guardedSalt = createXHarness.exposed_guard(salt);
            vm.stopPrank();
            permissionedDeployProtection = true;
        } else if (senderBytes == CreateX.SenderBytes.MsgSender) {
            // Reverts if the 21st byte is greater than `0x01` in order to enforce developer explicitness.
            mustRevert = true;
        } else if (
            senderBytes == CreateX.SenderBytes.ZeroAddress &&
            redeployProtectionFlag == CreateX.RedeployProtectionFlag.True
        ) {
            vm.startPrank(originalDeployer);
            // Configures solely a cross-chain redeploy protection.
            guardedSalt = createXHarness.exposed_guard(salt);
            vm.stopPrank();
            xChainRedeployProtection = true;
        } else if (
            senderBytes == CreateX.SenderBytes.ZeroAddress &&
            redeployProtectionFlag == CreateX.RedeployProtectionFlag.Unspecified
        ) {
            // Reverts if the 21st byte is greater than `0x01` in order to enforce developer explicitness.
            mustRevert = true;
        } else {
            // In all other cases, the salt value `salt` is not modified.
            guardedSalt = salt;
        }
    }
}
