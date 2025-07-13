import { queryLlama } from '../services/llamaService.js';

// ✅ Static application flow as context (Misai Care)
const applicationFlow = `
Misai Care - Real-Time Health Insurance & Claim Flow:

1. User installs Misai Care app (Flutter).
2. Selects language (e.g., Tamil) and completes onboarding with GPT voice assistant.
3. Links ABHA health ID via ABDM gateway.
4. A Decentralized ID (DID) and Verifiable Credential (VC) are issued and stored securely in the user’s wallet using IPFS.

Insurance Purchase:
5. AI recommends personalized policies based on age, job, and voice input.
6. User selects a policy and pays via UPI.
7. A Policy VC is issued and cryptographically linked to their DID.

Hospital Visit & Pre-Authorization:
8. User visits a hospital, shows DID/ABHA QR.
9. Hospital staff logs in to the Angular web portal and submits pre-auth for treatment.
10. GPT-based engine checks policy rules and either auto-approves or escalates to DAO voting.
11. A Pre-Authorization VC is issued.

Treatment & Claim:
12. Hospital uploads treatment notes.
13. GPT + Medical NER extract structured FHIR record.
14. A Treatment VC is issued with ICD codes and cost.
15. User submits claim using ZKP (Circom + SnarkJS) proving eligibility without revealing sensitive data.
16. Smart contract verifies ZKP and VCs.
17. Funds are transferred to hospital or user (reimbursement).

PHR Update:
18. GPT generates layman summary.
19. After consent, it syncs to ABHA PHR (FHIR compliant).

Privacy and Ownership:
- All credentials are owned by the user.
- Sensitive data is never revealed due to Zero-Knowledge Proofs.
- GPT provides localized, understandable decision-making.
`;

export async function getAnswer(question) {
  console.log("🧠 Building prompt...");

  const prompt = `
You are a smart, friendly assistant for Misai Care — a decentralized, AI-powered health insurance system.

Use the following application flow to respond clearly and helpfully in a conversational way.

${applicationFlow}

User: ${question}
Assistant:
`;

  const answer = await queryLlama(prompt);
  console.log("🧠 Answer from llamaService:", answer);

  return answer.trim();
}

// module.exports = { getAnswer };
