import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";

describe("Test SaveAsset Functionality", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployContractsFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await hre.ethers.getSigners();

    const ERC20 = await hre.ethers.getContractFactory("ERC20");
    const erc20 = await ERC20.deploy();
    const tokenName = "WEB3CXIV";
    const tokenSymbol = "CXIV";

    const SaveAssetFactory = await hre.ethers.getContractFactory("SaveAsset");
    const SaveAsset = await SaveAssetFactory.deploy(erc20.target);

    return { owner, otherAccount, erc20, tokenName, tokenSymbol, SaveAsset };
  }

  describe("Test ERC20 basic props", function () {
    it("Should set the right name", async function () {
      const { erc20, tokenName } = await loadFixture(deployContractsFixture);

      expect(await erc20.name()).to.equal(tokenName);
    });

    it("Should set the right symbol", async function () {
      const { erc20, tokenSymbol } = await loadFixture(deployContractsFixture);

      expect(await erc20.symbol()).to.equal(tokenSymbol);
    });
  });

  describe("Test SaveAsset Functions", function () {
    it("Should deposit ether successfully and stop zero deposit", async function () {
      const { SaveAsset, owner } = await loadFixture(deployContractsFixture);
      const depositAmount = hre.ethers.parseEther("1");

      await expect(SaveAsset.deposit({ value: depositAmount }))
        .to.emit(SaveAsset, "DepositSuccessful")
        .withArgs(owner.address, depositAmount);
        
      await expect(SaveAsset.deposit({ value: 0 })).to.be.revertedWith(
        "Can't deposit zero value"
      );

      expect(await SaveAsset.balances(owner.address)).to.equal(depositAmount);
    });

    it("Should deposit erc20 token successfully and stop zero deposit", async function () {
      const { SaveAsset, erc20 } = await loadFixture(deployContractsFixture);
      const depositAmount = 100;

      await expect(SaveAsset.depositERC20(depositAmount))
        .to.emit(SaveAsset, "DepositSuccessful")
        // .withArgs(owner.address, depositAmount);

      await expect(SaveAsset.depositERC20(0)).to.be.revertedWith(
        "Can't send zero value"
      );
    });
  });
});
