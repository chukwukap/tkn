import { expect } from "chai";
import { ethers } from "hardhat";
import { BlabStakingContract, BlabToken } from "../../typechain-types";
import { Signer } from "ethers";

describe("BlabStakingContract", function () {
  let stakingContract: BlabStakingContract;
  let blabToken: BlabToken;
  let owner: Signer;
  let staker1: Signer;
  let staker2: Signer;

  const REWARD_RATE = ethers.parseEther("1"); // 1 token per year
  const MIN_STAKE_AMOUNT = ethers.parseEther("1");
  const MAX_STAKE_AMOUNT = ethers.parseEther("1000000");
  const STAKING_DURATION = 365 * 24 * 60 * 60; // 1 year in seconds

  beforeEach(async function () {
    [owner, staker1, staker2] = await ethers.getSigners();

    const BlabToken = await ethers.getContractFactory("BlabToken");
    blabToken = await BlabToken.deploy();
    // await blabToken.deployed();

    const BlabStakingContract = await ethers.getContractFactory(
      "BlabStakingContract"
    );
    stakingContract = await BlabStakingContract.deploy(
      await blabToken.getAddress()
    );
    // await stakingContract.deployed();

    // Transfer tokens to stakers
    const staker1Amount = ethers.parseEther("100");
    const staker2Amount = ethers.parseEther("200");
    await blabToken.transfer(await staker1.getAddress(), staker1Amount);
    await blabToken.transfer(await staker2.getAddress(), staker2Amount);
  });

  describe("Deployment", function () {
    it("should set the correct staking token and deployment time", async function () {
      expect(await stakingContract.stakingToken()).to.equal(
        await blabToken.getAddress()
      );
      expect(await stakingContract.deploymentTime()).to.be.closeTo(
        Math.floor(Date.now() / 1000),
        10
      );
    });
  });

  describe("Stake", function () {
    it("should stake tokens successfully", async function () {
      const stakeAmount = ethers.parseEther("10");
      await blabToken
        .connect(staker1)
        .approve(await stakingContract.getAddress(), stakeAmount);
      await stakingContract.connect(staker1).stake(stakeAmount);

      expect(
        await stakingContract.stakers(await staker1.getAddress())
      ).to.have.property("amount", stakeAmount);
      expect(await stakingContract.totalStaked()).to.equal(stakeAmount);
    });

    it("should revert if staking amount is too low", async function () {
      const stakeAmount = ethers.parseEther("0.5");
      await blabToken
        .connect(staker1)
        .approve(await stakingContract.getAddress(), stakeAmount);
      await expect(
        stakingContract.connect(staker1).stake(stakeAmount)
      ).to.be.revertedWith("Invalid staking amount");
    });

    it("should revert if staking amount is too high", async function () {
      const stakeAmount = MAX_STAKE_AMOUNT + 1n;
      await blabToken
        .connect(staker1)
        .approve(await stakingContract.getAddress(), stakeAmount);
      await expect(
        stakingContract.connect(staker1).stake(stakeAmount)
      ).to.be.revertedWith("Invalid staking amount");
    });

    it("should revert if insufficient token balance", async function () {
      const stakeAmount = ethers.parseEther("1000");
      await blabToken
        .connect(staker1)
        .approve(await stakingContract.getAddress(), stakeAmount);
      await expect(
        stakingContract.connect(staker1).stake(stakeAmount)
      ).to.be.revertedWith("Insufficient balance");
    });
  });

  describe("Unstake", function () {
    it("should unstake tokens successfully", async function () {
      const stakeAmount = ethers.parseEther("10");
      await blabToken
        .connect(staker1)
        .approve(await stakingContract.getAddress(), stakeAmount);
      await stakingContract.connect(staker1).stake(stakeAmount);

      const unstakeAmount = ethers.parseEther("5");
      await stakingContract.connect(staker1).unstake(unstakeAmount);

      expect(
        await stakingContract.stakers(await staker1.getAddress())
      ).to.have.property("amount", stakeAmount + unstakeAmount);
      expect(await stakingContract.totalStaked()).to.equal(
        stakeAmount - unstakeAmount
      );
    });

    it("should revert if unstaking amount is zero", async function () {
      await expect(
        stakingContract.connect(staker1).unstake(0)
      ).to.be.revertedWith("Amount must be greater than 0");
    });

    it("should revert if insufficient staked amount", async function () {
      const unstakeAmount = ethers.parseEther("10");
      await expect(
        stakingContract.connect(staker1).unstake(unstakeAmount)
      ).to.be.revertedWith("Insufficient staked amount");
    });
  });

  describe("Claim Reward", function () {
    it("should claim rewards correctly", async function () {
      const stakeAmount = ethers.parseEther("100");
      await blabToken
        .connect(staker1)
        .approve(await stakingContract.getAddress(), stakeAmount);
      await stakingContract.connect(staker1).stake(stakeAmount);

      // Fast-forward time
      const fastForwardDuration = 365 * 24 * 60 * 60; // 1 year
      await ethers.provider.send("evm_increaseTime", [fastForwardDuration]);
      await ethers.provider.send("evm_mine", []);

      const expectedReward =
        (stakeAmount * REWARD_RATE) / ethers.parseEther("1");
      await stakingContract.connect(staker1).claimReward();

      expect(await blabToken.balanceOf(await staker1.getAddress())).to.equal(
        expectedReward
      );
      expect(
        await stakingContract.stakers(await staker1.getAddress())
      ).to.have.property("rewardDebt", expectedReward);
    });

    it("should not claim rewards if no tokens staked", async function () {
      await stakingContract.connect(staker1).claimReward();
      expect(await blabToken.balanceOf(await staker1.getAddress())).to.equal(0);
    });
  });

  describe("Recover Token", function () {
    it("should recover non-staking tokens", async function () {
      const recoveryToken = await (
        await ethers.getContractFactory("BlabToken")
      ).deploy();
      const tokenAmount = ethers.parseEther("100");
      await recoveryToken.transfer(
        await stakingContract.getAddress(),
        tokenAmount
      );

      const initialBalance = await recoveryToken.balanceOf(
        await owner.getAddress()
      );
      await stakingContract
        .connect(owner)
        .recoverToken(await recoveryToken.getAddress());
      expect(await recoveryToken.balanceOf(await owner.getAddress())).to.equal(
        initialBalance + tokenAmount
      );
    });

    it("should revert if trying to recover staking token", async function () {
      await expect(
        stakingContract
          .connect(owner)
          .recoverToken(await blabToken.getAddress())
      ).to.be.revertedWith("Cannot recover staking or reward tokens");
    });

    it("should revert if no tokens to recover", async function () {
      const recoveryToken = await (
        await ethers.getContractFactory("BlabToken")
      ).deploy();
      await expect(
        stakingContract
          .connect(owner)
          .recoverToken(await recoveryToken.getAddress())
      ).to.be.revertedWith("No tokens to recover");
    });
  });
});
