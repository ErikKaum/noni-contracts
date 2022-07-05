const hre = require("hardhat");

async function main() {
  const Contract = await hre.ethers.getContractFactory("Game");
  const contract = await Contract.deploy();

  await contract.deployed();

  console.log("contract address:", contract.address);

  const board = await contract.checkWinner(0, -1)
  console.log(board)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
