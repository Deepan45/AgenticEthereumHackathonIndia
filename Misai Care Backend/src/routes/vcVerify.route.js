import express from 'express';
const { verifyVC } = require('../services/vcVerification.service');
const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: VC
 *   description: Verifiable Credentials management
 */

/**
 * @swagger
 * /api/vc/verify:
 *   post:
 *     tags: [VC]
 *     summary: Verify a Verifiable Credential
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               vcJwt:
 *                 type: string
 *     responses:
 *       200:
 *         description: Verification result
 */

router.post('/verify', async (req, res) => {
  const { vcJwt } = req.body;
  if (!vcJwt) {
    return res.status(400).json({ error: 'Missing vcJwt' });
  }

  const result = await verifyVC(vcJwt);
  return res.status(result.valid ? 200 : 400).json(result);
});

export default router;