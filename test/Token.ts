import {expect} from 'chai';
import {ethers} from 'hardhat';

describe("Token", ()=>{
    const deployTokenContract = async (mintAmount: number)=>{
        const Token = await ethers.getContractFactory("Token");
        const token = await Token.deploy("SimpleToken", "STT", "18");

        const signers = await ethers.getSigners();

        const addresses = signers.map(signer=>signer.getAddress());
        
        await token.mint(addresses[0], mintAmount);

        return [token, ...addresses] as const;
    }    

    describe("Mint", ()=>{
        it("Minting self", async ()=>{
            const [token, ownerAddress] = await deployTokenContract(10000);

            const ownerBalance = await token.balanceOf(ownerAddress);

            expect(ownerBalance).to.equal(10000);
        })
    })

    describe("Transfer", ()=>{
        it("Transfer token to other one", async ()=>{
            const [token, ownerAddress, otherAddress] = await deployTokenContract(10000);

            await token.transfer(otherAddress, 5000);
            const ownerBalance = await token.balanceOf(ownerAddress);
            const otherBalance = await token.balanceOf(otherAddress);

            expect(ownerBalance).to.equal(5000);
            expect(otherBalance).to.equal(5000);
        })
    })

    describe("Approve", ()=>{
        it("Approve token to other one", async ()=>{
            const [token, ownerAddress, otherAddress] = await deployTokenContract(10000);

            await token.approve(otherAddress, 3000);
            const allowanceFromOwnerToOther = await token.allowance(ownerAddress, otherAddress);

            expect(allowanceFromOwnerToOther).to.equal(3000);
        })

        it("Transfer token to receiver by spender", async ()=>{
            const [token, ownerAddress, spenderAddress, receiverAddress]
            = await deployTokenContract(10000);

            const [owner, spender, receiver] = await ethers.getSigners();

            await token.approve(spenderAddress, 3000);
            await token.connect(spender).transferFrom(ownerAddress, receiverAddress, 2000);

            const receiverBalance = await token.balanceOf(receiverAddress);
            const allowance = await token.allowance(ownerAddress, spenderAddress);

            expect(receiverBalance).to.equal(2000);
            expect(allowance).to.equal(1000);
        })
    })
})