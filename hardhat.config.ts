import { HardhatUserConfig, task, vars } from "hardhat/config";
import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-verify";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "hardhat-contract-sizer";
import "hardhat-abi-exporter";

task("evm", "Prints the configured EVM version", async (_, hre) => {
  console.log(hre.config.solidity.compilers[0].settings.evmVersion);
});

const config: HardhatUserConfig = {
  paths: {
    sources: "./src",
  },
  solidity: {
    version: "0.8.22",
    settings: {
      optimizer: {
        enabled: true,
        runs: 999999,
      },
      evmVersion: "paris", // Prevent using the `PUSH0` opcode
      metadata: {
        bytecodeHash: "none", // Remove the metadata hash from the bytecode
      },
    },
  },
  networks: {
    hardhat: {
      initialBaseFeePerGas: 0,
      chainId: 31337,
      hardfork: "merge",
      forking: {
        url: vars.has("ETH_MAINNET_URL") ? vars.get("ETH_MAINNET_URL") : "",
        // The Hardhat network will by default fork from the latest mainnet block
        // To pin the block number, specify it below
        // You will need access to a node with archival data for this to work!
        // blockNumber: 14743877,
        // If you want to do some forking, set `enabled` to true
        enabled: false,
      },
    },
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    tenderly: {
      url: `https://rpc.tenderly.co/fork/${
        vars.has("TENDERLY_FORK_ID") ? vars.get("TENDERLY_FORK_ID") : ""
      }`,
    },
    devnet: {
      url: `https://rpc.vnet.tenderly.co/devnet/${
        vars.has("TENDERLY_DEVNET_ID") ? vars.get("TENDERLY_FORK_ID") : ""
      } `,
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    goerli: {
      chainId: 5,
      url: vars.has("ETH_GOERLI_TESTNET_URL")
        ? vars.get("ETH_GOERLI_TESTNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    sepolia: {
      chainId: 11155111,
      url: vars.has("ETH_SEPOLIA_TESTNET_URL")
        ? vars.get("ETH_SEPOLIA_TESTNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    holesky: {
      chainId: 17000,
      url: vars.has("ETH_HOLESKY_TESTNET_URL")
        ? vars.get("ETH_HOLESKY_TESTNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    ethMain: {
      chainId: 1,
      url: vars.has("ETH_MAINNET_URL") ? vars.get("ETH_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    bscTestnet: {
      chainId: 97,
      url: vars.has("BSC_TESTNET_URL") ? vars.get("BSC_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    bscMain: {
      chainId: 56,
      url: vars.has("BSC_MAINNET_URL") ? vars.get("BSC_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    optimismTestnet: {
      chainId: 420,
      url: vars.has("OPTIMISM_TESTNET_URL")
        ? vars.get("OPTIMISM_TESTNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    optimismSepolia: {
      chainId: 11155420,
      url: vars.has("OPTIMISM_SEPOLIA_URL")
        ? vars.get("OPTIMISM_SEPOLIA_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    optimismMain: {
      chainId: 10,
      url: vars.has("OPTIMISM_MAINNET_URL")
        ? vars.get("OPTIMISM_MAINNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    arbitrumTestnet: {
      chainId: 421613,
      url: vars.has("ARBITRUM_TESTNET_URL")
        ? vars.get("ARBITRUM_TESTNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    arbitrumSepolia: {
      chainId: 421614,
      url: vars.has("ARBITRUM_SEPOLIA_URL")
        ? vars.get("ARBITRUM_SEPOLIA_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    arbitrumMain: {
      chainId: 42161,
      url: vars.has("ARBITRUM_MAINNET_URL")
        ? vars.get("ARBITRUM_MAINNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    arbitrumNova: {
      chainId: 42170,
      url: vars.has("ARBITRUM_NOVA_URL") ? vars.get("ARBITRUM_NOVA_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    mumbai: {
      chainId: 80001,
      url: vars.has("POLYGON_TESTNET_URL")
        ? vars.get("POLYGON_TESTNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    polygonZkEVMTestnet: {
      chainId: 1442,
      url: vars.has("POLYGON_ZKEVM_TESTNET_URL")
        ? vars.get("POLYGON_ZKEVM_TESTNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    polygon: {
      chainId: 137,
      url: vars.has("POLYGON_MAINNET_URL")
        ? vars.get("POLYGON_MAINNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    polygonZkEVMMain: {
      chainId: 1101,
      url: vars.has("POLYGON_ZKEVM_MAINNET_URL")
        ? vars.get("POLYGON_ZKEVM_MAINNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    hecoTestnet: {
      chainId: 256,
      url: vars.has("HECO_TESTNET_URL") ? vars.get("HECO_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    hecoMain: {
      chainId: 128,
      url: vars.has("HECO_MAINNET_URL") ? vars.get("HECO_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    fantomTestnet: {
      chainId: 4002,
      url: vars.has("FANTOM_TESTNET_URL") ? vars.get("FANTOM_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    fantomMain: {
      chainId: 250,
      url: vars.has("FANTOM_MAINNET_URL") ? vars.get("FANTOM_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    fuji: {
      chainId: 43113,
      url: vars.has("AVALANCHE_TESTNET_URL")
        ? vars.get("AVALANCHE_TESTNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    avalanche: {
      chainId: 43114,
      url: vars.has("AVALANCHE_MAINNET_URL")
        ? vars.get("AVALANCHE_MAINNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    sokol: {
      chainId: 77,
      url: vars.has("SOKOL_TESTNET_URL") ? vars.get("SOKOL_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    chiado: {
      chainId: 10200,
      url: vars.has("GNOSIS_TESTNET_URL") ? vars.get("GNOSIS_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    gnosis: {
      chainId: 100,
      url: vars.has("GNOSIS_MAINNET_URL") ? vars.get("GNOSIS_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    moonbaseAlpha: {
      chainId: 1287,
      url: vars.has("MOONBEAM_TESTNET_URL")
        ? vars.get("MOONBEAM_TESTNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    moonriver: {
      chainId: 1285,
      url: vars.has("MOONRIVER_MAINNET_URL")
        ? vars.get("MOONRIVER_MAINNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    moonbeam: {
      chainId: 1284,
      url: vars.has("MOONBEAM_MAINNET_URL")
        ? vars.get("MOONBEAM_MAINNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    alfajores: {
      chainId: 44787,
      url: vars.has("CELO_TESTNET_URL") ? vars.get("CELO_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    celo: {
      chainId: 42220,
      url: vars.has("CELO_MAINNET_URL") ? vars.get("CELO_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    auroraTestnet: {
      chainId: 1313161555,
      url: vars.has("AURORA_TESTNET_URL") ? vars.get("AURORA_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    auroraMain: {
      chainId: 1313161554,
      url: vars.has("AURORA_MAINNET_URL") ? vars.get("AURORA_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    harmonyTestnet: {
      chainId: 1666700000,
      url: vars.has("HARMONY_TESTNET_URL")
        ? vars.get("HARMONY_TESTNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    harmonyMain: {
      chainId: 1666600000,
      url: vars.has("HARMONY_MAINNET_URL")
        ? vars.get("HARMONY_MAINNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    spark: {
      chainId: 123,
      url: vars.has("FUSE_TESTNET_URL") ? vars.get("FUSE_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    fuse: {
      chainId: 122,
      url: vars.has("FUSE_MAINNET_URL") ? vars.get("FUSE_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    cronosTestnet: {
      chainId: 338,
      url: vars.has("CRONOS_TESTNET_URL") ? vars.get("CRONOS_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    cronosMain: {
      chainId: 25,
      url: vars.has("CRONOS_MAINNET_URL") ? vars.get("CRONOS_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    evmosTestnet: {
      chainId: 9000,
      url: vars.has("EVMOS_TESTNET_URL") ? vars.get("EVMOS_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    evmosMain: {
      chainId: 9001,
      url: vars.has("EVMOS_MAINNET_URL") ? vars.get("EVMOS_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    bobaTestnet: {
      chainId: 2888,
      url: vars.has("BOBA_TESTNET_URL") ? vars.get("BOBA_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    bobaMain: {
      chainId: 288,
      url: vars.has("BOBA_MAINNET_URL") ? vars.get("BOBA_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    cantoTestnet: {
      chainId: 7701,
      url: vars.has("CANTO_TESTNET_URL") ? vars.get("CANTO_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    cantoMain: {
      chainId: 7700,
      url: vars.has("CANTO_MAINNET_URL") ? vars.get("CANTO_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    baseTestnet: {
      chainId: 84531,
      url: vars.has("BASE_TESTNET_URL") ? vars.get("BASE_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    baseSepolia: {
      chainId: 84532,
      url: vars.has("BASE_SEPOLIA_URL") ? vars.get("BASE_SEPOLIA_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    baseMain: {
      chainId: 8453,
      url: vars.has("BASE_MAINNET_URL") ? vars.get("BASE_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    mantleTestnet: {
      chainId: 5001,
      url: vars.has("MANTLE_TESTNET_URL") ? vars.get("MANTLE_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    mantleMain: {
      chainId: 5000,
      url: vars.has("MANTLE_MAINNET_URL") ? vars.get("MANTLE_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    filecoinTestnet: {
      chainId: 314159,
      url: vars.has("FILECOIN_TESTNET_URL")
        ? vars.get("FILECOIN_TESTNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    scrollTestnet: {
      chainId: 534351,
      url: vars.has("SCROLL_TESTNET_URL") ? vars.get("SCROLL_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    scrollMain: {
      chainId: 534352,
      url: vars.has("SCROLL_MAINNET_URL") ? vars.get("SCROLL_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    lineaTestnet: {
      chainId: 59140,
      url: vars.has("LINEA_TESTNET_URL") ? vars.get("LINEA_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    lineaMain: {
      chainId: 59144,
      url: vars.has("LINEA_MAINNET_URL") ? vars.get("LINEA_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    shimmerEVMTestnet: {
      chainId: 1071,
      url: vars.has("SHIMMEREVM_TESTNET_URL")
        ? vars.get("SHIMMEREVM_TESTNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    zoraTestnet: {
      chainId: 999,
      url: vars.has("ZORA_TESTNET_URL") ? vars.get("ZORA_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    zoraMain: {
      chainId: 7777777,
      url: vars.has("ZORA_MAINNET_URL") ? vars.get("ZORA_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    luksoTestnet: {
      chainId: 4201,
      url: vars.has("LUKSO_TESTNET_URL") ? vars.get("LUKSO_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    luksoMain: {
      chainId: 42,
      url: vars.has("LUKSO_MAINNET_URL") ? vars.get("LUKSO_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    mantaTestnet: {
      chainId: 3441005,
      url: vars.has("MANTA_TESTNET_URL") ? vars.get("MANTA_TESTNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    mantaMain: {
      chainId: 169,
      url: vars.has("MANTA_MAINNET_URL") ? vars.get("MANTA_MAINNET_URL") : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    shardeumTestnet: {
      chainId: 8081,
      url: vars.has("SHARDEUM_TESTNET_URL")
        ? vars.get("SHARDEUM_TESTNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
    artheraTestnet: {
      chainId: 10243,
      url: vars.has("ARTHERA_TESTNET_URL")
        ? vars.get("ARTHERA_TESTNET_URL")
        : "",
      accounts: vars.has("PRIVATE_KEY") ? [vars.get("PRIVATE_KEY")] : [],
    },
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
    strict: true,
    only: [],
    except: [],
  },
  gasReporter: {
    enabled: vars.has("REPORT_GAS") ? true : false,
  },
  abiExporter: {
    path: "./abis",
    runOnCompile: true,
    clear: true,
    flat: false,
    only: [],
    spacing: 2,
    pretty: true,
  },
  sourcify: {
    // Enable Sourcify verification by default
    enabled: true,
  },
  etherscan: {
    apiKey: {
      // For Ethereum testnets & mainnet
      mainnet: vars.has("ETHERSCAN_API_KEY")
        ? vars.get("ETHERSCAN_API_KEY")
        : "",
      goerli: vars.has("ETHERSCAN_API_KEY")
        ? vars.get("ETHERSCAN_API_KEY")
        : "",
      sepolia: vars.has("ETHERSCAN_API_KEY")
        ? vars.get("ETHERSCAN_API_KEY")
        : "",
      holesky: vars.has("ETHERSCAN_API_KEY")
        ? vars.get("ETHERSCAN_API_KEY")
        : "",
      // For BSC testnet & mainnet
      bsc: vars.has("BSC_API_KEY") ? vars.get("BSC_API_KEY") : "",
      bscTestnet: vars.has("BSC_API_KEY") ? vars.get("BSC_API_KEY") : "",
      // For Heco testnet & mainnet
      heco: vars.has("HECO_API_KEY") ? vars.get("HECO_API_KEY") : "",
      hecoTestnet: vars.has("HECO_API_KEY") ? vars.get("HECO_API_KEY") : "",
      // For Fantom testnet & mainnet
      opera: vars.has("FANTOM_API_KEY") ? vars.get("FANTOM_API_KEY") : "",
      ftmTestnet: vars.has("FANTOM_API_KEY") ? vars.get("FANTOM_API_KEY") : "",
      // For Optimism testnets & mainnet
      optimisticEthereum: vars.has("OPTIMISM_API_KEY")
        ? vars.get("OPTIMISM_API_KEY")
        : "",
      optimisticGoerli: vars.has("OPTIMISM_API_KEY")
        ? vars.get("OPTIMISM_API_KEY")
        : "",
      optimisticSepolia: vars.has("OPTIMISM_API_KEY")
        ? vars.get("OPTIMISM_API_KEY")
        : "",
      // For Polygon testnets & mainnets
      polygon: vars.has("POLYGON_API_KEY") ? vars.get("POLYGON_API_KEY") : "",
      polygonZkEVM: vars.has("POLYGON_ZKEVM_API_KEY")
        ? vars.get("POLYGON_ZKEVM_API_KEY")
        : "",
      polygonMumbai: vars.has("POLYGON_API_KEY")
        ? vars.get("POLYGON_API_KEY")
        : "",
      polygonZkEVMTestnet: vars.has("POLYGON_ZKEVM_API_KEY")
        ? vars.get("POLYGON_ZKEVM_API_KEY")
        : "",
      // For Arbitrum testnets & mainnets
      arbitrumOne: vars.has("ARBITRUM_API_KEY")
        ? vars.get("ARBITRUM_API_KEY")
        : "",
      arbitrumNova: vars.has("ARBITRUM_API_KEY")
        ? vars.get("ARBITRUM_API_KEY")
        : "",
      arbitrumGoerli: vars.has("ARBITRUM_API_KEY")
        ? vars.get("ARBITRUM_API_KEY")
        : "",
      arbitrumSepolia: vars.has("ARBITRUM_API_KEY")
        ? vars.get("ARBITRUM_API_KEY")
        : "",
      // For Avalanche testnet & mainnet
      avalanche: vars.has("AVALANCHE_API_KEY")
        ? vars.get("AVALANCHE_API_KEY")
        : "",
      avalancheFujiTestnet: vars.has("AVALANCHE_API_KEY")
        ? vars.get("AVALANCHE_API_KEY")
        : "",
      // For Moonbeam testnet & mainnets
      moonbeam: vars.has("MOONBEAM_API_KEY")
        ? vars.get("MOONBEAM_API_KEY")
        : "",
      moonriver: vars.has("MOONBEAM_API_KEY")
        ? vars.get("MOONBEAM_API_KEY")
        : "",
      moonbaseAlpha: vars.has("MOONBEAM_API_KEY")
        ? vars.get("MOONBEAM_API_KEY")
        : "",
      // For Harmony testnet & mainnet
      harmony: vars.has("HARMONY_API_KEY") ? vars.get("HARMONY_API_KEY") : "",
      harmonyTest: vars.has("HARMONY_API_KEY")
        ? vars.get("HARMONY_API_KEY")
        : "",
      // For Aurora testnet & mainnet
      aurora: vars.has("AURORA_API_KEY") ? vars.get("AURORA_API_KEY") : "",
      auroraTestnet: vars.has("AURORA_API_KEY")
        ? vars.get("AURORA_API_KEY")
        : "",
      // For Cronos testnet & mainnet
      cronos: vars.has("CRONOS_API_KEY") ? vars.get("CRONOS_API_KEY") : "",
      cronosTestnet: vars.has("CRONOS_API_KEY")
        ? vars.get("CRONOS_API_KEY")
        : "",
      // For Gnosis/xDai testnets & mainnets
      gnosis: vars.has("GNOSIS_API_KEY") ? vars.get("GNOSIS_API_KEY") : "",
      xdai: vars.has("GNOSIS_API_KEY") ? vars.get("GNOSIS_API_KEY") : "",
      sokol: vars.has("GNOSIS_API_KEY") ? vars.get("GNOSIS_API_KEY") : "",
      chiado: vars.has("GNOSIS_API_KEY") ? vars.get("GNOSIS_API_KEY") : "",
      // For Fuse testnet & mainnet
      fuse: vars.has("FUSE_API_KEY") ? vars.get("FUSE_API_KEY") : "",
      spark: vars.has("FUSE_API_KEY") ? vars.get("FUSE_API_KEY") : "",
      // For Evmos testnet & mainnet
      evmos: vars.has("EVMOS_API_KEY") ? vars.get("EVMOS_API_KEY") : "",
      evmosTestnet: vars.has("EVMOS_API_KEY") ? vars.get("EVMOS_API_KEY") : "",
      // For Boba network testnet & mainnet
      boba: vars.has("BOBA_API_KEY") ? vars.get("BOBA_API_KEY") : "",
      bobaTestnet: vars.has("BOBA_API_KEY") ? vars.get("BOBA_API_KEY") : "",
      // For Canto testnet & mainnet
      canto: vars.has("CANTO_API_KEY") ? vars.get("CANTO_API_KEY") : "",
      cantoTestnet: vars.has("CANTO_API_KEY") ? vars.get("CANTO_API_KEY") : "",
      // For Base testnets & mainnet
      base: vars.has("BASE_API_KEY") ? vars.get("BASE_API_KEY") : "",
      baseTestnet: vars.has("BASE_API_KEY") ? vars.get("BASE_API_KEY") : "",
      baseSepolia: vars.has("BASE_API_KEY") ? vars.get("BASE_API_KEY") : "",
      // For Mantle testnet & mainnet
      mantle: vars.has("MANTLE_API_KEY") ? vars.get("MANTLE_API_KEY") : "",
      mantleTestnet: vars.has("MANTLE_API_KEY")
        ? vars.get("MANTLE_API_KEY")
        : "",
      // For Scroll testnet & mainnet
      scroll: vars.has("SCROLL_API_KEY") ? vars.get("SCROLL_API_KEY") : "",
      scrollTestnet: vars.has("SCROLL_API_KEY")
        ? vars.get("SCROLL_API_KEY")
        : "",
      // For Linea testnet & mainnet
      linea: vars.has("LINEA_API_KEY") ? vars.get("LINEA_API_KEY") : "",
      lineaTestnet: vars.has("LINEA_API_KEY") ? vars.get("LINEA_API_KEY") : "",
      // For ShimmerEVM testnet
      shimmerEVMTestnet: vars.has("SHIMMEREVM_API_KEY")
        ? vars.get("SHIMMEREVM_API_KEY")
        : "",
      // For Zora testnet & mainnet
      zora: vars.has("ZORA_API_KEY") ? vars.get("ZORA_API_KEY") : "",
      zoraTestnet: vars.has("ZORA_API_KEY") ? vars.get("ZORA_API_KEY") : "",
      // For Lukso testnet & mainnet
      lukso: vars.has("LUKSO_API_KEY") ? vars.get("LUKSO_API_KEY") : "",
      luksoTestnet: vars.has("LUKSO_API_KEY") ? vars.get("LUKSO_API_KEY") : "",
      // For Manta testnet & mainnet
      manta: vars.has("MANTA_API_KEY") ? vars.get("MANTA_API_KEY") : "",
      mantaTestnet: vars.has("MANTA_API_KEY") ? vars.get("MANTA_API_KEY") : "",
      // For Arthera testnet
      artheraTestnet: vars.has("ARTHERA_API_KEY")
        ? vars.get("ARTHERA_API_KEY")
        : "",
    },
    customChains: [
      {
        network: "holesky",
        chainId: 17000,
        urls: {
          apiURL: "https://api-holesky.etherscan.io/api",
          browserURL: "https://holesky.etherscan.io",
        },
      },
      {
        network: "optimisticSepolia",
        chainId: 11155420,
        urls: {
          apiURL: "https://optimism-sepolia.blockscout.com/api",
          browserURL: "https://optimism-sepolia.blockscout.com",
        },
      },
      {
        network: "chiado",
        chainId: 10200,
        urls: {
          apiURL: "https://gnosis-chiado.blockscout.com/api",
          browserURL: "https://gnosis-chiado.blockscout.com",
        },
      },
      {
        network: "cronos",
        chainId: 25,
        urls: {
          apiURL: "https://api.cronoscan.com/api",
          browserURL: "https://cronoscan.com",
        },
      },
      {
        network: "cronosTestnet",
        chainId: 338,
        urls: {
          apiURL: "https://cronos.org/explorer/testnet3/api",
          browserURL: "https://cronos.org/explorer/testnet3",
        },
      },
      {
        network: "fuse",
        chainId: 122,
        urls: {
          apiURL: "https://explorer.fuse.io/api",
          browserURL: "https://explorer.fuse.io",
        },
      },
      {
        network: "spark",
        chainId: 123,
        urls: {
          apiURL: "https://explorer.fusespark.io/api",
          browserURL: "https://explorer.fusespark.io",
        },
      },
      {
        network: "evmos",
        chainId: 9001,
        urls: {
          apiURL: "https://escan.live/api",
          browserURL: "https://escan.live",
        },
      },
      {
        network: "evmosTestnet",
        chainId: 9000,
        urls: {
          apiURL: "https://testnet.escan.live/api",
          browserURL: "https://testnet.escan.live",
        },
      },
      {
        network: "boba",
        chainId: 288,
        urls: {
          apiURL: "https://api.bobascan.com/api",
          browserURL: "https://bobascan.com",
        },
      },
      {
        network: "bobaTestnet",
        chainId: 2888,
        urls: {
          apiURL: "https://api-testnet.bobascan.com/api",
          browserURL: "https://testnet.bobascan.com",
        },
      },
      {
        network: "arbitrumNova",
        chainId: 42170,
        urls: {
          apiURL: "https://api-nova.arbiscan.io/api",
          browserURL: "https://nova.arbiscan.io",
        },
      },
      {
        network: "arbitrumSepolia",
        chainId: 421614,
        urls: {
          apiURL: "https://api-sepolia.arbiscan.io/api",
          browserURL: "https://sepolia.arbiscan.io",
        },
      },
      {
        network: "canto",
        chainId: 7700,
        urls: {
          apiURL: "https://tuber.build/api",
          browserURL: "https://tuber.build",
        },
      },
      {
        network: "cantoTestnet",
        chainId: 7701,
        urls: {
          apiURL: "https://testnet.tuber.build/api",
          browserURL: "https://testnet.tuber.build",
        },
      },
      {
        network: "base",
        chainId: 8453,
        urls: {
          apiURL: "https://api.basescan.org/api",
          browserURL: "https://basescan.org",
        },
      },
      {
        network: "baseTestnet",
        chainId: 84531,
        urls: {
          apiURL: "https://api-goerli.basescan.org/api",
          browserURL: "https://goerli.basescan.org",
        },
      },
      {
        network: "baseSepolia",
        chainId: 84532,
        urls: {
          apiURL: "https://base-sepolia.blockscout.com/api",
          browserURL: "https://base-sepolia.blockscout.com",
        },
      },
      {
        network: "mantle",
        chainId: 5000,
        urls: {
          apiURL: "https://explorer.mantle.xyz/api",
          browserURL: "https://explorer.mantle.xyz",
        },
      },
      {
        network: "mantleTestnet",
        chainId: 5001,
        urls: {
          apiURL: "https://explorer.testnet.mantle.xyz/api",
          browserURL: "https://explorer.testnet.mantle.xyz",
        },
      },
      {
        network: "scroll",
        chainId: 534352,
        urls: {
          apiURL: "https://api.scrollscan.com/api",
          browserURL: "https://scrollscan.com",
        },
      },
      {
        network: "scrollTestnet",
        chainId: 534351,
        urls: {
          apiURL: "https://api-sepolia.scrollscan.com/api",
          browserURL: "https://sepolia.scrollscan.com",
        },
      },
      {
        network: "polygonZkEVM",
        chainId: 1101,
        urls: {
          apiURL: "https://api-zkevm.polygonscan.com/api",
          browserURL: "https://zkevm.polygonscan.com",
        },
      },
      {
        network: "polygonZkEVMTestnet",
        chainId: 1442,
        urls: {
          apiURL: "https://api-testnet-zkevm.polygonscan.com/api",
          browserURL: "https://testnet-zkevm.polygonscan.com",
        },
      },
      {
        network: "linea",
        chainId: 59144,
        urls: {
          apiURL: "https://api.lineascan.build/api",
          browserURL: "https://lineascan.build",
        },
      },
      {
        network: "lineaTestnet",
        chainId: 59140,
        urls: {
          apiURL: "https://api-testnet.lineascan.build/api",
          browserURL: "https://goerli.lineascan.build",
        },
      },
      {
        network: "shimmerEVMTestnet",
        chainId: 1071,
        urls: {
          apiURL: "https://explorer.evm.testnet.shimmer.network/api",
          browserURL: "https://explorer.evm.testnet.shimmer.network",
        },
      },
      {
        network: "zora",
        chainId: 7777777,
        urls: {
          apiURL: "https://explorer.zora.energy/api",
          browserURL: "https://explorer.zora.energy",
        },
      },
      {
        network: "zoraTestnet",
        chainId: 999,
        urls: {
          apiURL: "https://testnet.explorer.zora.energy/api",
          browserURL: "https://testnet.explorer.zora.energy",
        },
      },
      {
        network: "lukso",
        chainId: 42,
        urls: {
          apiURL: "https://explorer.execution.mainnet.lukso.network/api",
          browserURL: "https://explorer.execution.mainnet.lukso.network",
        },
      },
      {
        network: "luksoTestnet",
        chainId: 4201,
        urls: {
          apiURL: "https://explorer.execution.testnet.lukso.network/api",
          browserURL: "https://explorer.execution.testnet.lukso.network",
        },
      },
      {
        network: "manta",
        chainId: 169,
        urls: {
          apiURL: "https://pacific-explorer.manta.network/api",
          browserURL: "https://pacific-explorer.manta.network",
        },
      },
      {
        network: "mantaTestnet",
        chainId: 3441005,
        urls: {
          apiURL: "https://pacific-explorer.testnet.manta.network/api",
          browserURL: "https://pacific-explorer.testnet.manta.network",
        },
      },
      {
        network: "artheraTestnet",
        chainId: 10243,
        urls: {
          apiURL: "https://explorer-test.arthera.net/api",
          browserURL: "https://explorer-test.arthera.net",
        },
      },
    ],
  },
};

export default config;
