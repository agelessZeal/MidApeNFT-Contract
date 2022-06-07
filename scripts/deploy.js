//https://metacar.mypinata.cloud/ipfs/QmejiCkhVKaV4zRPAWFg2KKTK5Hx14xpa3HZdehtiBVcpF

const hre = require('hardhat')

const sleep = (delay) => new Promise((resolve) => setTimeout(resolve, delay * 1000));

const {splitSignature} = require("@ethersproject/bytes");

async function main () {
    const ethers = hre.ethers
    
    const {parseEther, formatEther} = ethers.utils;


    const tester = new ethers.Wallet(process.env.TEST_KEY, ethers.provider)

    const testerAddress = tester.address;
  
    console.log('tester:',testerAddress, formatEther(await tester.getBalance()));
  
    console.log('*****************************************************');

  
    const deployer = new ethers.Wallet(process.env.PRIVATE_KEY, ethers.provider)

    console.log('deployer:',deployer.address, formatEther(await deployer.getBalance()));

    console.log('network:', await ethers.provider.getNetwork())

    const hiddenMetaData = "https://midnight.mypinata.cloud/ipfs/QmSHuNNk7gk4S6o3LdT3NBao4iQmxTR8bjrTLfW6UaXakv";

    const MidnightApes = await ethers.getContractFactory("MidnightApes", deployer);

    const apes = await MidnightApes.deploy(hiddenMetaData);

    await apes.deployed();

    console.log("apes Contract deployed to ", apes.address)

    let tx

    tx = await apes.startMint()
    await tx.wait()

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })
