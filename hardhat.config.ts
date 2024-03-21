import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-ignition-ethers";
import "hardhat-gas-reporter";
import { config as dotenvConfig } from "dotenv";
dotenvConfig();

const config: HardhatUserConfig = {
  ignition: {
    blockPollingInterval: 1_000,
    timeBeforeBumpingFees: 3 * 60 * 1_000,
    maxFeeBumps: 4,
    requiredConfirmations: 2,
  },
  networks: {
    sepolia: {
      accounts: [process.env.SEPOLIA_PRIVATE_KEY!],
      chainId: parseInt(process.env.SEPOLIA_CHAINID!),
      url: process.env.SEPOLIA_RPC_URL!,
    },
    bscTestnet: {
      accounts: [process.env.BSC_PRIVATE_KEY2!, process.env.BSC_PRIVATE_KEY1!],
      // chainId: parseInt(process.env.BSC_TESTNET_CHAINID!),
      url: process.env.BSC_RPC_URL!,
    },
  },
  gasReporter: {
    enabled: true,
    outputFile: "gas-report.txt",
    noColors: true,
    currency: "USD",
    coinmarketcap: process.env.COINMARKETCAP_API_KEY!,
  },

  solidity: {
    compilers: [
      {
        version: "0.8.0",
      },
      {
        version: "0.8.20",
      },
    ],
  },
};

export default config;
