require("dotenv").config();
process.env.GOOGLE_APPLICATION_CREDENTIALS = process.env.GOOGLE_APPLICATION_CREDENTIALS || "./config/firebaseServiceAccount.json";

const express = require("express");
const admin = require("firebase-admin");
const { GoogleAuth, OAuth2Client } = require("google-auth-library");

const GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID;
const GOOGLE_CLIENT_SECRET = process.env.GOOGLE_CLIENT_SECRET;
const PORT = process.env.PORT || 3000;

if (!GOOGLE_CLIENT_ID || !GOOGLE_CLIENT_SECRET) {
    console.error("❌ Missing Google OAuth environment variables. Check your .env file.");
    process.exit(1);
}

const serviceAccount = require("./config/firebaseServiceAccount.json");
const messageServiceAccount = require("./socialconnect-d72ef-7a9e7205afa2.json");

if (!admin.apps.length) {
    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
}

const db = admin.firestore();
const messaging = admin.messaging();

const app = express();
app.use(express.json());

const client = new OAuth2Client(GOOGLE_CLIENT_ID);


async function getAccessToken() {
    try {
        console.log("🟡 Requesting OAuth token...");
        const auth = new GoogleAuth({ scopes: ["https://www.googleapis.com/auth/firebase.messaging"] });
        const client = await auth.getClient();
        const accessToken = await client.getAccessToken();
        return accessToken.token;
    } catch (error) {
        console.error("❌ Error getting OAuth token:", error);
        return null;
    }
}


async function sendFCMNotification(registrationToken) {
    const accessToken = await getAccessToken();
    if (!accessToken) return { error: "Failed to retrieve OAuth token" };

    const message = {
        message: {
            token: registrationToken,
            notification: { title: "Hello from Firebase!", body: "This is a test notification" }
        }
    };

    const response = await fetch(`https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send`, {
        method: "POST",
        headers: { "Authorization": `Bearer ${accessToken}`, "Content-Type": "application/json" },
        body: JSON.stringify(message)
    });

    return response.json();
}

// ✅ API to send FCM notification
app.get("/api/get-fcm-token", async (req, res) => {
    try {
        const registrationToken = req.query.token;
        if (!registrationToken) return res.status(400).json({ error: "Missing FCM token" });

        const response = await sendFCMNotification(registrationToken);
        res.json({ success: true, message: "Notification sent", response });
    } catch (error) {
        console.error("❌ Error sending notification:", error);
        res.status(500).json({ error: "Failed to send notification" });
    }
});

// ✅ Google Authentication
app.post("/auth/google", async (req, res) => {
    try {
        console.log("🚀 Received Google Auth request");

        const { idToken } = req.body;
        if (!idToken) {
            return res.status(400).json({ error: "Missing ID Token" });
        }

        // ✅ Verify ID Token
        const ticket = await client.verifyIdToken({ idToken, audience: GOOGLE_CLIENT_ID });
        const payload = ticket.getPayload();

        const userId = payload["sub"];
        const email = payload["email"];
        const name = payload["name"];
        const picture = payload["picture"];

        console.log(`👤 Extracted User Data: ${userId}, ${email}, ${name}`);

        // ✅ Store user in Firestore
        const userRef = db.collection("users").doc(userId);
        await userRef.set(
            { email, name, picture, lastLogin: admin.firestore.Timestamp.now() },
            { merge: true }
        );

        res.json({ message: "User authenticated", userId, email, name, picture });
    } catch (error) {
        console.error("❌ Error verifying Google ID Token:", error);
        res.status(401).json({ error: "Invalid ID Token" });
    }
});

// ✅ Fetch paginated posts using cursor-based pagination
app.get("/api/posts", async (req, res) => {
    try {
        let { cursor = null, limit = 10 } = req.query;
        limit = parseInt(limit);

        console.log(`Limit: ${limit}, Cursor: ${cursor}`);

        // ✅ Get total post count
        const totalItemsSnapshot = await db.collection("posts").count().get();
        const totalItems = totalItemsSnapshot.data().count || 0;

        let query = db.collection("posts").orderBy("createdAt", "desc").limit(limit);

        if (cursor) {
            const lastDocSnapshot = await db.collection("posts").doc(cursor).get();
            if (lastDocSnapshot.exists) {
                query = query.startAfter(lastDocSnapshot);
            } else {
                console.log("Invalid cursor provided");
            }
        }

        const snapshot = await query.get();
        if (snapshot.empty) {
            return res.json({ limit, totalItems, hasNextPage: false, nextCursor: null, data: [] });
        }

        const posts = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        const nextCursor = posts.length ? posts[posts.length - 1].id : null;
        const hasNextPage = posts.length === limit;

        res.json({ limit, totalItems, hasNextPage, nextCursor, data: posts });
    } catch (error) {
        console.error("❌ Error fetching paginated posts:", error);
        res.status(500).json({ error: "Failed to fetch paginated posts" });
    }
});

// ✅ API to create a new post
app.post("/api/posts", async (req, res) => {
    try {
        const { title, content, userId } = req.body;

        if (!title || !content || !userId) {
            return res.status(400).json({ error: "Missing required fields: title, content, or userId" });
        }

        const newPostRef = db.collection("posts").doc();
        const newPost = {
            id: newPostRef.id,
            title,
            content,
            userId,
            imageUrl: `https://picsum.photos/200?random=${newPostRef.id}`,
            likes: 0,
            description: "No description available",
            createdAt: admin.firestore.Timestamp.now()
        };

        await newPostRef.set(newPost);

        res.status(201).json({ message: "Post created successfully", id: newPostRef.id });
    } catch (error) {
        console.error("❌ Error creating post:", error);
        res.status(500).json({ error: "Failed to create post" });
    }
});

// ✅ API to delete a post
app.delete("/api/posts/:id", async (req, res) => {
    try {
        const { id } = req.params;
        await db.collection("posts").doc(id).delete();
        res.json({ message: "Post deleted successfully" });
    } catch (error) {
        console.error("❌ Error deleting post:", error);
        res.status(500).json({ error: "Failed to delete post" });
    }
});

// ✅ API to get user data
app.get("/api/users/:userId", async (req, res) => {
    try {
        const { userId } = req.params;
        const userDoc = await db.collection("users").doc(userId).get();

        if (!userDoc.exists) {
            return res.status(404).json({ error: "User not found" });
        }

        res.json(userDoc.data());
    } catch (error) {
        console.error("❌ Error fetching user:", error);
        res.status(500).json({ error: "Failed to fetch user data" });
    }
});


console.log("🔎 GOOGLE_APPLICATION_CREDENTIALS:", process.env.GOOGLE_APPLICATION_CREDENTIALS);


// Start the server
app.listen(PORT, () => console.log(`🚀 Server running on http://127.0.0.1:${PORT}`));
getAccessToken().then(token => console.log("OAuth Token at Server Start:", token)).catch(err => console.error("❌ Error:", err));


