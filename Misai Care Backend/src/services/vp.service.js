const { createVerifiablePresentationJwt } = require('did-jwt-vc');
const { EthrDID } = require('ethr-did');
const { Resolver } = require('did-resolver');
const { getResolver } = require('ethr-did-resolver');
const { ethers } = require('ethers');

// ✅ Replace with user’s DID private key — in real apps, use wallet or session signer
const PRIVATE_KEY = '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890';
const wallet = new ethers.Wallet(PRIVATE_KEY);
const userDID = new EthrDID({
  identifier: wallet.address,
  privateKey: PRIVATE_KEY,
  chainNameOrId: 'mainnet'
});

const resolver = new Resolver(getResolver({
  networks: [
    {
      name: 'mainnet',
      chainId: 1,
      rpcUrl: 'https://mainnet.infura.io/v3/98fd383251cf4e5dbc12d76347d427d8'
    }
  ]
}));

export async function issueVP({ vcJwt }) {
  const vpPayload = {
    vp: {
      '@context': ['https://www.w3.org/2018/credentials/v1'],
      type: ['VerifiablePresentation'],
      verifiableCredential: [vcJwt]
    }
  };

  const vpJwt = await createVerifiablePresentationJwt(vpPayload, userDID);
  return {
    vp: { jwt: vpJwt }
  };
}

