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
      hardfork: "cancun",
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
    hoodi: {
      chainId: 560048,
      url: vars.get(
        "ETH_HOODI_TESTNET_URL",
        "https://rpc.hoodi.ethpandaops.io",
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
    amoy: {
      chainId: 80002,
      url: vars.get(
        "POLYGON_TESTNET_URL",
        "https://rpc-amoy.polygon.technology",
      ),
      accounts,
    },
    polygonZkEVMTestnet: {
      chainId: 2442,
      url: vars.get(
        "POLYGON_ZKEVM_TESTNET_URL",
        "https://rpc.cardona.zkevm-rpc.com",
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
      url: vars.get("BOBA_MAINNET_URL", "https://replica.boba.network"),
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
      chainId: 5003,
      url: vars.get("MANTLE_TESTNET_URL", "https://rpc.sepolia.mantle.xyz"),
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
      chainId: 59141,
      url: vars.get("LINEA_TESTNET_URL", "https://rpc.sepolia.linea.build"),
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
      chainId: 999999999,
      url: vars.get("ZORA_TESTNET_URL", "https://sepolia.rpc.zora.energy"),
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
      chainId: 3441006,
      url: vars.get(
        "MANTA_TESTNET_URL",
        "https://pacific-rpc.sepolia-testnet.manta.network/http",
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
    frameTestnet: {
      chainId: 68840142,
      url: vars.get("FRAME_TESTNET_URL", "https://rpc.testnet.frame.xyz/http"),
      accounts,
    },
    enduranceTestnet: {
      chainId: 6480,
      url: vars.get(
        "ENDURANCE_TESTNET_URL",
        "https://myrpctestnet.fusionist.io",
      ),
      accounts,
    },
    openduranceTestnet: {
      chainId: 6480001001,
      url: vars.get(
        "OPENDURANCE_TESTNET_URL",
        "https://rpc-l2-testnet.fusionist.io",
      ),
      accounts,
    },
    enduranceMain: {
      chainId: 648,
      url: vars.get(
        "ENDURANCE_MAINNET_URL",
        "https://rpc-endurance.fusionist.io",
      ),
      accounts,
    },
    blastTestnet: {
      chainId: 168587773,
      url: vars.get("BLAST_TESTNET_URL", "https://sepolia.blast.io"),
      accounts,
    },
    blastMain: {
      chainId: 81457,
      url: vars.get("BLAST_MAINNET_URL", "https://rpc.blast.io"),
      accounts,
    },
    kromaTestnet: {
      chainId: 2358,
      url: vars.get("KROMA_TESTNET_URL", "https://api.sepolia.kroma.network"),
      accounts,
    },
    kromaMain: {
      chainId: 255,
      url: vars.get("KROMA_MAINNET_URL", "https://api.kroma.network"),
      accounts,
    },
    dosTestnet: {
      chainId: 3939,
      url: vars.get("DOS_TESTNET_URL", "https://test.doschain.com"),
      accounts,
    },
    dosMain: {
      chainId: 7979,
      url: vars.get("DOS_MAINNET_URL", "https://main.doschain.com"),
      accounts,
    },
    fraxtalTestnet: {
      chainId: 2522,
      url: vars.get("FRAXTAL_TESTNET_URL", "https://rpc.testnet.frax.com"),
      accounts,
    },
    fraxtalMain: {
      chainId: 252,
      url: vars.get("FRAXTAL_MAINNET_URL", "https://rpc.frax.com"),
      accounts,
    },
    kavaMain: {
      chainId: 2222,
      url: vars.get("KAVA_MAINNET_URL", "https://evm.kava-rpc.com"),
      accounts,
    },
    metisTestnet: {
      chainId: 59902,
      url: vars.get("METIS_TESTNET_URL", "https://sepolia.metisdevops.link"),
      accounts,
    },
    metisMain: {
      chainId: 1088,
      url: vars.get(
        "METIS_MAINNET_URL",
        "https://andromeda.metis.io/?owner=1088",
      ),
      accounts,
    },
    modeTestnet: {
      chainId: 919,
      url: vars.get("MODE_TESTNET_URL", "https://sepolia.mode.network"),
      accounts,
    },
    modeMain: {
      chainId: 34443,
      url: vars.get("MODE_MAINNET_URL", "https://mainnet.mode.network"),
      accounts,
    },
    seiTestnet: {
      chainId: 713715,
      url: vars.get("SEI_TESTNET_URL", "https://evm-rpc-arctic-1.sei-apis.com"),
      accounts,
    },
    xlayerTestnet: {
      chainId: 195,
      url: vars.get("XLAYER_TESTNET_URL", "https://testrpc.xlayer.tech"),
      accounts,
    },
    xlayerMain: {
      chainId: 196,
      url: vars.get("XLAYER_MAINNET_URL", "https://rpc.xlayer.tech"),
      accounts,
    },
    bobTestnet: {
      chainId: 111,
      url: vars.get("BOB_TESTNET_URL", "https://testnet.rpc.gobob.xyz"),
      accounts,
    },
    bobMain: {
      chainId: 60808,
      url: vars.get("BOB_MAINNET_URL", "https://rpc.gobob.xyz"),
      accounts,
    },
    coreTestnet: {
      chainId: 1115,
      url: vars.get("CORE_TESTNET_URL", "https://rpc.test.btcs.network"),
      accounts,
    },
    coreMain: {
      chainId: 1116,
      url: vars.get("CORE_MAINNET_URL", "https://rpc.coredao.org"),
      accounts,
    },
    telosTestnet: {
      chainId: 41,
      url: vars.get("TELOS_TESTNET_URL", "https://testnet.telos.net/evm"),
      accounts,
    },
    telosMain: {
      chainId: 40,
      url: vars.get("TELOS_MAINNET_URL", "https://mainnet.telos.net/evm"),
      accounts,
    },
    rootstockTestnet: {
      chainId: 31,
      url: vars.get(
        "ROOTSTOCK_TESTNET_URL",
        "https://public-node.testnet.rsk.co",
      ),
      accounts,
    },
    rootstockMain: {
      chainId: 30,
      url: vars.get("ROOTSTOCK_MAINNET_URL", "https://public-node.rsk.co"),
      accounts,
    },
    chilizTestnet: {
      chainId: 88882,
      url: vars.get("CHILIZ_TESTNET_URL", "https://spicy-rpc.chiliz.com"),
      accounts,
    },
    chilizMain: {
      chainId: 88888,
      url: vars.get("CHILIZ_MAINNET_URL", "https://rpc.ankr.com/chiliz"),
      accounts,
    },
    taraxaTestnet: {
      chainId: 842,
      url: vars.get("TARAXA_TESTNET_URL", "https://rpc.testnet.taraxa.io"),
      accounts,
    },
    taraxaMain: {
      chainId: 841,
      url: vars.get("TARAXA_MAINNET_URL", "https://rpc.mainnet.taraxa.io"),
      accounts,
    },
    gravityAlphaTestnet: {
      chainId: 13505,
      url: vars.get(
        "GRAVITY_ALPHA_TESTNET_URL",
        "https://rpc-sepolia.gravity.xyz",
      ),
      accounts,
    },
    gravityAlphaMain: {
      chainId: 1625,
      url: vars.get("GRAVITY_ALPHA_MAINNET_URL", "https://rpc.gravity.xyz"),
      accounts,
    },
    taikoTestnet: {
      chainId: 167009,
      url: vars.get("TAIKO_TESTNET_URL", "https://rpc.hekla.taiko.xyz"),
      accounts,
    },
    taikoMain: {
      chainId: 167000,
      url: vars.get("TAIKO_MAINNET_URL", "https://rpc.taiko.xyz"),
      accounts,
    },
    zetaChainTestnet: {
      chainId: 7001,
      url: vars.get("ZETA_CHAIN_TESTNET_URL", "https://7001.rpc.thirdweb.com"),
      accounts,
    },
    zetaChainMain: {
      chainId: 7000,
      url: vars.get("ZETA_CHAIN_MAINNET_URL", "https://7000.rpc.thirdweb.com"),
      accounts,
    },
    "5ireChainTestnet": {
      chainId: 997,
      url: vars.get(
        "5IRE_CHAIN_TESTNET_URL",
        "https://rpc.testnet.5ire.network",
      ),
      accounts,
    },
    "5ireChainMain": {
      chainId: 995,
      url: vars.get("5IRE_CHAIN_MAINNET_URL", "https://rpc.5ire.network"),
      accounts,
    },
    sapphireTestnet: {
      chainId: 23295,
      url: vars.get(
        "SAPPHIRE_TESTNET_URL",
        "https://testnet.sapphire.oasis.io",
      ),
      accounts,
    },
    sapphireMain: {
      chainId: 23294,
      url: vars.get("SAPPHIRE_MAINNET_URL", "https://sapphire.oasis.io"),
      accounts,
    },
    worldChainTestnet: {
      chainId: 4801,
      url: vars.get(
        "WORLD_CHAIN_TESTNET_URL",
        "https://worldchain-sepolia.g.alchemy.com/public",
      ),
      accounts,
    },
    worldChainMain: {
      chainId: 480,
      url: vars.get(
        "WORLD_CHAIN_MAINNET_URL",
        "https://worldchain-mainnet.g.alchemy.com/public",
      ),
      accounts,
    },
    plumeTestnet: {
      chainId: 98867,
      url: vars.get(
        "PLUME_TESTNET_URL",
        "https://testnet-rpc.plumenetwork.xyz",
      ),
      accounts,
    },
    plumeMain: {
      chainId: 98866,
      url: vars.get(
        "PLUME_MAINNET_URL",
        "https://phoenix-rpc.plumenetwork.xyz",
      ),
      accounts,
    },
    unichainTestnet: {
      chainId: 1301,
      url: vars.get("UNICHAIN_TESTNET_URL", "https://sepolia.unichain.org"),
      accounts,
    },
    unichainMain: {
      chainId: 130,
      url: vars.get("UNICHAIN_MAINNET_URL", "https://mainnet.unichain.org"),
      accounts,
    },
    xdcTestnet: {
      chainId: 51,
      url: vars.get("XDC_TESTNET_URL", "https://erpc.apothem.network"),
      accounts,
    },
    xdcMain: {
      chainId: 50,
      url: vars.get("XDC_MAINNET_URL", "https://rpc.xinfin.network"),
      accounts,
    },
    sxTestnet: {
      chainId: 79479957,
      url: vars.get(
        "SX_TESTNET_URL",
        "https://rpc.sx-rollup-testnet.t.raas.gelato.cloud",
      ),
      accounts,
    },
    sxMain: {
      chainId: 4162,
      url: vars.get("SX_MAINNET_URL", "https://rpc.sx-rollup.gelato.digital"),
      accounts,
    },
    liskTestnet: {
      chainId: 4202,
      url: vars.get("LISK_TESTNET_URL", "https://rpc.sepolia-api.lisk.com"),
      accounts,
    },
    liskMain: {
      chainId: 1135,
      url: vars.get("LISK_MAINNET_URL", "https://rpc.api.lisk.com"),
      accounts,
    },
    metalL2Testnet: {
      chainId: 1740,
      url: vars.get("METALL2_TESTNET_URL", "https://testnet.rpc.metall2.com"),
      accounts,
    },
    metalL2Main: {
      chainId: 1750,
      url: vars.get("METALL2_MAINNET_URL", "https://rpc.metall2.com"),
      accounts,
    },
    superseedTestnet: {
      chainId: 53302,
      url: vars.get("SUPERSEED_TESTNET_URL", "https://sepolia.superseed.xyz"),
      accounts,
    },
    superseedMain: {
      chainId: 5330,
      url: vars.get("SUPERSEED_MAINNET_URL", "https://mainnet.superseed.xyz"),
      accounts,
    },
    storyTestnet: {
      chainId: 1315,
      url: vars.get("STORY_TESTNET_URL", "https://aeneid.storyrpc.io"),
      accounts,
    },
    sonicTestnet: {
      chainId: 57054,
      url: vars.get("SONIC_TESTNET_URL", "https://rpc.blaze.soniclabs.com"),
      accounts,
    },
    sonicMain: {
      chainId: 146,
      url: vars.get("SONIC_MAINNET_URL", "https://rpc.soniclabs.com"),
      accounts,
    },
    flowTestnet: {
      chainId: 545,
      url: vars.get("FLOW_TESTNET_URL", "https://testnet.evm.nodes.onflow.org"),
      accounts,
    },
    flowMain: {
      chainId: 747,
      url: vars.get("FLOW_MAINNET_URL", "https://mainnet.evm.nodes.onflow.org"),
      accounts,
    },
    inkTestnet: {
      chainId: 763373,
      url: vars.get(
        "INK_TESTNET_URL",
        "https://rpc-gel-sepolia.inkonchain.com",
      ),
      accounts,
    },
    inkMain: {
      chainId: 57073,
      url: vars.get("INK_MAINNET_URL", "https://rpc-gel.inkonchain.com"),
      accounts,
    },
    morphTestnet: {
      chainId: 2810,
      url: vars.get(
        "MORPH_TESTNET_URL",
        "https://rpc-quicknode-holesky.morphl2.io",
      ),
      accounts,
    },
    morphMain: {
      chainId: 2818,
      url: vars.get("MORPH_MAINNET_URL", "https://rpc-quicknode.morphl2.io"),
      accounts,
    },
    shapeTestnet: {
      chainId: 11011,
      url: vars.get("SHAPE_TESTNET_URL", "https://sepolia.shape.network"),
      accounts,
    },
    shapeMain: {
      chainId: 360,
      url: vars.get("SHAPE_MAINNET_URL", "https://mainnet.shape.network"),
      accounts,
    },
    etherlinkTestnet: {
      chainId: 128123,
      url: vars.get(
        "ETHERLINK_TESTNET_URL",
        "https://node.ghostnet.etherlink.com",
      ),
      accounts,
    },
    etherlinkMain: {
      chainId: 42793,
      url: vars.get(
        "ETHERLINK_MAINNET_URL",
        "https://node.mainnet.etherlink.com",
      ),
      accounts,
    },
    soneiumTestnet: {
      chainId: 1946,
      url: vars.get("SONEIUM_TESTNET_URL", "https://rpc.minato.soneium.org"),
      accounts,
    },
    soneiumMain: {
      chainId: 1868,
      url: vars.get("SONEIUM_MAINNET_URL", "https://rpc.soneium.org"),
      accounts,
    },
    swellTestnet: {
      chainId: 1924,
      url: vars.get(
        "SWELL_TESTNET_URL",
        "https://swell-testnet.alt.technology",
      ),
      accounts,
    },
    swellMain: {
      chainId: 1923,
      url: vars.get(
        "SWELL_MAINNET_URL",
        "https://swell-mainnet.alt.technology",
      ),
      accounts,
    },
    hemiTestnet: {
      chainId: 743111,
      url: vars.get("HEMI_TESTNET_URL", "https://testnet.rpc.hemi.network/rpc"),
      accounts,
    },
    hemiMain: {
      chainId: 43111,
      url: vars.get("HEMI_MAINNET_URL", "https://rpc.hemi.network/rpc"),
      accounts,
    },
    berachainTestnet: {
      chainId: 80084,
      url: vars.get("BERACHAIN_TESTNET_URL", "https://bartio.drpc.org"),
      accounts,
    },
    berachainMain: {
      chainId: 80094,
      url: vars.get("BERACHAIN_MAINNET_URL", "https://rpc.berachain.com"),
      accounts,
    },
    monadTestnet: {
      chainId: 10143,
      url: vars.get("MONAD_TESTNET_URL", "https://testnet-rpc.monad.xyz"),
      accounts,
    },
    cornTestnet: {
      chainId: 21000001,
      url: vars.get("CORN_TESTNET_URL", "https://testnet.corn-rpc.com"),
      accounts,
    },
    cornMain: {
      chainId: 21000000,
      url: vars.get("CORN_MAINNET_URL", "https://mainnet.corn-rpc.com"),
      accounts,
    },
    arenazTestnet: {
      chainId: 9897,
      url: vars.get(
        "ARENAZ_TESTNET_URL",
        "https://rpc.arena-z.t.raas.gelato.cloud",
      ),
      accounts,
    },
    arenazMain: {
      chainId: 7897,
      url: vars.get("ARENAZ_MAINNET_URL", "https://rpc.arena-z.gg"),
      accounts,
    },
    iotexTestnet: {
      chainId: 4690,
      url: vars.get("IOTEX_TESTNET_URL", "https://babel-api.testnet.iotex.io"),
      accounts,
    },
    iotexMain: {
      chainId: 4689,
      url: vars.get("IOTEX_MAINNET_URL", "https://babel-api.mainnet.iotex.io"),
      accounts,
    },
    hychainTestnet: {
      chainId: 29112,
      url: vars.get(
        "HYCHAIN_TESTNET_URL",
        "https://testnet-rpc.hychain.com/http",
      ),
      accounts,
    },
    hychainMain: {
      chainId: 2911,
      url: vars.get("HYCHAIN_MAINNET_URL", "https://rpc.hychain.com/http"),
      accounts,
    },
    zircuitTestnet: {
      chainId: 48898,
      url: vars.get(
        "ZIRCUIT_TESTNET_URL",
        "https://garfield-testnet.zircuit.com",
      ),
      accounts,
    },
    zircuitMain: {
      chainId: 48900,
      url: vars.get("ZIRCUIT_MAINNET_URL", "https://zircuit-mainnet.drpc.org"),
      accounts,
    },
    megaETHTestnet: {
      chainId: 6342,
      url: vars.get("MEGAETH_TESTNET_URL", "https://carrot.megaeth.com/rpc"),
      accounts,
    },
    bitlayerTestnet: {
      chainId: 200810,
      url: vars.get("BITLAYER_TESTNET_URL", "https://testnet-rpc.bitlayer.org"),
      accounts,
    },
    bitlayerMain: {
      chainId: 200901,
      url: vars.get("BITLAYER_MAINNET_URL", "https://rpc.bitlayer.org"),
      accounts,
    },
    roninTestnet: {
      chainId: 2021,
      url: vars.get(
        "RONIN_TESTNET_URL",
        "https://saigon-testnet.roninchain.com/rpc",
      ),
      accounts,
    },
    roninMain: {
      chainId: 2020,
      url: vars.get("RONIN_MAINNET_URL", "https://api.roninchain.com/rpc"),
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
      hoodi: vars.get("ETHERSCAN_API_KEY", ""),
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
      polygonAmoy: vars.get("POLYGON_API_KEY", ""),
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
      // For Celo testnet & mainnet
      celo: vars.get("CELO_API_KEY", ""),
      alfajores: vars.get("CELO_API_KEY", ""),
      // For Harmony testnet & mainnet
      harmony: vars.get("HARMONY_API_KEY", ""),
      harmonyTestnet: vars.get("HARMONY_API_KEY", ""),
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
      // For Filecoin testnet & mainnet
      filecoin: vars.get("FILECOIN_API_KEY", ""),
      filecoinTestnet: vars.get("FILECOIN_API_KEY", ""),
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
      // For Endurance testnets & mainnet
      endurance: vars.get("ENDURANCE_API_KEY", ""),
      enduranceTestnet: vars.get("ENDURANCE_API_KEY", ""),
      openduranceTestnet: vars.get("OPENDURANCE_API_KEY", ""),
      // For Blast testnet & mainnet
      blast: vars.get("BLAST_API_KEY", ""),
      blastTestnet: vars.get("BLAST_API_KEY", ""),
      // For Kroma testnet & mainnet
      kroma: vars.get("KROMA_API_KEY", ""),
      kromaTestnet: vars.get("KROMA_API_KEY", ""),
      // For DOS Chain testnet & mainnet
      dos: vars.get("DOS_API_KEY", ""),
      dosTestnet: vars.get("DOS_API_KEY", ""),
      // For Fraxtal testnet & mainnet
      fraxtal: vars.get("FRAXTAL_API_KEY", ""),
      fraxtalTestnet: vars.get("FRAXTAL_API_KEY", ""),
      // For Kava mainnet
      kava: vars.get("KAVA_API_KEY", ""),
      // For Metis testnet & mainnet
      metis: vars.get("METIS_API_KEY", ""),
      metisTestnet: vars.get("METIS_API_KEY", ""),
      // For Mode testnet & mainnet
      mode: vars.get("MODE_API_KEY", ""),
      modeTestnet: vars.get("MODE_API_KEY", ""),
      // For X Layer testnet & mainnet
      xlayer: vars.get("OKLINK_API_KEY", ""),
      xlayerTestnet: vars.get("OKLINK_API_KEY", ""),
      // For BOB testnet & mainnet
      bob: vars.get("BOB_API_KEY", ""),
      bobTestnet: vars.get("BOB_API_KEY", ""),
      // For Core testnet & mainnet
      core: vars.get("CORE_MAINNET_API_KEY", ""),
      coreTestnet: vars.get("CORE_TESTNET_API_KEY", ""),
      // For Telos testnet & mainnet
      telos: vars.get("TELOS_API_KEY", ""),
      telosTestnet: vars.get("TELOS_API_KEY", ""),
      // For Rootstock testnet & mainnet
      rootstock: vars.get("ROOTSTOCK_API_KEY", ""),
      rootstockTestnet: vars.get("ROOTSTOCK_API_KEY", ""),
      // For Chiliz testnet & mainnet
      chiliz: vars.get("CHILIZ_API_KEY", ""),
      chilizTestnet: vars.get("CHILIZ_API_KEY", ""),
      // For Gravity Alpha testnet & mainnet
      gravityAlpha: vars.get("GRAVITY_ALPHA_API_KEY", ""),
      gravityAlphaTestnet: vars.get("GRAVITY_ALPHA_API_KEY", ""),
      // For Taiko testnet & mainnet
      taiko: vars.get("TAIKO_API_KEY", ""),
      taikoTestnet: vars.get("TAIKO_API_KEY", ""),
      // For ZetaChain testnet & mainnet
      zetaChain: vars.get("ZETA_CHAIN_API_KEY", ""),
      zetaChainTestnet: vars.get("ZETA_CHAIN_API_KEY", ""),
      // For 5ireChain testnet & mainnet
      "5ireChain": vars.get("5IRE_CHAIN_API_KEY", ""),
      "5ireChainTestnet": vars.get("5IRE_CHAIN_API_KEY", ""),
      // For Oasis Sapphire testnet & mainnet
      sapphire: vars.get("SAPPHIRE_API_KEY", ""),
      sapphireTestnet: vars.get("SAPPHIRE_API_KEY", ""),
      // For World Chain testnet & mainnet
      worldChain: vars.get("WORLD_CHAIN_API_KEY", ""),
      worldChainTestnet: vars.get("WORLD_CHAIN_API_KEY", ""),
      // For Plume testnet & mainnet
      plume: vars.get("PLUME_API_KEY", ""),
      plumeTestnet: vars.get("PLUME_API_KEY", ""),
      // For Unichain testnet & mainnet
      unichain: vars.get("UNICHAIN_API_KEY", ""),
      unichainTestnet: vars.get("UNICHAIN_API_KEY", ""),
      // For XDC testnet & mainnet
      xdc: vars.get("XDC_API_KEY", ""),
      xdcTestnet: vars.get("XDC_API_KEY", ""),
      // For SX testnet & mainnet
      sx: vars.get("SX_API_KEY", ""),
      sxTestnet: vars.get("SX_API_KEY", ""),
      // For Lisk testnet & mainnet
      lisk: vars.get("LISK_API_KEY", ""),
      liskTestnet: vars.get("LISK_API_KEY", ""),
      // For Metal L2 testnet & mainnet
      metalL2: vars.get("METALL2_API_KEY", ""),
      metalL2Testnet: vars.get("METALL2_API_KEY", ""),
      // For Superseed testnet & mainnet
      superseed: vars.get("SUPERSEED_API_KEY", ""),
      superseedTestnet: vars.get("SUPERSEED_API_KEY", ""),
      // For Story testnet
      storyTestnet: vars.get("STORY_API_KEY", ""),
      // For Sonic testnet & mainnet
      sonic: vars.get("SONIC_API_KEY", ""),
      sonicTestnet: vars.get("SONIC_API_KEY", ""),
      // For EVM on Flow testnet & mainnet
      flow: vars.get("FLOW_API_KEY", ""),
      flowTestnet: vars.get("FLOW_API_KEY", ""),
      // For Ink testnet & mainnet
      ink: vars.get("INK_API_KEY", ""),
      inkTestnet: vars.get("INK_API_KEY", ""),
      // For Morph testnet & mainnet
      morph: vars.get("MORPH_API_KEY", ""),
      morphTestnet: vars.get("MORPH_API_KEY", ""),
      // For Shape testnet & mainnet
      shape: vars.get("SHAPE_API_KEY", ""),
      shapeTestnet: vars.get("SHAPE_API_KEY", ""),
      // For Etherlink testnet & mainnet
      etherlink: vars.get("ETHERLINK_API_KEY", ""),
      etherlinkTestnet: vars.get("ETHERLINK_API_KEY", ""),
      // For Soneium testnet & mainnet
      soneium: vars.get("SONEIUM_API_KEY", ""),
      soneiumTestnet: vars.get("SONEIUM_API_KEY", ""),
      // For Swellchain testnet & mainnet
      swell: vars.get("SWELL_API_KEY", ""),
      swellTestnet: vars.get("SWELL_API_KEY", ""),
      // For Hemi testnet & mainnet
      hemi: vars.get("HEMI_API_KEY", ""),
      hemiTestnet: vars.get("HEMI_API_KEY", ""),
      // For Berachain testnet & mainnet
      berachain: vars.get("BERACHAIN_API_KEY", ""),
      berachainTestnet: vars.get("BERACHAIN_API_KEY", ""),
      // For Corn testnet & mainnet
      corn: vars.get("CORN_API_KEY", ""),
      cornTestnet: vars.get("CORN_API_KEY", ""),
      // For Arena-Z testnet & mainnet
      arenaz: vars.get("ARENAZ_API_KEY", ""),
      arenazTestnet: vars.get("ARENAZ_API_KEY", ""),
      // For IoTeX testnet & mainnet
      iotex: vars.get("IOTEX_API_KEY", ""),
      iotexTestnet: vars.get("IOTEX_API_KEY", ""),
      // For HYCHAIN testnet & mainnet
      hychain: vars.get("HYCHAIN_API_KEY", ""),
      hychainTestnet: vars.get("HYCHAIN_API_KEY", ""),
      // For Zircuit testnet & mainnet
      zircuit: vars.get("ZIRCUIT_API_KEY", ""),
      zircuitTestnet: vars.get("ZIRCUIT_API_KEY", ""),
      // For Bitlayer testnet & mainnet
      bitlayer: vars.get("BITLAYER_API_KEY", ""),
      bitlayerTestnet: vars.get("BITLAYER_API_KEY", ""),
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
        network: "hoodi",
        chainId: 560048,
        urls: {
          apiURL: "https://api-hoodi.etherscan.io/api",
          browserURL: "https://hoodi.etherscan.io",
        },
      },
      {
        network: "optimisticSepolia",
        chainId: 11155420,
        urls: {
          apiURL: "https://api-sepolia-optimistic.etherscan.io/api",
          browserURL: "https://sepolia-optimism.etherscan.io",
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
        network: "celo",
        chainId: 42220,
        urls: {
          apiURL: "https://api.celoscan.io/api",
          browserURL: "https://celoscan.io",
        },
      },
      {
        network: "alfajores",
        chainId: 44787,
        urls: {
          apiURL: "https://api-alfajores.celoscan.io/api",
          browserURL: "https://alfajores.celoscan.io",
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
          apiURL: "https://api.verify.mintscan.io/evm/api/0x2329",
          browserURL: "https://www.mintscan.io/evmos",
        },
      },
      {
        network: "evmosTestnet",
        chainId: 9000,
        urls: {
          apiURL: "https://api.verify.mintscan.io/evm/api/0x2328",
          browserURL: "https://www.mintscan.io/evmos-testnet",
        },
      },
      {
        network: "boba",
        chainId: 288,
        urls: {
          apiURL:
            "https://api.routescan.io/v2/network/mainnet/evm/288/etherscan",
          browserURL: "https://bobascan.com",
        },
      },
      {
        network: "bobaTestnet",
        chainId: 2888,
        urls: {
          apiURL:
            "https://api.routescan.io/v2/network/testnet/evm/2888/etherscan",
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
          apiURL: "https://api-sepolia.basescan.org/api",
          browserURL: "https://sepolia.basescan.org",
        },
      },
      {
        network: "mantle",
        chainId: 5000,
        urls: {
          apiURL: "https://api.mantlescan.xyz/api",
          browserURL: "https://mantlescan.xyz",
        },
      },
      {
        network: "mantleTestnet",
        chainId: 5003,
        urls: {
          apiURL: "https://api-sepolia.mantlescan.xyz/api",
          browserURL: "https://sepolia.mantlescan.xyz",
        },
      },
      {
        network: "filecoin",
        chainId: 314,
        urls: {
          apiURL: "https://filfox.info/api/v1/tools/verifyContract",
          browserURL: "https://filfox.info/en",
        },
      },
      {
        network: "filecoinTestnet",
        chainId: 314159,
        urls: {
          apiURL: "https://calibration.filfox.info/api/v1/tools/verifyContract",
          browserURL: "https://calibration.filfox.info/en",
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
        network: "polygonAmoy",
        chainId: 80002,
        urls: {
          apiURL: "https://api-amoy.polygonscan.com/api",
          browserURL: "https://amoy.polygonscan.com",
        },
      },
      {
        network: "polygonZkEVMTestnet",
        chainId: 2442,
        urls: {
          apiURL: "https://api-cardona-zkevm.polygonscan.com/api",
          browserURL: "https://cardona-zkevm.polygonscan.com",
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
        chainId: 59141,
        urls: {
          apiURL: "https://api-sepolia.lineascan.build/api",
          browserURL: "https://sepolia.lineascan.build",
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
        chainId: 999999999,
        urls: {
          apiURL: "https://sepolia.explorer.zora.energy/api",
          browserURL: "https://sepolia.explorer.zora.energy",
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
        chainId: 3441006,
        urls: {
          apiURL: "https://pacific-explorer.sepolia-testnet.manta.network/api",
          browserURL: "https://pacific-explorer.sepolia-testnet.manta.network",
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
      {
        network: "endurance",
        chainId: 648,
        urls: {
          apiURL: "https://explorer-endurance.fusionist.io/api",
          browserURL: "https://explorer-endurance.fusionist.io",
        },
      },
      {
        network: "enduranceTestnet",
        chainId: 6480,
        urls: {
          apiURL: "https://myexplorertestnet.fusionist.io/api",
          browserURL: "https://myexplorertestnet.fusionist.io",
        },
      },
      {
        network: "openduranceTestnet",
        chainId: 6480001001,
        urls: {
          apiURL: "https://explorer-l2-testnet.fusionist.io/api",
          browserURL: "https://explorer-l2-testnet.fusionist.io",
        },
      },
      {
        network: "blast",
        chainId: 81457,
        urls: {
          apiURL: "https://api.blastscan.io/api",
          browserURL: "https://blastscan.io",
        },
      },
      {
        network: "blastTestnet",
        chainId: 168587773,
        urls: {
          apiURL: "https://api-sepolia.blastscan.io/api",
          browserURL: "https://sepolia.blastscan.io",
        },
      },
      {
        network: "kroma",
        chainId: 255,
        urls: {
          apiURL: "https://api.kromascan.com/api",
          browserURL: "https://kromascan.com",
        },
      },
      {
        network: "kromaTestnet",
        chainId: 2358,
        urls: {
          apiURL: "https://api-sepolia.kromascan.com",
          browserURL: "https://sepolia.kromascan.com",
        },
      },
      {
        network: "dos",
        chainId: 7979,
        urls: {
          apiURL: "https://doscan.io/api",
          browserURL: "https://doscan.io",
        },
      },
      {
        network: "dosTestnet",
        chainId: 3939,
        urls: {
          apiURL: "https://test.doscan.io/api",
          browserURL: "https://test.doscan.io",
        },
      },
      {
        network: "fraxtal",
        chainId: 252,
        urls: {
          apiURL: "https://api.fraxscan.com/api",
          browserURL: "https://fraxscan.com",
        },
      },
      {
        network: "fraxtalTestnet",
        chainId: 2522,
        urls: {
          apiURL: "https://api-holesky.fraxscan.com/api",
          browserURL: "https://holesky.fraxscan.com",
        },
      },
      {
        network: "kava",
        chainId: 2222,
        urls: {
          apiURL: "https://kavascan.com/api",
          browserURL: "https://kavascan.com",
        },
      },
      {
        network: "metis",
        chainId: 1088,
        urls: {
          apiURL: "https://andromeda-explorer.metis.io/api",
          browserURL: "https://andromeda-explorer.metis.io",
        },
      },
      {
        network: "metisTestnet",
        chainId: 59902,
        urls: {
          apiURL: "https://sepolia-explorer.metisdevops.link/api",
          browserURL: "https://sepolia-explorer.metisdevops.link",
        },
      },
      {
        network: "mode",
        chainId: 34443,
        urls: {
          apiURL: "https://explorer.mode.network/api",
          browserURL: "https://explorer.mode.network",
        },
      },
      {
        network: "modeTestnet",
        chainId: 919,
        urls: {
          apiURL: "https://sepolia.explorer.mode.network/api",
          browserURL: "https://sepolia.explorer.mode.network",
        },
      },
      {
        network: "xlayer",
        chainId: 196,
        urls: {
          apiURL:
            "https://www.oklink.com/api/v5/explorer/contract/verify-source-code-plugin/XLAYER",
          browserURL: "https://www.oklink.com/x-layer",
        },
      },
      {
        network: "xlayerTestnet",
        chainId: 195,
        urls: {
          apiURL:
            "https://www.oklink.com/api/v5/explorer/contract/verify-source-code-plugin/XLAYER_TESTNET",
          browserURL: "https://www.oklink.com/x-layer-testnet",
        },
      },
      {
        network: "bob",
        chainId: 60808,
        urls: {
          apiURL: "https://explorer.gobob.xyz/api",
          browserURL: "https://explorer.gobob.xyz",
        },
      },
      {
        network: "bobTestnet",
        chainId: 111,
        urls: {
          apiURL: "https://testnet-explorer.gobob.xyz/api",
          browserURL: "https://testnet-explorer.gobob.xyz",
        },
      },
      {
        network: "core",
        chainId: 1116,
        urls: {
          apiURL: "https://openapi.coredao.org/api",
          browserURL: "https://scan.coredao.org",
        },
      },
      {
        network: "coreTestnet",
        chainId: 1115,
        urls: {
          apiURL: "https://api.test.btcs.network/api",
          browserURL: "https://scan.test.btcs.network",
        },
      },
      {
        network: "telos",
        chainId: 40,
        urls: {
          apiURL: "https://api.teloscan.io/api",
          browserURL: "https://www.teloscan.io",
        },
      },
      {
        network: "telosTestnet",
        chainId: 41,
        urls: {
          apiURL: "https://api.testnet.teloscan.io/api",
          browserURL: "https://testnet.teloscan.io",
        },
      },
      {
        network: "rootstock",
        chainId: 30,
        urls: {
          apiURL: "https://rootstock.blockscout.com/api",
          browserURL: "https://rootstock.blockscout.com",
        },
      },
      {
        network: "rootstockTestnet",
        chainId: 31,
        urls: {
          apiURL: "https://rootstock-testnet.blockscout.com/api",
          browserURL: "https://rootstock-testnet.blockscout.com",
        },
      },
      {
        network: "chiliz",
        chainId: 88888,
        urls: {
          apiURL:
            "https://api.routescan.io/v2/network/mainnet/evm/88888/etherscan/api",
          browserURL: "https://chiliscan.com",
        },
      },
      {
        network: "chilizTestnet",
        chainId: 88882,
        urls: {
          apiURL:
            "https://api.routescan.io/v2/network/testnet/evm/88882/etherscan/api",
          browserURL: "https://testnet.chiliscan.com",
        },
      },
      {
        network: "harmony",
        chainId: 1666600000,
        urls: {
          apiURL: "https://explorer.harmony.one/api",
          browserURL: "https://explorer.harmony.one",
        },
      },
      {
        network: "harmonyTestnet",
        chainId: 1666700000,
        urls: {
          apiURL: "https://explorer.testnet.harmony.one/api",
          browserURL: "https://explorer.testnet.harmony.one",
        },
      },
      {
        network: "gravityAlpha",
        chainId: 1625,
        urls: {
          apiURL: "https://explorer.gravity.xyz/api",
          browserURL: "https://explorer.gravity.xyz",
        },
      },
      {
        network: "gravityAlphaTestnet",
        chainId: 13505,
        urls: {
          apiURL: "https://explorer-sepolia.gravity.xyz/api",
          browserURL: "https://explorer-sepolia.gravity.xyz",
        },
      },
      {
        network: "taiko",
        chainId: 167000,
        urls: {
          apiURL: "https://api.taikoscan.io/api",
          browserURL: "https://taikoscan.io",
        },
      },
      {
        network: "taikoTestnet",
        chainId: 167009,
        urls: {
          apiURL: "https://api-hekla.taikoscan.io/api",
          browserURL: "https://hekla.taikoscan.io",
        },
      },
      {
        network: "zetaChain",
        chainId: 7000,
        urls: {
          apiURL: "https://zetachain.blockscout.com/api",
          browserURL: "https://zetachain.blockscout.com",
        },
      },
      {
        network: "zetaChainTestnet",
        chainId: 7001,
        urls: {
          apiURL: "https://zetachain-athens-3.blockscout.com/api",
          browserURL: "https://zetachain-athens-3.blockscout.com",
        },
      },
      {
        network: "5ireChain",
        chainId: 995,
        urls: {
          apiURL: "https://5irescan.io/api",
          browserURL: "https://5irescan.io",
        },
      },
      {
        network: "5ireChainTestnet",
        chainId: 997,
        urls: {
          apiURL: "https://testnet.5irescan.io/api",
          browserURL: "https://testnet.5irescan.io",
        },
      },
      {
        network: "sapphire",
        chainId: 23294,
        urls: {
          apiURL: "https://explorer.oasis.io/mainnet/sapphire/api",
          browserURL: "https://explorer.oasis.io/mainnet/sapphire",
        },
      },
      {
        network: "sapphireTestnet",
        chainId: 23295,
        urls: {
          apiURL: "https://explorer.oasis.io/testnet/sapphire/api",
          browserURL: "https://explorer.oasis.io/testnet/sapphire",
        },
      },
      {
        network: "worldChain",
        chainId: 480,
        urls: {
          apiURL: "https://worldchain-mainnet.explorer.alchemy.com/api",
          browserURL: "https://worldchain-mainnet.explorer.alchemy.com",
        },
      },
      {
        network: "worldChainTestnet",
        chainId: 4801,
        urls: {
          apiURL: "https://worldchain-sepolia.explorer.alchemy.com/api",
          browserURL: "https://worldchain-sepolia.explorer.alchemy.com",
        },
      },
      {
        network: "plume",
        chainId: 98866,
        urls: {
          apiURL: "https://phoenix-explorer.plumenetwork.xyz/api",
          browserURL: "https://phoenix-explorer.plumenetwork.xyz",
        },
      },
      {
        network: "plumeTestnet",
        chainId: 98867,
        urls: {
          apiURL: "https://testnet-explorer.plumenetwork.xyz/api",
          browserURL: "https://testnet-explorer.plumenetwork.xyz",
        },
      },
      {
        network: "unichain",
        chainId: 130,
        urls: {
          apiURL: "https://api.uniscan.xyz/api",
          browserURL: "https://uniscan.xyz",
        },
      },
      {
        network: "unichainTestnet",
        chainId: 1301,
        urls: {
          apiURL: "https://api-sepolia.uniscan.xyz/api",
          browserURL: "https://sepolia.uniscan.xyz",
        },
      },
      {
        network: "xdc",
        chainId: 50,
        urls: {
          apiURL: "https://api.xdcscan.com/api",
          browserURL: "https://xdcscan.com",
        },
      },
      {
        network: "xdcTestnet",
        chainId: 51,
        urls: {
          apiURL: "https://api-testnet.xdcscan.com/api",
          browserURL: "https://testnet.xdcscan.com",
        },
      },
      {
        network: "sx",
        chainId: 4162,
        urls: {
          apiURL: "https://explorerl2.sx.technology/api",
          browserURL: "https://explorerl2.sx.technology",
        },
      },
      {
        network: "sxTestnet",
        chainId: 79479957,
        urls: {
          apiURL: "https://explorerl2.toronto.sx.technology/api",
          browserURL: "https://explorerl2.toronto.sx.technology",
        },
      },
      {
        network: "lisk",
        chainId: 1135,
        urls: {
          apiURL: "https://blockscout.lisk.com/api",
          browserURL: "https://blockscout.lisk.com",
        },
      },
      {
        network: "liskTestnet",
        chainId: 4202,
        urls: {
          apiURL: "https://sepolia-blockscout.lisk.com/api",
          browserURL: "https://sepolia-blockscout.lisk.com",
        },
      },
      {
        network: "metalL2",
        chainId: 1750,
        urls: {
          apiURL: "https://explorer.metall2.com/api",
          browserURL: "https://explorer.metall2.com",
        },
      },
      {
        network: "metalL2Testnet",
        chainId: 1740,
        urls: {
          apiURL: "https://testnet.explorer.metall2.com/api",
          browserURL: "https://testnet.explorer.metall2.com",
        },
      },
      {
        network: "superseed",
        chainId: 5330,
        urls: {
          apiURL: "https://explorer.superseed.xyz/api",
          browserURL: "https://explorer.superseed.xyz",
        },
      },
      {
        network: "superseedTestnet",
        chainId: 53302,
        urls: {
          apiURL: "https://sepolia-explorer.superseed.xyz/api",
          browserURL: "https://sepolia-explorer.superseed.xyz",
        },
      },
      {
        network: "storyTestnet",
        chainId: 1315,
        urls: {
          apiURL: "https://aeneid.storyscan.io/api",
          browserURL: "https://aeneid.storyscan.io",
        },
      },
      {
        network: "sonic",
        chainId: 146,
        urls: {
          apiURL: "https://api.sonicscan.org/api",
          browserURL: "https://sonicscan.org",
        },
      },
      {
        network: "sonicTestnet",
        chainId: 57054,
        urls: {
          apiURL: "https://api-testnet.sonicscan.org/api",
          browserURL: "https://testnet.sonicscan.org",
        },
      },
      {
        network: "flow",
        chainId: 747,
        urls: {
          apiURL: "https://evm.flowscan.io/api",
          browserURL: "https://evm.flowscan.io",
        },
      },
      {
        network: "flowTestnet",
        chainId: 545,
        urls: {
          apiURL: "https://evm-testnet.flowscan.io/api",
          browserURL: "https://evm-testnet.flowscan.io",
        },
      },
      {
        network: "ink",
        chainId: 57073,
        urls: {
          apiURL: "https://explorer.inkonchain.com/api",
          browserURL: "https://explorer.inkonchain.com",
        },
      },
      {
        network: "inkTestnet",
        chainId: 763373,
        urls: {
          apiURL: "https://explorer-sepolia.inkonchain.com/api",
          browserURL: "https://explorer-sepolia.inkonchain.com",
        },
      },
      {
        network: "morph",
        chainId: 2818,
        urls: {
          apiURL: "https://explorer.morphl2.io/api",
          browserURL: "https://explorer.morphl2.io",
        },
      },
      {
        network: "morphTestnet",
        chainId: 2810,
        urls: {
          apiURL: "https://explorer-holesky.morphl2.io/api",
          browserURL: "https://explorer-holesky.morphl2.io",
        },
      },
      {
        network: "shape",
        chainId: 360,
        urls: {
          apiURL: "https://shapescan.xyz/api",
          browserURL: "https://shapescan.xyz",
        },
      },
      {
        network: "shapeTestnet",
        chainId: 11011,
        urls: {
          apiURL: "https://sepolia.shapescan.xyz/api",
          browserURL: "https://sepolia.shapescan.xyz",
        },
      },
      {
        network: "etherlink",
        chainId: 42793,
        urls: {
          apiURL: "https://explorer.etherlink.com/api",
          browserURL: "https://explorer.etherlink.com",
        },
      },
      {
        network: "etherlinkTestnet",
        chainId: 128123,
        urls: {
          apiURL: "https://testnet.explorer.etherlink.com/api",
          browserURL: "https://testnet.explorer.etherlink.com",
        },
      },
      {
        network: "soneium",
        chainId: 1868,
        urls: {
          apiURL: "https://soneium.blockscout.com/api",
          browserURL: "https://soneium.blockscout.com",
        },
      },
      {
        network: "soneiumTestnet",
        chainId: 1946,
        urls: {
          apiURL: "https://soneium-minato.blockscout.com/api",
          browserURL: "https://soneium-minato.blockscout.com",
        },
      },
      {
        network: "swell",
        chainId: 1923,
        urls: {
          apiURL: "https://explorer.swellnetwork.io/api",
          browserURL: "https://explorer.swellnetwork.io",
        },
      },
      {
        network: "swellTestnet",
        chainId: 1924,
        urls: {
          apiURL: "https://swell-testnet-explorer.alt.technology/api",
          browserURL: "https://swell-testnet-explorer.alt.technology",
        },
      },
      {
        network: "hemi",
        chainId: 43111,
        urls: {
          apiURL: "https://explorer.hemi.xyz/api",
          browserURL: "https://explorer.hemi.xyz",
        },
      },
      {
        network: "hemiTestnet",
        chainId: 743111,
        urls: {
          apiURL: "https://testnet.explorer.hemi.xyz/api",
          browserURL: "https://testnet.explorer.hemi.xyz",
        },
      },
      {
        network: "berachain",
        chainId: 80094,
        urls: {
          apiURL: "https://api.berascan.com/api",
          browserURL: "https://berascan.com",
        },
      },
      {
        network: "berachainTestnet",
        chainId: 80084,
        urls: {
          apiURL:
            "https://api.routescan.io/v2/network/testnet/evm/80084/etherscan",
          browserURL: "https://bartio.beratrail.io",
        },
      },
      {
        network: "corn",
        chainId: 21000000,
        urls: {
          apiURL:
            "https://api.routescan.io/v2/network/mainnet/evm/21000000/etherscan",
          browserURL: "https://cornscan.io",
        },
      },
      {
        network: "cornTestnet",
        chainId: 21000001,
        urls: {
          apiURL:
            "https://api.routescan.io/v2/network/testnet/evm/21000001/etherscan",
          browserURL: "https://testnet.cornscan.io",
        },
      },
      {
        network: "arenaz",
        chainId: 7897,
        urls: {
          apiURL: "https://explorer.arena-z.gg/api",
          browserURL: "https://explorer.arena-z.gg",
        },
      },
      {
        network: "arenazTestnet",
        chainId: 9897,
        urls: {
          apiURL: "https://arena-z.blockscout.com/api",
          browserURL: "https://arena-z.blockscout.com",
        },
      },
      {
        network: "iotex",
        chainId: 4689,
        urls: {
          apiURL: "https://iotexscout.io/api",
          browserURL: "https://iotexscan.io",
        },
      },
      {
        network: "iotexTestnet",
        chainId: 4690,
        urls: {
          apiURL: "https://testnet.iotexscan.io/api",
          browserURL: "https://testnet.iotexscan.io",
        },
      },
      {
        network: "hychain",
        chainId: 2911,
        urls: {
          apiURL: "https://explorer.hychain.com/api",
          browserURL: "https://explorer.hychain.com",
        },
      },
      {
        network: "hychainTestnet",
        chainId: 29112,
        urls: {
          apiURL: "https://testnet.explorer.hychain.com/api",
          browserURL: "https://testnet.explorer.hychain.com",
        },
      },
      {
        network: "zircuit",
        chainId: 48900,
        urls: {
          apiURL: "https://explorer.zircuit.com/api/contractVerifyHardhat",
          browserURL: "https://explorer.zircuit.com",
        },
      },
      {
        network: "zircuitTestnet",
        chainId: 48898,
        urls: {
          apiURL:
            "https://explorer.garfield-testnet.zircuit.com/api/contractVerifyHardhat",
          browserURL: "https://explorer.garfield-testnet.zircuit.com",
        },
      },
      {
        network: "bitlayer",
        chainId: 200901,
        urls: {
          apiURL: "https://api.btrscan.com/scan/api",
          browserURL: "https://www.btrscan.com",
        },
      },
      {
        network: "bitlayerTestnet",
        chainId: 200810,
        urls: {
          apiURL: "https://api-testnet.btrscan.com/scan/api",
          browserURL: "https://testnet.btrscan.com",
        },
      },
    ],
  },
};

export default config;
