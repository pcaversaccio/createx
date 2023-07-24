// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

contract CreateXDeployer {
    /**
     * @dev Error that occurs when the contract creation failed.
     * @param emitter The contract that emits the error.
     */
    error FailedContractCreation(address emitter);

    /**
     * @dev Error that occurs when the contract initialisation call failed.
     * @param emitter The contract that emits the error.
     */
    error FailedContractInitialisation(address emitter);

    /**
     * @dev Error that occurs when the nonce value is invalid.
     * @param emitter The contract that emits the error.
     */
    error InvalidNonceValue(address emitter);

    /**
     * @dev Event that is emitted when a contract is successfully created.
     * @param newContract The address of the new contract.
     */
    event ContractCreation(address newContract);

    /*//////////////////////////////////////////////////////////////
                                 CREATE
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Deploys a new contract via calling the `CREATE` opcode and using
     * the creation bytecode `initCode` and `msg.value` as inputs. In order to save
     * deployment costs, we do not sanity check the `initCode` length. Note that
     * if `msg.value` is non-zero, `initCode` must have a `payable` constructor.
     * @param initCode The creation bytecode.
     * @return newContract The 20-byte address where the contract was deployed.
     */
    function deployCreate(bytes memory initCode) external payable returns (address newContract) {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            newContract := create(callvalue(), add(initCode, 0x20), mload(initCode))
        }
        if (newContract == address(0)) revert FailedContractCreation(address(this));
        emit ContractCreation(newContract);
    }

    /**
     * @dev Deploys and initialises a new contract via calling the `CREATE` opcode and
     * using the creation bytecode `initCode`, `msg.value`, and `data` as inputs. In order
     * to save deployment costs, we do not sanity check the `initCode` length. Note that
     * if `msg.value` is non-zero, `initCode` must have a `payable` constructor.
     * @param initCode The creation bytecode.
     * @param data The initialisation code that is passed to the deployed contract.
     * @return newContract The 20-byte address where the contract was deployed.
     * @custom:security This function allows for reentrancy, however we refrain from adding
     * a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol
     * level that potentially malicious reentrant calls do not affect your smart contract system.
     */
    function deployCreateAndInit(bytes memory initCode, bytes calldata data)
        external
        payable
        returns (address newContract)
    {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            newContract := create(callvalue(), add(initCode, 0x20), mload(initCode))
        }
        if (newContract == address(0)) revert FailedContractCreation(address(this));
        emit ContractCreation(newContract);

        // solhint-disable-next-line avoid-low-level-calls
        (bool success,) = newContract.call(data);
        if (!success) revert FailedContractInitialisation(address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via
     * `deployer` using the `CREATE` opcode. For the specification of the Recursive
     * Length Prefix (RLP) encoding scheme, please refer to p. 19 of the Ethereum
     * Yellow Paper (https://ethereum.github.io/yellowpaper/paper.pdf) and the Ethereum
     * Wiki (https://ethereum.org/en/developers/docs/data-structures-and-encoding/rlp/).
     * For further insights also, see the following issue: https://github.com/transmissions11/solmate/issues/207.
     *
     * Based on the EIP-161 (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-161.md)
     * specification, all contract accounts on the Ethereum mainnet are initiated with
     * `nonce = 1`. Thus, the first contract address created by another contract is calculated
     * with a non-zero nonce.
     * @param deployer The 20-byte deployer address.
     * @param nonce The next 32-byte nonce of the deployer address.
     * @return computedAddress The 20-byte address where a contract will be stored.
     */
    // prettier-ignore
    function computeCreateAddress(address deployer, uint256 nonce) public view returns (address computedAddress) {
        bytes memory data;
        bytes1 len = bytes1(0x94);

        /**
         * @dev The theoretical allowed limit, based on EIP-2681, for an account nonce is 2**64-2:
         * https://eips.ethereum.org/EIPS/eip-2681.
         */
        if (nonce > type(uint64).max - 1) revert InvalidNonceValue(address(this));

        /**
         * @dev The integer zero is treated as an empty byte string and therefore has only one
         * length prefix, 0x80, which is calculated via 0x80 + 0.
         */
        if (nonce == 0x00) {
            data = abi.encodePacked(bytes1(0xd6), len, deployer, bytes1(0x80));
        }
        /**
         * @dev A one-byte integer in the [0x00, 0x7f] range uses its own value as a length prefix,
         * there is no additional "0x80 + length" prefix that precedes it.
         */
        else if (nonce <= 0x7f) {
            data = abi.encodePacked(bytes1(0xd6), len, deployer, uint8(nonce));
        }
        /**
         * @dev In the case of `nonce > 0x7f` and `nonce <= type(uint8).max`, we have the following
         * encoding scheme (the same calculation can be carried over for higher nonce bytes):
         * 0xda = 0xc0 (short RLP prefix) + 0x1a (= the bytes length of: 0x94 + address + 0x84 + nonce, in hex),
         * 0x94 = 0x80 + 0x14 (= the bytes length of an address, 20 bytes, in hex),
         * 0x84 = 0x80 + 0x04 (= the bytes length of the nonce, 4 bytes, in hex).
         */
        else if (nonce <= type(uint8).max) {
            data = abi.encodePacked(bytes1(0xd7), len, deployer, bytes1(0x81), uint8(nonce));
        } else if (nonce <= type(uint16).max) {
            data = abi.encodePacked(bytes1(0xd8), len, deployer, bytes1(0x82), uint16(nonce));
        } else if (nonce <= type(uint24).max) {
            data = abi.encodePacked(bytes1(0xd9), len, deployer, bytes1(0x83), uint24(nonce));
        } else if (nonce <= type(uint32).max) {
            data = abi.encodePacked(bytes1(0xda), len, deployer, bytes1(0x84), uint32(nonce));
        } else if (nonce <= type(uint40).max) {
            data = abi.encodePacked(bytes1(0xdb), len, deployer, bytes1(0x85), uint40(nonce));
        } else if (nonce <= type(uint48).max) {
            data = abi.encodePacked(bytes1(0xdc), len, deployer, bytes1(0x86), uint48(nonce));
        } else if (nonce <= type(uint56).max) {
            data = abi.encodePacked(bytes1(0xdd), len, deployer, bytes1(0x87), uint56(nonce));
        } else {
            data = abi.encodePacked(bytes1(0xde), len, deployer, bytes1(0x88), uint64(nonce));
        }

        computedAddress = address(uint160(uint256(keccak256(data))));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via
     * this contract using the `CREATE` opcode. For the specification of the Recursive
     * Length Prefix (RLP) encoding scheme, please refer to p. 19 of the Ethereum
     * Yellow Paper (https://ethereum.github.io/yellowpaper/paper.pdf) and the Ethereum
     * Wiki (https://ethereum.org/en/developers/docs/data-structures-and-encoding/rlp/).
     * For further insights also, see the following issue: https://github.com/transmissions11/solmate/issues/207.
     *
     * Based on the EIP-161 (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-161.md)
     * specification, all contract accounts on the Ethereum mainnet are initiated with
     * `nonce = 1`. Thus, the first contract address created by another contract is calculated
     * with a non-zero nonce.
     * @param nonce The next 32-byte nonce of this contract.
     * @return computedAddress The 20-byte address where a contract will be stored.
     */
    // prettier-ignore
    function computeCreateAddress(uint256 nonce) public view returns (address computedAddress) {
        return computeCreateAddress(address(this), nonce);
    }
}
