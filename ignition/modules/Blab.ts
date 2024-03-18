import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Blab", (m) => {
  const blabAddress = m.contract("BlabToken", []);
  const presale = m.contract("BlabPresale", [blabAddress]);
  console.log(presale);
  // m.call(blabAddress, "totalSupply", []);

  return { blabAddress };
});
