# SocialConnect

**SocialConnect** is a next-gen iOS app designed with **MVVM**, Clean Architecture, and AI-powered recommendations. It features OAuth2 authentication, Keychain-secured token storage, and end-to-end encryption for privacy. With real-time push notifications (**APNs** & Firebase Cloud Messaging**), users receive personalized updates. The app leverages Core ML & Firebase MLKit for dynamic content recommendations, while async/await and Combine optimize performance. SocialConnect is built for scalability, security, and intelligent engagement, making it a great mobile experience.

---

## 🛠 Features
## SocialConnect - Key Strengths

Modern iOS Architecture & Best Practices

## Clean Architecture (MVVM + Coordinators):
Structured into Presentation, Domain, and Data layers, ensuring maintainability and scalability.
Modularization & Code Separation:
Organized ViewModels, Use Cases, and Repository pattern, adhering to SOLID principles.
Swift Concurrency:
Utilizes async/await and Task for smooth, performant asynchronous handling.
SwiftUI + UIKit Hybrid:
A SwiftUI-first approach, with UIHostingController integration where necessary.
Security & Privacy-First Approach

## Keychain Integration:
Securely stores authentication tokens and sensitive user data.
OAuth2 Authentication:
Implements Firebase Auth & Sign In with Apple for secure login flows.
End-to-End Encryption (E2EE):
Secure messaging and data exchange for private user interactions.
Secure Storage:
Uses Core Data & UserDefaults with encryption for storing user preferences safely.
Networking & Data Layer

## Combine & URLSession for Networking:
Efficient, reactive API handling using AnyPublisher and PassthroughSubject.
RESTful API Integration:
Adopts Decodable models for smooth JSON parsing and integrates with Cloud Firestore.
Feature Flags & A/B Testing:
Utilizes remote feature toggles to dynamically roll out experimental features.
User Experience & Performance

## Optimized Collection Views (DiffableDataSource):
Ensures a smooth scrolling experience for content-heavy screens.
Push Notifications (Firebase Cloud Messaging):
Custom notifications based on user engagement & AI-powered recommendations.
Advanced UI Animations (SwiftUI & Core Animation):
Enhances user interactions with smooth, elegant animations.
AI-Powered Smart Recommendations

## Core ML & Firebase MLKit Integration:
Implements Collaborative Filtering & Content-Based Recommendations.
Dynamic AI-Powered Feeds:
Smartly curates content for "Trending Now" & "Because You Watched…" sections.
Robust Testing & CI/CD Pipeline

## XCTest & UI Testing:
Strong test coverage with XCTest for SignUp, Login, Profile, and HomeViewModel.
Automated CI/CD with GitHub Actions & Fastlane:
Streamlined deployment process for TestFlight & App Store releases.
SwiftLint & Danger Integration:
Enforces clean, maintainable code and best practices.
📡 Cloud & Backend Infrastructure

## Cloud Firestore & Firebase Storage:
Scales seamlessly for real-time updates and multimedia content.
Node.js Backend Deployment on Firebase Functions:
Secure API handling for messaging, authentication, and real-time updates.
GraphQL Integration (for future scalability):
Future-proofing backend queries with a flexible GraphQL API structure.


---


## 📸 Screenshots


<div style="display: flex; justify-content: space-between; flex-wrap: wrap;">
  <img src="https://github.com/AkinCodes/SocialConnect/blob/main/Screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-03-17%20at%2014.25.58.png?raw=true" width="300" style="margin-right: 10px;">
  <img src="https://github.com/AkinCodes/SocialConnect/blob/main/Screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-03-17%20at%2014.26.09.png?raw=true" width="300" style="margin-right: 10px;">
  <img src="https://github.com/AkinCodes/SocialConnect/blob/main/Screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-03-20%20at%2000.57.25.png?raw=true" width="300">
</div>



<div style="display: flex; justify-content: space-between; flex-wrap: wrap;">
  <img src="https://github.com/AkinCodes/SocialConnect/blob/main/Screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-03-17%20at%2014.22.06.png?raw=true" width="300" style="margin-right: 10px;">
  <img src="https://github.com/AkinCodes/SocialConnect/blob/main/Screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-03-17%20at%2014.22.09.png?raw=true" width="300">
 <img src="https://github.com/AkinCodes/SocialConnect/blob/main/Screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-03-17%20at%2014.22.00.png?raw=true" width="300" style="margin-right: 10px;">
</div>


---


## 🔧 Installation & Setup

### 1️⃣ **Clone the Repository**
```sh
git clone https://github.com/AkinCodes/SocialConnect.git 
cd SocialConnect2
```

### 2️⃣ **Install Dependencies**
Ensure you have **CocoaPods** installed:
```sh
pod install
```
Then, open the `.xcworkspace` file:
```sh
open SocialConnect.xcworkspace
```

---

## 🔥 Firebase Setup (Required)

### 📝 3️⃣ **Add `GoogleService-Info.plist`**
1. **Go to** [Firebase Console](https://console.firebase.google.com/).
2. **Select your project** (`SocialConnect`).
3. **Navigate to:**  
   `Project Settings` → `General` → `Your Apps`
4. **Click "Download GoogleService-Info.plist"**.
5. **Move the file to**:
   ```sh
   SocialConnect/GoogleService-Info.plist
   ```
6. **Ensure it contains real values instead of placeholders.**

✅ **Example (`GoogleService-Info.plist` Placeholder)**
```xml
<key>API_KEY</key>
<string>INSERT_YOUR_API_KEY</string>

<key>CLIENT_ID</key>
<string>INSERT_YOUR_CLIENT_ID</string>

<key>GCM_SENDER_ID</key>
<string>INSERT_YOUR_GCM_SENDER_ID</string>

<key>GOOGLE_APP_ID</key>
<string>INSERT_YOUR_GOOGLE_APP_ID</string>
```

---

### 📝 4️⃣ **Add `credentials.plist` for OAuth**
1. **Go to** [Google Cloud Console](https://console.cloud.google.com/apis/credentials).
2. **Create an OAuth 2.0 Client ID** for an iOS app.
3. **Download the `.plist` file** or manually create `credentials.plist`:
   ```sh
   SocialConnect/credentials.plist
   ```
✅ **Example (`credentials.plist` Placeholder)**
```xml
<key>CLIENT_ID</key>
<string>INSERT_YOUR_CLIENT_ID</string>

<key>REVERSED_CLIENT_ID</key>
<string>INSERT_YOUR_REVERSED_CLIENT_ID</string>

<key>BUNDLE_ID</key>
<string>INSERT_YOUR_BUNDLE_ID</string>
```

---

How to Obtain Your Own Firebase Service Account JSON
Go to your Firebase Console → Project Settings → Service Accounts.
Click Generate new private key and download the JSON file.
Move the file to a secure location in your project directory (e.g., outside the repo).
How to Use the JSON Securely
Local Development: Store the path in an environment variable:

export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/socialconnect-credentials.json"
Production Deployment: Use secrets management tools like Google Secret Manager or GitHub Actions Secrets instead of hardcoding it.

---

## 📲 Testing Push Notifications (For Reviewers & Recruiters)

This project includes **real-time push notifications** using Firebase Cloud Messaging (FCM) with support for **deep linking** — so you can send a notification and navigate directly to a specific screen within the app.

To test this feature manually, follow the instructions below.

---

### ✅ Send a Test Notification with `curl`

You can use the Firebase HTTP v1 API to send a notification using a simple `curl` command:

```bash
curl -X POST "https://fcm.googleapis.com/v1/projects/<YOUR_PROJECT_ID>/messages:send" \
  -H "Authorization: Bearer <YOUR_ACCESS_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "<YOUR_DEVICE_FCM_TOKEN>",
      "notification": {
        "title": "🚀 Push Test from FCM V1",
        "body": "This is a test notification sent via Firebase API V1!"
      },
      "data": {
        "category": "PROFILE"
      }
    }
  }'


Replace the placeholders:
Placeholder	Description
<YOUR_PROJECT_ID>	Your Firebase project ID (e.g., socialconnect-d72ef)
<YOUR_ACCESS_TOKEN>	A valid OAuth 2.0 token generated using a Firebase Service Account
<YOUR_DEVICE_FCM_TOKEN>	The device token shown in Xcode console when the app runs
⚠️ Note: This project does not expose any real tokens for security reasons. You’ll need to set these up in your own Firebase Console.


Deep Link Categories
The app supports smart navigation via the category key in the data payload. Try changing it to:

"category": "PROFILE" → Opens the profile screen

"category": "SETTINGS" → Opens the settings screen

"category": "POST_DETAILS" → Opens a sample post view (if implemented)

This is handled by the DeepLinkHandler in the app via FCM data messages.


---

### 🛠 Running the Backend Server (Important Instruction for README)
To ensure the app retrieves data correctly, users must start the backend server before running the project.

How to Start the Backend Server
Open Terminal and navigate to the backend folder:

```cd path/to/backend ```
(Replace path/to/backend with the actual path to your backend directory.)

Run the server using Node.js:


```node server.js```

The backend should now be running, and the app will be able to fetch data successfully.

**⚠ Important: Ensure you have Node.js installed before running this command. If you don’t have it, install it from nodejs.org.**

**This instruction is critical for users to receive data on their device or simulator.**

---

### **Ensure `.gitignore` is Configured**
Run:
```sh
git check-ignore -v SocialConnect/GoogleService-Info.plist credentials.plist
```
If `GoogleService-Info.plist` or `credentials.plist` is **not ignored**, add them to `.gitignore`:
```sh
# Ignore sensitive files
SocialConnect/GoogleService-Info.plist
SocialConnect/credentials.plist
```

Then commit:
```sh
git add .gitignore
git commit -m "Updated .gitignore to ignore sensitive files"
git push origin main
```

---

## 🚀 Run the App
Start the project in **Xcode**:
```sh
Cmd + R
```
**If everything is set up correctly, the app should launch without API errors.**  

---

## Contribution Guidelines
We welcome contributions! Follow these steps:

1. **Fork the repo**  
2. **Create a feature branch**
   ```sh
   git checkout -b feature-new
   ```
3. **Commit changes**
   ```sh
   git commit -m "Added new feature"
   ```
4. **Push & submit a pull request**
   ```sh
   git push origin feature-new
   ```

---

**Akin Olusanya**  
🎓 iOS Engineer | ML Enthusiast | Full-Stack Creator  
📧 workwithakin@gmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/akindeveloper)  
📁 [GitHub](https://github.com/AkinCodes)
