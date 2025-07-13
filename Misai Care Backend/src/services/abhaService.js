import axios from 'axios';
import { v4 as uuidv4 } from 'uuid';
import forge from 'node-forge';
import dotenv from 'dotenv';
dotenv.config();

const BASE_URL = 'https://abhasbx.abdm.gov.in/abha/api/v3';

let accessToken = '';
let tokenExpiry = null;

const PUBLIC_KEY_PEM = `-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAstWB95C5pHLXiYW59qyO
4Xb+59KYVm9Hywbo77qETZVAyc6VIsxU+UWhd/k/YtjZibCznB+HaXWX9TVTFs9N
wgv7LRGq5uLczpZQDrU7dnGkl/urRA8p0Jv/f8T0MZdFWQgks91uFffeBmJOb58u
68ZRxSYGMPe4hb9XXKDVsgoSJaRNYviH7RgAI2QhTCwLEiMqIaUX3p1SAc178ZlN
8qHXSSGXvhDR1GKM+y2DIyJqlzfik7lD14mDY/I4lcbftib8cv7llkybtjX1Aayf
Zp4XpmIXKWv8nRM488/jOAF81Bi13paKgpjQUUuwq9tb5Qd/DChytYgBTBTJFe7i
rDFCmTIcqPr8+IMB7tXA3YXPp3z605Z6cGoYxezUm2Nz2o6oUmarDUntDhq/PnkN
ergmSeSvS8gD9DHBuJkJWZweG3xOPXiKQAUBr92mdFhJGm6fitO5jsBxgpmulxpG
0oKDy9lAOLWSqK92JMcbMNHn4wRikdI9HSiXrrI7fLhJYTbyU3I4v5ESdEsayHXu
iwO/1C8y56egzKSw44GAtEpbAkTNEEfK5H5R0QnVBIXOvfeF4tzGvmkfOO6nNXU3
o/WAdOyV3xSQ9dqLY5MEL4sJCGY1iJBIAQ452s8v0ynJG5Yq+8hNhsCVnklCzAls
IzQpnSVDUVEzv17grVAw078CAwEAAQ==
-----END PUBLIC KEY-----`;

function encryptValue(value) {
  const publicKey = forge.pki.publicKeyFromPem(PUBLIC_KEY_PEM);
  const encrypted = publicKey.encrypt(value, 'RSA-OAEP');
  return forge.util.encode64(encrypted);
}

export async function getAbhaToken() {
  if (accessToken && tokenExpiry && new Date() < tokenExpiry) {
    return accessToken;
  }

  const res = await axios.post(
    'https://dev.abdm.gov.in/gateway/v0.5/sessions',
    {
      clientId: process.env.ABHA_CLIENT_ID,
      clientSecret: process.env.ABHA_CLIENT_SECRET,
      grantType: 'client_credentials',
    },
    {
      headers: {
        'Content-Type': 'application/json',
        'request-id': uuidv4(),
        'timestamp': new Date().toISOString(),
      },
    }
  );

  accessToken = res.data.accessToken;
  const expiresIn = res.data.expiresIn || 1800;
  tokenExpiry = new Date(Date.now() + (expiresIn - 300) * 1000);
  return accessToken;
}

async function getHeaders(txnId = '') {
  const token = await getAbhaToken();
  return {
    Authorization: `Bearer ${token}`,
    'Content-Type': 'application/json',
    'request-id': uuidv4(),
    'timestamp': new Date().toISOString(),
    ...(txnId && { 'X-Transaction-Id': txnId }),
  };
}

// Aadhaar OTP Request (Enrollment Flow)
export async function sendOtpAadhaar(aadhaar) {
  const headers = await getHeaders();
  const payload = {
    txnId: '',
    scope: ['abha-enrol'],
    loginHint: 'aadhaar',
    loginId: encryptValue(aadhaar),
    otpSystem: 'aadhaar',
  };

  try {
    const res = await axios.post(`${BASE_URL}/enrollment/request/otp`, payload, { headers });
    return res.data;
  } catch (error) {
    console.error('🔴 OTP Request Error:', {
      message: error.message,
      status: error.response?.status,
      data: error.response?.data,
    });
    throw new Error(error.response?.data?.message || 'Failed to request Aadhaar OTP');
  }
}


export async function verifyOtp({ txnId, otp, mobile }) {
  const headers = await getHeaders();

  const payload = {
    authData: {
      authMethods: ['otp'],
      otp: {
        timeStamp: new Date().toISOString(),
        txnId,
        otpValue: encryptValue(otp),
        mobile
      }
    },
    consent: {
      code: 'abha-enrollment',
      version: '1.4'
    }
  };
  try {
    const res = await axios.post(`${BASE_URL}/enrollment/enrol/byAadhaar`, payload, { headers });
    return res.data;
  } catch (error) {
    console.error('OTP Encrypted Verify Error:', {
      message: error.message,
      status: error.response?.status,
      data: error.response?.data,
    });
    throw new Error(error.response?.data?.message || 'Encrypted OTP verification failed');
  }
}

export async function getAbhaSuggestions(txnId) {
  if (!txnId) throw new Error('Transaction ID (txnId) is required');

  const headers = await getHeaders(txnId);

  headers['Transaction_Id'] = txnId;             
  headers['REQUEST-ID'] = uuidv4();               
  headers['TIMESTAMP'] = new Date().toISOString();

  try {
    const res = await axios.get(`${BASE_URL}/enrollment/enrol/suggestion`, {
      headers,
    });
    return res.data;
  } catch (error) {
    console.error('Suggestion Fetch Error:', {
      message: error.message,
      status: error.response?.status,
      data: error.response?.data,
    });
    throw new Error(error.response?.data?.message || 'Failed to fetch ABHA suggestions');
  }
}

export async function setAbhaAddress(txnId, abhaAddress, preferred = 1) {
  if (!txnId || !abhaAddress) {
    throw new Error('txnId and abhaAddress are required');
  }

  const headers = await getHeaders(txnId);
  const payload = {
    txnId,
    abhaAddress,
    preferred,
  };

  try {
    const res = await axios.post(`${BASE_URL}/enrollment/enrol/abha-address`, payload, { headers });
    return res.data;
  } catch (error) {
    console.error('Set ABHA Address Error:', {
      message: error.message,
      status: error.response?.status,
      data: error.response?.data,
    });
    throw new Error(error.response?.data?.message || 'Failed to set ABHA address');
  }
}


export async function getAbhaCard() {
  const headers = await getHeaders();
  const res = await axios.get(`${BASE_URL}/profile/account/abha-card`, {
    headers,
    responseType: 'stream',
  });
  return res.data;
}

export async function searchAbhaByMobile(mobile) {
  if (!mobile) throw new Error('Mobile number is required');

  const headers = await getHeaders();
  const payload = {
    scope: ['search-abha'],
    mobile: encryptValue(mobile),
  };

  try {
    const res = await axios.post(`${BASE_URL}/profile/account/abha/search`, payload, { headers });
    return res.data;
  } catch (error) {
    console.error('Search ABHA Error:', {
      message: error.message,
      status: error.response?.status,
      data: error.response?.data,
    });
    throw new Error(error.response?.data?.message || 'Failed to search ABHA account');
  }
}

export async function sendLoginOtpByIndex(index, txnId) {
  if (!index || !txnId) throw new Error('ABHA index and txnId are required');

  const headers = await getHeaders(txnId);
  const encryptedLoginId = encryptValue(index);
  const payload = {
    scope: ['abha-login', 'search-abha', 'mobile-verify'],
    loginHint: 'mobile',
    loginId: encryptedLoginId,
    otpSystem: 'abdm',
    txnId
  };

  console.log('🔐 Requesting Login OTP with:');
  console.log('👉 Index (Plain):', index);
  console.log('🔒 Index (Encrypted):', encryptedLoginId);
  console.log('📦 Payload:', JSON.stringify(payload, null, 2));
  console.log('🧾 Headers:', headers);

  try {
    const res = await axios.post(`${BASE_URL}/profile/login/request/otp`, payload, { headers });
    console.log(' OTP Request Success:', res.data);
    return res.data;
  } catch (error) {
    console.error(' Login OTP Request Error:', {
      message: error.message,
      status: error.response?.status,
      data: error.response?.data,
    });
    throw new Error(error.response?.data?.message || 'Failed to request login OTP');
  }
}


export async function verifyLoginOtp(txnId, otp) {
  if (!txnId || !otp) throw new Error('txnId and OTP are required');

  const headers = await getHeaders(txnId);
  const payload = {
    scope: ['abha-login', 'mobile-verify'],
    authData: {
      authMethods: ['otp'],
      otp: {
        txnId,
        otpValue: encryptValue(otp)
      }
    }
  };

  try {
    const res = await axios.post(`${BASE_URL}/profile/login/verify`, payload, { headers });
    return res.data;
  } catch (error) {
    console.error('Login OTP Verify Error:', {
      message: error.message,
      status: error.response?.status,
      data: error.response?.data,
    });
    throw new Error(error.response?.data?.message || 'Failed to verify login OTP');
  }
}

export async function requestDeleteOtp(abhaNumber, xToken) {
  if (!abhaNumber) throw new Error('ABHA number is required');
  if (!xToken) throw new Error('X-Token is required');

  const headers = await getHeaders();
  headers['X-token'] = `Bearer ${xToken}`;

  const payload = {
    scope: ['abha-profile', 'delete'],
    loginHint: 'abha-number',
    loginId: encryptValue(abhaNumber),
    otpSystem: 'aadhaar',
  };

  try {
    const res = await axios.post(`${BASE_URL}/profile/account/request/otp`, payload, { headers });
    return res.data;
  } catch (error) {
    console.error('Request Delete OTP Error:', {
      message: error.message,
      status: error.response?.status,
      data: error.response?.data,
    });
    throw new Error(error.response?.data?.message || 'Failed to request delete OTP');
  }
}


export async function verifyDeleteOtp(txnId, otp) {
  if (!txnId || !otp) throw new Error('Transaction ID and OTP are required');

  const headers = await getHeaders(txnId);

  const payload = {
    scope: ['abha-profile', 'delete'],
    authData: {
      authMethods: ['otp'],
      otp: {
        txnId,
        otpValue: encryptValue(otp)
      }
    },
    reasons: ['test'] 
  };

  try {
    const res = await axios.post(`${BASE_URL}/profile/account/verify`, payload, { headers });
    return res.data;
  } catch (error) {
    console.error('Delete Verify OTP Error:', {
      message: error.message,
      status: error.response?.status,
      data: error.response?.data,
    });
    throw new Error(error.response?.data?.message || 'Failed to verify OTP and delete ABHA account');
  }
}


// module.exports = {
//   getAbhaToken,
//   sendOtpAadhaar,
//   verifyOtp,
//   getAbhaSuggestions,
//   getAbhaCard,
//   setAbhaAddress,
//   searchAbhaByMobile,
//   sendLoginOtpByIndex,
//   verifyLoginOtp,
//   requestDeleteOtp,     
//   verifyDeleteOtp   
// };
