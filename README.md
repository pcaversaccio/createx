# [`CreateX`](./src/CreateX.sol) – A Trustless, Universal Contract Deployer

[![🕵️‍♂️ Test CreateX](https://github.com/pcaversaccio/createx/actions/workflows/test-createx.yml/badge.svg)](https://github.com/pcaversaccio/createx/actions/workflows/test-createx.yml)
[![Test Coverage](https://img.shields.io/badge/Coverage-100%25-green)](#test-coverage)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

<img src=https://github-production-user-asset-6210df.s3.amazonaws.com/25297591/272914952-38a5989c-0113-427d-9158-47646971b7d8.png  width="1050"/>

Factory smart contract to make easier and safer usage of the [`CREATE`](https://www.evm.codes/#f0?fork=shanghai) and [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai) EVM opcodes as well as of [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171)-based (i.e. without an initcode factor) contract creations.

> **Note**<br>
> The [`CreateX`](https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol) contract should be considered as maximally extensible. Be encouraged to build on top of it! The Solidity-based interface can be found [here](https://github.com/pcaversaccio/createx/blob/main/src/ICreateX.sol).

- [`CreateX` – A Trustless, Universal Contract Deployer](#createx--a-trustless-universal-contract-deployer)
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
    - [Contract Verification](#contract-verification)
  - [`CreateX` Deployments](#createx-deployments)

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
  description: The 32-byte random value used to create the proxy contract address.

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
  description: The 32-byte random value used to create the proxy contract address.
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

> **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system. Furthermore, we strongly recommend implementing a permissioned deploy protection by setting the first 20 bytes equal to `msg.sender` in the `salt` to prevent maliciously intended frontrun proxy deployments on other chains.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L764-L799"><code>deployCreate3AndInit(bytes,bytes,tuple(uint256,uint256),address)</code></a> </summary>

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

> **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system. Furthermore, this function does not implement any permissioned deploy protection, thus anyone can frontrun the same proxy deployment on other chains. Use with caution!

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L667-L725"><code>deployCreate3AndInit(bytes32,bytes,bytes,tuple(uint256,uint256),address)</code></a> </summary>

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

> **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system. Furthermore, we strongly recommend implementing a permissioned deploy protection by setting the first 20 bytes equal to `msg.sender` in the `salt` to prevent maliciously intended frontrun proxy deployments on other chains.

</details>

## Special Features

### Permissioned Deploy Protection and Cross-Chain Redeploy Protection

The `salt` value implements different safeguarding mechanisms depending on the encoded values in the salt (`||` stands for byte-wise concatenation):

```console
=> salt (32 bytes) = 0xbebebebebebebebebebebebebebebebebebebebe||ff||1212121212121212121212
```

- The first 20 bytes (i.e. `bebebebebebebebebebebebebebebebebebebebe`) may be used to implement a permissioned deploy protection by setting them equal to `msg.sender`,
- The 21st byte (i.e. `ff`) may be used to implement a cross-chain redeploy protection by setting it equal to `0x01`,
- The last random 11 bytes (i.e. `1212121212121212121212`) allow for $2^{88}$ bits of entropy for mining a salt.

The full logic is implemented in the `internal` [`_guard`](./src/CreateX.sol#L879-L917) function:

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
    // In all other cases, the salt value `salt` is not modified.
    guardedSalt = salt;
  }
}
```

Please note that when you configure a permissioned deploy protection, you **must** specify whether you want cross-chain redeploy protection (i.e. 21st byte equals `0x01`) or not (i.e. the 21st byte equals `0x00`). The underlying reason for this logic is to enforce developer explicitness. If you don't specify a cross-chain redeploy protection decision (i.e. the 21st byte is greater than `0x01`) the function reverts.

Furthermore, you can configure _only_ cross-chain redeploy protection by setting the first 20 bytes equal to the zero address `0x0000000000000000000000000000000000000000`. The rationale behind this logic is to prevent a pseudo-randomly generated 32 byte salt from inadvertently activating cross-chain redeploy protection. Also in this case, if you don't specify a cross-chain redeploy protection, i.e. the 21st byte is greater than `0x01`, the function reverts. The underlying reason for this logic is as well to enforce developer explicitness.

### Pseudo-Random Salt Value

For developer convenience, the [`CreateX`](./src/CreateX.sol) contract offers several overloaded functions that generate the salt value pseudo-randomly using a diverse selection of block and transaction properties. Please note that this approach does not guarantee true randomness!

The full logic is implemented in the `internal` [`_generateSalt`](./src/CreateX.sol#L965-L993) function:

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
> **Warning**<br>
> **This contract is unaudited!**
<!-- prettier-ignore-end -->

Generally, for security issues, see our [Security Policy](./SECURITY.md). Furthermore, you must be aware of the following aspects:

- Several functions allow for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system.
- In the functions:

  - [`deployCreate3(bytes32,bytes)`](https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L616-L646),
  - [`deployCreate3AndInit(bytes32,bytes,bytes,tuple(uint256,uint256))`](https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L727-L762), and
  - [`deployCreate3AndInit(bytes32,bytes,bytes,tuple(uint256,uint256),address)`](https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L667-L725)

  we strongly recommend implementing a permissioned deploy protection by setting the first 20 bytes equal to `msg.sender` in the `salt` to prevent maliciously intended frontrun proxy deployments on other chains.

- The functions:

  - [`deployCreate3(bytes)`](https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L648-L665),
  - [`deployCreate3AndInit(bytes,bytes,tuple(uint256,uint256))`](https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L801-L834), and
  - [`deployCreate3AndInit(bytes,bytes,tuple(uint256,uint256),address)`](https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L764-L799)

  do not implement any permissioned deploy protection, thus anyone can frontrun the same proxy deployment on other chains. Use with caution!

## Tests

For all (fuzz) tests available in the [`test`](./test) directory, we have consistently applied the [Branching Tree Technique](https://twitter.com/PaulRBerg/status/1682346315806539776) with [`bulloak`](https://github.com/alexfertel/bulloak). This means that each test file is accompanied by a `.tree` file that defines all the necessary branches to be tested.

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
│   │   └── It should return the unmodified salt value.
│   └── When the 21st byte of the salt is greater than 0x01
│       └── It should revert.
└── When the first 20 bytes of the salt do not equal the caller or the zero address
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
| src/CreateX.sol | 100.00% (149/149) | 100.00% (210/210) | 100.00% (78/78) | 100.00% (31/31) |
```

> **Note**<br>
> A test coverage of 100% does not mean that there are no vulnerabilities. What really counts is the quality and spectrum of the tests themselves!

## ABI (Application Binary Interface)

> **Note**<br>
> If you `forge install` this repository, the Solidity-based interface can also be found [here](https://github.com/pcaversaccio/createx/blob/main/src/ICreateX.sol).

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

> **Warning**<br>
> The address `0x0000000000000000000000000000000000000000` is a simple placeholder for now. Do not send any funds there!

We offer two options for deploying [`CreateX`](./src/CreateX.sol) to your desired chain:

1. Deploy it yourself by using one of the pre-signed transactions. Details can be found in the subsequent paragraph.
2. Request a deployment by opening an [issue](https://github.com/pcaversaccio/createx/issues/new?assignees=pcaversaccio&labels=new+deployment+%E2%9E%95&projects=&template=deployment_request.yml&title=%5BNew-Deployment-Request%5D%3A+). You can significantly reduce the time to deployment by sending funds to cover the deployment cost to the deployer account: [`0x0000000000000000000000000000000000000000`](https://etherscan.io/address/0x0000000000000000000000000000000000000000).

TBD (section on pre-signed transactions; we will offer multiple pre-signed transactions with different `gasLimit` levels; will be added after the feedback phase)

### Contract Verification

To verify a deployed [`CreateX`](./src/CreateX.sol) contract on a block explorer, use the following parameters:

- TBD (will be added after the feedback phase)

## [`CreateX`](./src/CreateX.sol) Deployments

> **Warning**<br>
> The address `0x0000000000000000000000000000000000000000` is a simple placeholder for now. Do not send any funds there!

- EVM-Based Production Networks:
  - Ethereum: [`0x0000000000000000000000000000000000000000`](https://etherscan.io/address/0x0000000000000000000000000000000000000000)
- Ethereum Test Networks:
  - Goerli: [`0x0000000000000000000000000000000000000000`](https://goerli.etherscan.io/address/0x0000000000000000000000000000000000000000)
- Additional EVM-Based Test Networks:
  - Optimism Testnet (Goerli): [`0x0000000000000000000000000000000000000000`](https://goerli-optimism.etherscan.io/address/0x0000000000000000000000000000000000000000)
