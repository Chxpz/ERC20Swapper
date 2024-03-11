import { expect } from "chai";
import { Signer } from "ethers";
import { ethers, network } from "hardhat";
import { abi } from "./ERC20Abi.json";

require("chai").use(require("chai-as-promised")).should();

/**
 * @notice This is a test suite for the Swapper Smart Contract
 * @notice Extensive tests not performed intentionally due to time constraints
 * a production version would require more extensive testing
 * @dev Runs this test forking the mumbai network
 */

describe("Tests for Swapper Smart Contracts", function () {
  let admin: Signer;
  let user1: Signer;

  let swapper: any;
  let uniSwapMarketLib: any;
  let wethContract: any;
  let daiContract: any;

  this.beforeAll(async function () {
    [admin] = await ethers.getSigners();

    const SWAPPER = await ethers.getContractFactory("ERC20Swapper");
    const wethAddress = "0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889";

    const UNISWAPMARKETLIB = await ethers.getContractFactory("UniswapMarket");
    uniSwapMarketLib = await UNISWAPMARKETLIB.deploy();
    swapper = await SWAPPER.deploy(
      await admin.getAddress(),
      wethAddress,
      await uniSwapMarketLib.getAddress()
    );

    wethContract = await ethers.getContractAt("IWETH9", wethAddress);
    daiContract = await ethers.getContractAt(
      abi,
      "0x001B3B4d0F3714Ca98ba10F6042DaEbF0B1B7b6F"
    );

    user1 = await ethers.getImpersonatedSigner(
      "0xfd027dec21ac710c4b7e6b9a96534fd377c2d18c"
    );
    await network.provider.send("hardhat_setBalance", [
      "0xfd027dec21ac710c4b7e6b9a96534fd377c2d18c",
      "0x100000000000000000",
    ]);
  });

  describe("Smart Contract Tests", function () {
    it("Should deploy the Smart Contract", async function () {
      expect(await swapper.getAddress()).to.not.be.undefined;
      expect(await uniSwapMarketLib.getAddress()).to.not.be.undefined;
    });
    it("Should Swap Eth to Dai", async () => {
      const user1Address = await user1.getAddress();

      const ethBalanceBefore = await ethers.provider.getBalance(user1Address);

      const value = ethers.parseEther("1");

      await swapper
        .connect(user1)
        .swapEtherToToken(await daiContract.getAddress(), 1, {
          value,
        });

      const daiBalance = await daiContract.balanceOf(user1Address);
      const ethBalanceAfter = await ethers.provider.getBalance(user1Address);

      const balanceWeth = await wethContract.balanceOf(
        await user1.getAddress()
      );

      expect(daiBalance).to.be.gt(0);
      expect(ethBalanceAfter).to.be.lt(ethBalanceBefore);
      expect(balanceWeth).to.be.eq(0);
    });
  });
});
