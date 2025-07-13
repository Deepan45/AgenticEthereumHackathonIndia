import { issueIdentityVC } from '../services/vc.service.js';
import { storeVCOnIPFS } from '../services/ipfs.service.js';

export const issueIdentityVCHandler = async (req, res) => {
   try {
    const { userDid, abhaId, mobile } = req.body;

    if (!userDid || !abhaId || !mobile) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const vcJwt = await issueIdentityVC(userDid, abhaId, mobile);

    const ipfsCid = await storeVCOnIPFS(vcJwt);

    res.status(200).json({ vcJwt, ipfsCid });
  } catch (error) {
    console.error('Error issuing Identity VC:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};
