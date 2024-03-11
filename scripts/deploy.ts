import { ethers } from "hardhat";

async function main() {
  const owner = "0x420b7259ff5f04C200dcaADFeE585C2397B410EE";
  const wethAddress = "0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889";

  const UniswapMarket = await ethers.deployContract(
    "UniswapMarketUniversalRouter"
  );
  await UniswapMarket.waitForDeployment();

  const ERC20Swapper = await ethers.deployContract("ERC20Swapper", [
    owner,
    wethAddress,
    UniswapMarket.target,
  ]);
  await ERC20Swapper.waitForDeployment();

  console.log(`ERC20Swapper deployed to ${ERC20Swapper.target}`);

  console.log(`UniswapMarket deployed to ${UniswapMarket.target}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
