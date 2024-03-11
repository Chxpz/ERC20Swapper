import * as dotenv from "dotenv";
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.24",
      },
    ],
    settings: {
      optimizer: {
        enabled: true,
        runs: 2000,
      },
    },
  },

  networks: {
    hardhat: {
      forking: {
        url: process.env.MUMBAI_URL || "",
      },
    },
    mumbai: {
      url: process.env.MUMBAI_URL || "",
      accounts: process.env.PVT_KEY !== undefined ? [process.env.PVT_KEY] : [],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};

export default config;
