const { ethers } = require('ethers');
const User = require('../models/user.model');

async function createDIDForUser(mobile, otp) {
  if (!mobile || !otp) throw new Error('Mobile and OTP required');

  const wallet = ethers.Wallet.createRandom();
  const did = `did:ethr:${wallet.address}`;
  const privateKey = wallet.privateKey;

  const existing = await User.findOne({ where: { mobile } });
  if (existing) {
    await existing.update({ did, privateKey });
    return { did, privateKey };
  }

  await User.create({ mobile, otp, did, privateKey });
  return { did, privateKey };
}

module.exports = { createDIDForUser };
