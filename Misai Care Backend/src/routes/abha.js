import express from 'express';
import {
  getAbhaToken,
  sendOtpAadhaar,
  verifyOtp,
  getAbhaSuggestions,
  getAbhaCard,
  searchAbhaByMobile,
  sendLoginOtpByIndex,
  verifyLoginOtp,
  requestDeleteOtp,
  setAbhaAddress,
  verifyDeleteOtp,
  // linkABHA,
} from '../services/abhaService.js'; // <- also update abhaService.js to export properly

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: ABHA
 *   description: ABHA-related APIs
 */

/**
 * @swagger
 * /api/abha/token:
 *   get:
 *     summary: Get ABHA access token
 *     tags: [ABHA]
 *     responses:
 *       200:
 *         description: Returns access token
 */
router.get('/token', async (req, res) => {
  try {
    const token = await getAbhaToken();
    res.json({ accessToken: token });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * @swagger
 * /api/abha/aadhaar/otp:
 *   post:
 *     summary: Send OTP to Aadhaar number
 *     tags: [ABHA]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               aadhaar:
 *                 type: string
 *     responses:
 *       200:
 *         description: OTP sent
 */
router.post('/aadhaar/otp', async (req, res) => {
  const { aadhaar } = req.body;
  try {
    const response = await sendOtpAadhaar(aadhaar);
    res.json(response);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * @swagger
 * /api/abha/aadhaar/verify:
 *   post:
 *     summary: Verify OTP for Aadhaar Enrollment
 *     tags:
 *       - ABHA
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - txnId
 *               - otp
 *               - mobile
 *             properties:
 *               txnId:
 *                 type: string
 *                 example: "51b96ff7-294e-4800-9d09-1747f0814bdf"
 *               otp:
 *                 type: string
 *                 example: "33332"
 *               mobile:
 *                 type: string
 *                 example: "9443715670"
 *     responses:
 *       200:
 *         description: OTP verified successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 abhaId:
 *                   type: string
 *                   example: "1234-5678-9012"
 *                 message:
 *                   type: string
 *                   example: "ABHA created successfully"
 *       400:
 *         description: Bad Request – Missing or invalid parameters
 *       500:
 *         description: Internal Server Error – Verification failed
 */

router.post('/aadhaar/verify', async (req, res) => {
  const { txnId, otp, mobile } = req.body;

  try {
    const response = await verifyOtp({ txnId, otp, mobile });
    res.json(response);
  } catch (err) {
  }
});


/**
 * @swagger
 * /api/abha/aadhaar/suggestion/{txnId}:
 *   get:
 *     summary: Get ABHA address suggestions
 *     tags: [ABHA]
 *     parameters:
 *       - in: path
 *         name: txnId
 *         required: true
 *         schema:
 *           type: string
 *         description: Transaction ID
 *     responses:
 *       200:
 *         description: Suggestions received
 */
router.get('/aadhaar/suggestion/:txnId', async (req, res) => {
  try {
    const response = await getAbhaSuggestions(req.params.txnId);
    res.json(response);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * @swagger
 * /api/abha/aadhaar/set-address:
 *   post:
 *     summary: Set ABHA address as preferred
 *     tags: [ABHA]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - txnId
 *               - abhaAddress
 *             properties:
 *               txnId:
 *                 type: string
 *               abhaAddress:
 *                 type: string
 *               preferred:
 *                 type: integer
 *                 default: 1
 *     responses:
 *       200:
 *         description: ABHA address set successfully
 */
router.post('/aadhaar/set-address', async (req, res) => {
  const { txnId, abhaAddress, preferred = 1 } = req.body;

  try {
    const result = await setAbhaAddress(txnId, abhaAddress, preferred);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * @swagger
 * /api/abha/aadhaar/card:
 *   get:
 *     summary: Download ABHA card as PDF
 *     tags: [ABHA]
 *     responses:
 *       200:
 *         description: Returns ABHA card in PDF format
 *         content:
 *           application/pdf:
 *             schema:
 *               type: string
 *               format: binary
 */
router.get('/aadhaar/card', async (req, res) => {
  try {
    const stream = await getAbhaCard();
    res.setHeader('Content-Type', 'application/pdf');
    stream.pipe(res);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * @swagger
 * /api/abha/link:
 *   post:
 *     summary: Link ABHA with user or patient
 *     tags: [ABHA]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             example:
 *               abhaAddress: test@abdm
 *               patientId: 123
 *     responses:
 *       200:
 *         description: ABHA linked successfully
 */
router.post('/link', async (req, res) => {
  try {
    const data = await linkABHA(req.body);
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * @swagger
 * /api/abha/search:
 *   post:
 *     summary: Search ABHA using encrypted mobile number
 *     tags: [ABHA]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - mobile
 *             properties:
 *               mobile:
 *                 type: string
 *                 example: "9876543210"
 *     responses:
 *       200:
 *         description: Returns ABHA account details
 *       400:
 *         description: Bad Request – Mobile number is missing
 *       500:
 *         description: Internal Server Error
 */
router.post('/search', async (req, res) => {
  const { mobile } = req.body;

  if (!mobile) {
    return res.status(400).json({ error: 'Mobile number is required' });
  }

  try {
    const result = await searchAbhaByMobile(mobile);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * @swagger
 * /api/abha/login/request-otp:
 *   post:
 *     summary: Request OTP for ABHA login
 *     tags: [ABHA]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - txnId
 *               - loginId
 *             properties:
 *               txnId:
 *                 type: string
 *                 example: "search-txn-id-uuid"
 *               loginId:
 *                 type: string
 *                 example: "index@abdm"
 *     responses:
 *       200:
 *         description: Login OTP sent successfully
 */
router.post('/login/request-otp', async (req, res) => {
  const { txnId, loginId } = req.body;

  console.log(' Request received for login OTP');
  console.log('txnId:', txnId);
  console.log('loginId:', loginId);

  if (!txnId || !loginId) {
    return res.status(400).json({ error: 'txnId and loginId are required' });
  }

  try {
    const response = await sendLoginOtpByIndex(loginId, txnId);
    res.json(response);
  } catch (err) {
    console.error(' sendLoginOtpByIndex failed:', err);
    res.status(500).json({ error: err.message });
  }
});


/**
 * @swagger
 * /api/abha/login/verify:
 *   post:
 *     summary: Verify OTP for ABHA login
 *     tags: [ABHA]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - txnId
 *               - otp
 *             properties:
 *               txnId:
 *                 type: string
 *               otp:
 *                 type: string
 *     responses:
 *       200:
 *         description: Login successful
 */
router.post('/login/verify', async (req, res) => {
  const { txnId, otp } = req.body;
  try {
    const response = await verifyLoginOtp(txnId, otp); 
    res.json(response);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * @swagger
 * /api/abha/delete/request-otp:
 *   post:
 *     summary: Request OTP for ABHA deletion
 *     tags: [ABHA]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [abhaNumber]
 *             properties:
 *               abhaNumber:
 *                 type: string
 *     parameters:
 *       - in: header
 *         name: X-Token
 *         required: true
 *         schema:
 *           type: string
 *         description: ABHA Access Token
 *     responses:
 *       200:
 *         description: OTP sent for deletion
 *       400:
 *         description: Missing ABHA number or X-Token
 */
router.post('/delete/request-otp', async (req, res) => {
  const { abhaNumber } = req.body;
  const xToken = req.headers['x-token'];

  if (!abhaNumber || !xToken) {
    return res.status(400).json({ error: 'abhaNumber and X-Token are required' });
  }

  try {
    const response = await requestDeleteOtp(abhaNumber, xToken);
    res.json(response);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


/**
 * @swagger
 * /api/abha/delete/verify-otp:
 *   post:
 *     summary: Verify OTP and delete ABHA account
 *     tags: [ABHA]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [txnId, otp]
 *             properties:
 *               txnId:
 *                 type: string
 *               otp:
 *                 type: string
 *     responses:
 *       200:
 *         description: ABHA account deleted successfully
 */
router.post('/delete/verify-otp', async (req, res) => {
  const { txnId, otp } = req.body;
  try {
    const response = await verifyDeleteOtp(txnId, otp);
    res.json(response);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;