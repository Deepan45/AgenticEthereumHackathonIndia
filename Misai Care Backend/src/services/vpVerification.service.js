const { verifyPresentation } = require('did-jwt-vc');
const { Resolver } = require('did-resolver');
const { getResolver } = require('ethr-did-resolver');

// Setup DID Resolver
const didResolver = new Resolver(getResolver({
  networks: [
    {
      name: 'mainnet',
      chainId: 1,
      rpcUrl: 'https://mainnet.infura.io/v3/98fd383251cf4e5dbc12d76347d427d8'
    }
  ]
}));

// Verifies a VP JWT
export async function verifyVP(jwt) {
  try {
    const verified = await verifyPresentation(jwt, didResolver, { audience: undefined }); // optionally set audience
    return {
      valid: true,
      vp: verified.verifiablePresentation
    };
  } catch (err) {
    return {
      valid: false,
      error: err.message
    };
  }
}
