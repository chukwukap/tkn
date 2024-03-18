import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-ignition-ethers";
import { config as dotenvConfig } from "dotenv";
dotenvConfig();

const config: HardhatUserConfig = {
  // ignition: {
  //   blockPollingInterval: 1_000,
  //   timeBeforeBumpingFees: 3 * 60 * 1_000,
  //   maxFeeBumps: 4,
  //   requiredConfirmations: 5,
  // },

  networks: {
    sepolia: {
      accounts: [process.env.SEPOLIA_PRIVATE_KEY!],
      chainId: parseInt(process.env.SEPOLIA_CHAINID!),
      url: process.env.ALCHEMY_RPC_URL!,
    },
    bscTestnet: {
      accounts: [process.env.Bsc_PRIVATE_KEY!],
      chainId: parseInt(process.env.Bsc_TESTNET_CHAINID!),
      url: process.env.Bsc_RPC_URL!,
    },
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
