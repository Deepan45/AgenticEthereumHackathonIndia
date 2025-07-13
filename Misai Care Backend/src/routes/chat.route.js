import express from 'express';
const router = express.Router();
import { handleChat } from '../controllers/chatController.js';

/**
 * @swagger
 * /api/chat:
 *   post:
 *     summary: Get chatbot response from LLaMA model
 *     tags:
 *       - Chat
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - message
 *             properties:
 *               message:
 *                 type: string
 *                 example: How do I book an event?
 *     responses:
 *       200:
 *         description: Successful response from LLaMA model
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 answer:
 *                   type: string
 *                   example: You can book an event by logging in with your email and OTP...
 *       400:
 *         description: Missing message in request
 *       500:
 *         description: Server error
 */
router.post('/', handleChat);

export default router;