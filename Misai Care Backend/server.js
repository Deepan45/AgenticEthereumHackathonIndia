import dotenv from 'dotenv';
dotenv.config();

import { initModels } from './src/models/index.js';
import app from './src/app.js';

const PORT = process.env.PORT || 5000;

initModels().then(() => {
  app.listen(PORT, () => console.log(`🚀 Server started on port ${PORT}`));
});
