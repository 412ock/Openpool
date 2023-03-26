import {expect} from 'chai';
import {ethers} from 'hardhat';

describe("NFT Contract", ()=>{
    const deployNFTContract = async ()=>{
        const NFT = await ethers.getContractFactory("NFT");
        const nft = await NFT.deploy("TEST", "TT", "none");

        return nft;
    }

    describe("Support Interface", ()=>{
        it("Check Support Interface ERC721 Standard", async()=>{
            const nft = await deployNFTContract();

            const result = await nft.supportsInterface("0x80ac58cd")

            expect(result).to.equals(true);
        })
    })
})