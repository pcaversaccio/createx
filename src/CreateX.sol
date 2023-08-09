// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

/**
 * @title CreateX Factory Smart Contract
 * @author pcaversaccio (https://pcaversaccio.com)
 * @custom:coauthor Matt Solomon (https://mattsolomon.dev)
 * @dev Factory smart contract to make easier and safer usage of the
 * `CREATE` (https://www.evm.codes/#f0?fork=shanghai) and `CREATE2`
 * (https://www.evm.codes/#f5?fork=shanghai) EVM opcodes as well as of
 * `CREATE3`-based (https://github.com/ethereum/EIPs/pull/3171) contract creations.
 * @custom:security-contact See https://github.com/pcaversaccio/createx/security/policy.
 */
contract CreateX {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                            TYPES                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * @dev Struct for the `payable` amounts in a deploy-and-initialise call.
     */
    struct Values {
        uint256 constructorAmount;
        uint256 initCallAmount;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           EVENTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * @dev Event that is emitted when a contract is successfully created.
     * @param newContract The address of the new contract.
     */
    event ContractCreation(address indexed newContract);

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                        CUSTOM ERRORS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

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
     * @dev Error that occurs when transferring ether has failed.
     * @param emitter The contract that emits the error.
     */
    error FailedEtherTransfer(address emitter);

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          MODIFIERS                         */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * @dev Modifier that implements different safeguarding mechanisms depending on the encoded
     * values in the salt (`||` stands for byte-wise concatenation):
     * => salt (32 bytes) = 0xbebebebebebebebebebebebebebebebebebebebe||ff||1212121212121212121212
     * - The first 20 bytes (i.e. `bebebebebebebebebebebebebebebebebebebebe`) may be used to
     *   implement a permissioned deploy protection by setting them equal to `msg.sender`,
     * - The 21st byte (i.e. `ff`) may be used to implement a cross-chain redeploy protection by
     *   setting it equal to `0x01`,
     * - The last random 11 bytes (i.e. `1212121212121212121212`) allow for 2**88 bits of entropy
     *   for mining a salt.
     * @param salt The 32-byte random value used to create the contract address.
     */
    modifier guard(bytes32 salt) {
        if (address(bytes20(salt)) == msg.sender && bytes1(bytes16(uint128(uint256(salt)))) == hex"01") {
            /**
             * @dev Configures a permissioned deploy protection as well as a cross-chain redeploy protection.
             */
            salt = keccak256(abi.encode(msg.sender, salt, block.chainid));
        } else if (address(bytes20(salt)) == msg.sender && bytes1(bytes16(uint128(uint256(salt)))) == hex"00") {
            /**
             * @dev Configures solely a permissioned deploy protection.
             */
            salt = _efficientHash({a: bytes32(bytes20(uint160(msg.sender))), b: salt});
        } else if (address(bytes20(salt)) == address(0) && bytes1(bytes16(uint128(uint256(salt)))) == hex"01") {
            /**
             * @dev Configures solely a cross-chain redeploy protection. In order to prevent a pseudo-randomly
             * generated cross-chain redeploy protection, we enforce the zero address check for the first 20 bytes.
             */
            salt = _efficientHash({a: salt, b: bytes32(block.chainid)});
        }
        _;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           CREATE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * @dev Deploys a new contract via calling the `CREATE` opcode and using the creation
     * bytecode `initCode` and `msg.value` as inputs. In order to save deployment costs,
     * we do not sanity check the `initCode` length. Note that if `msg.value` is non-zero,
     * `initCode` must have a `payable` constructor.
     * @param initCode The creation bytecode.
     * @return newContract The 20-byte address where the contract was deployed.
     */
    function deployCreate(bytes memory initCode) public payable returns (address newContract) {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            newContract := create(callvalue(), add(initCode, 0x20), mload(initCode))
        }
        /**
         * @dev We ensure that `newContract` is a non-zero byte contract.
         */
        if (newContract == address(0) || newContract.code.length == 0)
            revert FailedContractCreation({emitter: address(this)});
        emit ContractCreation({newContract: newContract});
    }

    /**
     * @dev Deploys and initialises a new contract via calling the `CREATE` opcode and using the
     * creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable`
     * amounts `values`, the refund address `refundAddress`, and `msg.value` as inputs. In order to
     * save deployment costs, we do not sanity check the `initCode` length. Note that if `values.constructorAmount`
     * is non-zero, `initCode` must have a `payable` constructor.
     * @param initCode The creation bytecode.
     * @param data The initialisation code that is passed to the deployed contract.
     * @param values The specific `payable` amounts for the deployment and initialisation call.
     * @param refundAddress The 20-byte address where any excess ether is returned to.
     * @return newContract The 20-byte address where the contract was deployed.
     * @custom:security This function allows for reentrancy, however we refrain from adding
     * a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol
     * level that potentially malicious reentrant calls do not affect your smart contract system.
     */
    function deployCreateAndInit(
        bytes memory initCode,
        bytes memory data,
        Values memory values,
        address refundAddress
    ) public payable returns (address newContract) {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            newContract := create(mload(values), add(initCode, 0x20), mload(initCode))
        }
        /**
         * @dev We ensure that `newContract` is a non-zero byte contract.
         */
        if (newContract == address(0) || newContract.code.length == 0)
            revert FailedContractCreation({emitter: address(this)});
        emit ContractCreation({newContract: newContract});

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = newContract.call{value: values.initCallAmount}(data);
        if (!success) revert FailedContractInitialisation({emitter: address(this)});

        uint256 balance = address(this).balance;
        if (balance != 0) {
            /**
             * @dev Any wei amount previously forced into this contract (e.g. by
             * using the `SELFDESTRUCT` opcode) will be part of the refund transaction.
             */
            // solhint-disable-next-line avoid-low-level-calls
            (bool refunded, ) = refundAddress.call{value: balance}("");
            if (!refunded) revert FailedEtherTransfer({emitter: address(this)});
        }
    }

    /**
     * @dev Deploys and initialises a new contract via calling the `CREATE` opcode and using the
     * creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable`
     * amounts `values`, and `msg.value` as inputs. In order to save deployment costs, we do not
     * sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero,
     * `initCode` must have a `payable` constructor, and any excess ether is returned to `msg.sender`.
     * @param initCode The creation bytecode.
     * @param data The initialisation code that is passed to the deployed contract.
     * @param values The specific `payable` amounts for the deployment and initialisation call.
     * @return newContract The 20-byte address where the contract was deployed.
     * @custom:security This function allows for reentrancy, however we refrain from adding
     * a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol
     * level that potentially malicious reentrant calls do not affect your smart contract system.
     */
    function deployCreateAndInit(
        bytes memory initCode,
        bytes memory data,
        Values memory values
    ) public payable returns (address newContract) {
        newContract = deployCreateAndInit({initCode: initCode, data: data, values: values, refundAddress: msg.sender});
    }

    /**
     * @dev Deploys a new EIP-1167 minimal proxy contract using the `CREATE` opcode, and initialises
     * the implementation contract using the implementation address `implementation`, the initialisation
     * code `data`, and `msg.value` as inputs. Note that if `msg.value` is non-zero, the initialiser
     * function called via `data` must be `payable`.
     * @param implementation The 20-byte implementation contract address.
     * @param data The initialisation code that is passed to the deployed proxy contract.
     * @return proxy The 20-byte address where the clone was deployed.
     * @custom:security This function allows for reentrancy, however we refrain from adding
     * a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol
     * level that potentially malicious reentrant calls do not affect your smart contract system.
     */
    function deployCreateClone(address implementation, bytes memory data) public payable returns (address proxy) {
        bytes20 implementationInBytes = bytes20(implementation);
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            let clone := mload(0x40)
            mstore(clone, hex"3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000")
            mstore(add(clone, 0x14), implementationInBytes)
            mstore(add(clone, 0x28), hex"5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000")
            proxy := create(0, clone, 0x37)
        }
        if (proxy == address(0)) revert FailedContractCreation({emitter: address(this)});
        emit ContractCreation({newContract: proxy});

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = proxy.call{value: msg.value}(data);
        /**
         * @dev We ensure that `implementation` is a non-zero byte contract.
         */
        if (!success || implementation.code.length == 0) revert FailedContractInitialisation({emitter: address(this)});
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via `deployer` using
     * the `CREATE` opcode. For the specification of the Recursive Length Prefix (RLP) encoding
     * scheme, please refer to p. 19 of the Ethereum Yellow Paper (https://ethereum.github.io/yellowpaper/paper.pdf)
     * and the Ethereum Wiki (https://ethereum.org/en/developers/docs/data-structures-and-encoding/rlp/).
     * For further insights also, see the following issue: https://github.com/transmissions11/solmate/issues/207.
     *
     * Based on the EIP-161 (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-161.md) specification,
     * all contract accounts on the Ethereum mainnet are initiated with `nonce = 1`. Thus, the
     * first contract address created by another contract is calculated with a non-zero nonce.
     * @param deployer The 20-byte deployer address.
     * @param nonce The next 32-byte nonce of the deployer address.
     * @return computedAddress The 20-byte address where a contract will be stored.
     */
    function computeCreateAddress(address deployer, uint256 nonce) public view returns (address computedAddress) {
        bytes memory data;
        bytes1 len = bytes1(0x94);

        /**
         * @dev The theoretical allowed limit, based on EIP-2681, for an account nonce is 2**64-2:
         * https://eips.ethereum.org/EIPS/eip-2681.
         */
        if (nonce > type(uint64).max - 1) revert InvalidNonceValue({emitter: address(this)});

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
     * @dev Returns the address where a contract will be stored if deployed via this contract
     * using the `CREATE` opcode. For the specification of the Recursive Length Prefix (RLP)
     * encoding scheme, please refer to p. 19 of the Ethereum Yellow Paper (https://ethereum.github.io/yellowpaper/paper.pdf)
     * and the Ethereum Wiki (https://ethereum.org/en/developers/docs/data-structures-and-encoding/rlp/).
     * For further insights also, see the following issue: https://github.com/transmissions11/solmate/issues/207.
     *
     * Based on the EIP-161 (https://github.com/ethereum/EIPs/blob/master/EIPS/eip-161.md) specification,
     * all contract accounts on the Ethereum mainnet are initiated with `nonce = 1`. Thus, the
     * first contract address created by another contract is calculated with a non-zero nonce.
     * @param nonce The next 32-byte nonce of this contract.
     * @return computedAddress The 20-byte address where a contract will be stored.
     */
    function computeCreateAddress(uint256 nonce) public view returns (address computedAddress) {
        computedAddress = computeCreateAddress({deployer: address(this), nonce: nonce});
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           CREATE2                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * @dev Deploys a new contract via calling the `CREATE2` opcode and using the salt value `salt`,
     * the creation bytecode `initCode`, and `msg.value` as inputs. In order to save deployment costs,
     * we do not sanity check the `initCode` length. Note that if `msg.value` is non-zero, `initCode`
     * must have a `payable` constructor.
     * @param salt The 32-byte random value used to create the contract address.
     * @param initCode The creation bytecode.
     * @return newContract The 20-byte address where the contract was deployed.
     */
    function deployCreate2(
        bytes32 salt,
        bytes memory initCode
    ) public payable guard(salt) returns (address newContract) {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            newContract := create2(callvalue(), add(initCode, 0x20), mload(initCode), salt)
        }
        /**
         * @dev We ensure that `newContract` is a non-zero byte contract.
         */
        if (newContract == address(0) || newContract.code.length == 0)
            revert FailedContractCreation({emitter: address(this)});
        emit ContractCreation({newContract: newContract});
    }

    /**
     * @dev Deploys a new contract via calling the `CREATE2` opcode and using the creation bytecode
     * `initCode` and `msg.value` as inputs. The salt value is calculated pseudo-randomly using a
     * diverse selection of block and transaction properties. This approach does not guarantee true
     * randomness! In order to save deployment costs, we do not sanity check the `initCode` length.
     * Note that if `msg.value` is non-zero, `initCode` must have a `payable` constructor.
     * @param initCode The creation bytecode.
     * @return newContract The 20-byte address where the contract was deployed.
     */
    function deployCreate2(bytes memory initCode) public payable returns (address newContract) {
        /**
         * @dev Note that the modifier `guard` is called as part of the overloaded function `deployCreate2`.
         */
        newContract = deployCreate2({salt: _generateSalt(), initCode: initCode});
    }

    /**
     * @dev Deploys and initialises a new contract via calling the `CREATE2` opcode and using the
     * salt value `salt`, the creation bytecode `initCode`, the initialisation code `data`, the struct
     * for the `payable` amounts `values`, the refund address `refundAddress`, and `msg.value` as inputs.
     * In order to save deployment costs, we do not sanity check the `initCode` length. Note that if
     * `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor.
     * @param salt The 32-byte random value used to create the contract address.
     * @param initCode The creation bytecode.
     * @param data The initialisation code that is passed to the deployed contract.
     * @param values The specific `payable` amounts for the deployment and initialisation call.
     * @param refundAddress The 20-byte address where any excess ether is returned to.
     * @return newContract The 20-byte address where the contract was deployed.
     * @custom:security This function allows for reentrancy, however we refrain from adding
     * a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol
     * level that potentially malicious reentrant calls do not affect your smart contract system.
     */
    function deployCreate2AndInit(
        bytes32 salt,
        bytes memory initCode,
        bytes memory data,
        Values memory values,
        address refundAddress
    ) public payable guard(salt) returns (address newContract) {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            newContract := create2(mload(values), add(initCode, 0x20), mload(initCode), salt)
        }
        /**
         * @dev We ensure that `newContract` is a non-zero byte contract.
         */
        if (newContract == address(0) || newContract.code.length == 0)
            revert FailedContractCreation({emitter: address(this)});
        emit ContractCreation({newContract: newContract});

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = newContract.call{value: values.initCallAmount}(data);
        if (!success) revert FailedContractInitialisation({emitter: address(this)});

        uint256 balance = address(this).balance;
        if (balance != 0) {
            /**
             * @dev Any wei amount previously forced into this contract (e.g. by
             * using the `SELFDESTRUCT` opcode) will be part of the refund transaction.
             */
            // solhint-disable-next-line avoid-low-level-calls
            (bool refunded, ) = refundAddress.call{value: balance}("");
            if (!refunded) revert FailedEtherTransfer({emitter: address(this)});
        }
    }

    /**
     * @dev Deploys and initialises a new contract via calling the `CREATE2` opcode and using the
     * salt value `salt`, creation bytecode `initCode`, the initialisation code `data`, the struct for
     * the `payable` amounts `values`, and `msg.value` as inputs. In order to save deployment costs,
     * we do not sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero,
     * `initCode` must have a `payable` constructor, and any excess ether is returned to `msg.sender`.
     * @param salt The 32-byte random value used to create the contract address.
     * @param initCode The creation bytecode.
     * @param data The initialisation code that is passed to the deployed contract.
     * @param values The specific `payable` amounts for the deployment and initialisation call.
     * @return newContract The 20-byte address where the contract was deployed.
     * @custom:security This function allows for reentrancy, however we refrain from adding
     * a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol
     * level that potentially malicious reentrant calls do not affect your smart contract system.
     */
    function deployCreate2AndInit(
        bytes32 salt,
        bytes memory initCode,
        bytes memory data,
        Values memory values
    ) public payable returns (address newContract) {
        /**
         * @dev Note that the modifier `guard` is called as part of the overloaded function `deployCreate2AndInit`.
         */
        newContract = deployCreate2AndInit({
            salt: salt,
            initCode: initCode,
            data: data,
            values: values,
            refundAddress: msg.sender
        });
    }

    /**
     * @dev Deploys and initialises a new contract via calling the `CREATE2` opcode and using the
     * creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable`
     * amounts `values`, the refund address `refundAddress`, and `msg.value` as inputs. The salt value
     * is calculated pseudo-randomly using a diverse selection of block and transaction properties.
     * This approach does not guarantee true randomness! In order to save deployment costs, we do not
     * sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero, `initCode`
     * must have a `payable` constructor.
     * @param initCode The creation bytecode.
     * @param data The initialisation code that is passed to the deployed contract.
     * @param values The specific `payable` amounts for the deployment and initialisation call.
     * @param refundAddress The 20-byte address where any excess ether is returned to.
     * @return newContract The 20-byte address where the contract was deployed.
     * @custom:security This function allows for reentrancy, however we refrain from adding
     * a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol
     * level that potentially malicious reentrant calls do not affect your smart contract system.
     */
    function deployCreate2AndInit(
        bytes memory initCode,
        bytes memory data,
        Values memory values,
        address refundAddress
    ) public payable returns (address newContract) {
        /**
         * @dev Note that the modifier `guard` is called as part of the overloaded function `deployCreate2AndInit`.
         */
        newContract = deployCreate2AndInit({
            salt: _generateSalt(),
            initCode: initCode,
            data: data,
            values: values,
            refundAddress: refundAddress
        });
    }

    /**
     * @dev Deploys and initialises a new contract via calling the `CREATE2` opcode and using the
     * creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable` amounts
     * `values`, and `msg.value` as inputs. The salt value is calculated pseudo-randomly using a
     * diverse selection of block and transaction properties. This approach does not guarantee true
     * randomness! In order to save deployment costs, we do not sanity check the `initCode` length.
     * Note that if `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor,
     * and any excess ether is returned to `msg.sender`.
     * @param initCode The creation bytecode.
     * @param data The initialisation code that is passed to the deployed contract.
     * @param values The specific `payable` amounts for the deployment and initialisation call.
     * @return newContract The 20-byte address where the contract was deployed.
     * @custom:security This function allows for reentrancy, however we refrain from adding
     * a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol
     * level that potentially malicious reentrant calls do not affect your smart contract system.
     */
    function deployCreate2AndInit(
        bytes memory initCode,
        bytes memory data,
        Values memory values
    ) public payable returns (address newContract) {
        /**
         * @dev Note that the modifier `guard` is called as part of the overloaded function `deployCreate2AndInit`.
         */
        newContract = deployCreate2AndInit({
            salt: _generateSalt(),
            initCode: initCode,
            data: data,
            values: values,
            refundAddress: msg.sender
        });
    }

    /**
     * @dev Deploys a new EIP-1167 minimal proxy contract using the `CREATE2` opcode and the salt
     * value `salt`, and initialises the implementation contract using the implementation address
     * `implementation`, the initialisation code `data`, and `msg.value` as inputs. Note that if
     * `msg.value` is non-zero, the initialiser function called via `data` must be `payable`.
     * @param salt The 32-byte random value used to create the proxy contract address.
     * @param implementation The 20-byte implementation contract address.
     * @param data The initialisation code that is passed to the deployed proxy contract.
     * @return proxy The 20-byte address where the clone was deployed.
     * @custom:security This function allows for reentrancy, however we refrain from adding
     * a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol
     * level that potentially malicious reentrant calls do not affect your smart contract system.
     */
    function deployCreate2Clone(
        bytes32 salt,
        address implementation,
        bytes memory data
    ) public payable returns (address proxy) {
        bytes20 implementationInBytes = bytes20(implementation);
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            let clone := mload(0x40)
            mstore(clone, hex"3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000")
            mstore(add(clone, 0x14), implementationInBytes)
            mstore(add(clone, 0x28), hex"5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000")
            proxy := create2(0, clone, 0x37, salt)
        }
        if (proxy == address(0)) revert FailedContractCreation({emitter: address(this)});
        emit ContractCreation({newContract: proxy});

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, ) = proxy.call{value: msg.value}(data);
        /**
         * @dev We ensure that `implementation` is a non-zero byte contract.
         */
        if (!success || implementation.code.length == 0) revert FailedContractInitialisation({emitter: address(this)});
    }

    /**
     * @dev Deploys a new EIP-1167 minimal proxy contract using the `CREATE2` opcode and the salt
     * value `salt`, and initialises the implementation contract using the implementation address
     * `implementation`, the initialisation code `data`, and `msg.value` as inputs. The salt value is
     * calculated pseudo-randomly using a diverse selection of block and transaction properties. This
     * approach does not guarantee true randomness! Note that if `msg.value` is non-zero, the initialiser
     * function called via `data` must be `payable`.
     * @param implementation The 20-byte implementation contract address.
     * @param data The initialisation code that is passed to the deployed proxy contract.
     * @return proxy The 20-byte address where the clone was deployed.
     * @custom:security This function allows for reentrancy, however we refrain from adding
     * a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol
     * level that potentially malicious reentrant calls do not affect your smart contract system.
     */
    function deployCreate2Clone(address implementation, bytes memory data) public payable returns (address proxy) {
        proxy = deployCreate2Clone({salt: _generateSalt(), implementation: implementation, data: data});
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via `deployer` using
     * the `CREATE2` opcode. Any change in the `initCodeHash` or `salt` values will result in a new
     * destination address. This implementation is based on OpenZeppelin:
     * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Create2.sol.
     * @param salt The 32-byte random value used to create the contract address.
     * @param initCodeHash The 32-byte bytecode digest of the contract creation bytecode.
     * @param deployer The 20-byte deployer address.
     * @return computedAddress The 20-byte address where a contract will be stored.
     */
    function computeCreate2Address(
        bytes32 salt,
        bytes32 initCodeHash,
        address deployer
    ) public pure returns (address computedAddress) {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x40), initCodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer)
            let start := add(ptr, 0x0b)
            computedAddress := keccak256(start, 85)
        }
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via this contract using
     * the `CREATE2` opcode. Any change in the `initCodeHash` or `salt` values will result in a new
     * destination address.
     * @param salt The 32-byte random value used to create the contract address.
     * @param initCodeHash The 32-byte bytecode digest of the contract creation bytecode.
     * @return computedAddress The 20-byte address where a contract will be stored.
     */
    function computeCreate2Address(bytes32 salt, bytes32 initCodeHash) public view returns (address computedAddress) {
        computedAddress = computeCreate2Address({salt: salt, initCodeHash: initCodeHash, deployer: address(this)});
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           CREATE3                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * @dev Deploys a new contract via employing the `CREATE3` pattern (i.e. without an initcode
     * factor) and using the salt value `salt`, the creation bytecode `initCode`, and `msg.value`
     * as inputs. In order to save deployment costs, we do not sanity check the `initCode` length.
     * Note that if `msg.value` is non-zero, `initCode` must have a `payable` constructor. This
     * implementation is based on Solmate:
     * https://github.com/transmissions11/solmate/blob/v7/src/utils/CREATE3.sol.
     * @param salt The 32-byte random value used to create the contract address.
     * @param initCode The creation bytecode.
     * @return newContract The 20-byte address where the contract was deployed.
     * @custom:security We strongly recommend implementing a permissioned deploy protection by setting
     * the first 20 bytes equal to `msg.sender` in the `salt` to prevent maliciously intended frontrun
     * proxy deployments on other chains.
     */
    function deployCreate3(
        bytes32 salt,
        bytes memory initCode
    ) public payable guard(salt) returns (address newContract) {
        bytes memory proxyChildBytecode = hex"67363d3d37363d34f03d5260086018f3";
        address proxy;
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            proxy := create2(0, add(proxyChildBytecode, 32), mload(proxyChildBytecode), salt)
        }
        if (proxy == address(0)) revert FailedContractCreation({emitter: address(this)});
        emit ContractCreation({newContract: proxy});

        newContract = computeCreate3Address({salt: salt});
        (bool success, ) = proxy.call{value: msg.value}(initCode);
        /**
         * @dev We ensure that `newContract` is a non-zero byte contract.
         */
        if (!success || newContract.code.length == 0) revert FailedContractCreation({emitter: address(this)});
        emit ContractCreation({newContract: newContract});
    }

    /**
     * @dev Deploys a new contract via employing the `CREATE3` pattern (i.e. without an initcode
     * factor) and using the salt value `salt`, the creation bytecode `initCode`, and `msg.value`
     * as inputs. The salt value is calculated pseudo-randomly using a diverse selection of block
     * and transaction properties. This approach does not guarantee true randomness! In order to save
     * deployment costs, we do not sanity check the `initCode` length. Note that if `msg.value` is
     * non-zero, `initCode` must have a `payable` constructor. This implementation is based on Solmate:
     * https://github.com/transmissions11/solmate/blob/v7/src/utils/CREATE3.sol.
     * @param initCode The creation bytecode.
     * @return newContract The 20-byte address where the contract was deployed.
     * @custom:security This function does not implement any permissioned deploy protection, thus
     * anyone can frontrun the same proxy deployment on other chains. Use with caution!
     */
    function deployCreate3(bytes memory initCode) public payable returns (address newContract) {
        /**
         * @dev Note that the modifier `guard` is called as part of the overloaded function `deployCreate3`.
         */
        newContract = deployCreate3({salt: _generateSalt(), initCode: initCode});
    }

    /**
     * @dev Deploys and initialises a new contract via employing the `CREATE3` pattern (i.e. without
     * an initcode factor) and using the salt value `salt`, the creation bytecode `initCode`, the
     * initialisation code `data`, the struct for the `payable` amounts `values`, the refund address
     * `refundAddress`, and `msg.value` as inputs. In order to save deployment costs, we do not sanity
     * check the `initCode` length. Note that if `values.constructorAmount` is non-zero, `initCode` must
     * have a `payable` constructor. This implementation is based on Solmate:
     * https://github.com/transmissions11/solmate/blob/v7/src/utils/CREATE3.sol.
     * @param salt The 32-byte random value used to create the contract address.
     * @param initCode The creation bytecode.
     * @param data The initialisation code that is passed to the deployed contract.
     * @param values The specific `payable` amounts for the deployment and initialisation call.
     * @param refundAddress The 20-byte address where any excess ether is returned to.
     * @return newContract The 20-byte address where the contract was deployed.
     * @custom:security This function allows for reentrancy, however we refrain from adding
     * a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol
     * level that potentially malicious reentrant calls do not affect your smart contract system.
     * Furthermore, we strongly recommend implementing a permissioned deploy protection by setting
     * the first 20 bytes equal to `msg.sender` in the `salt` to prevent maliciously intended frontrun
     * proxy deployments on other chains.
     */
    function deployCreate3AndInit(
        bytes32 salt,
        bytes memory initCode,
        bytes memory data,
        Values memory values,
        address refundAddress
    ) public payable guard(salt) returns (address newContract) {
        bytes memory proxyChildBytecode = hex"67363d3d37363d34f03d5260086018f3";
        address proxy;
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            proxy := create2(0, add(proxyChildBytecode, 32), mload(proxyChildBytecode), salt)
        }
        if (proxy == address(0)) revert FailedContractCreation({emitter: address(this)});
        emit ContractCreation({newContract: proxy});

        newContract = computeCreate3Address({salt: salt});
        (bool success, ) = proxy.call{value: values.constructorAmount}(initCode);
        /**
         * @dev We ensure that `newContract` is a non-zero byte contract.
         */
        if (!success || newContract.code.length == 0) revert FailedContractCreation({emitter: address(this)});
        emit ContractCreation({newContract: newContract});

        // solhint-disable-next-line avoid-low-level-calls
        (success, ) = newContract.call{value: values.initCallAmount}(data);
        if (!success) revert FailedContractInitialisation({emitter: address(this)});

        uint256 balance = address(this).balance;
        if (balance != 0) {
            /**
             * @dev Any wei amount previously forced into this contract (e.g. by
             * using the `SELFDESTRUCT` opcode) will be part of the refund transaction.
             */
            // solhint-disable-next-line avoid-low-level-calls
            (bool refunded, ) = refundAddress.call{value: balance}("");
            if (!refunded) revert FailedEtherTransfer({emitter: address(this)});
        }
    }

    /**
     * @dev Deploys and initialises a new contract via employing the `CREATE3` pattern (i.e. without
     * an initcode factor) and using the salt value `salt`, the creation bytecode `initCode`, the
     * initialisation code `data`, the struct for the `payable` amounts `values`, and `msg.value` as
     * inputs. In order to save deployment costs, we do not sanity check the `initCode` length. Note
     * that if `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor,
     * and any excess ether is returned to `msg.sender`. This implementation is based on Solmate:
     * https://github.com/transmissions11/solmate/blob/v7/src/utils/CREATE3.sol.
     * @param salt The 32-byte random value used to create the contract address.
     * @param initCode The creation bytecode.
     * @param data The initialisation code that is passed to the deployed contract.
     * @param values The specific `payable` amounts for the deployment and initialisation call.
     * @return newContract The 20-byte address where the contract was deployed.
     * @custom:security This function allows for reentrancy, however we refrain from adding
     * a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol
     * level that potentially malicious reentrant calls do not affect your smart contract system.
     * Furthermore, we strongly recommend implementing a permissioned deploy protection by setting
     * the first 20 bytes equal to `msg.sender` in the `salt` to prevent maliciously intended frontrun
     * proxy deployments on other chains.
     */
    function deployCreate3AndInit(
        bytes32 salt,
        bytes memory initCode,
        bytes memory data,
        Values memory values
    ) public payable returns (address newContract) {
        /**
         * @dev Note that the modifier `guard` is called as part of the overloaded function `deployCreate3AndInit`.
         */
        newContract = deployCreate3AndInit({
            salt: salt,
            initCode: initCode,
            data: data,
            values: values,
            refundAddress: msg.sender
        });
    }

    /**
     * @dev Deploys and initialises a new contract via employing the `CREATE3` pattern (i.e. without
     * an initcode factor) and using the creation bytecode `initCode`, the initialisation code `data`,
     * the struct for the `payable` amounts `values`, the refund address `refundAddress`, and `msg.value`
     * as inputs. The salt value is calculated pseudo-randomly using a diverse selection of block and
     * transaction properties. This approach does not guarantee true randomness! In order to save deployment
     * costs, we do not sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero,
     * `initCode` must have a `payable` constructor. This implementation is based on Solmate:
     * https://github.com/transmissions11/solmate/blob/v7/src/utils/CREATE3.sol.
     * @param initCode The creation bytecode.
     * @param data The initialisation code that is passed to the deployed contract.
     * @param values The specific `payable` amounts for the deployment and initialisation call.
     * @param refundAddress The 20-byte address where any excess ether is returned to.
     * @return newContract The 20-byte address where the contract was deployed.
     * @custom:security This function allows for reentrancy, however we refrain from adding
     * a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol
     * level that potentially malicious reentrant calls do not affect your smart contract system.
     * Furthermore, this function does not implement any permissioned deploy protection, thus
     * anyone can frontrun the same proxy deployment on other chains. Use with caution!
     */
    function deployCreate3AndInit(
        bytes memory initCode,
        bytes memory data,
        Values memory values,
        address refundAddress
    ) public payable returns (address newContract) {
        /**
         * @dev Note that the modifier `guard` is called as part of the overloaded function `deployCreate3AndInit`.
         */
        newContract = deployCreate3AndInit({
            salt: _generateSalt(),
            initCode: initCode,
            data: data,
            values: values,
            refundAddress: refundAddress
        });
    }

    /**
     * @dev Deploys and initialises a new contract via employing the `CREATE3` pattern (i.e. without
     * an initcode factor) and using the creation bytecode `initCode`, the initialisation code `data`,
     * the struct for the `payable` amounts `values`, `msg.value` as inputs. The salt value is calculated
     * pseudo-randomly using a diverse selection of block and transaction properties. This approach does
     * not guarantee true randomness! In order to save deployment costs, we do not sanity check the `initCode`
     * length. Note that if `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor,
     * and any excess ether is returned to `msg.sender`. This implementation is based on Solmate:
     * https://github.com/transmissions11/solmate/blob/v7/src/utils/CREATE3.sol.
     * @param initCode The creation bytecode.
     * @param data The initialisation code that is passed to the deployed contract.
     * @param values The specific `payable` amounts for the deployment and initialisation call.
     * @return newContract The 20-byte address where the contract was deployed.
     * @custom:security This function allows for reentrancy, however we refrain from adding
     * a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol
     * level that potentially malicious reentrant calls do not affect your smart contract system.
     * Furthermore, this function does not implement any permissioned deploy protection, thus
     * anyone can frontrun the same proxy deployment on other chains. Use with caution!
     */
    function deployCreate3AndInit(
        bytes memory initCode,
        bytes memory data,
        Values memory values
    ) public payable returns (address newContract) {
        /**
         * @dev Note that the modifier `guard` is called as part of the overloaded function `deployCreate3AndInit`.
         */
        newContract = deployCreate3AndInit({
            salt: _generateSalt(),
            initCode: initCode,
            data: data,
            values: values,
            refundAddress: msg.sender
        });
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via `deployer` using
     * the `CREATE3` pattern (i.e. without an initcode factor). Any change in the `salt` value will
     * result in a new destination address. This implementation is based on Solady:
     * https://github.com/Vectorized/solady/blob/main/src/utils/CREATE3.sol.
     * @param salt The 32-byte random value used to create the contract address.
     * @param deployer The 20-byte deployer address.
     * @return computedAddress The 20-byte address where a contract will be stored.
     */
    function computeCreate3Address(bytes32 salt, address deployer) public pure returns (address computedAddress) {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(0x00, deployer)
            mstore8(0x0b, 0xff)
            mstore(0x20, salt)
            mstore(0x40, hex"21c35dbe1b344a2488cf3321d6ce542f8e9f305544ff09e4993a62319a497c1f")
            mstore(0x14, keccak256(0x0b, 0x55))
            mstore(0x40, ptr)
            mstore(0x00, 0xd694)
            mstore8(0x34, 0x01)
            computedAddress := keccak256(0x1e, 0x17)
        }
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via this contract using
     * the `CREATE3` pattern (i.e. without an initcode factor). Any change in the `salt` value will
     * result in a new destination address. This implementation is based on Solady:
     * https://github.com/Vectorized/solady/blob/main/src/utils/CREATE3.sol.
     * @param salt The 32-byte random value used to create the contract address.
     * @return computedAddress The 20-byte address where a contract will be stored.
     */
    function computeCreate3Address(bytes32 salt) public view returns (address computedAddress) {
        computedAddress = computeCreate3Address({salt: salt, deployer: address(this)});
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      HELPER FUNCTIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /**
     * @dev Returns the `keccak256` hash of `a` and `b` after concatenation.
     * @param a The first 32-byte value to be concatenated and hashed.
     * @param b The second 32-byte value to be concatenated and hashed.
     * @return hash The 32-byte `keccak256` hash of `a` and `b`.
     */
    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 hash) {
        // solhint-disable-next-line no-inline-assembly
        assembly ("memory-safe") {
            mstore(0x00, a)
            mstore(0x20, b)
            hash := keccak256(0x00, 0x40)
        }
    }

    /**
     * @dev Generates pseudo-randomly a salt value using a diverse selection of block and
     * transaction properties.
     * @return salt The 32-byte pseudo-random salt value.
     */
    function _generateSalt() private view returns (bytes32 salt) {
        salt = keccak256(
            abi.encode(
                blockhash(block.number),
                block.coinbase,
                block.number,
                // solhint-disable-next-line not-rely-on-time
                block.timestamp,
                block.prevrandao,
                block.chainid,
                msg.sender
            )
        );
    }
}
