require('dotenv').config();
const { OAuth2Client } = require('google-auth-library');

// Use environment variable if available, otherwise fallback to hardcoded Client ID
const CLIENT_ID = process.env.GOOGLE_CLIENT_ID || "294216953490-6o02j2ps16u0apdbmb4o65ilv6so6h2b.apps.googleusercontent.com";

const client = new OAuth2Client(CLIENT_ID);

async function verify(token) {
  try {
    const ticket = await client.verifyIdToken({
      idToken: token,
      audience: CLIENT_ID, // Must match Client ID
    });

    const payload = ticket.getPayload();
    
    console.log("✅ User Verified:", payload);
    console.log("📌 Audience (aud):", payload.aud); // Log audience to check mismatch issues

    return payload;
  } catch (error) {
    console.error("❌ Error verifying token:", error.message);
    throw new Error("Invalid token");
  }
}

module.exports = { verify };
