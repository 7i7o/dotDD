const { ethers } = require("hardhat");
const hre = require("hardhat");
const { stringify } = require("querystring");

const CONTRACT_NAME = "DevDaoDomain"
const CONTRACT_ADDR = "0x7B2812F7E2F857b756886222d54dd63657f89c4C"

async function main() {

  // We get the contract to deploy
  const ContractFactory = await hre.ethers.getContractFactory(CONTRACT_NAME);
  // const deployedContract = await ContractFactory.deploy();
  // await deployedContract.deployed();
  // console.log("Contract deployed to:", deployedContract.address);

  const deployedContract = await ContractFactory.attach(CONTRACT_ADDR);
  console.log("Attached contract:", deployedContract.address);



  // We also save the contract's artifacts and address in the frontend directory
  saveFrontendFiles(deployedContract);

  const domain = 'naderFull';
  // Mint a domain to see if it works
  const txn = await deployedContract.mint(domain);
  const receipt = await txn.wait();

  if (receipt.status === 1) {
    const event = receipt.events.find(event => event.event === 'Transfer');
    const [from, to, tokenId] = event.args;
    console.log(from, to, tokenId);
    // const mintId = tokenId.toNumber();

    console.log(`${domain}.devdao minted with TokenId: ${tokenId}`);

    // await deployedContract.setTwitter(tokenId, true, '@dabit3')

    const info = {
      showAddress: true,
      showUrl: true,
      showTwitter: true,
      showDiscord: true,
      showGithub: true,
      showD4R: true,
      addr: ethers.utils.getAddress('0xB2Ebc9b3a788aFB1E942eD65B59E9E49A1eE500D'),
      domain: '',
      url: 'https://dev.to/dabit3',
      twitter: '@dabit3',
      discord: 'nader#1506',
      github: 'dabit3',
    }

    console.log(`Setting info on ${domain}.devdao:`)
    await deployedContract.setInfo(domain, info);

    console.log(`${domain} TokenURI:`)
    console.log(`------------`)

    const tokenURI = await deployedContract.tokenURI(tokenId);

    console.log(tokenURI)

    console.log(`------------`)
  }



}

function saveFrontendFiles(deployedContract) {
  const fs = require("fs");
  const contractsDir = __dirname + "/../frontend/src/contracts";

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    contractsDir + "/contract-address.json",
    JSON.stringify({ Contract: deployedContract.address }, undefined, 2)
  );

  const ContractArtifact = artifacts.readArtifactSync(CONTRACT_NAME);

  fs.writeFileSync(
    contractsDir + "/contract-artifact.json",
    JSON.stringify(ContractArtifact, null, 2)
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
