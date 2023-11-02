# `CreateX` – A Trustless, Universal Contract Deployer

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

Returns the address where a contract will be stored if deployed via _this contract_ using the `CREATE` opcode. For the specification of the Recursive Length Prefix (RLP) encoding scheme, please refer to p. 19 of the [Ethereum Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf) and the [Ethereum Wiki](https://ethereum.org/en/developers/docs/data-structures-and-encoding/rlp/). Based on the [EIP-161](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-161.md) specification, all contract accounts on the Ethereum mainnet are initiated with `nonce = 1`. Thus, the first contract address created by another contract is calculated with a non-zero nonce.

</details>

<details>
<summary> <code>computeCreateAddress(address,uint256)</code> </summary>

Returns the address where a contract will be stored if deployed via `deployer` using the `CREATE` opcode. For the specification of the Recursive Length Prefix (RLP) encoding scheme, please refer to p. 19 of the [Ethereum Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf) and the [Ethereum Wiki](https://ethereum.org/en/developers/docs/data-structures-and-encoding/rlp/). Based on the [EIP-161](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-161.md) specification, all contract accounts on the Ethereum mainnet are initiated with `nonce = 1`. Thus, the first contract address created by another contract is calculated with a non-zero nonce.

</details>

<details>
<summary> <code>deployCreate(bytes)</code> </summary>

Deploys a new contract via calling the `CREATE` opcode and using the creation bytecode `initCode` and `msg.value` as inputs. In order to save deployment costs, we do not sanity check the `initCode` length. Note that if `msg.value` is non-zero, `initCode` must have a `payable` constructor.

<details>
<summary> <code>deployCreateAndInit(bytes,bytes,tuple(uint256,uint256))</code> </summary>

</details>

<details>
<summary> <code>deployCreateAndInit(bytes,bytes,tuple(uint256,uint256),address)</code> </summary>

</details>

<details>
<summary> <code>deployCreateClone(address,bytes)</code> </summary>

</details>

<details>
<summary> <code>computeCreate2Address(bytes32,bytes32)</code> </summary>

</details>

<details>
<summary> <code>computeCreate2Address(bytes32,bytes32,address)</code> </summary>

</details>

<details>
<summary> <code>deployCreate2(bytes)</code> </summary>

</details>

<details>
<summary> <code>deployCreate2(bytes32,bytes)</code> </summary>

</details>

<details>
<summary> <code>deployCreate2AndInit(bytes,bytes,tuple(uint256,uint256))</code> </summary>

</details>

<details>
<summary> <code>deployCreate2AndInit(bytes32,bytes,bytes,tuple(uint256,uint256))</code> </summary>

</details>

<details>
<summary> <code>deployCreate2AndInit(bytes,bytes,tuple(uint256,uint256),address)</code> </summary>

</details>

<details>
<summary> <code>deployCreate2AndInit(bytes32,bytes,bytes,tuple(uint256,uint256),address)</code> </summary>

</details>

<details>
<summary> <code>deployCreate2Clone(bytes32,address,bytes)</code> </summary>

</details>

<details>
<summary> <code>deployCreate2Clone(address,bytes)</code> </summary>

</details>

<details>
<summary> <code>computeCreate3Address(bytes32)</code> </summary>

</details>

<details>
<summary> <code>computeCreate3Address(bytes32,address)</code> </summary>

</details>

<details>
<summary> <code>deployCreate3(bytes)</code> </summary>

</details>

<details>
<summary> <code>deployCreate3(bytes32,bytes)</code> </summary>

</details>

<details>
<summary> <code>deployCreate3AndInit(bytes,bytes,tuple(uint256,uint256))</code> </summary>

</details>

<details>
<summary> <code>deployCreate3AndInit(bytes32,bytes,bytes,tuple(uint256,uint256))</code> </summary>

</details>

<details>
<summary> <code>deployCreate3AndInit(bytes,bytes,tuple(uint256,uint256),address)</code> </summary>

</details>

<details>
<summary> <code>deployCreate3AndInit(bytes32,bytes,bytes,tuple(uint256,uint256),address)</code> </summary>

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
