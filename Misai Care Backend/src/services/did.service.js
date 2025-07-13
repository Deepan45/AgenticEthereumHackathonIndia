import { ethers } from 'ethers';
import { Op } from 'sequelize';
import User from '../models/user.model.js';

export async function createDIDForUser(mobile, otp) {
  const existing = await User.findOne({ where: { mobile } });

  if (existing && existing.did) {
    throw new Error('User already has a DID');
  }

  const wallet = ethers.Wallet.createRandom();
  const did = `did:ethr:${wallet.address}`;
  const privateKey = wallet.privateKey;

  await User.upsert({ mobile, otp, did, privateKey });

  return { did, privateKey };
}

export async function getAllDIDs() {
  const users = await User.findAll({
    where: {
      did: {
        [Op.ne]: null,
      },
    },
    attributes: ['mobile', 'did', 'privateKey'],
  });

  return users;
}

