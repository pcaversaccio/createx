# [`CreateX`](./src/CreateX.sol) – A Trustless, Universal Contract Deployer

[![🕵️‍♂️ Test CreateX](https://github.com/pcaversaccio/createx/actions/workflows/test-createx.yml/badge.svg)](https://github.com/pcaversaccio/createx/actions/workflows/test-createx.yml)
[![Test coverage](https://img.shields.io/badge/coverage-100%25-yellowgreen)](#test-coverage)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

<img src=https://github-production-user-asset-6210df.s3.amazonaws.com/25297591/272914952-38a5989c-0113-427d-9158-47646971b7d8.png  width="1050"/>

Factory smart contract to make easier and safer usage of the [`CREATE`](https://www.evm.codes/#f0?fork=shanghai) and [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai) EVM opcodes as well as of [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171)-based (i.e. without an initcode factor) contract creations.

- [Available Versatile Functions](#available-versatile-functions)

## Available Versatile Functions

```ml
CreateX
├── CREATE
│   ├── Read-Only Functions
│   │   ├── "computeCreateAddress(uint256) view returns (address)"
│   │   └── "computeCreateAddress(address,uint256) view returns (address)"
│   └── Write Functions
│       ├── "function deployCreate(bytes) payable returns (address)"
│       ├── "function deployCreateAndInit(bytes,bytes,tuple(uint256,uint256)) payable returns (address)"
│       ├── "function deployCreateAndInit(bytes,bytes,tuple(uint256,uint256),address) payable returns (address)"
│       └── "deployCreateClone(address,bytes) payable returns (address)"
├── CREATE2
│   ├── Read-Only Functions
│   │   ├── "function computeCreate2Address(bytes32,bytes32) view returns (address)"
│   │   └── "function computeCreate2Address(bytes32,bytes32,address) pure returns (address)"
│   └── Write Functions
│       ├── "function deployCreate2(bytes) payable returns (address)"
│       ├── "function deployCreate2(bytes32,bytes) payable returns (address)"
│       ├── "function deployCreate2AndInit(bytes,bytes,tuple(uint256,uint256)) payable returns (address)"
│       ├── "function deployCreate2AndInit(bytes32,bytes,bytes,tuple(uint256,uint256)) payable returns (address)"
│       ├── "function deployCreate2AndInit(bytes,bytes,tuple(uint256,uint256),address) payable returns (address)"
│       ├── "function deployCreate2AndInit(bytes32,bytes,bytes,tuple(uint256,uint256),address) payable returns (address)"
│       ├── "function deployCreate2Clone(address,bytes) payable returns (address)"
│       └── "function deployCreate2Clone(bytes32,address,bytes) payable returns (address)"
└── CREATE3
    ├── Read-Only Functions
    │   ├── "function computeCreate3Address(bytes32) view returns (address)"
    │   └── "function computeCreate3Address(bytes32,address) pure returns (address)"
    └── Write Functions
        ├── "function deployCreate3(bytes) payable returns (address)"
        ├── "function deployCreate3(bytes32,bytes) payable returns (address)"
        ├── "function deployCreate3AndInit(bytes,bytes,tuple(uint256,uint256)) payable returns (address)"
        ├── "function deployCreate3AndInit(bytes32,bytes,bytes,tuple(uint256,uint256)) payable returns (address)"
        ├── "function deployCreate3AndInit(bytes,bytes,tuple(uint256,uint256),address) payable returns (address)"
        └── "function deployCreate3AndInit(bytes32,bytes,bytes,tuple(uint256,uint256),address) payable returns (address)"
```

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L302-L317"><code>computeCreateAddress(uint256)</code></a> </summary>

Returns the address where a contract will be stored if deployed via _this contract_ (i.e. [`CreateX`](./src/CreateX.sol)) using the [`CREATE`](https://www.evm.codes/#f0?fork=shanghai) opcode. For the specification of the Recursive Length Prefix (RLP) encoding scheme, please refer to p. 19 of the [Ethereum Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf) and the [Ethereum Wiki](https://ethereum.org/en/developers/docs/data-structures-and-encoding/rlp/). Based on the [EIP-161](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-161.md) specification, all contract accounts on the Ethereum mainnet are initiated with `nonce = 1`. Thus, the first contract address created by another contract is calculated with a non-zero nonce.

```yml
# /*:°• Function Argument •°:*/ #
- name: nonce
  type: uint256
  description: The next 32-byte nonce of this contract.

# /*:°• Return Value •°:*/ #
- name: computedAddress
  type: address
  description: The 20-byte address where a contract will be stored.
```

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L242-L300"><code>computeCreateAddress(address,uint256)</code></a> </summary>

Returns the address where a contract will be stored if deployed via `deployer` using the [`CREATE`](https://www.evm.codes/#f0?fork=shanghai) opcode. For the specification of the Recursive Length Prefix (RLP) encoding scheme, please refer to p. 19 of the [Ethereum Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf) and the [Ethereum Wiki](https://ethereum.org/en/developers/docs/data-structures-and-encoding/rlp/). Based on the [EIP-161](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-161.md) specification, all contract accounts on the Ethereum mainnet are initiated with `nonce = 1`. Thus, the first contract address created by another contract is calculated with a non-zero nonce.

```yml
# /*:°• Function Arguments •°:*/ #
- name: deployer
  type: address
  description: The 20-byte deployer address.
- name: nonce
  type: uint256
  description: The next 32-byte nonce of the deployer address.

# /*:°• Return Value •°:*/ #
- name: computedAddress
  type: address
  description: The 20-byte address where a contract will be stored.
```

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L122-L136"><code>deployCreate(bytes)</code></a> </summary>

Deploys a new contract via calling the [`CREATE`](https://www.evm.codes/#f0?fork=shanghai) opcode and using the creation bytecode `initCode` and `msg.value` as inputs. In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `msg.value` is non-zero, `initCode` must have a `payable` constructor.

```yml
# /*:°• Function Argument •°:*/ #
- name: initCode
  type: bytes
  description: The creation bytecode.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the contract was deployed.
```

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L180-L200"><code>deployCreateAndInit(bytes,bytes,tuple(uint256,uint256))</code></a> </summary>

Deploys and initialises a new contract via calling the [`CREATE`](https://www.evm.codes/#f0?fork=shanghai) opcode and using the creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable` amounts `values`, and `msg.value` as inputs. In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor, and any excess ether is returned to `msg.sender`.

```yml
# /*:°• Function Arguments •°:*/ #
- name: initCode
  type: bytes
  description: The creation bytecode.
- name: data
  type: bytes
  description: The initialisation code that is passed to the deployed contract.
- name: values
  type: tuple(uint256,uint256)
  description: The specific `payable` amounts for the deployment and initialisation call.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the contract was deployed.
```

> **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L138-L178"><code>deployCreateAndInit(bytes,bytes,tuple(uint256,uint256),address)</code></a> </summary>

Deploys and initialises a new contract via calling the [`CREATE`](https://www.evm.codes/#f0?fork=shanghai) opcode and using the creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable` amounts `values`, the refund address `refundAddress`, and `msg.value` as inputs. In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor.

```yml
# /*:°• Function Arguments •°:*/ #
- name: initCode
  type: bytes
  description: The creation bytecode.
- name: data
  type: bytes
  description: The initialisation code that is passed to the deployed contract.
- name: values
  type: tuple(uint256,uint256)
  description: The specific `payable` amounts for the deployment and initialisation call.
- name: refundAddress
  type: address
  description: The 20-byte address where any excess ether is returned to.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the contract was deployed.
```

> **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L202-L240"><code>deployCreateClone(address,bytes)</code> </a> </summary>

Deploys a new [EIP-1167](https://eips.ethereum.org/EIPS/eip-1167) minimal proxy contract using the [`CREATE`](https://www.evm.codes/#f0?fork=shanghai) opcode, and initialises the implementation contract using the implementation address `implementation`, the initialisation code `data`, and `msg.value` as inputs. Note that if `msg.value` is non-zero, the initialiser function called via `data` must be `payable`.

```yml
# /*:°• Function Arguments •°:*/ #
- name: implementation
  type: address
  description: The 20-byte implementation contract address.
- name: data
  type: bytes
  description: The initialisation code that is passed to the deployed proxy contract.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the clone was deployed.
```

> **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L600-L610"><code>computeCreate2Address(bytes32,bytes32)</code></a> </summary>

Returns the address where a contract will be stored if deployed via _this contract_ (i.e. [`CreateX`](./src/CreateX.sol)) using the [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai) opcode. Any change in the `initCodeHash` or `salt` values will result in a new destination address.

```yml
# /*:°• Function Arguments •°:*/ #
- name: salt
  type: bytes32
  description: The 32-byte random value used to create the contract address.
- name: initCodeHash
  type: bytes32
  description: The 32-byte bytecode digest of the contract creation bytecode.

# /*:°• Return Value •°:*/ #
- name: computedAddress
  type: address
  description: The 20-byte address where a contract will be stored.
```

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L565-L598"><code>computeCreate2Address(bytes32,bytes32,address)</code></a> </summary>

Returns the address where a contract will be stored if deployed via `deployer` using the [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai) opcode. Any change in the `initCodeHash` or `salt` values will result in a new destination address.

```yml
# /*:°• Function Arguments •°:*/ #
- name: salt
  type: bytes32
  description: The 32-byte random value used to create the contract address.
- name: initCodeHash
  type: bytes32
  description: The 32-byte bytecode digest of the contract creation bytecode.
- name: deployer
  type: address
  description: The 20-byte deployer address.

# /*:°• Return Value •°:*/ #
- name: computedAddress
  type: address
  description: The 20-byte address where a contract will be stored.
```

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L341-L354"><code>deployCreate2(bytes)</code></a> </summary>

Deploys a new contract via calling the [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai) opcode and using the creation bytecode `initCode` and `msg.value` as inputs. The salt value is calculated _pseudo-randomly_ using a diverse selection of block and transaction properties. This approach does not guarantee true randomness! In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `msg.value` is non-zero, `initCode` must have a `payable` constructor.

```yml
# /*:°• Function Argument •°:*/ #
- name: initCode
  type: bytes
  description: The creation bytecode.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the contract was deployed.
```

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L323-L339"><code>deployCreate2(bytes32,bytes)</code></a> </summary>

Deploys a new contract via calling the [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai) opcode and using the salt value `salt`, the creation bytecode `initCode`, and `msg.value` as inputs. In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `msg.value` is non-zero, `initCode` must have a `payable` constructor.

```yml
# /*:°• Function Arguments •°:*/ #
- name: salt
  type: bytes32
  description: The 32-byte random value used to create the contract address.
- name: initCode
  type: bytes
  description: The creation bytecode.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the contract was deployed.
```

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L467-L497"><code>deployCreate2AndInit(bytes,bytes,tuple(uint256,uint256))</code></a> </summary>

Deploys and initialises a new contract via calling the [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai) opcode and using the creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable` amounts `values`, and `msg.value` as inputs. The salt value is calculated _pseudo-randomly_ using a diverse selection of block and transaction properties. This approach does not guarantee true randomness! In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor, and any excess ether is returned to `msg.sender`.

```yml
# /*:°• Function Arguments •°:*/ #
- name: initCode
  type: bytes
  description: The creation bytecode.
- name: data
  type: bytes
  description: The initialisation code that is passed to the deployed contract.
- name: values
  type: tuple(uint256,uint256)
  description: The specific `payable` amounts for the deployment and initialisation call.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the contract was deployed.
```

> **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L401-L431"><code>deployCreate2AndInit(bytes32,bytes,bytes,tuple(uint256,uint256))</code></a> </summary>

Deploys and initialises a new contract via calling the [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai) opcode and using the salt value `salt`, creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable` amounts `values`, and `msg.value` as inputs. In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor, and any excess ether is returned to `msg.sender`.

```yml
# /*:°• Function Arguments •°:*/ #
- name: salt
  type: bytes32
  description: The 32-byte random value used to create the contract address.
- name: initCode
  type: bytes
  description: The creation bytecode.
- name: data
  type: bytes
  description: The initialisation code that is passed to the deployed contract.
- name: values
  type: tuple(uint256,uint256)
  description: The specific `payable` amounts for the deployment and initialisation call.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the contract was deployed.
```

> **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L433-L465"><code>deployCreate2AndInit(bytes,bytes,tuple(uint256,uint256),address)</code></a> </summary>

Deploys and initialises a new contract via calling the [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai) opcode and using the creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable` amounts `values`, the refund address `refundAddress`, and `msg.value` as inputs. The salt value is calculated _pseudo-randomly_ using a diverse selection of block and transaction properties. This approach does not guarantee true randomness! In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor.

```yml
# /*:°• Function Arguments •°:*/ #
- name: initCode
  type: bytes
  description: The creation bytecode.
- name: data
  type: bytes
  description: The initialisation code that is passed to the deployed contract.
- name: values
  type: tuple(uint256,uint256)
  description: The specific `payable` amounts for the deployment and initialisation call.
- name: refundAddress
  type: address
  description: The 20-byte address where any excess ether is returned to.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the contract was deployed.
```

> **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L356-L399"><code>deployCreate2AndInit(bytes32,bytes,bytes,tuple(uint256,uint256),address)</code></a> </summary>

Deploys and initialises a new contract via calling the [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai) opcode and using the salt value `salt`, the creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable` amounts `values`, the refund address `refundAddress`, and `msg.value` as inputs. In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor.

```yml
# /*:°• Function Arguments •°:*/ #
- name: salt
  type: bytes32
  description: The 32-byte random value used to create the contract address.
- name: initCode
  type: bytes
  description: The creation bytecode.
- name: data
  type: bytes
  description: The initialisation code that is passed to the deployed contract.
- name: values
  type: tuple(uint256,uint256)
  description: The specific `payable` amounts for the deployment and initialisation call.
- name: refundAddress
  type: address
  description: The 20-byte address where any excess ether is returned to.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the contract was deployed.
```

> **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L545-L563"><code>deployCreate2Clone(address,bytes)</code></a> </summary>

Deploys a new [EIP-1167](https://eips.ethereum.org/EIPS/eip-1167) minimal proxy contract using the [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai) opcode and the salt value `salt`, and initialises the implementation contract using the implementation address `implementation`, the initialisation code `data`, and `msg.value` as inputs. The salt value is calculated _pseudo-randomly_ using a diverse selection of block and transaction properties. This approach does not guarantee true randomness! Note that if `msg.value` is non-zero, the initialiser function called via `data` must be `payable`.

```yml
# /*:°• Function Arguments •°:*/ #
- name: implementation
  type: address
  description: The 20-byte implementation contract address.
- name: data
  type: bytes
  description: The initialisation code that is passed to the deployed proxy contract.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the clone was deployed.
```

> **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L499-L543"><code>deployCreate2Clone(bytes32,address,bytes)</code></a> </summary>

Deploys a new [EIP-1167](https://eips.ethereum.org/EIPS/eip-1167) minimal proxy contract using the [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai) opcode and the salt value `salt`, and initialises the implementation contract using the implementation address `implementation`, the initialisation code `data`, and `msg.value` as inputs. Note that if `msg.value` is non-zero, the initialiser function called via `data` must be `payable`.

```yml
# /*:°• Function Arguments •°:*/ #
- name: salt
  type: bytes32
  description: The 32-byte random value used to create the contract address.
- name: implementation
  type: address
  description: The 20-byte implementation contract address.
- name: data
  type: bytes
  description: The initialisation code that is passed to the deployed proxy contract.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the clone was deployed.
```

> **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L863-L873"><code>computeCreate3Address(bytes32)</code></a> </summary>

Returns the address where a contract will be stored if deployed via _this contract_ (i.e. [`CreateX`](./src/CreateX.sol)) using the [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171) pattern (i.e. without an initcode factor). Any change in the `salt` value will result in a new destination address.

```yml
# /*:°• Function Argument •°:*/ #
- name: salt
  type: bytes32
  description: The 32-byte random value used to create the contract address.

# /*:°• Return Value •°:*/ #
- name: computedAddress
  type: address
  description: The 20-byte address where a contract will be stored.
```

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L836-L861"><code>computeCreate3Address(bytes32,address)</code></a> </summary>

Returns the address where a contract will be stored if deployed via `deployer` using the [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171) pattern (i.e. without an initcode factor). Any change in the `salt` value will result in a new destination address.

```yml
# /*:°• Function Arguments •°:*/ #
- name: salt
  type: bytes32
  description: The 32-byte random value used to create the contract address.
- name: deployer
  type: address
  description: The 20-byte deployer address.

# /*:°• Return Value •°:*/ #
- name: computedAddress
  type: address
  description: The 20-byte address where a contract will be stored.
```

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L648-L665"><code>deployCreate3(bytes)</code></a> </summary>

Deploys a new contract via employing the [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171) pattern (i.e. without an initcode factor) and using the salt value `salt`, the creation bytecode `initCode`, and `msg.value` as inputs. The salt value is calculated _pseudo-randomly_ using a diverse selection of block and transaction properties. This approach does not guarantee true randomness! In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `msg.value` is non-zero, `initCode` must have a `payable` constructor.

```yml
# /*:°• Function Argument •°:*/ #
- name: initCode
  type: bytes
  description: The creation bytecode.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the contract was deployed.
```

> **Note**<br>
> This function does not implement any permissioned deploy protection, thus anyone can frontrun the same proxy deployment on other chains. Use with caution!

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L616-L646"><code>deployCreate3(bytes32,bytes)</code></a> </summary>

Deploys a new contract via employing the [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171) pattern (i.e. without an initcode factor) and using the salt value `salt`, the creation bytecode `initCode`, and `msg.value` as inputs. In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `msg.value` is non-zero, `initCode` must have a `payable` constructor.

```yml
# /*:°• Function Arguments •°:*/ #
- name: salt
  type: bytes32
  description: The 32-byte random value used to create the contract address.
- name: initCode
  type: bytes
  description: The creation bytecode.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the contract was deployed.
```

> **Note**<br>
> We strongly recommend implementing a permissioned deploy protection by setting the first 20 bytes equal to `msg.sender` in the `salt` to prevent maliciously intended frontrun proxy deployments on other chains.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L801-L834"><code>deployCreate3AndInit(bytes,bytes,tuple(uint256,uint256))</code></a> </summary>

Deploys and initialises a new contract via employing the [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171) pattern (i.e. without an initcode factor) and using the creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable` amounts `values`, `msg.value` as inputs. The salt value is calculated _pseudo-randomly_ using a diverse selection of block and transaction properties. This approach does not guarantee true randomness! In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor, and any excess ether is returned to `msg.sender`.

```yml
# /*:°• Function Arguments •°:*/ #
- name: initCode
  type: bytes
  description: The creation bytecode.
- name: data
  type: bytes
  description: The initialisation code that is passed to the deployed contract.
- name: values
  type: tuple(uint256,uint256)
  description: The specific `payable` amounts for the deployment and initialisation call.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the contract was deployed.
```

> **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system. Furthermore, this function does not implement any permissioned deploy protection, thus anyone can frontrun the same proxy deployment on other chains. Use with caution!

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L727-L762"><code>deployCreate3AndInit(bytes32,bytes,bytes,tuple(uint256,uint256))</code></a> </summary>

Deploys and initialises a new contract via employing the [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171) pattern (i.e. without an initcode factor) and using the salt value `salt`, the creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable` amounts `values`, and `msg.value` as inputs. In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor, and any excess ether is returned to `msg.sender`.

```yml
# /*:°• Function Arguments •°:*/ #
- name: salt
  type: bytes32
  description: The 32-byte random value used to create the contract address.
- name: initCode
  type: bytes
  description: The creation bytecode.
- name: data
  type: bytes
  description: The initialisation code that is passed to the deployed contract.
- name: values
  type: tuple(uint256,uint256)
  description: The specific `payable` amounts for the deployment and initialisation call.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the contract was deployed.
```

> **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system. Furthermore, this function does not implement any permissioned deploy protection, thus anyone can frontrun the same proxy deployment on other chains. Use with caution!

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L764-L799"><code>deployCreate3AndInit(bytes,bytes,tuple(uint256,uint256),address)</code></a> </summary>

Deploys and initialises a new contract via employing the [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171) pattern (i.e. without an initcode factor) and using the creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable` amounts `values`, the refund address `refundAddress`, and `msg.value` as inputs. The salt value is calculated pseudo-randomly using a diverse selection of block and transaction properties. This approach does not guarantee true randomness! In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor.

```yml
# /*:°• Function Arguments •°:*/ #
- name: initCode
  type: bytes
  description: The creation bytecode.
- name: data
  type: bytes
  description: The initialisation code that is passed to the deployed contract.
- name: values
  type: tuple(uint256,uint256)
  description: The specific `payable` amounts for the deployment and initialisation call.
- name: refundAddress
  type: address
  description: The 20-byte address where any excess ether is returned to.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the contract was deployed.
```

> **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system. Furthermore, this function does not implement any permissioned deploy protection, thus anyone can frontrun the same proxy deployment on other chains. Use with caution!

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L727-L762"><code>deployCreate3AndInit(bytes32,bytes,bytes,tuple(uint256,uint256),address)</code></a> </summary>

Deploys and initialises a new contract via employing the [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171) pattern (i.e. without an initcode factor) and using the salt value `salt`, the creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable` amounts `values`, and `msg.value` as inputs. In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor, and any excess ether is returned to `msg.sender`.

```yml
# /*:°• Function Arguments •°:*/ #
- name: salt
  type: bytes32
  description: The 32-byte random value used to create the contract address.
- name: initCode
  type: bytes
  description: The creation bytecode.
- name: data
  type: bytes
  description: The initialisation code that is passed to the deployed contract.
- name: values
  type: tuple(uint256,uint256)
  description: The specific `payable` amounts for the deployment and initialisation call.
- name: refundAddress
  type: address
  description: The 20-byte address where any excess ether is returned to.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the contract was deployed.
```

> **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system. Furthermore, we strongly recommend implementing a permissioned deploy protection by setting the first 20 bytes equal to `msg.sender` in the `salt` to prevent maliciously intended frontrun proxy deployments on other chains.

</details>

## Features

TBD

## Security Considerations

TBD

## Tests

### Stateless Fuzz Tests

TBD

### Stateful Fuzz (a.k.a. Invariant) Tests

### Test Coverage

This project repository uses [`forge coverage`](https://book.getfoundry.sh/reference/forge/forge-coverage). Simply run:

```console
forge coverage
```

The written tests available in the directory [`test`](./test) achieve a test coverage of **100%** for the [`CreateX`](./src/CreateX.sol) contract:

```console
| File            | % Lines           | % Statements      | % Branches      | % Funcs         |
|-----------------|-------------------|-------------------|-----------------|-----------------|
| src/CreateX.sol | 100.00% (149/149) | 100.00% (210/210) | 100.00% (78/78) | 100.00% (31/31) |
```

> **Important:** A test coverage of 100% does not mean that there are no vulnerabilities. What really counts is the quality and spectrum of the tests themselves!

## ABI

<details>
<summary> <a href="https://docs.soliditylang.org/en/latest/">Solidity</a> </summary>

```solidity
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.4;

/**
 * @title CreateX Factory Interface Definition
 * @author pcaversaccio (https://web.archive.org/web/20230921103111/https://pcaversaccio.com/)
 * @custom:coauthor Matt Solomon (https://web.archive.org/web/20230921103335/https://mattsolomon.dev/)
 */
interface ICreateX {
  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                            TYPES                           */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  struct Values {
    uint256 constructorAmount;
    uint256 initCallAmount;
  }

  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                           EVENTS                           */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  event ContractCreation(address indexed newContract, bytes32 indexed salt);
  event ContractCreation(address indexed newContract);
  event Create3ProxyContractCreation(
    address indexed newContract,
    bytes32 indexed salt
  );

  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                        CUSTOM ERRORS                       */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  error FailedContractCreation(address emitter);
  error FailedContractInitialisation(address emitter, bytes revertData);
  error InvalidSalt(address emitter);
  error InvalidNonceValue(address emitter);
  error FailedEtherTransfer(address emitter, bytes revertData);

  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                           CREATE                           */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  function deployCreate(
    bytes memory initCode
  ) external payable returns (address newContract);

  function deployCreateAndInit(
    bytes memory initCode,
    bytes memory data,
    Values memory values,
    address refundAddress
  ) external payable returns (address newContract);

  function deployCreateAndInit(
    bytes memory initCode,
    bytes memory data,
    Values memory values
  ) external payable returns (address newContract);

  function deployCreateClone(
    address implementation,
    bytes memory data
  ) external payable returns (address proxy);

  function computeCreateAddress(
    address deployer,
    uint256 nonce
  ) external view returns (address computedAddress);

  function computeCreateAddress(
    uint256 nonce
  ) external view returns (address computedAddress);

  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                           CREATE2                          */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  function deployCreate2(
    bytes32 salt,
    bytes memory initCode
  ) external payable returns (address newContract);

  function deployCreate2(
    bytes memory initCode
  ) external payable returns (address newContract);

  function deployCreate2AndInit(
    bytes32 salt,
    bytes memory initCode,
    bytes memory data,
    Values memory values,
    address refundAddress
  ) external payable returns (address newContract);

  function deployCreate2AndInit(
    bytes32 salt,
    bytes memory initCode,
    bytes memory data,
    Values memory values
  ) external payable returns (address newContract);

  function deployCreate2AndInit(
    bytes memory initCode,
    bytes memory data,
    Values memory values,
    address refundAddress
  ) external payable returns (address newContract);

  function deployCreate2AndInit(
    bytes memory initCode,
    bytes memory data,
    Values memory values
  ) external payable returns (address newContract);

  function deployCreate2Clone(
    bytes32 salt,
    address implementation,
    bytes memory data
  ) external payable returns (address proxy);

  function deployCreate2Clone(
    address implementation,
    bytes memory data
  ) external payable returns (address proxy);

  function computeCreate2Address(
    bytes32 salt,
    bytes32 initCodeHash,
    address deployer
  ) external pure returns (address computedAddress);

  function computeCreate2Address(
    bytes32 salt,
    bytes32 initCodeHash
  ) external view returns (address computedAddress);

  /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
  /*                           CREATE3                          */
  /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

  function deployCreate3(
    bytes32 salt,
    bytes memory initCode
  ) external payable returns (address newContract);

  function deployCreate3(
    bytes memory initCode
  ) external payable returns (address newContract);

  function deployCreate3AndInit(
    bytes32 salt,
    bytes memory initCode,
    bytes memory data,
    Values memory values,
    address refundAddress
  ) external payable returns (address newContract);

  function deployCreate3AndInit(
    bytes32 salt,
    bytes memory initCode,
    bytes memory data,
    Values memory values
  ) external payable returns (address newContract);

  function deployCreate3AndInit(
    bytes memory initCode,
    bytes memory data,
    Values memory values,
    address refundAddress
  ) external payable returns (address newContract);

  function deployCreate3AndInit(
    bytes memory initCode,
    bytes memory data,
    Values memory values
  ) external payable returns (address newContract);

  function computeCreate3Address(
    bytes32 salt,
    address deployer
  ) external pure returns (address computedAddress);

  function computeCreate3Address(
    bytes32 salt
  ) external view returns (address computedAddress);
}
```

</details>

<details>
<summary> <a href="https://docs.ethers.org/v6/">ethers.js</a> </summary>

```json
[
  "error FailedContractCreation(address)",
  "error FailedContractInitialisation(address,bytes)",
  "error FailedEtherTransfer(address,bytes)",
  "error InvalidNonceValue(address)",
  "error InvalidSalt(address)",
  "event ContractCreation(address indexed,bytes32 indexed)",
  "event ContractCreation(address indexed)",
  "event Create3ProxyContractCreation(address indexed,bytes32 indexed)",
  "function computeCreate2Address(bytes32,bytes32) view returns (address)",
  "function computeCreate2Address(bytes32,bytes32,address) pure returns (address)",
  "function computeCreate3Address(bytes32,address) pure returns (address)",
  "function computeCreate3Address(bytes32) view returns (address)",
  "function computeCreateAddress(uint256) view returns (address)",
  "function computeCreateAddress(address,uint256) view returns (address)",
  "function deployCreate(bytes) payable returns (address)",
  "function deployCreate2(bytes32,bytes) payable returns (address)",
  "function deployCreate2(bytes) payable returns (address)",
  "function deployCreate2AndInit(bytes32,bytes,bytes,tuple(uint256,uint256),address) payable returns (address)",
  "function deployCreate2AndInit(bytes,bytes,tuple(uint256,uint256)) payable returns (address)",
  "function deployCreate2AndInit(bytes,bytes,tuple(uint256,uint256),address) payable returns (address)",
  "function deployCreate2AndInit(bytes32,bytes,bytes,tuple(uint256,uint256)) payable returns (address)",
  "function deployCreate2Clone(bytes32,address,bytes) payable returns (address)",
  "function deployCreate2Clone(address,bytes) payable returns (address)",
  "function deployCreate3(bytes) payable returns (address)",
  "function deployCreate3(bytes32,bytes) payable returns (address)",
  "function deployCreate3AndInit(bytes32,bytes,bytes,tuple(uint256,uint256)) payable returns (address)",
  "function deployCreate3AndInit(bytes,bytes,tuple(uint256,uint256)) payable returns (address)",
  "function deployCreate3AndInit(bytes32,bytes,bytes,tuple(uint256,uint256),address) payable returns (address)",
  "function deployCreate3AndInit(bytes,bytes,tuple(uint256,uint256),address) payable returns (address)",
  "function deployCreateAndInit(bytes,bytes,tuple(uint256,uint256)) payable returns (address)",
  "function deployCreateAndInit(bytes,bytes,tuple(uint256,uint256),address) payable returns (address)",
  "function deployCreateClone(address,bytes) payable returns (address)"
]
```

</details>

<details>
<summary> <a href="https://viem.sh">viem</a> </summary>

```ts
[
  "error FailedContractCreation(address emitter)",
  "error FailedContractInitialisation(address emitter, bytes revertData)",
  "error FailedEtherTransfer(address emitter, bytes revertData)",
  "error InvalidNonceValue(address emitter)",
  "error InvalidSalt(address emitter)",
  "event ContractCreation(address indexed newContract, bytes32 indexed salt)",
  "event ContractCreation(address indexed newContract)",
  "event Create3ProxyContractCreation(address indexed newContract, bytes32 indexed salt)",
  "function computeCreate2Address(bytes32 salt, bytes32 initCodeHash) view returns (address computedAddress)",
  "function computeCreate2Address(bytes32 salt, bytes32 initCodeHash, address deployer) pure returns (address computedAddress)",
  "function computeCreate3Address(bytes32 salt, address deployer) pure returns (address computedAddress)",
  "function computeCreate3Address(bytes32 salt) view returns (address computedAddress)",
  "function computeCreateAddress(uint256 nonce) view returns (address computedAddress)",
  "function computeCreateAddress(address deployer, uint256 nonce) view returns (address computedAddress)",
  "function deployCreate(bytes initCode) payable returns (address newContract)",
  "function deployCreate2(bytes32 salt, bytes initCode) payable returns (address newContract)",
  "function deployCreate2(bytes initCode) payable returns (address newContract)",
  "function deployCreate2AndInit(bytes32 salt, bytes initCode, bytes data, (uint256 constructorAmount, uint256 initCallAmount) values, address refundAddress) payable returns (address newContract)",
  "function deployCreate2AndInit(bytes initCode, bytes data, (uint256 constructorAmount, uint256 initCallAmount) values) payable returns (address newContract)",
  "function deployCreate2AndInit(bytes initCode, bytes data, (uint256 constructorAmount, uint256 initCallAmount) values, address refundAddress) payable returns (address newContract)",
  "function deployCreate2AndInit(bytes32 salt, bytes initCode, bytes data, (uint256 constructorAmount, uint256 initCallAmount) values) payable returns (address newContract)",
  "function deployCreate2Clone(bytes32 salt, address implementation, bytes data) payable returns (address proxy)",
  "function deployCreate2Clone(address implementation, bytes data) payable returns (address proxy)",
  "function deployCreate3(bytes initCode) payable returns (address newContract)",
  "function deployCreate3(bytes32 salt, bytes initCode) payable returns (address newContract)",
  "function deployCreate3AndInit(bytes32 salt, bytes initCode, bytes data, (uint256 constructorAmount, uint256 initCallAmount) values) payable returns (address newContract)",
  "function deployCreate3AndInit(bytes initCode, bytes data, (uint256 constructorAmount, uint256 initCallAmount) values) payable returns (address newContract)",
  "function deployCreate3AndInit(bytes32 salt, bytes initCode, bytes data, (uint256 constructorAmount, uint256 initCallAmount) values, address refundAddress) payable returns (address newContract)",
  "function deployCreate3AndInit(bytes initCode, bytes data, (uint256 constructorAmount, uint256 initCallAmount) values, address refundAddress) payable returns (address newContract)",
  "function deployCreateAndInit(bytes initCode, bytes data, (uint256 constructorAmount, uint256 initCallAmount) values) payable returns (address newContract)",
  "function deployCreateAndInit(bytes initCode, bytes data, (uint256 constructorAmount, uint256 initCallAmount) values, address refundAddress) payable returns (address newContract)",
  "function deployCreateClone(address implementation, bytes data) payable returns (address proxy)",
] as const;
```

</details>

<details>
<summary> <a href="https://docs.soliditylang.org/en/latest/abi-spec.html#json">JSON</a> </summary>

```json
[
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "emitter",
        "type": "address"
      }
    ],
    "name": "FailedContractCreation",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "emitter",
        "type": "address"
      },
      {
        "internalType": "bytes",
        "name": "revertData",
        "type": "bytes"
      }
    ],
    "name": "FailedContractInitialisation",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "emitter",
        "type": "address"
      },
      {
        "internalType": "bytes",
        "name": "revertData",
        "type": "bytes"
      }
    ],
    "name": "FailedEtherTransfer",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "emitter",
        "type": "address"
      }
    ],
    "name": "InvalidNonceValue",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "emitter",
        "type": "address"
      }
    ],
    "name": "InvalidSalt",
    "type": "error"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "newContract",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "bytes32",
        "name": "salt",
        "type": "bytes32"
      }
    ],
    "name": "ContractCreation",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "newContract",
        "type": "address"
      }
    ],
    "name": "ContractCreation",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "newContract",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "bytes32",
        "name": "salt",
        "type": "bytes32"
      }
    ],
    "name": "Create3ProxyContractCreation",
    "type": "event"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "salt",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32",
        "name": "initCodeHash",
        "type": "bytes32"
      }
    ],
    "name": "computeCreate2Address",
    "outputs": [
      {
        "internalType": "address",
        "name": "computedAddress",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "salt",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32",
        "name": "initCodeHash",
        "type": "bytes32"
      },
      {
        "internalType": "address",
        "name": "deployer",
        "type": "address"
      }
    ],
    "name": "computeCreate2Address",
    "outputs": [
      {
        "internalType": "address",
        "name": "computedAddress",
        "type": "address"
      }
    ],
    "stateMutability": "pure",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "salt",
        "type": "bytes32"
      },
      {
        "internalType": "address",
        "name": "deployer",
        "type": "address"
      }
    ],
    "name": "computeCreate3Address",
    "outputs": [
      {
        "internalType": "address",
        "name": "computedAddress",
        "type": "address"
      }
    ],
    "stateMutability": "pure",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "salt",
        "type": "bytes32"
      }
    ],
    "name": "computeCreate3Address",
    "outputs": [
      {
        "internalType": "address",
        "name": "computedAddress",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "nonce",
        "type": "uint256"
      }
    ],
    "name": "computeCreateAddress",
    "outputs": [
      {
        "internalType": "address",
        "name": "computedAddress",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "deployer",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "nonce",
        "type": "uint256"
      }
    ],
    "name": "computeCreateAddress",
    "outputs": [
      {
        "internalType": "address",
        "name": "computedAddress",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes",
        "name": "initCode",
        "type": "bytes"
      }
    ],
    "name": "deployCreate",
    "outputs": [
      {
        "internalType": "address",
        "name": "newContract",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "salt",
        "type": "bytes32"
      },
      {
        "internalType": "bytes",
        "name": "initCode",
        "type": "bytes"
      }
    ],
    "name": "deployCreate2",
    "outputs": [
      {
        "internalType": "address",
        "name": "newContract",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes",
        "name": "initCode",
        "type": "bytes"
      }
    ],
    "name": "deployCreate2",
    "outputs": [
      {
        "internalType": "address",
        "name": "newContract",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "salt",
        "type": "bytes32"
      },
      {
        "internalType": "bytes",
        "name": "initCode",
        "type": "bytes"
      },
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      },
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "constructorAmount",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "initCallAmount",
            "type": "uint256"
          }
        ],
        "internalType": "struct CreateX.Values",
        "name": "values",
        "type": "tuple"
      },
      {
        "internalType": "address",
        "name": "refundAddress",
        "type": "address"
      }
    ],
    "name": "deployCreate2AndInit",
    "outputs": [
      {
        "internalType": "address",
        "name": "newContract",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes",
        "name": "initCode",
        "type": "bytes"
      },
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      },
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "constructorAmount",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "initCallAmount",
            "type": "uint256"
          }
        ],
        "internalType": "struct CreateX.Values",
        "name": "values",
        "type": "tuple"
      }
    ],
    "name": "deployCreate2AndInit",
    "outputs": [
      {
        "internalType": "address",
        "name": "newContract",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes",
        "name": "initCode",
        "type": "bytes"
      },
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      },
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "constructorAmount",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "initCallAmount",
            "type": "uint256"
          }
        ],
        "internalType": "struct CreateX.Values",
        "name": "values",
        "type": "tuple"
      },
      {
        "internalType": "address",
        "name": "refundAddress",
        "type": "address"
      }
    ],
    "name": "deployCreate2AndInit",
    "outputs": [
      {
        "internalType": "address",
        "name": "newContract",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "salt",
        "type": "bytes32"
      },
      {
        "internalType": "bytes",
        "name": "initCode",
        "type": "bytes"
      },
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      },
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "constructorAmount",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "initCallAmount",
            "type": "uint256"
          }
        ],
        "internalType": "struct CreateX.Values",
        "name": "values",
        "type": "tuple"
      }
    ],
    "name": "deployCreate2AndInit",
    "outputs": [
      {
        "internalType": "address",
        "name": "newContract",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "salt",
        "type": "bytes32"
      },
      {
        "internalType": "address",
        "name": "implementation",
        "type": "address"
      },
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      }
    ],
    "name": "deployCreate2Clone",
    "outputs": [
      {
        "internalType": "address",
        "name": "proxy",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "implementation",
        "type": "address"
      },
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      }
    ],
    "name": "deployCreate2Clone",
    "outputs": [
      {
        "internalType": "address",
        "name": "proxy",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes",
        "name": "initCode",
        "type": "bytes"
      }
    ],
    "name": "deployCreate3",
    "outputs": [
      {
        "internalType": "address",
        "name": "newContract",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "salt",
        "type": "bytes32"
      },
      {
        "internalType": "bytes",
        "name": "initCode",
        "type": "bytes"
      }
    ],
    "name": "deployCreate3",
    "outputs": [
      {
        "internalType": "address",
        "name": "newContract",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "salt",
        "type": "bytes32"
      },
      {
        "internalType": "bytes",
        "name": "initCode",
        "type": "bytes"
      },
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      },
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "constructorAmount",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "initCallAmount",
            "type": "uint256"
          }
        ],
        "internalType": "struct CreateX.Values",
        "name": "values",
        "type": "tuple"
      }
    ],
    "name": "deployCreate3AndInit",
    "outputs": [
      {
        "internalType": "address",
        "name": "newContract",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes",
        "name": "initCode",
        "type": "bytes"
      },
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      },
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "constructorAmount",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "initCallAmount",
            "type": "uint256"
          }
        ],
        "internalType": "struct CreateX.Values",
        "name": "values",
        "type": "tuple"
      }
    ],
    "name": "deployCreate3AndInit",
    "outputs": [
      {
        "internalType": "address",
        "name": "newContract",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "salt",
        "type": "bytes32"
      },
      {
        "internalType": "bytes",
        "name": "initCode",
        "type": "bytes"
      },
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      },
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "constructorAmount",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "initCallAmount",
            "type": "uint256"
          }
        ],
        "internalType": "struct CreateX.Values",
        "name": "values",
        "type": "tuple"
      },
      {
        "internalType": "address",
        "name": "refundAddress",
        "type": "address"
      }
    ],
    "name": "deployCreate3AndInit",
    "outputs": [
      {
        "internalType": "address",
        "name": "newContract",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes",
        "name": "initCode",
        "type": "bytes"
      },
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      },
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "constructorAmount",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "initCallAmount",
            "type": "uint256"
          }
        ],
        "internalType": "struct CreateX.Values",
        "name": "values",
        "type": "tuple"
      },
      {
        "internalType": "address",
        "name": "refundAddress",
        "type": "address"
      }
    ],
    "name": "deployCreate3AndInit",
    "outputs": [
      {
        "internalType": "address",
        "name": "newContract",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes",
        "name": "initCode",
        "type": "bytes"
      },
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      },
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "constructorAmount",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "initCallAmount",
            "type": "uint256"
          }
        ],
        "internalType": "struct CreateX.Values",
        "name": "values",
        "type": "tuple"
      }
    ],
    "name": "deployCreateAndInit",
    "outputs": [
      {
        "internalType": "address",
        "name": "newContract",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes",
        "name": "initCode",
        "type": "bytes"
      },
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      },
      {
        "components": [
          {
            "internalType": "uint256",
            "name": "constructorAmount",
            "type": "uint256"
          },
          {
            "internalType": "uint256",
            "name": "initCallAmount",
            "type": "uint256"
          }
        ],
        "internalType": "struct CreateX.Values",
        "name": "values",
        "type": "tuple"
      },
      {
        "internalType": "address",
        "name": "refundAddress",
        "type": "address"
      }
    ],
    "name": "deployCreateAndInit",
    "outputs": [
      {
        "internalType": "address",
        "name": "newContract",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "implementation",
        "type": "address"
      },
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      }
    ],
    "name": "deployCreateClone",
    "outputs": [
      {
        "internalType": "address",
        "name": "proxy",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "function"
  }
]
```

</details>

## How to Request a Deployment

TBD

### Contract Verification

## [`CreateX`](./src/CreateX.sol) Deployments

- EVM-Based Production Networks:
  - Ethereum: [`0x0000000000000000000000000000000000000000`](https://etherscan.io/address/0x0000000000000000000000000000000000000000)
- Ethereum Test Networks:
  - Goerli: [`0x0000000000000000000000000000000000000000`](https://goerli.etherscan.io/address/0x0000000000000000000000000000000000000000)
- Additional EVM-Based Test Networks:
  - Optimism Testnet (Goerli): [`0x0000000000000000000000000000000000000000`](https://goerli-optimism.etherscan.io/address/0x0000000000000000000000000000000000000000)
