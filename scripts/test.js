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

    const baseURI = 'https://xxx.mypinata.cloud/ipfs/'

    const initURI = "https://nft.service.cometh.io/1000422";

    const MidnightApes = await ethers.getContractFactory("MidnightApes", deployer);

    const apes = await MidnightApes.deploy(initURI);

    await apes.deployed();

    console.log("apes Contract deployed to ", apes.address)

    let tx

    tx = await apes.startMint()
    await tx.wait()

    console.log('start mint:')

    tx = await apes.mint(2,{value:parseEther('0')})
    await tx.wait()
    
    {
      const tokens = await apes.tokensOfOwner(deployer.address);

      console.log('deployer nfts:',tokens)

      console.log('deployer nfts tokenURI:',tokens[0],(await apes.tokenURI(tokens[0])))
    }

    console.log('total minted nft:',(await apes.totalMinted()));
    console.log('user minted nft count:',(await apes.numberMinted(deployer.address)));


    tx = await apes.connect(tester).mint(2,{value:parseEther('0')})
    await tx.wait()

    // tx = await apes.connect(tester).mint(2,{value:parseEther('0')})
    // await tx.wait()

    console.log('tester apes minted:');

    console.log('total minted nft:',(await apes.totalMinted()));
    console.log('user minted nft count:',(await apes.numberMinted(deployer.address)));
    console.log('tester minted nft count:',(await apes.numberMinted(tester.address)));


    tx = await apes.setMintPrice(parseEther('0.005'))
    await tx.wait()
    console.log('change mint price')

    tx = await apes.mint(3,{value:parseEther('0.015')})
    await tx.wait()


    tx = await apes.mint(9,{value:parseEther('0.045')})
    await tx.wait()

    console.log('mint nft with eth:')

    console.log('total minted nft:',(await apes.totalMinted()));
    console.log('user minted nft count:',(await apes.numberMinted(deployer.address)));


    tx = await apes.setBaseURI(baseURI)
    await tx.wait()
    console.log('change baseURI',baseURI)
    

    {
      const tokens = await apes.tokensOfOwner(deployer.address);

      console.log('deployer nfts:',tokens)

      console.log('deployer nfts tokenURI:',tokens[0],(await apes.tokenURI(tokens[0])))
    }


    tx = await apes.revealNFT()
    await tx.wait()

    console.log('reveal nft')

    {
      const tokens = await apes.tokensOfOwner(deployer.address);

      console.log('deployer nfts:',tokens)

      console.log('deployer nfts tokenURI:',tokens[0],(await apes.tokenURI(tokens[0])))
    }



    console.log('deployer:',deployer.address, formatEther(await deployer.getBalance()));
    console.log('contract balance:',deployer.address, formatEther(await ethers.provider.getBalance(apes.address)));


}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })
