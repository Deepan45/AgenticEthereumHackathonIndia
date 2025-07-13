import { create } from 'ipfs-http-client';

// Connect to IPFS node
const ipfs = create({ url: 'http://127.0.0.1:5001/api/v0' }); // or use Infura

// Upload JSON directly to IPFS
export async function storeJSON(jsonObj) {
  const buffer = Buffer.from(JSON.stringify(jsonObj));
  const result = await ipfs.add(buffer);
  return result.cid.toString();
}

// Upload file (in-memory buffer) to IPFS
export async function storeBufferFile(buffer, fileName) {
  const result = await ipfs.add({ path: fileName, content: buffer });
  return result.cid.toString();
}

export async function storeVCOnIPFS(vcJwt) {
  const { cid } = await ipfs.add(vcJwt);
  console.log('Stored VC on IPFS with CID:', cid.toString());
  return cid.toString();
}

export async function uploadVC(vcJson) {
  const { cid } = await ipfs.add(JSON.stringify(vcJson));
  return cid.toString();
}
