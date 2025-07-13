// import express from 'express';
// import { issueIdentityVC } from '../services/vc.service.js';

// import { verifyVC } from '../services/vcVerification.service.js';
// import { generateVCQrCode } from '../services/qr.service.js';

// const router = express.Router();

// // /**
// //  * @swagger
// //  * tags:
// //  *   name: VC
// //  *   description: Verifiable Credentials management
// //  */

// // /**
// //  * @swagger
// //  * /api/vc/identity:
// //  *   post:
// //  *     tags: [VC]
// //  *     summary: Issue Identity Verifiable Credential
// //  *     requestBody:
// //  *       required: true
// //  *       content:
// //  *         application/json:
// //  *           schema:
// //  *             type: object
// //  *             properties:
// //  *               did:
// //  *                 type: string
// //  *               abhaId:
// //  *                 type: string
// //  *             required:
// //  *               - did
// //  *               - abhaId
// //  *     responses:
// //  *       200:
// //  *         description: VC issued successfully
// //  *         content:
// //  *           application/json:
// //  *             schema:
// //  *               type: object
// //  *               properties:
// //  *                 vc:
// //  *                   type: object
// //  *                 cid:
// //  *                   type: string
// //  */

// // router.post('/identity', async (req, res) => {
// //   try {
// //     const { did, abhaId } = req.body;

// //     if (!did || !abhaId) {
// //       return res.status(400).json({ error: 'Missing did or abhaId in request body' });
// //     }

// //     const result = await issueIdentityVC({ did, abhaId });
// //     res.status(200).json(result); // { vc: { jwt }, cid }
// //   } catch (error) {
// //     console.error('Error issuing VC:', error);
// //     res.status(500).json({ error: error.message || 'Internal Server Error' });
// //   }
// // });
// // src/routes/vc.routes.js
// // const express = require('express');
// // const router = express.Router();
// import { issueIdentityVCHandler } from '../controllers/vc.controller.js';

// /**
//  * @swagger
//  * /api/vc/identity:
//  *   post:
//  *     summary: Issue Identity VC for a user
//  *     tags:
//  *       - Verifiable Credentials
//  *     requestBody:
//  *       required: true
//  *       content:
//  *         application/json:
//  *           schema:
//  *             type: object
//  *             properties:
//  *               userDid:
//  *                 type: string
//  *                 example: did:ethr:0xabc123
//  *               abhaId:
//  *                 type: string
//  *                 example: 1234-5678-9012-3456
//  *               mobile:
//  *                 type: string
//  *                 example: "9876543210"
//  *     responses:
//  *       200:
//  *         description: Verifiable Credential JWT
//  *         content:
//  *           application/json:
//  *             schema:
//  *               type: object
//  *               properties:
//  *                 vcJwt:
//  *                   type: string
//  *       400:
//  *         description: Bad Request
//  *       500:
//  *         description: Server Error
//  */
// router.post('/identity', issueIdentityVCHandler);

// /**
//  * @swagger
//  * tags:
//  *   name: Verifiable Credentials
//  *   description: Operations related to Verifiable Credentials (VC)
//  */

// /**
//  * @swagger
//  * /api/vc/verify:
//  *   post:
//  *     summary: Verify a Verifiable Credential JWT
//  *     tags: [Verifiable Credentials]
//  *     requestBody:
//  *       description: Verifiable Credential JWT to verify
//  *       required: true
//  *       content:
//  *         application/json:
//  *           schema:
//  *             type: object
//  *             required:
//  *               - vcJwt
//  *             properties:
//  *               vcJwt:
//  *                 type: string
//  *                 example: eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9...
//  *     responses:
//  *       200:
//  *         description: VC verification successful
//  *         content:
//  *           application/json:
//  *             schema:
//  *               type: object
//  *               properties:
//  *                 verified:
//  *                   type: boolean
//  *                   example: true
//  *                 payload:
//  *                   type: object
//  *                   description: Decoded VC payload
//  *       400:
//  *         description: Bad request or verification failed
//  *         content:
//  *           application/json:
//  *             schema:
//  *               type: object
//  *               properties:
//  *                 verified:
//  *                   type: boolean
//  *                   example: false
//  *                 error:
//  *                   type: string
//  *                   example: Invalid VC JWT
//  */
// router.post('/verify', async (req, res) => {
//   try {
//     const { vcJwt } = req.body;
//     if (!vcJwt) return res.status(400).json({ error: 'Missing vcJwt' });

//     const result = await verifyVC(vcJwt);
//     res.json({ verified: true, payload: result.payload });
//   } catch (err) {
//     res.status(400).json({ verified: false, error: err.message });
//   }
// });

// /**
//  * @swagger
//  * /api/vc/qrcode:
//  *   post:
//  *     summary: Generate a QR code for a Verifiable Credential JWT
//  *     tags: [Verifiable Credentials]
//  *     requestBody:
//  *       description: Verifiable Credential JWT to encode as QR code
//  *       required: true
//  *       content:
//  *         application/json:
//  *           schema:
//  *             type: object
//  *             required:
//  *               - vcJwt
//  *             properties:
//  *               vcJwt:
//  *                 type: string
//  *                 example: eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9...
//  *     responses:
//  *       200:
//  *         description: QR code generation successful
//  *         content:
//  *           application/json:
//  *             schema:
//  *               type: object
//  *               properties:
//  *                 qrCodeDataUrl:
//  *                   type: string
//  *                   description: Data URL of the generated QR code image
//  *                   example: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...
//  *       500:
//  *         description: QR code generation failed
//  *         content:
//  *           application/json:
//  *             schema:
//  *               type: object
//  *               properties:
//  *                 error:
//  *                   type: string
//  *                   example: QR code generation failed
//  */
// router.post('/qrcode', async (req, res) => {
//   try {
//     const { vcJwt } = req.body;
//     if (!vcJwt) return res.status(400).json({ error: 'Missing vcJwt' });

//     const qrCodeDataUrl = await generateVCQrCode(vcJwt);
//     res.json({ qrCodeDataUrl });
//   } catch (err) {
//     res.status(500).json({ error: 'QR code generation failed' });
//   }
// });

// export default router;

import express from 'express';
import Web3 from 'web3';
import VCRegistryABI from '../../contracts/build/contracts/VCRegistry.json' assert { type: "json" };
import { uploadVC } from '../services/ipfs.service.js';
import { signVC } from '../services/vcSigner.js';
import dotenv from 'dotenv';
dotenv.config();

const router = express.Router();

const web3 = new Web3(process.env.INFURA_URL);
const account = web3.eth.accounts.privateKeyToAccount(process.env.PRIVATE_KEY);
web3.eth.accounts.wallet.add(account);

const contractAddress = process.env.VC_REGISTRY_ADDRESS;
const contract = new web3.eth.Contract(VCRegistryABI.abi, contractAddress);

/**
 * @swagger
 * tags:
 *   name: VC Registry
 *   description: Verifiable Credential issuance and verification via blockchain
 */

/**
 * @swagger
 * /api/vc/issue-vc:
 *   post:
 *     summary: Issue a Verifiable Credential and store on IPFS + Blockchain
 *     tags: [VC Registry]
 *     requestBody:
 *       required: true
 *       description: VC data for issuance
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - type
 *               - credentialSubject
 *             properties:
 *               type:
 *                 type: array
 *                 items:
 *                   type: string
 *                 example: ["IdentityCredential"]
 *               credentialSubject:
 *                 type: object
 *                 required:
 *                   - id
 *                 properties:
 *                   id:
 *                     type: string
 *                     example: did:ethr:0xabc123456789
 *                   abhaId:
 *                     type: string
 *                     example: 1234-5678-9012-3456
 *                   mobile:
 *                     type: string
 *                     example: "9876543210"
 *     responses:
 *       200:
 *         description: Credential issued successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 vcId:
 *                   type: string
 *                 ipfsHash:
 *                   type: string
 *                 txHash:
 *                   type: string
 *                 jwt:
 *                   type: string
 *       500:
 *         description: Server error
 */
router.post('/issue-vc', async (req, res) => {
  try {
    const vcData = req.body;

    const vcPayload = {
      sub: vcData.credentialSubject.id,
      nbf: Math.floor(Date.now() / 1000),
      vc: {
        '@context': ['https://www.w3.org/2018/credentials/v1'],
        type: ['VerifiableCredential', ...vcData.type],
        credentialSubject: vcData.credentialSubject
      }
    };

    const jwt = await signVC(vcPayload);

    const fullVC = {
      ...vcPayload.vc,
      issuer: process.env.ISSUER_DID,
      issuanceDate: new Date().toISOString(),
      proof: {
        type: 'EcdsaSecp256k1Signature2019',
        created: new Date().toISOString(),
        proofPurpose: 'assertionMethod',
        verificationMethod: `${process.env.ISSUER_DID}#keys-1`,
        jws: jwt
      }
    };
    fullVC.credentialSubject.id = vcPayload.sub;

    const ipfsHash = await uploadVC(fullVC);

    const vcId = web3.utils.soliditySha3(
      fullVC.credentialSubject.id,
      fullVC.issuanceDate,
      ipfsHash
    );

    try {
      await contract.methods.issueVC(vcId, ipfsHash).call({ from: account.address });
      console.log("Call succeeded");
    } catch (err) {
      console.error("Call failed:", err);
      return res.status(400).json({ error: 'Transaction call failed: ' + err.message });
    }

    // Define tx here!
    const tx = contract.methods.issueVC(vcId, ipfsHash);
    const gas = await tx.estimateGas({ from: account.address });
    const receipt = await tx.send({ from: account.address, gas });

    return res.json({ success: true, vcId, ipfsHash, txHash: receipt.transactionHash, jwt });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: error.message });
  }
});

/**
 * @swagger
 * /api/vc/verify-vc:
 *   post:
 *     summary: Verify if a VC exists and is not revoked
 *     tags: [VC Registry]
 *     requestBody:
 *       required: true
 *       description: VC ID to verify
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - vcId
 *             properties:
 *               vcId:
 *                 type: string
 *                 example: 0xsha3hashofVC
 *     responses:
 *       200:
 *         description: Verification result
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 valid:
 *                   type: boolean
 *                   example: true
 *                 issuer:
 *                   type: string
 *                   example: did:ethr:0xissuer
 *                 ipfsHash:
 *                   type: string
 *                   example: QmZ123...
 *       500:
 *         description: Error during verification
 */
router.post('/verify-vc', async (req, res) => {
  try {
    const { vcId } = req.body;
    const record = await contract.methods.vcs(vcId).call();

    if (!record.issuedAt || record.revoked) {
      return res.json({ valid: false, reason: 'VC not issued or revoked' });
    }

    return res.json({ valid: true, issuer: record.issuer, ipfsHash: record.ipfsHash });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
});

export default router;
