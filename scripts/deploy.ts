import { ethers } from "hardhat";

async function main() {
  const owner = "0x51BfB0d94b98428e1bb87c4EDAFbD93366D2Ab71";
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
