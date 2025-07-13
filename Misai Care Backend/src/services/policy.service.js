// import { storeJSON } from './ipfs.service.js';
// import { createPolicyVC } from './vc.service.js';

// // Simulated policies
// const availablePolicies = [
//   {
//     id: "POLICY001",
//     name: "Basic Care Plan",
//     premium: "₹500/month",
//     coverage: ["General Consultation", "Diagnostics"],
//   },
//   {
//     id: "POLICY002",
//     name: "Premium Care Plan",
//     premium: "₹1200/month",
//     coverage: ["Surgery", "Hospitalization", "Dental"],
//   },
// ];

// export async function listPolicies() {
//   return availablePolicies;
// }

// export async function purchasePolicy(userDid, policyId) {
//   const policy = availablePolicies.find(p => p.id === policyId);
//   if (!policy) throw new Error("Policy not found");

//   const vc = await createPolicyVC(userDid, policy, "did:issuer:misaicare");

//   const ipfsHash = await storeJSON(vc);

//   return {
//     vc,
//     ipfsHash,
//   };
// }

// // module.exports = { listPolicies, purchasePolicy };
