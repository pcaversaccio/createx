export const SITE_NAME = "CreateX";
export const SITE_DESCRIPTION = "A Trustless, Universal Contract Deployer";
export const COMPANY_NAME = "pcaversaccio";
export const COMPANY_URL = "https://pcaversaccio.com";
export const GITHUB_URL = "https://github.com/pcaversaccio/createx";
export const X_URL = "https://twitter.com/pcaversaccio";
export const SITE_IMAGE =
  "https://github-production-user-asset-6210df.s3.amazonaws.com/25297591/272914952-38a5989c-0113-427d-9158-47646971b7d8.png";

export const CREATEX_ADDRESS = "0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed";
export const CREATEX_ABI = [
  {
    inputs: [
      {
        internalType: "address",
        name: "emitter",
        type: "address",
      },
    ],
    name: "FailedContractCreation",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "emitter",
        type: "address",
      },
      {
        internalType: "bytes",
        name: "revertData",
        type: "bytes",
      },
    ],
    name: "FailedContractInitialisation",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "emitter",
        type: "address",
      },
      {
        internalType: "bytes",
        name: "revertData",
        type: "bytes",
      },
    ],
    name: "FailedEtherTransfer",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "emitter",
        type: "address",
      },
    ],
    name: "InvalidNonceValue",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "emitter",
        type: "address",
      },
    ],
    name: "InvalidSalt",
    type: "error",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "newContract",
        type: "address",
      },
      {
        indexed: true,
        internalType: "bytes32",
        name: "salt",
        type: "bytes32",
      },
    ],
    name: "ContractCreation",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "newContract",
        type: "address",
      },
    ],
    name: "ContractCreation",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "newContract",
        type: "address",
      },
      {
        indexed: true,
        internalType: "bytes32",
        name: "salt",
        type: "bytes32",
      },
    ],
    name: "Create3ProxyContractCreation",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "salt",
        type: "bytes32",
      },
      {
        internalType: "bytes32",
        name: "initCodeHash",
        type: "bytes32",
      },
    ],
    name: "computeCreate2Address",
    outputs: [
      {
        internalType: "address",
        name: "computedAddress",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "salt",
        type: "bytes32",
      },
      {
        internalType: "bytes32",
        name: "initCodeHash",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "deployer",
        type: "address",
      },
    ],
    name: "computeCreate2Address",
    outputs: [
      {
        internalType: "address",
        name: "computedAddress",
        type: "address",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "salt",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "deployer",
        type: "address",
      },
    ],
    name: "computeCreate3Address",
    outputs: [
      {
        internalType: "address",
        name: "computedAddress",
        type: "address",
      },
    ],
    stateMutability: "pure",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "salt",
        type: "bytes32",
      },
    ],
    name: "computeCreate3Address",
    outputs: [
      {
        internalType: "address",
        name: "computedAddress",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "nonce",
        type: "uint256",
      },
    ],
    name: "computeCreateAddress",
    outputs: [
      {
        internalType: "address",
        name: "computedAddress",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "deployer",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "nonce",
        type: "uint256",
      },
    ],
    name: "computeCreateAddress",
    outputs: [
      {
        internalType: "address",
        name: "computedAddress",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "initCode",
        type: "bytes",
      },
    ],
    name: "deployCreate",
    outputs: [
      {
        internalType: "address",
        name: "newContract",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "salt",
        type: "bytes32",
      },
      {
        internalType: "bytes",
        name: "initCode",
        type: "bytes",
      },
    ],
    name: "deployCreate2",
    outputs: [
      {
        internalType: "address",
        name: "newContract",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "initCode",
        type: "bytes",
      },
    ],
    name: "deployCreate2",
    outputs: [
      {
        internalType: "address",
        name: "newContract",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "salt",
        type: "bytes32",
      },
      {
        internalType: "bytes",
        name: "initCode",
        type: "bytes",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
      {
        components: [
          {
            internalType: "uint256",
            name: "constructorAmount",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "initCallAmount",
            type: "uint256",
          },
        ],
        internalType: "struct CreateX.Values",
        name: "values",
        type: "tuple",
      },
      {
        internalType: "address",
        name: "refundAddress",
        type: "address",
      },
    ],
    name: "deployCreate2AndInit",
    outputs: [
      {
        internalType: "address",
        name: "newContract",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "initCode",
        type: "bytes",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
      {
        components: [
          {
            internalType: "uint256",
            name: "constructorAmount",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "initCallAmount",
            type: "uint256",
          },
        ],
        internalType: "struct CreateX.Values",
        name: "values",
        type: "tuple",
      },
    ],
    name: "deployCreate2AndInit",
    outputs: [
      {
        internalType: "address",
        name: "newContract",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "initCode",
        type: "bytes",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
      {
        components: [
          {
            internalType: "uint256",
            name: "constructorAmount",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "initCallAmount",
            type: "uint256",
          },
        ],
        internalType: "struct CreateX.Values",
        name: "values",
        type: "tuple",
      },
      {
        internalType: "address",
        name: "refundAddress",
        type: "address",
      },
    ],
    name: "deployCreate2AndInit",
    outputs: [
      {
        internalType: "address",
        name: "newContract",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "salt",
        type: "bytes32",
      },
      {
        internalType: "bytes",
        name: "initCode",
        type: "bytes",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
      {
        components: [
          {
            internalType: "uint256",
            name: "constructorAmount",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "initCallAmount",
            type: "uint256",
          },
        ],
        internalType: "struct CreateX.Values",
        name: "values",
        type: "tuple",
      },
    ],
    name: "deployCreate2AndInit",
    outputs: [
      {
        internalType: "address",
        name: "newContract",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "salt",
        type: "bytes32",
      },
      {
        internalType: "address",
        name: "implementation",
        type: "address",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
    ],
    name: "deployCreate2Clone",
    outputs: [
      {
        internalType: "address",
        name: "proxy",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "implementation",
        type: "address",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
    ],
    name: "deployCreate2Clone",
    outputs: [
      {
        internalType: "address",
        name: "proxy",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "initCode",
        type: "bytes",
      },
    ],
    name: "deployCreate3",
    outputs: [
      {
        internalType: "address",
        name: "newContract",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "salt",
        type: "bytes32",
      },
      {
        internalType: "bytes",
        name: "initCode",
        type: "bytes",
      },
    ],
    name: "deployCreate3",
    outputs: [
      {
        internalType: "address",
        name: "newContract",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "salt",
        type: "bytes32",
      },
      {
        internalType: "bytes",
        name: "initCode",
        type: "bytes",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
      {
        components: [
          {
            internalType: "uint256",
            name: "constructorAmount",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "initCallAmount",
            type: "uint256",
          },
        ],
        internalType: "struct CreateX.Values",
        name: "values",
        type: "tuple",
      },
    ],
    name: "deployCreate3AndInit",
    outputs: [
      {
        internalType: "address",
        name: "newContract",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "initCode",
        type: "bytes",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
      {
        components: [
          {
            internalType: "uint256",
            name: "constructorAmount",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "initCallAmount",
            type: "uint256",
          },
        ],
        internalType: "struct CreateX.Values",
        name: "values",
        type: "tuple",
      },
    ],
    name: "deployCreate3AndInit",
    outputs: [
      {
        internalType: "address",
        name: "newContract",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "salt",
        type: "bytes32",
      },
      {
        internalType: "bytes",
        name: "initCode",
        type: "bytes",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
      {
        components: [
          {
            internalType: "uint256",
            name: "constructorAmount",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "initCallAmount",
            type: "uint256",
          },
        ],
        internalType: "struct CreateX.Values",
        name: "values",
        type: "tuple",
      },
      {
        internalType: "address",
        name: "refundAddress",
        type: "address",
      },
    ],
    name: "deployCreate3AndInit",
    outputs: [
      {
        internalType: "address",
        name: "newContract",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "initCode",
        type: "bytes",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
      {
        components: [
          {
            internalType: "uint256",
            name: "constructorAmount",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "initCallAmount",
            type: "uint256",
          },
        ],
        internalType: "struct CreateX.Values",
        name: "values",
        type: "tuple",
      },
      {
        internalType: "address",
        name: "refundAddress",
        type: "address",
      },
    ],
    name: "deployCreate3AndInit",
    outputs: [
      {
        internalType: "address",
        name: "newContract",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "initCode",
        type: "bytes",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
      {
        components: [
          {
            internalType: "uint256",
            name: "constructorAmount",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "initCallAmount",
            type: "uint256",
          },
        ],
        internalType: "struct CreateX.Values",
        name: "values",
        type: "tuple",
      },
    ],
    name: "deployCreateAndInit",
    outputs: [
      {
        internalType: "address",
        name: "newContract",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "initCode",
        type: "bytes",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
      {
        components: [
          {
            internalType: "uint256",
            name: "constructorAmount",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "initCallAmount",
            type: "uint256",
          },
        ],
        internalType: "struct CreateX.Values",
        name: "values",
        type: "tuple",
      },
      {
        internalType: "address",
        name: "refundAddress",
        type: "address",
      },
    ],
    name: "deployCreateAndInit",
    outputs: [
      {
        internalType: "address",
        name: "newContract",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "implementation",
        type: "address",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
    ],
    name: "deployCreateClone",
    outputs: [
      {
        internalType: "address",
        name: "proxy",
        type: "address",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
] as const;

export const CREATEX_ABI_VIEM = `[
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
] as const;`;

export const CREATEX_ABI_ETHERS = `[
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
]`;

export const CREATEX_SOLIDITY_INTERFACE = `// SPDX-License-Identifier: AGPL-3.0-only
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
`;
