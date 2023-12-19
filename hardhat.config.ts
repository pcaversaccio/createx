import { HardhatUserConfig, task, vars } from "hardhat/config";
import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-verify";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "hardhat-contract-sizer";
import "hardhat-abi-exporter";

export const ethMainnetUrl = vars.get(
  "ETH_MAINNET_URL",
  "https://rpc.ankr.com/eth",
);
export const accounts = [
  vars.get(
    "CREATEX_DEPLOYER",
    // `keccak256("DEFAULT_VALUE")`
    "0x0d1706281056b7de64efd2088195fa8224c39103f578c9b84f951721df3fa71c",
  ),
];

task("solc", "Prints the configured Solidity version", async (_, hre) => {
  console.log(hre.config.solidity.compilers[0].version);
});

task("evm", "Prints the configured EVM version", async (_, hre) => {
  console.log(hre.config.solidity.compilers[0].settings.evmVersion);
});

const config: HardhatUserConfig = {
  paths: {
    sources: "./src",
  },
  solidity: {
    version: "0.8.23",
    settings: {
      optimizer: {
        enabled: true,
        runs: 10_000_000,
      },
      evmVersion: "paris", // Prevent using the `PUSH0` opcode
      viaIR: false, // Disable compilation pipeline to go through the Yul intermediate representation
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
        url: vars.get("ETH_MAINNET_URL", ethMainnetUrl),
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
      url: `https://rpc.tenderly.co/fork/${vars.get("TENDERLY_FORK_ID", "")}`,
    },
    devnet: {
      url: `https://rpc.vnet.tenderly.co/devnet/${vars.get(
        "TENDERLY_DEVNET_ID",
        "",
      )}`,
      accounts,
    },
    goerli: {
      chainId: 5,
      url: vars.get(
        "ETH_GOERLI_TESTNET_URL",
        "https://rpc.ankr.com/eth_goerli",
      ),
      accounts,
    },
    sepolia: {
      chainId: 11155111,
      url: vars.get("ETH_SEPOLIA_TESTNET_URL", "https://rpc.sepolia.org"),
      accounts,
    },
    holesky: {
      chainId: 17000,
      url: vars.get(
        "ETH_HOLESKY_TESTNET_URL",
        "https://holesky.rpc.thirdweb.com",
      ),
      accounts,
    },
    ethMain: {
      chainId: 1,
      url: ethMainnetUrl,
      accounts,
    },
    bscTestnet: {
      chainId: 97,
      url: vars.get(
        "BSC_TESTNET_URL",
        "https://data-seed-prebsc-1-s1.binance.org:8545",
      ),
      accounts,
    },
    bscMain: {
      chainId: 56,
      url: vars.get("BSC_MAINNET_URL", "https://bsc-dataseed1.binance.org"),
      accounts,
    },
    optimismTestnet: {
      chainId: 420,
      url: vars.get("OPTIMISM_TESTNET_URL", "https://goerli.optimism.io"),
      accounts,
    },
    optimismSepolia: {
      chainId: 11155420,
      url: vars.get("OPTIMISM_SEPOLIA_URL", "https://sepolia.optimism.io"),
      accounts,
    },
    optimismMain: {
      chainId: 10,
      url: vars.get("OPTIMISM_MAINNET_URL", "https://mainnet.optimism.io"),
      accounts,
    },
    arbitrumSepolia: {
      chainId: 421614,
      url: vars.get(
        "ARBITRUM_SEPOLIA_URL",
        "https://sepolia-rollup.arbitrum.io/rpc",
      ),
      accounts,
    },
    arbitrumMain: {
      chainId: 42161,
      url: vars.get("ARBITRUM_MAINNET_URL", "https://arb1.arbitrum.io/rpc"),
      accounts,
    },
    arbitrumNova: {
      chainId: 42170,
      url: vars.get("ARBITRUM_NOVA_URL", "https://nova.arbitrum.io/rpc"),
      accounts,
    },
    mumbai: {
      chainId: 80001,
      url: vars.get("POLYGON_TESTNET_URL", "https://rpc-mumbai.maticvigil.com"),
      accounts,
    },
    polygonZkEVMTestnet: {
      chainId: 1442,
      url: vars.get(
        "POLYGON_ZKEVM_TESTNET_URL",
        "https://rpc.public.zkevm-test.net",
      ),
      accounts,
    },
    polygon: {
      chainId: 137,
      url: vars.get("POLYGON_MAINNET_URL", "https://polygon-rpc.com"),
      accounts,
    },
    polygonZkEVMMain: {
      chainId: 1101,
      url: vars.get("POLYGON_ZKEVM_MAINNET_URL", "https://zkevm-rpc.com"),
      accounts,
    },
    hecoMain: {
      chainId: 128,
      url: vars.get("HECO_MAINNET_URL", "https://http-mainnet.hecochain.com"),
      accounts,
    },
    fantomTestnet: {
      chainId: 4002,
      url: vars.get("FANTOM_TESTNET_URL", "https://rpc.testnet.fantom.network"),
      accounts,
    },
    fantomMain: {
      chainId: 250,
      url: vars.get("FANTOM_MAINNET_URL", "https://rpc.ankr.com/fantom"),
      accounts,
    },
    fuji: {
      chainId: 43113,
      url: vars.get(
        "AVALANCHE_TESTNET_URL",
        "https://api.avax-test.network/ext/bc/C/rpc",
      ),
      accounts,
    },
    avalanche: {
      chainId: 43114,
      url: vars.get(
        "AVALANCHE_MAINNET_URL",
        "https://api.avax.network/ext/bc/C/rpc",
      ),
      accounts,
    },
    chiado: {
      chainId: 10200,
      url: vars.get("GNOSIS_TESTNET_URL", "https://rpc.chiadochain.net"),
      accounts,
    },
    gnosis: {
      chainId: 100,
      url: vars.get("GNOSIS_MAINNET_URL", "https://rpc.gnosischain.com"),
      accounts,
    },
    moonbaseAlpha: {
      chainId: 1287,
      url: vars.get(
        "MOONBEAM_TESTNET_URL",
        "https://rpc.api.moonbase.moonbeam.network",
      ),
      accounts,
    },
    moonriver: {
      chainId: 1285,
      url: vars.get(
        "MOONRIVER_MAINNET_URL",
        "https://moonriver.public.blastapi.io",
      ),
      accounts,
    },
    moonbeam: {
      chainId: 1284,
      url: vars.get(
        "MOONBEAM_MAINNET_URL",
        "https://moonbeam.public.blastapi.io",
      ),
      accounts,
    },
    alfajores: {
      chainId: 44787,
      url: vars.get(
        "CELO_TESTNET_URL",
        "https://alfajores-forno.celo-testnet.org",
      ),
      accounts,
    },
    celo: {
      chainId: 42220,
      url: vars.get("CELO_MAINNET_URL", "https://forno.celo.org"),
      accounts,
    },
    auroraTestnet: {
      chainId: 1313161555,
      url: vars.get("AURORA_TESTNET_URL", "https://testnet.aurora.dev"),
      accounts,
    },
    auroraMain: {
      chainId: 1313161554,
      url: vars.get("AURORA_MAINNET_URL", "https://mainnet.aurora.dev"),
      accounts,
    },
    harmonyTestnet: {
      chainId: 1666700000,
      url: vars.get("HARMONY_TESTNET_URL", "https://api.s0.b.hmny.io"),
      accounts,
    },
    harmonyMain: {
      chainId: 1666600000,
      url: vars.get("HARMONY_MAINNET_URL", "https://api.harmony.one"),
      accounts,
    },
    spark: {
      chainId: 123,
      url: vars.get("FUSE_TESTNET_URL", "https://rpc.fusespark.io"),
      accounts,
    },
    fuse: {
      chainId: 122,
      url: vars.get("FUSE_MAINNET_URL", "https://rpc.fuse.io"),
      accounts,
    },
    cronosTestnet: {
      chainId: 338,
      url: vars.get("CRONOS_TESTNET_URL", "https://evm-t3.cronos.org"),
      accounts,
    },
    cronosMain: {
      chainId: 25,
      url: vars.get("CRONOS_MAINNET_URL", "https://evm.cronos.org"),
      accounts,
    },
    evmosTestnet: {
      chainId: 9000,
      url: vars.get("EVMOS_TESTNET_URL", "https://evmos-testnet.lava.build"),
      accounts,
    },
    evmosMain: {
      chainId: 9001,
      url: vars.get("EVMOS_MAINNET_URL", "https://evmos.lava.build"),
      accounts,
    },
    bobaTestnet: {
      chainId: 2888,
      url: vars.get("BOBA_TESTNET_URL", "https://goerli.boba.network"),
      accounts,
    },
    bobaMain: {
      chainId: 288,
      url: vars.get("BOBA_MAINNET_URL", "https://mainnet.boba.network"),
      accounts,
    },
    cantoTestnet: {
      chainId: 7701,
      url: vars.get("CANTO_TESTNET_URL", "https://canto-testnet.plexnode.wtf"),
      accounts,
    },
    cantoMain: {
      chainId: 7700,
      url: vars.get("CANTO_MAINNET_URL", "https://canto.slingshot.finance"),
      accounts,
    },
    baseTestnet: {
      chainId: 84531,
      url: vars.get("BASE_TESTNET_URL", "https://goerli.base.org"),
      accounts,
    },
    baseSepolia: {
      chainId: 84532,
      url: vars.get("BASE_SEPOLIA_URL", "https://sepolia.base.org"),
      accounts,
    },
    baseMain: {
      chainId: 8453,
      url: vars.get("BASE_MAINNET_URL", "https://mainnet.base.org"),
      accounts,
    },
    mantleTestnet: {
      chainId: 5001,
      url: vars.get("MANTLE_TESTNET_URL", "https://rpc.testnet.mantle.xyz"),
      accounts,
    },
    mantleMain: {
      chainId: 5000,
      url: vars.get("MANTLE_MAINNET_URL", "https://rpc.mantle.xyz"),
      accounts,
    },
    filecoinTestnet: {
      chainId: 314159,
      url: vars.get(
        "FILECOIN_TESTNET_URL",
        "https://rpc.ankr.com/filecoin_testnet",
      ),
      accounts,
    },
    filecoinMain: {
      chainId: 314,
      url: vars.get("FILECOIN_MAINNET_URL", "https://rpc.ankr.com/filecoin"),
      accounts,
    },
    scrollTestnet: {
      chainId: 534351,
      url: vars.get("SCROLL_TESTNET_URL", "https://sepolia-rpc.scroll.io"),
      accounts,
    },
    scrollMain: {
      chainId: 534352,
      url: vars.get("SCROLL_MAINNET_URL", "https://rpc.scroll.io"),
      accounts,
    },
    lineaTestnet: {
      chainId: 59140,
      url: vars.get("LINEA_TESTNET_URL", "https://rpc.goerli.linea.build"),
      accounts,
    },
    lineaMain: {
      chainId: 59144,
      url: vars.get("LINEA_MAINNET_URL", "https://rpc.linea.build"),
      accounts,
    },
    shimmerEVMTestnet: {
      chainId: 1071,
      url: vars.get(
        "SHIMMEREVM_TESTNET_URL",
        "https://json-rpc.evm.testnet.shimmer.network",
      ),
      accounts,
    },
    zoraTestnet: {
      chainId: 999,
      url: vars.get("ZORA_TESTNET_URL", "https://testnet.rpc.zora.energy"),
      accounts,
    },
    zoraMain: {
      chainId: 7777777,
      url: vars.get("ZORA_MAINNET_URL", "https://rpc.zora.energy"),
      accounts,
    },
    luksoTestnet: {
      chainId: 4201,
      url: vars.get("LUKSO_TESTNET_URL", "https://rpc.testnet.lukso.network"),
      accounts,
    },
    luksoMain: {
      chainId: 42,
      url: vars.get("LUKSO_MAINNET_URL", "https://rpc.lukso.gateway.fm"),
      accounts,
    },
    mantaTestnet: {
      chainId: 3441005,
      url: vars.get(
        "MANTA_TESTNET_URL",
        "https://pacific-rpc.testnet.manta.network/http",
      ),
      accounts,
    },
    mantaMain: {
      chainId: 169,
      url: vars.get(
        "MANTA_MAINNET_URL",
        "https://pacific-rpc.manta.network/http",
      ),
      accounts,
    },
    shardeumTestnet: {
      chainId: 8081,
      url: vars.get("SHARDEUM_TESTNET_URL", "https://dapps.shardeum.org"),
      accounts,
    },
    artheraTestnet: {
      chainId: 10243,
      url: vars.get("ARTHERA_TESTNET_URL", "https://rpc-test.arthera.net"),
      accounts,
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
    apiUrl: "https://sourcify.dev/server",
    browserUrl: "https://repo.sourcify.dev",
  },
  etherscan: {
    apiKey: {
      // For Ethereum testnets & mainnet
      mainnet: vars.get("ETHERSCAN_API_KEY", ""),
      goerli: vars.get("ETHERSCAN_API_KEY", ""),
      sepolia: vars.get("ETHERSCAN_API_KEY", ""),
      holesky: vars.get("ETHERSCAN_API_KEY", ""),
      // For BSC testnet & mainnet
      bsc: vars.get("BSC_API_KEY", ""),
      bscTestnet: vars.get("BSC_API_KEY", ""),
      // For Heco mainnet
      heco: vars.get("HECO_API_KEY", ""),
      // For Fantom testnet & mainnet
      opera: vars.get("FANTOM_API_KEY", ""),
      ftmTestnet: vars.get("FANTOM_API_KEY", ""),
      // For Optimism testnets & mainnet
      optimisticEthereum: vars.get("OPTIMISM_API_KEY", ""),
      optimisticGoerli: vars.get("OPTIMISM_API_KEY", ""),
      optimisticSepolia: vars.get("OPTIMISM_API_KEY", ""),
      // For Polygon testnets & mainnets
      polygon: vars.get("POLYGON_API_KEY", ""),
      polygonZkEVM: vars.get("POLYGON_ZKEVM_API_KEY", ""),
      polygonMumbai: vars.get("POLYGON_API_KEY", ""),
      polygonZkEVMTestnet: vars.get("POLYGON_ZKEVM_API_KEY", ""),
      // For Arbitrum testnet & mainnets
      arbitrumOne: vars.get("ARBITRUM_API_KEY", ""),
      arbitrumNova: vars.get("ARBITRUM_API_KEY", ""),
      arbitrumSepolia: vars.get("ARBITRUM_API_KEY", ""),
      // For Avalanche testnet & mainnet
      avalanche: vars.get("AVALANCHE_API_KEY", ""),
      avalancheFujiTestnet: vars.get("AVALANCHE_API_KEY", ""),
      // For Moonbeam testnet & mainnets
      moonbeam: vars.get("MOONBEAM_API_KEY", ""),
      moonriver: vars.get("MOONBEAM_API_KEY", ""),
      moonbaseAlpha: vars.get("MOONBEAM_API_KEY", ""),
      // For Harmony testnet & mainnet
      harmony: vars.get("HARMONY_API_KEY", ""),
      harmonyTest: vars.get("HARMONY_API_KEY", ""),
      // For Aurora testnet & mainnet
      aurora: vars.get("AURORA_API_KEY", ""),
      auroraTestnet: vars.get("AURORA_API_KEY", ""),
      // For Cronos testnet & mainnet
      cronos: vars.get("CRONOS_API_KEY", ""),
      cronosTestnet: vars.get("CRONOS_API_KEY", ""),
      // For Gnosis/xDai testnet & mainnets
      gnosis: vars.get("GNOSIS_API_KEY", ""),
      xdai: vars.get("GNOSIS_API_KEY", ""),
      chiado: vars.get("GNOSIS_API_KEY", ""),
      // For Fuse testnet & mainnet
      fuse: vars.get("FUSE_API_KEY", ""),
      spark: vars.get("FUSE_API_KEY", ""),
      // For Evmos testnet & mainnet
      evmos: vars.get("EVMOS_API_KEY", ""),
      evmosTestnet: vars.get("EVMOS_API_KEY", ""),
      // For Boba network testnet & mainnet
      boba: vars.get("BOBA_API_KEY", ""),
      bobaTestnet: vars.get("BOBA_API_KEY", ""),
      // For Canto testnet & mainnet
      canto: vars.get("CANTO_API_KEY", ""),
      cantoTestnet: vars.get("CANTO_API_KEY", ""),
      // For Base testnets & mainnet
      base: vars.get("BASE_API_KEY", ""),
      baseTestnet: vars.get("BASE_API_KEY", ""),
      baseSepolia: vars.get("BASE_API_KEY", ""),
      // For Mantle testnet & mainnet
      mantle: vars.get("MANTLE_API_KEY", ""),
      mantleTestnet: vars.get("MANTLE_API_KEY", ""),
      // For Scroll testnet & mainnet
      scroll: vars.get("SCROLL_API_KEY", ""),
      scrollTestnet: vars.get("SCROLL_API_KEY", ""),
      // For Linea testnet & mainnet
      linea: vars.get("LINEA_API_KEY", ""),
      lineaTestnet: vars.get("LINEA_API_KEY", ""),
      // For ShimmerEVM testnet
      shimmerEVMTestnet: vars.get("SHIMMEREVM_API_KEY", ""),
      // For Zora testnet & mainnet
      zora: vars.get("ZORA_API_KEY", ""),
      zoraTestnet: vars.get("ZORA_API_KEY", ""),
      // For Lukso testnet & mainnet
      lukso: vars.get("LUKSO_API_KEY", ""),
      luksoTestnet: vars.get("LUKSO_API_KEY", ""),
      // For Manta testnet & mainnet
      manta: vars.get("MANTA_API_KEY", ""),
      mantaTestnet: vars.get("MANTA_API_KEY", ""),
      // For Arthera testnet
      artheraTestnet: vars.get("ARTHERA_API_KEY", ""),
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
