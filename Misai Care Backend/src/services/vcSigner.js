import { createVerifiableCredentialJwt } from 'did-jwt-vc';
import { EthrDID } from 'ethr-did';
import Web3 from 'web3';
import dotenv from 'dotenv';
dotenv.config();

const INFURA_URL = process.env.INFURA_URL;

const web3 = new Web3(INFURA_URL);

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ISSUER_DID = process.env.ISSUER_DID; 

const issuerDid = new EthrDID({
  identifier: ISSUER_DID,
  privateKey: PRIVATE_KEY,
  provider: web3.currentProvider,
  chainNameOrId: 'sepolia'
});

export async function signVC(vcPayload) {
  return await createVerifiableCredentialJwt(vcPayload, issuerDid);
}
