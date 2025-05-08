# [`CreateX`](./src/CreateX.sol) – A Trustless, Universal Contract Deployer <!-- omit from toc -->

[![🕵️‍♂️ Test CreateX](https://github.com/pcaversaccio/createx/actions/workflows/test-createx.yml/badge.svg)](https://github.com/pcaversaccio/createx/actions/workflows/test-createx.yml)
[![Test Coverage](https://img.shields.io/badge/Coverage-100%25-green)](#test-coverage)
[![👮‍♂️ Sanity checks](https://github.com/pcaversaccio/createx/actions/workflows/checks.yml/badge.svg)](https://github.com/pcaversaccio/createx/actions/workflows/checks.yml)
[![🚀 UI deployment](https://github.com/pcaversaccio/createx/actions/workflows/deploy.yml/badge.svg)](https://github.com/pcaversaccio/createx/actions/workflows/deploy.yml)
[![License: AGPL-3.0-only](https://img.shields.io/badge/License-AGPL--3.0--only-blue)](https://www.gnu.org/licenses/agpl-3.0)

<img src=https://github-production-user-asset-6210df.s3.amazonaws.com/25297591/272914952-38a5989c-0113-427d-9158-47646971b7d8.png  width="1050"/>

Factory smart contract to make easier and safer usage of the [`CREATE`](https://www.evm.codes/#f0?fork=shanghai) and [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai) EVM opcodes as well as of [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171)-based (i.e. without an initcode factor) contract creations.

> [!NOTE]
> The [`CreateX`](./src/CreateX.sol) contract should be considered as maximally extensible. Be encouraged to build on top of it! The Solidity-based interface can be found [here](./src/ICreateX.sol).

- [So What on Earth Is a Contract Factory?](#so-what-on-earth-is-a-contract-factory)
- [Available Versatile Functions](#available-versatile-functions)
- [Special Features](#special-features)
  - [Permissioned Deploy Protection and Cross-Chain Redeploy Protection](#permissioned-deploy-protection-and-cross-chain-redeploy-protection)
  - [Pseudo-Random Salt Value](#pseudo-random-salt-value)
- [Design Principles](#design-principles)
- [Security Considerations](#security-considerations)
- [Tests](#tests)
  - [Test Coverage](#test-coverage)
- [ABI (Application Binary Interface)](#abi-application-binary-interface)
- [New Deployment(s)](#new-deployments)
  - [`ethers.js`](#ethersjs)
  - [`cast`](#cast)
  - [Contract Verification](#contract-verification)
- [`CreateX` Deployments](#createx-deployments)
  - [EVM-Based Production Networks](#evm-based-production-networks)
  - [Ethereum Test Networks](#ethereum-test-networks)
  - [Additional EVM-Based Test Networks](#additional-evm-based-test-networks)
- [Integration With External Tooling](#integration-with-external-tooling)
- [Community-Maintained Dune Dashboards](#community-maintained-dune-dashboards)
- [🙏🏼 Acknowledgement](#-acknowledgement)

## So What on Earth Is a Contract Factory?

It is important to understand that Ethereum Virtual Machine (EVM) opcodes can only be called via a smart contract. A contract factory in the context of the EVM refers to a special smart contract that is used to create and deploy other smart contracts on EVM-compatible blockchains using contract creation opcodes (i.e. [`CREATE`](https://www.evm.codes/#f0?fork=shanghai) or [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai)). Using a contract factory provides a flexible and efficient way to deploy and manage smart contracts that share similar functionalities but may have different configurations or settings.

Different approaches can be used to create contracts using a factory contract, and this is exactly what [`CreateX`](./src/CreateX.sol) offers: _a comprehensive range of contract creation functions that are triggered by a smart contract itself_. It is worth emphasising the two differences in the address calculation of the opcodes [`CREATE`](https://www.evm.codes/#f0?fork=shanghai) and [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai) (`||` stands for byte-wise concatenation, `[12:]` refers to the last 20 bytes of a 32-byte expression, and `rlp` is an abbreviation for Ethereum's "Recursive Length Prefix" serialisation scheme):

- [`CREATE`](https://www.evm.codes/#f0?fork=shanghai): `address computedAddress = keccak256(rlpEncode([deployerAddress, deployerNonce]))[12:]`,
- [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai): `address computedAddress = keccak256(0xff||deployerAddress||salt||keccak256(initCode))[12:]`.

## Available Versatile Functions

```ml
CreateX
├── CREATE
│   ├── Read-Only Functions
│   │   ├── "function computeCreateAddress(uint256) view returns (address)"
│   │   └── "function computeCreateAddress(address,uint256) view returns (address)"
│   └── Write Functions
│       ├── "function deployCreate(bytes) payable returns (address)"
│       ├── "function deployCreateAndInit(bytes,bytes,tuple(uint256,uint256)) payable returns (address)"
│       ├── "function deployCreateAndInit(bytes,bytes,tuple(uint256,uint256),address) payable returns (address)"
│       └── "function deployCreateClone(address,bytes) payable returns (address)"
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

> ℹ️ **Note**<br>
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

> ℹ️ **Note**<br>
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

> ℹ️ **Note**<br>
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

> ℹ️ **Note**<br>
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

> ℹ️ **Note**<br>
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

> ℹ️ **Note**<br>
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

> ℹ️ **Note**<br>
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

> ℹ️ **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L499-L543"><code>deployCreate2Clone(bytes32,address,bytes)</code></a> </summary>

Deploys a new [EIP-1167](https://eips.ethereum.org/EIPS/eip-1167) minimal proxy contract using the [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai) opcode and the salt value `salt`, and initialises the implementation contract using the implementation address `implementation`, the initialisation code `data`, and `msg.value` as inputs. Note that if `msg.value` is non-zero, the initialiser function called via `data` must be `payable`.

```yml
# /*:°• Function Arguments •°:*/ #
- name: salt
  type: bytes32
  description: The 32-byte random value used to create the proxy contract address.
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

> ℹ️ **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L857-L867"><code>computeCreate3Address(bytes32)</code></a> </summary>

Returns the address where a contract will be stored if deployed via _this contract_ (i.e. [`CreateX`](./src/CreateX.sol)) using the [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171) pattern (i.e. without an initcode factor). Any change in the `salt` value will result in a new destination address.

```yml
# /*:°• Function Argument •°:*/ #
- name: salt
  type: bytes32
  description: The 32-byte random value used to create the proxy contract address.

# /*:°• Return Value •°:*/ #
- name: computedAddress
  type: address
  description: The 20-byte address where a contract will be stored.
```

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L830-L855"><code>computeCreate3Address(bytes32,address)</code></a> </summary>

Returns the address where a contract will be stored if deployed via `deployer` using the [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171) pattern (i.e. without an initcode factor). Any change in the `salt` value will result in a new destination address.

```yml
# /*:°• Function Arguments •°:*/ #
- name: salt
  type: bytes32
  description: The 32-byte random value used to create the proxy contract address.
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
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L648-L663"><code>deployCreate3(bytes)</code></a> </summary>

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

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L616-L646"><code>deployCreate3(bytes32,bytes)</code></a> </summary>

Deploys a new contract via employing the [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171) pattern (i.e. without an initcode factor) and using the salt value `salt`, the creation bytecode `initCode`, and `msg.value` as inputs. In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `msg.value` is non-zero, `initCode` must have a `payable` constructor.

```yml
# /*:°• Function Arguments •°:*/ #
- name: salt
  type: bytes32
  description: The 32-byte random value used to create the proxy contract address.
- name: initCode
  type: bytes
  description: The creation bytecode.

# /*:°• Return Value •°:*/ #
- name: newContract
  type: address
  description: The 20-byte address where the contract was deployed.
```

> ℹ️ **Note**<br>
> We strongly recommend implementing a permissioned deploy protection by setting the first 20 bytes equal to `msg.sender` in the `salt` to prevent maliciously intended frontrun proxy deployments on other chains.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L797-L828"><code>deployCreate3AndInit(bytes,bytes,tuple(uint256,uint256))</code></a> </summary>

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

> ℹ️ **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L725-L760"><code>deployCreate3AndInit(bytes32,bytes,bytes,tuple(uint256,uint256))</code></a> </summary>

Deploys and initialises a new contract via employing the [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171) pattern (i.e. without an initcode factor) and using the salt value `salt`, the creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable` amounts `values`, and `msg.value` as inputs. In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor, and any excess ether is returned to `msg.sender`.

```yml
# /*:°• Function Arguments •°:*/ #
- name: salt
  type: bytes32
  description: The 32-byte random value used to create the proxy contract address.
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

> ℹ️ **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system. Furthermore, we strongly recommend implementing a permissioned deploy protection by setting the first 20 bytes equal to `msg.sender` in the `salt` to prevent maliciously intended frontrun proxy deployments on other chains.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L762-L795"><code>deployCreate3AndInit(bytes,bytes,tuple(uint256,uint256),address)</code></a> </summary>

Deploys and initialises a new contract via employing the [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171) pattern (i.e. without an initcode factor) and using the creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable` amounts `values`, the refund address `refundAddress`, and `msg.value` as inputs. The salt value is calculated _pseudo-randomly_ using a diverse selection of block and transaction properties. This approach does not guarantee true randomness! In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor.

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

> ℹ️ **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L665-L723"><code>deployCreate3AndInit(bytes32,bytes,bytes,tuple(uint256,uint256),address)</code></a> </summary>

Deploys and initialises a new contract via employing the [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171) pattern (i.e. without an initcode factor) and using the salt value `salt`, the creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable` amounts `values`, the refund address `refundAddress`, and `msg.value` as inputs. In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor.

```yml
# /*:°• Function Arguments •°:*/ #
- name: salt
  type: bytes32
  description: The 32-byte random value used to create the proxy contract address.
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

> ℹ️ **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system. Furthermore, we strongly recommend implementing a permissioned deploy protection by setting the first 20 bytes equal to `msg.sender` in the `salt` to prevent maliciously intended frontrun proxy deployments on other chains.

</details>

## Special Features

> [!TIP]
> Note that the separate project [`createXcrunch`](https://github.com/HrikB/createXcrunch) is a [Rust](https://www.rust-lang.org)-based program designed to efficiently find _zero-leading_, _zero-containing_, or _pattern-matching_ deployment addresses, taking into account the subsequent special features of [`CreateX`](./src/CreateX.sol).

### Permissioned Deploy Protection and Cross-Chain Redeploy Protection

The `salt` value implements different safeguarding mechanisms depending on the encoded values in the salt (`||` stands for byte-wise concatenation):

```console
=> salt (32 bytes) = 0xbebebebebebebebebebebebebebebebebebebebe||ff||1212121212121212121212
```

- The first 20 bytes (i.e. `bebebebebebebebebebebebebebebebebebebebe`) may be used to implement a permissioned deploy protection by setting them equal to `msg.sender`,
- The 21st byte (i.e. `ff`) may be used to implement a cross-chain redeploy protection by setting it equal to `0x01`,
- The last random 11 bytes (i.e. `1212121212121212121212`) allow for $2^{88}$ bits of entropy for mining a salt.

The full logic is implemented in the `internal` [`_guard`](./src/CreateX.sol#L873-L912) function:

```solidity
function _guard(bytes32 salt) internal view returns (bytes32 guardedSalt) {
  (
    SenderBytes senderBytes,
    RedeployProtectionFlag redeployProtectionFlag
  ) = _parseSalt({ salt: salt });

  if (
    senderBytes == SenderBytes.MsgSender &&
    redeployProtectionFlag == RedeployProtectionFlag.True
  ) {
    // Configures a permissioned deploy protection as well as a cross-chain redeploy protection.
    guardedSalt = keccak256(abi.encode(msg.sender, block.chainid, salt));
  } else if (
    senderBytes == SenderBytes.MsgSender &&
    redeployProtectionFlag == RedeployProtectionFlag.False
  ) {
    // Configures solely a permissioned deploy protection.
    guardedSalt = _efficientHash({
      a: bytes32(uint256(uint160(msg.sender))),
      b: salt
    });
  } else if (senderBytes == SenderBytes.MsgSender) {
    // Reverts if the 21st byte is greater than `0x01` in order to enforce developer explicitness.
    revert InvalidSalt({ emitter: _SELF });
  } else if (
    senderBytes == SenderBytes.ZeroAddress &&
    redeployProtectionFlag == RedeployProtectionFlag.True
  ) {
    // Configures solely a cross-chain redeploy protection. In order to prevent a pseudo-randomly
    // generated cross-chain redeploy protection, we enforce the zero address check for the first 20 bytes.
    guardedSalt = _efficientHash({ a: bytes32(block.chainid), b: salt });
  } else if (
    senderBytes == SenderBytes.ZeroAddress &&
    redeployProtectionFlag == RedeployProtectionFlag.Unspecified
  ) {
    // Reverts if the 21st byte is greater than `0x01` in order to enforce developer explicitness.
    revert InvalidSalt({ emitter: _SELF });
  } else {
    // For the non-pseudo-random cases, the salt value `salt` is hashed to prevent the safeguard mechanisms
    // from being bypassed. Otherwise, the salt value `salt` is not modified.
    guardedSalt = (salt != _generateSalt())
      ? keccak256(abi.encode(salt))
      : salt;
  }
}
```

Please note that when you configure a permissioned deploy protection, you **must** specify whether you want cross-chain redeploy protection (i.e. 21st byte equals `0x01`) or not (i.e. the 21st byte equals `0x00`). The underlying reason for this logic is to enforce developer explicitness. If you don't specify a cross-chain redeploy protection decision (i.e. the 21st byte is greater than `0x01`) the function reverts.

Furthermore, you can configure _only_ cross-chain redeploy protection by setting the first 20 bytes equal to the zero address `0x0000000000000000000000000000000000000000`. The rationale behind this logic is to prevent a pseudo-randomly generated 32 byte salt from inadvertently activating cross-chain redeploy protection. Also in this case, if you don't specify a cross-chain redeploy protection, i.e. the 21st byte is greater than `0x01`, the function reverts. The underlying reason for this logic is as well to enforce developer explicitness.

> [!IMPORTANT]
> When using the read-only functions [`computeCreate2Address(bytes32,bytes32)`](https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L600-L610) or [`computeCreate3Address(bytes32)`](https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L857-L867), it is essential to provide the _guarded_ `salt` value, meaning the value after being processed by the `_guard` function, as the input parameter. This ensures the correct computation of the deployment address. For more details, refer to [this issue](https://github.com/pcaversaccio/createx/issues/140).

### Pseudo-Random Salt Value

For developer convenience, the [`CreateX`](./src/CreateX.sol) contract offers several overloaded functions that generate the salt value pseudo-randomly using a diverse selection of block and transaction properties. Please note that this approach does not guarantee true randomness!

The full logic is implemented in the `internal` [`_generateSalt`](./src/CreateX.sol#L960-L988) function:

```solidity
function _generateSalt() internal view returns (bytes32 salt) {
  unchecked {
    salt = keccak256(
      abi.encode(
        // We don't use `block.number - 256` (the maximum value on the EVM) to accommodate
        // any chains that may try to reduce the amount of available historical block hashes.
        // We also don't subtract 1 to mitigate any risks arising from consecutive block
        // producers on a PoS chain. Therefore, we use `block.number - 32` as a reasonable
        // compromise, one we expect should work on most chains, which is 1 epoch on Ethereum
        // mainnet. Please note that if you use this function between the genesis block and block
        // number 31, the block property `blockhash` will return zero, but the returned salt value
        // `salt` will still have a non-zero value due to the hashing characteristic and the other
        // remaining properties.
        blockhash(block.number - 32),
        block.coinbase,
        block.number,
        block.timestamp,
        block.prevrandao,
        block.chainid,
        msg.sender
      )
    );
  }
}
```

## Design Principles

- [`CreateX`](./src/CreateX.sol) should cover _most_ but not all contract creation use cases.
- [`CreateX`](./src/CreateX.sol) should be human-readable and should be simple to understand for readers with low prior experience.
- [`CreateX`](./src/CreateX.sol) should be maximally secure, i.e. no hidden footguns.
- [`CreateX`](./src/CreateX.sol) should be trustless.
- [`CreateX`](./src/CreateX.sol) should be stateless.
- [`CreateX`](./src/CreateX.sol) should be extensible (i.e. it can be used to deploy protocols, within protocols, or to deploy other types of deterministic deployer factories).

The following consequences result from these principles:

- We only use inline assembly if it is required or if the code section itself is based on short and/or audited code.
- We document the contract to the smallest detail.
- We extensively fuzz test all functions.
- We deliberately do not implement special functions for [clones with immutable arguments](https://github.com/wighawag/clones-with-immutable-args), as there is neither a finalised standard nor a properly audited contract version.
- We do not implement any special functions for [EIP-5202](https://eips.ethereum.org/EIPS/eip-5202) (a.k.a. blueprint contracts), as all existing functions in [`CreateX`](./src/CreateX.sol) are already cost-effective alternatives in our opinion.

## Security Considerations

<!-- prettier-ignore-start -->
> [!WARNING]
> **This contract is unaudited!** Special thanks go to [Oleksii Matiiasevych](https://github.com/lastperson) for his thorough review and feedback 🙏🏽.
<!-- prettier-ignore-end -->

Generally, for security issues, see our [Security Policy](./SECURITY.md). Furthermore, you must be aware of the following aspects:

- Several functions allow for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system.
- In the functions:

  - [`deployCreate3(bytes32,bytes)`](https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L616-L646),
  - [`deployCreate3AndInit(bytes32,bytes,bytes,tuple(uint256,uint256))`](https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L725-L760), and
  - [`deployCreate3AndInit(bytes32,bytes,bytes,tuple(uint256,uint256),address)`](https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L665-L723)

  we strongly recommend implementing a permissioned deploy protection by setting the first 20 bytes equal to `msg.sender` in the `salt` to prevent maliciously intended frontrun proxy deployments on other chains.

- The target EVM version for compilation is set to [`paris`](https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/paris.md), i.e. neither the contract creation bytecode of [`CreateX`](./src/CreateX.sol) nor the returned runtime bytecode contains a [`PUSH0`](https://www.evm.codes/#5f?fork=shanghai) instruction.
- Please refer to our comment in the discussion [here](https://github.com/pcaversaccio/createx/discussions/61#discussioncomment-7937359) for background information on the risks of our private-key-based deployment approach. We recommend verifying prior to interacting with [`CreateX`](./src/CreateX.sol) on any chain, that the `keccak256` hash of the broadcasted contract creation bytecode is `0x12ec861579b63a3ab9db3b5a23c57d56402ad3061475b088f17054e2f2daf22f` or of the deployed runtime bytecode is `0xbd8a7ea8cfca7b4e5f5041d7d4b17bc317c5ce42cfbc42066a00cf26b43eb53f`.

## Tests

For all (fuzz) tests available in the [`test`](./test) directory, we have consistently applied the [Branching Tree Technique](https://x.com/PaulRBerg/status/1682346315806539776) with [`bulloak`](https://github.com/alexfertel/bulloak). This means that each test file is accompanied by a `.tree` file that defines all the necessary branches to be tested.

**Example ([`CreateX._guard.tree`](./test/internal/CreateX._guard.tree)):**

```tree
CreateX_Guard_Internal_Test
├── When the first 20 bytes of the salt equals the caller
│   ├── When the 21st byte of the salt equals 0x01
│   │   └── It should return the keccak256 hash of the ABI-encoded values msg.sender, block.chainid, and the salt.
│   ├── When the 21st byte of the salt equals 0x00
│   │   └── It should return the keccak256 hash of the ABI-encoded values msg.sender and the salt.
│   └── When the 21st byte of the salt is greater than 0x01
│       └── It should revert.
├── When the first 20 bytes of the salt equals the zero address
│   ├── When the 21st byte of the salt equals 0x01
│   │   └── It should return the keccak256 hash of the ABI-encoded values block.chainid and the salt.
│   ├── When the 21st byte of the salt equals 0x00
│   │   └── It should return the keccak256 hash of the ABI-encoded value salt.
│   └── When the 21st byte of the salt is greater than 0x01
│       └── It should revert.
└── When the first 20 bytes of the salt do not equal the caller or the zero address
    ├── It should return the keccak256 hash of the ABI-encoded value salt.
    └── When the salt value is generated pseudo-randomly
        └── It should return the unmodified salt value.
```

### Test Coverage

This project repository uses [`forge coverage`](https://book.getfoundry.sh/reference/forge/forge-coverage). Simply run:

```console
forge coverage
```

In order to generate an `HTML` file with the coverage data, you can invoke:

```console
pnpm coverage:report
```

The written tests available in the directory [`test`](./test) achieve a test coverage of **100%** for the [`CreateX`](./src/CreateX.sol) contract:

```console
| File            | % Lines           | % Statements      | % Branches      | % Funcs         |
|-----------------|-------------------|-------------------|-----------------|-----------------|
| src/CreateX.sol | 100.00% (206/206) | 100.00% (211/211) | 100.00% (61/61) | 100.00% (31/31) |
```

> [!IMPORTANT]
> A test coverage of 100% does not mean that there are no vulnerabilities. What really counts is the quality and spectrum of the tests themselves!

## ABI (Application Binary Interface)

> [!TIP]
> If you `forge install` this repository, the Solidity-based interface can also be found [here](./src/ICreateX.sol).

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

## New Deployment(s)

We offer two options for deploying [`CreateX`](./src/CreateX.sol) to your desired chain:

1. Deploy it yourself by using one of the pre-signed transactions. Details can be found in the subsequent paragraph.
2. Request a deployment by opening an [issue](https://github.com/pcaversaccio/createx/issues/new?assignees=pcaversaccio&labels=new+deployment+%E2%9E%95&projects=&template=deployment_request.yml&title=%5BNew-Deployment-Request%5D%3A+). You can significantly reduce the time to deployment by sending funds to cover the deployment cost (a reliable amount with a small tip 😏 would be ~0.3 ETH) to the deployer account: `0xeD456e05CaAb11d66C4c797dD6c1D6f9A7F352b5`.

> [!CAUTION]
> Prior to using a pre-signed transaction, you **MUST** ensure that the gas metering of the target chain is **EQUIVALENT** to that of Ethereum's EVM version!
>
> The _default_ pre-signed transaction has a gas limit of 3,000,000 gas, so if the target chain requires more than 3 million gas to deploy, the contract creation transaction will revert and we will not be able to deploy [`CreateX`](./src/CreateX.sol) to the address `0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed`. In this case, the only way to get [`CreateX`](./src/CreateX.sol) deployed at the expected address is for the chain to store the contract there as a predeploy.
>
> If you are not sure how to validate this, you can either use the [`eth_estimateGas`](https://ethereum.github.io/execution-apis/api-documentation/) JSON-RPC method or simply deploy the [`CreateX`](./src/CreateX.sol) contract from another account and see how much gas is needed for the deployment. Standard EVM chains should require exactly 2,580,902 gas to deploy [`CreateX`](./src/CreateX.sol).

We repeat: PLEASE DO NOT BROADCAST ANY PRE-SIGNED TRANSACTION WITHOUT LOCAL TESTING! Also, before deploying, you MUST send at least 0.3 ETH to the deployer address `0xeD456e05CaAb11d66C4c797dD6c1D6f9A7F352b5`. We offer three pre-signed, pre-[`EIP-155`](https://eips.ethereum.org/EIPS/eip-155) transactions with the same gas price of 100 gwei, but different `gasLimit` levels:

- _Default Case:_ `gasLimit = 3_000_000`; [`signed_serialised_transaction_gaslimit_3000000_.json`](./scripts/presigned-createx-deployment-transactions/signed_serialised_transaction_gaslimit_3000000_.json),
- _Medium Case:_ `gasLimit = 25_000_000`; [`signed_serialised_transaction_gaslimit_25000000_.json`](./scripts/presigned-createx-deployment-transactions/signed_serialised_transaction_gaslimit_25000000_.json),
- _Heavy Case:_ `gasLimit = 45_000_000`; [`signed_serialised_transaction_gaslimit_45000000_.json`](./scripts/presigned-createx-deployment-transactions/signed_serialised_transaction_gaslimit_45000000_.json).

You can broadcast the transaction using either [`ethers.js`](https://docs.ethers.org/v6/) or [`cast`](https://book.getfoundry.sh/reference/cli/cast):

#### [`ethers.js`](https://docs.ethers.org/v6/)

It is recommended to install [`pnpm`](https://pnpm.io) through the `npm` package manager, which comes bundled with [Node.js](https://nodejs.org/en) when you install it on your system. It is recommended to use a Node.js version `>=22.11.0`.

Once you have `npm` installed, you can run the following both to install and upgrade `pnpm`:

```console
npm install -g pnpm
```

After having installed `pnpm`, simply run:

```console
git clone https://github.com/pcaversaccio/createx.git
cd createx
pnpm install
```

Now configure your target chain in the [`hardhat.config.ts`](./hardhat.config.ts) file with the `networks` and `etherscan` properties, or use one of the preconfigured network configurations. After you have locally ensured that the `gasLimit` of 3 million works on your target chain, you can invoke:

```console
npx hardhat run --no-compile --network <NETWORK_NAME> scripts/deploy.ts
```

The [`deploy.ts`](./scripts/deploy.ts) script ensures that [`CreateX`](./src/CreateX.sol) is automatically verified if you have configured the `etherscan` property accordingly. The current script broadcasts the _default_ pre-signed transaction, which has a gas limit of 3,000,000 gas. If you want to use a different pre-signed transaction, you must change the import of the pre-signed transaction in the [`deploy.ts`](./scripts/deploy.ts) script.

#### [`cast`](https://book.getfoundry.sh/reference/cli/cast)

It is recommended to install [Foundry](https://github.com/foundry-rs/foundry) via:

```console
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

To broadcast a pre-signed transaction, you can invoke:

```console
# $TX is the pre-signed transaction.
# $RPC_URL is the RPC URL of the target chain to which you want to deploy.
cast publish $TX --rpc-url $RPC_URL
```

You must verify the [`CreateX`](./src/CreateX.sol) contract separately, as specified in the next section.

> [!IMPORTANT]
> After deployment, please open a pull request that updates the [`deployments.json`](./deployments/deployments.json) file and the [`CreateX` Deployments](#createx-deployments) section with the new deployment so that other users can easily know that it has been deployed.

### Contract Verification

To verify a deployed [`CreateX`](./src/CreateX.sol) contract on a block explorer, use the following parameters:

- _Verification Method / Compiler Type:_ `Solidity (Standard JSON Input)`,
- _Compiler Version:_ `v0.8.23+commit.f704f362`,
- _Open Source License Type:_ `GNU Affero General Public License (GNU AGPLv3)`,
- _Standard Input JSON File:_ Upload the file [here](./verification/CreateX.json),
- _Constructor Arguments ABI-Encoded:_ Leave empty.

> [!IMPORTANT]
> We removed the metadata hash `bytecodeHash` from the bytecode in order to guarantee a deterministic compilation across all operating systems. This implies that all [sourcify.eth](https://sourcify.dev) verifications have partial verification, as opposed to [perfect verification](https://docs.sourcify.dev/blog/verify-contracts-perfectly/), which requires a matching metadata hash.

## [`CreateX`](./src/CreateX.sol) Deployments

📌 The deployment address of [`CreateX`](./src/CreateX.sol) is **`0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed`**.

> [!TIP]
> The complete list with additional chain information per deployment can be retrieved via [createx.rocks](https://createx.rocks). In addition, all [sourcify.eth](https://sourcify.dev) verification links (for the chains that are [supported](https://docs.sourcify.dev/docs/chains/) by [sourcify.eth](https://sourcify.dev)) can be found in the [`deployments.json`](./deployments/deployments.json) file.

#### EVM-Based Production Networks

- [Ethereum](https://etherscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [BNB Smart Chain](https://bscscan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [OP (Optimism)](https://optimistic.etherscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Arbitrum One](https://arbiscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Arbitrum Nova](https://nova.arbiscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Polygon](https://polygonscan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Polygon zkEVM](https://zkevm.polygonscan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Fantom](https://explorer.fantom.network/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Avalanche](https://snowscan.xyz/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Gnosis Chain](https://gnosisscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Moonriver](https://moonriver.moonscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Moonbeam](https://moonbeam.moonscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Celo](https://celoscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Aurora](https://explorer.mainnet.aurora.dev/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Harmony](https://explorer.harmony.one/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Fuse Network](https://explorer.fuse.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Cronos](https://cronoscan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Evmos](https://www.mintscan.io/evmos/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Boba Network](https://bobascan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Canto](https://tuber.build/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Base](https://basescan.org/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Mantle](https://mantlescan.xyz/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Filecoin](https://filfox.info/en/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Scroll](https://scrollscan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Linea](https://lineascan.build/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Zora](https://explorer.zora.energy/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [LUKSO](https://explorer.execution.mainnet.lukso.network/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Manta Pacific](https://pacific-explorer.manta.network/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Blast](https://blastscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [DOS Chain](https://doscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Fraxtal](https://fraxscan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Endurance](https://explorer-endurance.fusionist.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Kava](https://kavascan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Metis Andromeda](https://andromeda-explorer.metis.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Mode](https://explorer.mode.network/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Sei](https://seitrace.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed?chain=pacific-1)
- [X Layer](https://www.oklink.com/x-layer/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [BOB](https://explorer.gobob.xyz/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Core](https://scan.coredao.org/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Telos](https://www.teloscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Rootstock](https://rootstock.blockscout.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Chiliz](https://chiliscan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Taraxa](https://mainnet.explorer.taraxa.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Gravity Alpha](https://explorer.gravity.xyz/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Taiko](https://taikoscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [ZetaChain](https://explorer.zetachain.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [5ireChain](https://5irescan.io/contract/evm/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Oasis Sapphire](https://explorer.oasis.io/mainnet/sapphire/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [World Chain](https://worldscan.org/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Plume](https://explorer.plume.org/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Unichain](https://uniscan.xyz/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [XDC Network](https://xdcscan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [SX Network](https://explorerl2.sx.technology/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Lisk](https://blockscout.lisk.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Metal L2](https://explorer.metall2.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Superseed](https://explorer.superseed.xyz/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Sonic](https://sonicscan.org/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [EVM on Flow](https://evm.flowscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Ink](https://explorer.inkonchain.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Morph](https://explorer.morphl2.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Shape](https://shapescan.xyz/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Etherlink](https://explorer.etherlink.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Soneium](https://soneium.blockscout.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Swellchain](https://explorer.swellnetwork.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Hemi](https://explorer.hemi.xyz/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Berachain](https://berascan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Corn Maizenet](https://cornscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Arena-Z](https://explorer.arena-z.gg/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [IoTeX](https://iotexscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [HYCHAIN](https://explorer.hychain.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Zircuit](https://explorer.zircuit.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Bitlayer](https://www.btrscan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Ronin](https://app.roninchain.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [ZKsync Era](https://era.zksync.network/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Immutable zkEVM](https://explorer.immutable.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)

#### Ethereum Test Networks

- [Sepolia](https://sepolia.etherscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Holešky (Holešovice)](https://holesky.etherscan.io/address/0xba5ed099633d3b313e4d5f7bdc1305d3c28ba5ed)
- [Hoodi](https://hoodi.etherscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)

#### Additional EVM-Based Test Networks

- [BNB Smart Chain Testnet](https://testnet.bscscan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [OP (Optimism) Sepolia Testnet](https://sepolia-optimism.etherscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Arbitrum Sepolia Testnet](https://sepolia.arbiscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Polygon Sepolia Testnet (Amoy)](https://amoy.polygonscan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Polygon Testnet (zkEVM)](https://cardona-zkevm.polygonscan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Fantom Testnet](https://explorer.testnet.fantom.network/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Avalanche Testnet (Fuji)](https://testnet.snowscan.xyz/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Gnosis Chain Testnet (Chiado)](https://gnosis-chiado.blockscout.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Moonbeam Testnet (Moonbase Alpha)](https://moonbase.moonscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Celo Testnet (Alfajores)](https://alfajores.celoscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Aurora Testnet](https://explorer.testnet.aurora.dev/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Harmony Testnet](https://explorer.testnet.harmony.one/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Fuse Network Testnet (Spark)](https://explorer.fusespark.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Cronos Testnet](https://cronos.org/explorer/testnet3/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Evmos Testnet](https://www.mintscan.io/evmos-testnet/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Boba Network Testnet](https://testnet.bobascan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Canto Testnet](https://testnet.tuber.build/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Base Sepolia Testnet](https://sepolia.basescan.org/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Mantle Sepolia Testnet](https://sepolia.mantlescan.xyz/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Filecoin Testnet (Calibration)](https://calibration.filfox.info/en/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Scroll Sepolia Testnet](https://sepolia.scrollscan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Linea Sepolia Testnet](https://sepolia.lineascan.build/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Zora Sepolia Testnet](https://sepolia.explorer.zora.energy/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [LUKSO Testnet](https://explorer.execution.testnet.lukso.network/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Manta Pacific Sepolia Testnet](https://pacific-explorer.sepolia-testnet.manta.network/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Blast Sepolia Testnet](https://sepolia.blastscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [DOS Chain Testnet](https://test.doscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Fraxtal Holešky Testnet](https://holesky.fraxscan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Metis Sepolia Testnet](https://sepolia-explorer.metisdevops.link/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Mode Sepolia Testnet](https://sepolia.explorer.mode.network/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Sei Arctic Devnet](https://seitrace.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed?chain=arctic-1)
- [Sei Atlantic Testnet](https://seitrace.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed?chain=atlantic-2)
- [X Layer Sepolia Testnet](https://www.oklink.com/x-layer-testnet/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [BOB Sepolia Testnet](https://testnet-explorer.gobob.xyz/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Core Testnet](https://scan.test.btcs.network/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Telos Testnet](https://testnet.teloscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Rootstock Testnet](https://rootstock-testnet.blockscout.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Chiliz Testnet (Spicy)](https://testnet.chiliscan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Taraxa Testnet](https://testnet.explorer.taraxa.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Taiko Holešky Testnet](https://hekla.taikoscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [ZetaChain Testnet (Athens-3)](https://athens.explorer.zetachain.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [5ireChain Testnet](https://testnet.5irescan.io/contract/evm/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Oasis Sapphire Testnet](https://explorer.oasis.io/testnet/sapphire/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [World Chain Sepolia Testnet](https://sepolia.worldscan.org/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Plume Sepolia Testnet](https://testnet-explorer.plume.org/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Unichain Sepolia Testnet](https://sepolia.uniscan.xyz/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [XDC Network Testnet (Apothem)](https://testnet.xdcscan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [SX Network Sepolia Testnet (Toronto)](https://explorerl2.toronto.sx.technology/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Lisk Sepolia Testnet](https://sepolia-blockscout.lisk.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Metal L2 Sepolia Testnet](https://testnet.explorer.metall2.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Superseed Sepolia Testnet](https://sepolia-explorer.superseed.xyz/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Story Testnet (Aeneid)](https://aeneid.storyscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Sonic Testnet (Blaze)](https://testnet.sonicscan.org/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [EVM on Flow Testnet](https://evm-testnet.flowscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Ink Sepolia Testnet](https://explorer-sepolia.inkonchain.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Morph Holešky Testnet](https://explorer-holesky.morphl2.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Shape Sepolia Testnet](https://sepolia.shapescan.xyz/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Etherlink Testnet (Ghostnet)](https://testnet.explorer.etherlink.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Soneium Sepolia Testnet (Minato)](https://soneium-minato.blockscout.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Swellchain Sepolia Testnet](https://swell-testnet-explorer.alt.technology/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Hemi Sepolia Testnet](https://testnet.explorer.hemi.xyz/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Berachain Testnet (Bepolia)](https://testnet.berascan.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Monad Testnet](https://testnet.monadexplorer.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Corn Sepolia Testnet](https://testnet.cornscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Arena-Z Sepolia Testnet](https://arena-z.blockscout.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [IoTeX Testnet](https://testnet.iotexscan.io/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [HYCHAIN Testnet](https://testnet.explorer.hychain.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Zircuit Sepolia Testnet (Garfield)](https://explorer.garfield-testnet.zircuit.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [MegaETH Testnet](https://www.megaexplorer.xyz/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Bitlayer Testnet](https://testnet-scan.bitlayer.org/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Ronin Testnet (Saigon)](https://saigon-app.roninchain.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [ZKsync Era Sepolia Testnet](https://sepolia-era.zksync.network/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)
- [Immutable zkEVM Sepolia Testnet](https://explorer.testnet.immutable.com/address/0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed)

## Integration With External Tooling

A list of external tooling that integrates with [`CreateX`](./src/CreateX.sol):

- [`xdeployer`](https://github.com/pcaversaccio/xdeployer)
- [`createx-forge`](https://github.com/radeksvarz/createx-forge)
- [`createXcrunch`](https://github.com/HrikB/createXcrunch)
- [`hardhat-ignition`](https://github.com/NomicFoundation/hardhat-ignition)

## Community-Maintained Dune Dashboards

- [`CreateX` Factory](https://dune.com/patronumlabs/createx)

## 🙏🏼 Acknowledgement

All the work has been done jointly by myself and [Matt Solomon](https://github.com/mds1) as a public good for our ecosystem. Public good software is not just code; it's the embodiment of collective progress, a testament to collaboration's power, and a canvas where innovation meets the needs of the many. I hope we can live up to these principles! 🫡
