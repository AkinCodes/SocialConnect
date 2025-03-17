const admin = require("firebase-admin");
const path = require("path");
const { User } = require("./models"); // Import User model

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(
            require(path.resolve(__dirname, "./config/firebaseServiceAccount.json"))
        ),
    });
}

// ✅ Send Push Notification to a User
async function sendNotification(userId, title, body) {
    try {
        const user = await User.findById(userId);
        if (!user || !user.fcmToken) {
            console.warn(`⚠️ No valid FCM token for user ${userId}`);
            return;
        }

        const message = {
            token: user.fcmToken,
            notification: { title, body },
            data: { userId: userId },
        };

        await admin.messaging().send(message);
        console.log("✅ Notification sent successfully");
    } catch (error) {
        console.error("❌ Failed to send notification:", error);
    }
}

module.exports = { sendNotification };
