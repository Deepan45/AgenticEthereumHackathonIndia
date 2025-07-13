import express from 'express';
import { issueVP } from '../services/vp.service';
import { verifyVP } from '../services/vpVerification.service';
const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: VP
 *   description: Verifiable Credentials management
 */

/**
 * @swagger
 * /api/vp/create:
 *   post:
 *     tags: [VP]
 *     summary: Create a Verifiable Presentation (VP) from a VC
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
 *         description: VP created
 */

router.post('/create', async (req, res) => {
  try {
    const { vcJwt } = req.body;

    if (!vcJwt) {
      return res.status(400).json({ error: 'Missing vcJwt' });
    }

    const result = await issueVP({ vcJwt });
    res.status(200).json(result); // { vp: { jwt } }
  } catch (err) {
    console.error('Error creating VP:', err);
    res.status(500).json({ error: err.message });
  }
});

/**
 * @swagger
 * /api/vp/verify:
 *   post:
 *     tags: [VP]
 *     summary: Verify a Verifiable Presentation (VP)
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               jwt:
 *                 type: string
 *     responses:
 *       200:
 *         description: Verification result
 */

router.post('/verify', async (req, res) => {
  try {
    const { jwt } = req.body;
    if (!jwt) {
      return res.status(400).json({ error: 'Missing jwt' });
    }

    const result = await verifyVP(jwt);
    res.status(result.valid ? 200 : 400).json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;

