const hre = require("hardhat");

async function main() {
  const Contract = await hre.ethers.getContractFactory("Noni");
  const contract = await Contract.deploy();

  await contract.deployed();

  console.log("contract address:", contract.address);

  // await contract.safeMint("QmNQ1ABiGJ9fv9wzxf1k1eKbc8nvXBQw7VnQSNedeRwwfo")
  // await contract.safeMint("QmNQ1ABiGJ9fv9wzxf1k1eKbc8nvXBQw7VnQSNedeRwwfo")
  // await contract.safeMint("QmNQ1ABiGJ9fv9wzxf1k1eKbc8nvXBQw7VnQSNedeRwwfo")

  // let howMany = await contract.balanceOf("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266")
  // howMany = howMany.toNumber()
  // console.log(howMany)

  // for (let i = 0; i < howMany; i++) {
  //   console.log(i)
  //   const stuff = await contract.tokenOfOwnerByIndex("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", i);
  //   console.log(stuff)
  // }

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
