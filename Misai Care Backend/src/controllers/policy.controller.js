import { listPolicies, purchasePolicy } from '../services/policy.service.js';

export async function getAllPolicies(req, res) {
  const policies = await listPolicies();
  res.status(200).json(policies);
}

export async function purchase(req, res) {
  const { did, policyId } = req.body;
  try {
    const result = await purchasePolicy(did, policyId);
    res.status(200).json(result);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
}
