import { verifyCredential } from 'did-jwt-vc';
import { Resolver } from 'did-resolver';
import { getResolver } from 'ethr-did-resolver';

const providerConfig = {
  networks: [
    {
      name: 'mainnet',
      chainId: 1,
      rpcUrl: 'https://mainnet.infura.io/v3/98fd383251cf4e5dbc12d76347d427d8'
    }
  ]
};

const ethrDidResolver = getResolver(providerConfig);
const didResolver = new Resolver(ethrDidResolver);

export async function verifyVC(vcJwt) {
  try {
    const verifiedVC = await verifyCredential(vcJwt, didResolver);
    return {
      valid: true,
      payload: verifiedVC.payload
    };
  } catch (error) {
    console.error('VC verification failed:', error);
    return {
      valid: false,
      error: error.message
    };
  }
}
