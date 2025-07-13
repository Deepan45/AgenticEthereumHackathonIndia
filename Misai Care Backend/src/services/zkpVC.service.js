import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import jsonld from 'jsonld';
import jsonldSignatures from 'jsonld-signatures';
const { sign, purposes } = jsonldSignatures;

import { BbsBlsSignature2020 } from '@mattrglobal/jsonld-signatures-bbs';
import { Bls12381G2KeyPair } from '@mattrglobal/bls12381-key-pair';
import { v4 as uuidv4 } from 'uuid';

const { AssertionProofPurpose } = purposes;

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const localContext = JSON.parse(
  fs.readFileSync(path.join(__dirname, '../contexts/security-bbs-v1.jsonld'), 'utf8')
);

function patchEnsureContext(suite) {
  suite.ensureSuiteContext = ({ document }) => {
    const ctx = 'https://w3id.org/security/bbs/v1';
    const c = document['@context'];
    if (Array.isArray(c) ? !c.includes(ctx) : c !== ctx) {
      throw new TypeError(`Missing context ${ctx}`);
    }
  };
  return suite;
}

let defaultLoader = jsonld.documentLoader;
const customLoader = async (url) => {
  if (url === 'https://w3id.org/security/bbs/v1') {
    return {
      contextUrl: null,
      documentUrl: url,
      document: localContext,
    };
  }
  return defaultLoader(url);
};

export async function issueZkpVC({ did, abha_id, wallet }) {
  const keyPair = await Bls12381G2KeyPair.generate({
    controller: did,
    id: `${did}#key-${uuidv4()}`
  });

  let suite = patchEnsureContext(new BbsBlsSignature2020({ key: keyPair }));

  const credential = {
    '@context': [
      'https://www.w3.org/2018/credentials/v1',
      'https://w3id.org/security/bbs/v1',
      {
        abha_id: 'https://schema.org/identifier',
        procedure: 'https://schema.org/MedicalProcedure',
        date: 'https://schema.org/Date',
        issued_by: 'https://schema.org/Organization',
        valid_claim: 'https://schema.org/Boolean',
        amount: 'https://schema.org/PriceSpecification',
        policy_id: 'https://schema.org/identifier',
        status: 'https://schema.org/Text',
        transaction_hash: 'https://schema.org/identifier'
      }
    ],
    id: `urn:uuid:${uuidv4()}`,
    type: ['VerifiableCredential', 'HealthClaimCredential'],
    issuer: did,
    issuanceDate: new Date().toISOString(),
    credentialSubject: {
      id: did,
      abha_id,
      procedure: "Laparoscopic Cholecystectomy",
      date: "2025-07-01",
      issued_by: "Apollo Hospital Pune",
      valid_claim: true,
      amount: "₹45,000",
      policy_id: "HDFC-HEALTH-9087",
      status: "Claim Approved",
      transaction_hash: "0x9a3f...c02b"
    }
  };

  const signedVC = await sign(credential, {
    suite,
    purpose: new AssertionProofPurpose(),
    documentLoader: customLoader,
  });

  // Reshape the result as per your requirement
  return {
    abha_id,
    wallet,
    did,
    credential: {
      procedure: credential.credentialSubject.procedure,
      date: credential.credentialSubject.date,
      issued_by: credential.credentialSubject.issued_by,
    },
    zk_proof: {
      valid_claim: credential.credentialSubject.valid_claim,
      amount: credential.credentialSubject.amount,
      policy_id: credential.credentialSubject.policy_id
    },
    status: credential.credentialSubject.status,
    transaction_hash: credential.credentialSubject.transaction_hash,
  };
}
