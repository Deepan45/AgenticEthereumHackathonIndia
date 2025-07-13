import express from 'express';
import multer from 'multer';
import axios from 'axios';
import { storeJSON, storeBufferFile } from '../services/ipfs.service.js';

const router = express.Router();
const upload = multer({ storage: multer.memoryStorage() }); // in-memory only

/**
 * @swagger
 * tags:
 *   name: IPFS
 *   description: Interact with IPFS
 */

/**
 * @swagger
 * /api/ipfs/upload-file:
 *   post:
 *     tags: [IPFS]
 *     summary: Upload file to IPFS
 *     consumes:
 *       - multipart/form-data
 *     requestBody:
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: File uploaded successfully
 */
router.post('/upload-file', upload.single('file'), async (req, res) => {
  try {
    const file = req.file;
    if (!file) return res.status(400).json({ error: 'No file uploaded' });

    const cid = await storeBufferFile(file.buffer, file.originalname);
    res.json({ cid, gatewayUrl: `http://127.0.0.1:8081/ipfs/${cid}` });
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ error: 'File upload failed' });
  }
});

/**
 * @swagger
 * /api/ipfs/upload-json:
 *   post:
 *     tags: [IPFS]
 *     summary: Upload JSON to IPFS
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             example:
 *               name: "Karthik"
 *               abhaId: "1234-5678"
 *     responses:
 *       200:
 *         description: JSON uploaded successfully
 */
router.post('/upload-json', express.json(), async (req, res) => {
  try {
    const cid = await storeJSON(req.body);
    res.json({ cid, gatewayUrl: `http://127.0.0.1:8081/ipfs/${cid}` });
  } catch (error) {
    console.error('JSON upload error:', error);
    res.status(500).json({ error: 'JSON upload failed' });
  }
});

/**
 * @swagger
 * /api/ipfs/view/{cid}:
 *   get:
 *     tags: [IPFS]
 *     summary: View file from IPFS by CID
 *     parameters:
 *       - in: path
 *         name: cid
 *         schema:
 *           type: string
 *         required: true
 *         description: The CID of the file
 *     responses:
 *       200:
 *         description: File streamed successfully
 *         content:
 *           application/octet-stream:
 *             schema:
 *               type: string
 *               format: binary
 */
router.get('/view/:cid', async (req, res) => {
  const { cid } = req.params;
  const ipfsGatewayUrl = `http://127.0.0.1:8081/ipfs/${cid}`;

  try {
    const response = await axios.get(ipfsGatewayUrl, { responseType: 'stream' });

    // Set correct content type
    res.setHeader('Content-Type', response.headers['content-type']);
    response.data.pipe(res);
  } catch (error) {
    console.error('View error:', error.message);
    res.status(500).json({ error: 'Failed to fetch from IPFS' });
  }
});

export default router;
