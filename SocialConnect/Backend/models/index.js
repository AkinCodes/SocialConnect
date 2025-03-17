const mongoose = require("mongoose");
const admin = require("firebase-admin");

// Define the Mongoose schema and model
const messageSchema = new mongoose.Schema({
    senderId: String,
    receiverId: String,
    message: String,
});

const Message = mongoose.model("Message", messageSchema);

// ✅ Initialize Firebase Admin SDK only if not initialized
if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(require("../config/firebaseServiceAccount.json")),
    });
}

// Export both Firestore and Mongoose model
const firestore = admin.firestore();
module.exports = { firestore, Message };
