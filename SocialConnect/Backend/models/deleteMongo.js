const mongoose = require("mongoose");

// Connect to MongoDB
mongoose.connect("mongodb://localhost:27017/YOUR_DATABASE_NAME", {
    useNewUrlParser: true,
    useUnifiedTopology: true,
});

async function deleteAllMongoData() {
    try {
        await mongoose.connection.dropDatabase();
        console.log("🔥 MongoDB database deleted successfully!");
        mongoose.connection.close();
    } catch (error) {
        console.error("❌ Error deleting MongoDB database:", error);
    }
}

deleteAllMongoData();
