import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import { any } from "hardhat/internal/core/params/argumentTypes";
require("dotenv").config();


type HttpNetworkAccountsUserConfig = any;
const config: HardhatUserConfig = {
  solidity: "0.8.9",
  networks: {
    alfajores: {
      url: "https://alfajores-forno.celo-testnet.org",
      accounts: [process.env.PRIVATE_KEY] as HttpNetworkAccountsUserConfig | undefined,
      chainId: 44787,
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  }
};



export default config;
