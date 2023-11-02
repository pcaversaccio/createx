# [`CreateX`](./src/CreateX.sol) – A Trustless, Universal Contract Deployer

[![🕵️‍♂️ Test smart contracts](https://github.com/pcaversaccio/createx/actions/workflows/test-contracts.yml/badge.svg)](https://github.com/pcaversaccio/createx/actions/workflows/test-contracts.yml)
[![Test coverage](https://img.shields.io/badge/coverage-100%25-yellowgreen)](#test-coverage)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

<img src=https://github-production-user-asset-6210df.s3.amazonaws.com/25297591/272914952-38a5989c-0113-427d-9158-47646971b7d8.png  width="1050"/>

Factory smart contract to make easier and safer usage of the [`CREATE`](https://www.evm.codes/#f0?fork=shanghai) and [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai) EVM opcodes as well as of [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171)-based (i.e. without an initcode factor) contract creations.

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
│       ├── "function deployCreate2Clone(bytes32,address,bytes) payable returns (address)"
│       └── "function deployCreate2Clone(address,bytes) payable returns (address)"
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

```solidity
/**
 * @param nonce The next 32-byte nonce of this contract.
 */
```

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L242-L300"><code>computeCreateAddress(address,uint256)</code></a> </summary>

Returns the address where a contract will be stored if deployed via `deployer` using the [`CREATE`](https://www.evm.codes/#f0?fork=shanghai) opcode. For the specification of the Recursive Length Prefix (RLP) encoding scheme, please refer to p. 19 of the [Ethereum Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf) and the [Ethereum Wiki](https://ethereum.org/en/developers/docs/data-structures-and-encoding/rlp/). Based on the [EIP-161](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-161.md) specification, all contract accounts on the Ethereum mainnet are initiated with `nonce = 1`. Thus, the first contract address created by another contract is calculated with a non-zero nonce.

```solidity
/**
 * @param deployer The 20-byte deployer address.
 * @param nonce The next 32-byte nonce of the deployer address.
 */ 
```

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L122-L136"><code>deployCreate(bytes)</code></a> </summary>

Deploys a new contract via calling the [`CREATE`](https://www.evm.codes/#f0?fork=shanghai) opcode and using the creation bytecode `initCode` and `msg.value` as inputs. In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `msg.value` is non-zero, `initCode` must have a `payable` constructor.

```solidity
/// Function Arguments
@param initCode The creation bytecode.
```

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L180-L200"><code>deployCreateAndInit(bytes,bytes,tuple(uint256,uint256))</code></a> </summary>

Deploys and initialises a new contract via calling the [`CREATE`](https://www.evm.codes/#f0?fork=shanghai) opcode and using the creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable` amounts `values`, and `msg.value` as inputs. In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor, and any excess ether is returned to `msg.sender`.

```solidity
/// Function Arguments
@param initCode The creation bytecode.
@param data The initialisation code that is passed to the deployed contract.
@param values The specific `payable` amounts for the deployment and initialisation call.
```

> **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L138-L178"><code>deployCreateAndInit(bytes,bytes,tuple(uint256,uint256),address)</code></a> </summary>

Deploys and initialises a new contract via calling the [`CREATE`](https://www.evm.codes/#f0?fork=shanghai) opcode and using the creation bytecode `initCode`, the initialisation code `data`, the struct for the `payable` amounts `values`, the refund address `refundAddress`, and `msg.value` as inputs. In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `values.constructorAmount` is non-zero, `initCode` must have a `payable` constructor.

```solidity
/// Function Arguments
@param initCode The creation bytecode.
@param data The initialisation code that is passed to the deployed contract.
@param values The specific `payable` amounts for the deployment and initialisation call.
@param refundAddress The 20-byte address where any excess ether is returned to.
```

> **Note**<br>
> This function allows for reentrancy, however we refrain from adding a mutex lock to keep it as use-case agnostic as possible. Please ensure at the protocol level that potentially malicious reentrant calls do not affect your smart contract system.

</details>

<details>
<summary> <a href="https://github.com/pcaversaccio/createx/blob/main/src/CreateX.sol#L202-L240"><code>deployCreateClone(address,bytes)</code> </a> </summary>

Deploys a new [EIP-1167](https://eips.ethereum.org/EIPS/eip-1167) minimal proxy contract using the [`CREATE`](https://www.evm.codes/#f0?fork=shanghai) opcode, and initialises the implementation contract using the implementation address `implementation`, the initialisation code `data`, and `msg.value` as inputs. Note that if `msg.value` is non-zero, the initialiser function called via `data` must be `payable`.

```solidity
// Function Arguments
@param salt The 32-byte random value used to create the contract address.
@param initCode The creation bytecode.
```

</details>

<details>
<summary> <code>computeCreate2Address(bytes32,bytes32)</code> </summary>

```solidity
/// Function Arguments
```

</details>

<details>
<summary> <code>computeCreate2Address(bytes32,bytes32,address)</code> </summary>

```solidity
/// Function Arguments
```

</details>

<details>
<summary> <code>deployCreate2(bytes)</code> </summary>

```solidity
/// Function Arguments
```

</details>

<details>
<summary> <code>deployCreate2(bytes32,bytes)</code> </summary>

```solidity
/// Function Arguments
```

</details>

<details>
<summary> <code>deployCreate2AndInit(bytes,bytes,tuple(uint256,uint256))</code> </summary>

```solidity
/// Function Arguments
```

</details>

<details>
<summary> <code>deployCreate2AndInit(bytes32,bytes,bytes,tuple(uint256,uint256))</code> </summary>

```solidity
/// Function Arguments
```

</details>

<details>
<summary> <code>deployCreate2AndInit(bytes,bytes,tuple(uint256,uint256),address)</code> </summary>

```solidity
/// Function Arguments
```

</details>

<details>
<summary> <code>deployCreate2AndInit(bytes32,bytes,bytes,tuple(uint256,uint256),address)</code> </summary>

```solidity
/// Function Arguments
```

</details>

<details>
<summary> <code>deployCreate2Clone(bytes32,address,bytes)</code> </summary>

```solidity
/// Function Arguments
```

</details>

<details>
<summary> <code>deployCreate2Clone(address,bytes)</code> </summary>

```solidity
/// Function Arguments
```

</details>

<details>
<summary> <code>computeCreate3Address(bytes32)</code> </summary>

```solidity
/// Function Arguments
```

</details>

<details>
<summary> <code>computeCreate3Address(bytes32,address)</code> </summary>

```solidity
/// Function Arguments
```

</details>

<details>
<summary> <code>deployCreate3(bytes)</code> </summary>

```solidity
/// Function Arguments
```

</details>

<details>
<summary> <code>deployCreate3(bytes32,bytes)</code> </summary>

```solidity
/// Function Arguments
```

</details>

<details>
<summary> <code>deployCreate3AndInit(bytes,bytes,tuple(uint256,uint256))</code> </summary>

```solidity
/// Function Arguments
```

</details>

<details>
<summary> <code>deployCreate3AndInit(bytes32,bytes,bytes,tuple(uint256,uint256))</code> </summary>

```solidity
/// Function Arguments
```

</details>

<details>
<summary> <code>deployCreate3AndInit(bytes,bytes,tuple(uint256,uint256),address)</code> </summary>

```solidity
/// Function Arguments
```

</details>

<details>
<summary> <code>deployCreate3AndInit(bytes32,bytes,bytes,tuple(uint256,uint256),address)</code> </summary>

```solidity
/// Function Arguments
```

</details>

## Unit Tests

TBD

## Test Coverage

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

## Security Considerations

TBD

## Deployment Approach

TBD

## How to Request a Deployment

TBD

## Deployments [`CreateX`](./src/CreateX.sol)

TBD
