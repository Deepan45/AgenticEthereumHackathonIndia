// src/controllers/did.controller.js
import { createDIDForUser, getAllDIDs as fetchAllDIDs } from '../services/did.service.js';

export const createDID = async (req, res) => {
  try {
    const { mobile, otp } = req.body;
    const { did, privateKey } = await createDIDForUser(mobile, otp);
    res.status(200).json({ did, privateKey });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

export const getAllDIDs = async (req, res) => {
  try {
    const dids = await fetchAllDIDs();
    res.status(200).json(dids);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch DIDs' });
  }
};
