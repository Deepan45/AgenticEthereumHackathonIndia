// src/app.js
import express from 'express';
import path from 'path';
import fs from 'fs';
import cors from 'cors';
import bodyParser from 'body-parser';
import swaggerUi from 'swagger-ui-express';
import swaggerSpec from './swagger.js'; 

import didRoutes from './routes/did.js';
import abhaRoutes from './routes/abha.js';
import vcRoutes from './routes/vc.js';
import ipfsRoutes from './routes/ipfs.route.js';
import chatRoutes from './routes/chat.route.js';
import zkpVCRoute from './routes/zkpVC.route.js';

const app = express();

app.use(cors());
app.use(bodyParser.json());

app.use('/swagger', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.use('/api/did', didRoutes);
app.use('/api/abha', abhaRoutes);
app.use('/api/vc', vcRoutes);
app.use('/api/ipfs', ipfsRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/zkpvc', zkpVCRoute);

app.use(express.json({
  strict: true,
  verify: (req, res, buf) => {
    try {
      JSON.parse(buf);
    } catch (e) {
      res.status(400).json({ error: 'Invalid JSON format' });
      throw Error('Invalid JSON');
    }
  }
}));

export default app;
