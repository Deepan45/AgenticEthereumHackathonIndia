import QRCode from 'qrcode';

export async function generateVCQrCode(vcJwt) {
  try {
    const qrDataUrl = await QRCode.toDataURL(vcJwt);
    return qrDataUrl; // base64 image URI
  } catch (err) {
    console.error('QR code generation failed:', err);
    throw err;
  }
}

// module.exports = { generateVCQrCode };
