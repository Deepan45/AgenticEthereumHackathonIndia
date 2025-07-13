import express from 'express';
const router = express.Router();
import { createDID, getAllDIDs } from '../controllers/did.controller.js';
/**
 * @swagger
 * tags:
 *   name: DID
 *   description: DID (Decentralized Identifier) management
 */

/**
 * @swagger
 * /api/did/create:
 *   post:
 *     tags: [DID]
 *     summary: Create a new Ethereum-based DID
 *     description: Generates a new DID and private key for a user
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - mobile
 *               - otp
 *             properties:
 *               mobile:
 *                 type: string
 *                 example: "9876543210"
 *               otp:
 *                 type: string
 *                 example: "123456"
 *     responses:
 *       200:
 *         description: DID created
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 did:
 *                   type: string
 *                 privateKey:
 *                   type: string
 */
router.post('/create', createDID);

/**
 * @swagger
 * /api/did/all:
 *   get:
 *     tags: [DID]
 *     summary: Get all generated DIDs
 *     responses:
 *       200:
 *         description: List of DIDs
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   mobile:
 *                     type: string
 *                   did:
 *                     type: string
 *                   privateKey:
 *                     type: string
 */
router.get('/all', getAllDIDs);

export default router;