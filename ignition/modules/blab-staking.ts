import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const BlabStakingModule = buildModule("BlabStakingModule", (m) => {
  const blabToken = m.contract("BlabToken");
  const blabStaking = m.contract("BlabStakingContract", [blabToken]);

  return { blabToken, blabStaking };
});

export default BlabStakingModule;
