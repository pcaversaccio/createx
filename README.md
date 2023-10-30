# `CreateX` – A Trustless, Universal Contract Deployer

[![Test smart contracts](https://github.com/pcaversaccio/createx/actions/workflows/test-contracts.yml/badge.svg)](https://github.com/pcaversaccio/createx/actions/workflows/test-contracts.yml)
[![Test coverage](https://img.shields.io/badge/coverage-100%25-yellowgreen)](#test-coverage)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

<img src=https://github-production-user-asset-6210df.s3.amazonaws.com/25297591/272914952-38a5989c-0113-427d-9158-47646971b7d8.png  width="1050"/>

Factory smart contract to make easier and safer usage of the [`CREATE`](https://www.evm.codes/#f0?fork=shanghai) and [`CREATE2`](https://www.evm.codes/#f5?fork=shanghai) EVM opcodes as well as of [`CREATE3`](https://github.com/ethereum/EIPs/pull/3171)-based contract creations.

## Features

TBD (elaborate here what is all possible)

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
