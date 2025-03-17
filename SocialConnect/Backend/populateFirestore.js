const admin = require("firebase-admin");

// ✅ Initialize Firebase Admin SDK
const serviceAccount = require("./config/firebaseServiceAccount.json");

if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
    });
}

const db = admin.firestore();

// ✅ Function to update existing posts with `createdAt`
const updateExistingPosts = async () => {
    console.log("🔄 Updating existing posts...");
    const snapshot = await db.collection("posts").get();
    const batch = db.batch();

    snapshot.forEach(doc => {
        const data = doc.data();
        if (!data.createdAt) {
            batch.update(doc.ref, { createdAt: admin.firestore.FieldValue.serverTimestamp() });
            console.log(`✅ Updated post: ${doc.id}`);
        }
    });

    await batch.commit();
    console.log("✅ All existing posts updated with `createdAt` timestamp!");
};

// ✅ Function to generate 20 new test posts
const seedNewPosts = async () => {
    console.log("🚀 Seeding new posts...");
    const batch = db.batch();

    for (let i = 1; i <= 20; i++) {
        const newPostRef = db.collection("posts").doc();
        batch.set(newPostRef, {
            id: newPostRef.id,
            title: `Generated Post ${i}`,
            content: `This is an auto-generated test post #${i}.`,
            userId: `user${Math.floor(Math.random() * 10) + 1}`,
            imageUrl: `https://picsum.photos/200/300?random=${i}`,
            likes: Math.floor(Math.random() * 100), // Random likes
            description: "This is a test description.",
            createdAt: admin.firestore.FieldValue.serverTimestamp() // ✅ Timestamp for sorting
        });

        console.log(`✅ Created post: ${newPostRef.id}`);
    }

    await batch.commit();
    console.log("✅ 20 new test posts added!");
};

// ✅ Run both update & seeding functions
const populateFirestore = async () => {
    await updateExistingPosts();
    await seedNewPosts();
    console.log("🎉 Firestore population completed!");
    process.exit(0);
};

populateFirestore().catch(error => {
    console.error("❌ Error populating Firestore:", error);
    process.exit(1);
});
