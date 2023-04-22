import { ethers } from "hardhat";

async function main() {

  // ////////////DEPLOYING THE IMPLEMENTATION CONTRACT/////////////
  // const MultisigWallet = await ethers.getContractFactory("MultisigWallet");
  // const multisigWallet = await MultisigWallet.deploy();
  // await multisigWallet.deployed();
  // console.log(`Multisig Wallet contract is deployed to ${multisigWallet.address}`);


  ///////////////DEPLOYING MULTISIG WALLET MINIMAL PROXY FACTORY///////////////
  const MinimalProxyFactory = await ethers.getContractFactory("MinimalProxy");
  const minimalProxy = await MinimalProxyFactory.deploy();

  await minimalProxy.deployed();

  console.log(`Minimal Proxy Factory is deployed to ${minimalProxy.address}`)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
