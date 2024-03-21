import { expect } from "chai";
import { ethers, ignition } from "hardhat";
import { BlabToken, ERC20 } from "../../typechain-types";
import { Signer } from "ethers";
import BlabStakingModule from "../../ignition/modules/blab-staking";

import { BlabToken__factory } from "../../typechain-types";

describe("BlabToken", function () {
  let BlabTokenFactory: BlabToken__factory;
  let blabToken: BlabToken;
  let owner: Signer;
  let user1: Signer;
  let user2: Signer;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();
    BlabTokenFactory = await ethers.getContractFactory("BlabToken");
    blabToken = await BlabTokenFactory.deploy();
  });

  describe("Deployment", function () {
    it("should set the right owner", async function () {
      expect(await blabToken.owner()).to.equal(await owner.getAddress());
    });

    it("should have the correct name and symbol", async function () {
      expect(await blabToken.name()).to.equal("BITSLAB");
      expect(await blabToken.symbol()).to.equal("BLAB");
    });

    it("should mint the total supply to the contract", async function () {
      const totalSupply: BigInt = await blabToken.TOTAL_SUPPLY();
      expect(await blabToken.totalSupply()).to.equal(totalSupply);
      expect(await blabToken.balanceOf(await blabToken.getAddress())).to.equal(
        totalSupply
      );
    });
  });

  describe("Transfers", function () {
    it("should transfer tokens between accounts", async function () {
      const transferAmount = ethers.parseEther("100");
      await blabToken.transfer(await user1.getAddress(), transferAmount);
      expect(await blabToken.balanceOf(await user1.getAddress())).to.equal(
        transferAmount
      );
    });

    it("should fail if sender doesn't have enough tokens", async function () {
      const initialOwnerBalance = await blabToken.balanceOf(
        await owner.getAddress()
      );
      await expect(
        blabToken.connect(user1).transfer(await owner.getAddress(), 1)
      ).to.be.revertedWith("ERC20: transfer amount exceeds balance");
      expect(await blabToken.balanceOf(await owner.getAddress())).to.equal(
        initialOwnerBalance
      );
    });

    it("should update balances after transfers", async function () {
      const initialOwnerBalance = await blabToken.balanceOf(
        await owner.getAddress()
      );
      const transferAmount = ethers.parseEther("100");
      await blabToken.transfer(await user1.getAddress(), transferAmount);
      expect(await blabToken.balanceOf(await owner.getAddress())).to.equal(
        initialOwnerBalance - transferAmount
      );
      expect(await blabToken.balanceOf(await user1.getAddress())).to.equal(
        transferAmount
      );
    });
  });

  describe("Allowance", function () {
    it("should approve and transfer tokens on behalf of the owner", async function () {
      const transferAmount = ethers.parseEther("100");
      await blabToken.approve(await user1.getAddress(), transferAmount);
      await blabToken
        .connect(user1)
        .transferFrom(
          await owner.getAddress(),
          await user2.getAddress(),
          transferAmount
        );
      expect(await blabToken.balanceOf(await user2.getAddress())).to.equal(
        transferAmount
      );
    });

    it("should fail if spender doesn't have enough allowance", async function () {
      const initialOwnerBalance = await blabToken.balanceOf(
        await owner.getAddress()
      );
      await expect(
        blabToken
          .connect(user1)
          .transferFrom(await owner.getAddress(), await user2.getAddress(), 1)
      ).to.be.revertedWith("ERC20: insufficient allowance");
      expect(await blabToken.balanceOf(await owner.getAddress())).to.equal(
        initialOwnerBalance
      );
    });
  });
});
