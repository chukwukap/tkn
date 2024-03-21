import { expect } from "chai";
import { ethers } from "hardhat";
import {
  BlabPresale,
  BlabToken,
  BlabToken__factory,
} from "../../typechain-types";
import { Signer } from "ethers";

describe("BlabPresale", function () {
  const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC_URL!);
  let blabPresale: BlabPresale;
  let blabToken: BlabToken;
  let owner: Signer;
  let buyer1: Signer;
  let buyer2: Signer;

  beforeEach(async function () {
    [owner, buyer1, buyer2] = await ethers.getSigners();

    const BlabToken = await ethers.getContractFactory("BlabToken");
    blabToken = await BlabToken.deploy();
    // await blabToken.deployed();

    const BlabPresale = await ethers.getContractFactory("BlabPresale");
    blabPresale = await BlabPresale.deploy(await blabToken.getAddress());
    // await blabPresale.deployed();
  });

  describe("Deployment", function () {
    it("should set the correct token address", async function () {
      expect(await blabPresale.token()).to.equal(await blabToken.getAddress());
    });

    it("should have the correct presale stage constants", async function () {
      expect(await blabPresale.PUBLIC_PRESALE_SUPPLY()).to.equal(
        ethers.parseEther("200000000")
      );
      expect(await blabPresale.PRIVATE_SALE_SUPPLY()).to.equal(
        ethers.parseEther("125000000")
      );
      // Add checks for other constants as needed
    });
  });

  describe("Presale Stage", function () {
    it("should start a presale stage successfully", async function () {
      await blabPresale.connect(owner).startPresaleStage(1);
      expect(await blabPresale.presaleStage()).to.equal(1);
    });

    it("should revert if trying to start an invalid presale stage", async function () {
      await expect(
        blabPresale.connect(owner).startPresaleStage(0)
      ).to.be.revertedWith("Invalid presale stage");
      await expect(
        blabPresale.connect(owner).startPresaleStage(7)
      ).to.be.revertedWith("Invalid presale stage");
    });
  });

  describe("Token Purchase", function () {
    beforeEach(async function () {
      await blabPresale.connect(owner).startPresaleStage(1);
    });

    it("should allow token purchase in a valid presale stage", async function () {
      const tokenAmount = ethers.parseEther("1000");
      const ethAmount = tokenAmount * ethers.parseEther("0.02");
      await expect(
        blabPresale.connect(buyer1).buyTokens(tokenAmount, { value: ethAmount })
      )
        .to.emit(blabPresale, "TokensPurchased")
        .withArgs(await buyer1.getAddress(), tokenAmount, 1);
      expect(await blabToken.balanceOf(await buyer1.getAddress())).to.equal(
        tokenAmount
      );
      expect(await blabPresale.stageTotalRaised(1)).to.equal(ethAmount);
    });

    it("should revert if presale is not active", async function () {
      await blabPresale.connect(owner).startPresaleStage(7);
      const tokenAmount = ethers.parseEther("1000");
      const ethAmount = tokenAmount * ethers.parseEther("0.02");
      await expect(
        blabPresale.connect(buyer1).buyTokens(tokenAmount, { value: ethAmount })
      ).to.be.revertedWith("Presale not active");
    });

    it("should revert if hardcap is reached", async function () {
      const hardcap = await blabPresale.PRESALE_STAGE_1_HARDCAP();
      const tokenAmount = hardcap / ethers.parseEther("0.02") + 1n;
      const ethAmount = tokenAmount * ethers.parseEther("0.02");
      await expect(
        blabPresale.connect(buyer1).buyTokens(tokenAmount, { value: ethAmount })
      ).to.be.revertedWith("Hardcap reached");
    });

    it("should revert if insufficient ETH is sent", async function () {
      const tokenAmount = ethers.parseEther("1000");
      const ethAmount = tokenAmount * ethers.parseEther("0.02") - 1n;
      await expect(
        blabPresale.connect(buyer1).buyTokens(tokenAmount, { value: ethAmount })
      ).to.be.revertedWith("Insufficient ETH sent");
    });

    it("should revert if insufficient token supply", async function () {
      const supplyLimit = await blabPresale.PRESALE_STAGE_1_SUPPLY();
      const tokenAmount = supplyLimit + 1n;
      const ethAmount = tokenAmount * ethers.parseEther("0.02");
      await expect(
        blabPresale.connect(buyer1).buyTokens(tokenAmount, { value: ethAmount })
      ).to.be.revertedWith("Insufficient token supply");
    });
  });

  describe("Private Sale Whitelist", function () {
    it("should add addresses to the private sale whitelist", async function () {
      const addresses = [await buyer1.getAddress(), await buyer2.getAddress()];
      await blabPresale.connect(owner).addToPrivateSaleWhitelist(addresses);
      expect(await blabPresale.privateSaleWhitelist(await buyer1.getAddress()))
        .to.be.true;
      expect(await blabPresale.privateSaleWhitelist(await buyer2.getAddress()))
        .to.be.true;
    });

    it("should revert if no addresses are provided", async function () {
      await expect(
        blabPresale.connect(owner).addToPrivateSaleWhitelist([])
      ).to.be.revertedWith("No address specified");
    });
  });

  describe("Withdraw Ether", function () {
    it("should allow the owner to withdraw Ether", async function () {
      const ethAmount = ethers.parseEther("1");
      await buyer1.sendTransaction({
        to: await blabPresale.getAddress(),
        value: ethAmount,
      });

      const initialOwnerBalance = await provider.getBalance(
        await owner.getAddress()
      );
      await blabPresale.connect(owner).withdrawEther(ethAmount);
      const finalOwnerBalance = await provider.getBalance(
        await owner.getAddress()
      );
      expect(finalOwnerBalance).to.be.gt(initialOwnerBalance);
    });

    it("should revert if insufficient balance", async function () {
      const ethAmount = ethers.parseEther("1000");
      await expect(
        blabPresale.connect(owner).withdrawEther(ethAmount)
      ).to.be.revertedWith("Insufficient balance");
    });
  });
});
