import { EthrDID } from 'ethr-did';
import { Resolver } from 'did-resolver';
import { getResolver } from 'ethr-did-resolver';
import { createVerifiableCredentialJwt } from 'did-jwt-vc';
import { storeJSON } from './ipfs.service.js'; // ✅ make sure .js is included in import path
import { ethers } from 'ethers';

// const PRIVATE_KEY = '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890';

// const wallet = new ethers.Wallet(PRIVATE_KEY);
// const address = wallet.address;

// const issuer = new EthrDID({
//   identifier: address,
//   privateKey: PRIVATE_KEY,
//   chainNameOrId: 'mainnet'
// });

// const providerConfig = {
//   networks: [
//     {
//       name: 'mainnet',
//       chainId: 1,
//       rpcUrl: `https://mainnet.infura.io/v3/98fd383251cf4e5dbc12d76347d427d8`
//     }
//   ]
// };

// const didResolver = new Resolver(getResolver(providerConfig));

// export async function issueIdentityVC({ did, abhaId }) {
//   const vcPayload = {
//     sub: did,
//     nbf: Math.floor(Date.now() / 1000),
//     vc: {
//       '@context': ['https://www.w3.org/2018/credentials/v1'],
//       type: ['VerifiableCredential', 'IdentityCredential'],
//       credentialSubject: {
//         id: did,
//         abhaId: abhaId
//       }
//     }
//   };

//   const jwtVC = await createVerifiableCredentialJwt(vcPayload, issuer);

//   const vcCid = await storeJSON({ jwt: jwtVC });

//   return { vc: { jwt: jwtVC }, cid: vcCid };
// }

// export async function createPolicyVC({ did, policyId }) {
//   const vcPayload = {
//     sub: did,
//     nbf: Math.floor(Date.now() / 1000),
//     vc: {
//       '@context': ['https://www.w3.org/2018/credentials/v1'],
//       type: ['VerifiableCredential', 'PolicyCredential'],
//       credentialSubject: {
//         id: did,
//         policyId
//       }
//     }
//   };

//   const jwtVC = await createVerifiableCredentialJwt(vcPayload, issuer);
//   const vcCid = await storeJSON({ jwt: jwtVC });

//   return { vc: { jwt: jwtVC }, cid: vcCid };
// }

const issuerPrivateKey = process.env.ISSUER_PRIVATE_KEY;
const issuerAddress = process.env.ISSUER_ADDRESS;

console.log('ISSUER_ADDRESS:', process.env.ISSUER_ADDRESS);
console.log('ISSUER_PRIVATE_KEY:', process.env.ISSUER_PRIVATE_KEY);

const issuerDID = new EthrDID({
  identifier: issuerAddress,
  privateKey: issuerPrivateKey,
  chainNameOrId: 80001   //mumbai
});

export async function issueIdentityVC(userDID, abhaId, mobile) {
  const vcPayload = {
    sub: userDID,
    nbf: Math.floor(Date.now() / 1000),
    vc: {
      "@context": ["https://www.w3.org/2018/credentials/v1"],
      type: ["VerifiableCredential", "IdentityCredential"],
      credentialSubject: {
        id: userDID,
        abhaId,
        mobile
      }
    }
  };

  const jwt = await createVerifiableCredentialJwt(vcPayload, issuerDID);
  return jwt;
}

// module.exports = { issueIdentityVC };

// module.exports = { issueIdentityVC };
