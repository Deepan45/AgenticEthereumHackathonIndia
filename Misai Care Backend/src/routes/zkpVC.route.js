import express from 'express';
import { issueZkpVC } from '../services/zkpVC.service.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: ZkpVC
 *   description: Zero-Knowledge Proof Verifiable Credentials
 */

/**
 * @swagger
 * /api/zkpvc/issue:
 *   post:
 *     tags: [ZkpVC]
 *     summary: Issue a ZKP-enabled Verifiable Credential
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               did:
 *                 type: string
 *               abha_id:
 *                 type: string
 *               wallet:
 *                 type: string
 *             required:
 *               - did
 *               - abha_id
 *               - wallet
 *     responses:
 *       200:
 *         description: ZKP VC issued successfully
 */

router.post('/issue', async (req, res) => {
  const { did, abha_id, wallet } = req.body;
  if (!did || !abha_id || !wallet) {
    return res.status(400).json({ error: 'Missing did, abha_id, or wallet' });
  }

  try {
    const result = await issueZkpVC({ did, abha_id, wallet });
    res.status(200).json(result);
  } catch (err) {
    console.error('Error issuing ZKP VC:', err);
    res.status(500).json({ error: err.message });
  }
});

export default router;
