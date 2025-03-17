# 🌟 SocialConnect

🚀 **SocialConnect** is a modern social media app built with **Swift** and **Firebase**.  
It supports **authentication, real-time messaging, image uploads, and notifications** while following **secure development practices** to avoid exposing sensitive data.

---

## 🛠 Features
SocialConnect 2 - Key Strengths

🚀 Modern iOS Architecture & Best Practices

Clean Architecture (MVVM + Coordinators):
Structured into Presentation, Domain, and Data layers, ensuring maintainability and scalability.
Modularization & Code Separation:
Organized ViewModels, Use Cases, and Repository pattern, adhering to SOLID principles.
Swift Concurrency:
Utilizes async/await and Task for smooth, performant asynchronous handling.
SwiftUI + UIKit Hybrid:
A SwiftUI-first approach, with UIHostingController integration where necessary.
🔐 Security & Privacy-First Approach

Keychain Integration:
Securely stores authentication tokens and sensitive user data.
OAuth2 Authentication:
Implements Firebase Auth & Sign In with Apple for secure login flows.
End-to-End Encryption (E2EE):
Secure messaging and data exchange for private user interactions.
Secure Storage:
Uses Core Data & UserDefaults with encryption for storing user preferences safely.
🌐 Networking & Data Layer

Combine & URLSession for Networking:
Efficient, reactive API handling using AnyPublisher and PassthroughSubject.
RESTful API Integration:
Adopts Decodable models for smooth JSON parsing and integrates with Cloud Firestore.
Feature Flags & A/B Testing:
Utilizes remote feature toggles to dynamically roll out experimental features.
🎨 User Experience & Performance

Optimized Collection Views (DiffableDataSource):
Ensures a smooth scrolling experience for content-heavy screens.
Push Notifications (Firebase Cloud Messaging):
Custom notifications based on user engagement & AI-powered recommendations.
Advanced UI Animations (SwiftUI & Core Animation):
Enhances user interactions with smooth, elegant animations.
🤖 AI-Powered Smart Recommendations

Core ML & Firebase MLKit Integration:
Implements Collaborative Filtering & Content-Based Recommendations.
Dynamic AI-Powered Feeds:
Smartly curates content for "Trending Now" & "Because You Watched…" sections.
🛠 Robust Testing & CI/CD Pipeline

XCTest & UI Testing:
Strong test coverage with XCTest for SignUp, Login, Profile, and HomeViewModel.
Automated CI/CD with GitHub Actions & Fastlane:
Streamlined deployment process for TestFlight & App Store releases.
SwiftLint & Danger Integration:
Enforces clean, maintainable code and best practices.
📡 Cloud & Backend Infrastructure

Cloud Firestore & Firebase Storage:
Scales seamlessly for real-time updates and multimedia content.
Node.js Backend Deployment on Firebase Functions:
Secure API handling for messaging, authentication, and real-time updates.
GraphQL Integration (for future scalability):
Future-proofing backend queries with a flexible GraphQL API structure.


---

## 📸 Screenshots

### 🖼 Screenshot 1
<img src="https://github.com/AkinCodes/SocialConnect/blob/main/Screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-03-17%20at%2014.22.00.png?raw=true" width="300">

### 🖼 Screenshot 2
<img src="https://github.com/AkinCodes/SocialConnect/blob/main/Screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-03-17%20at%2014.22.06.png?raw=true" width="300">

### 🖼 Screenshot 3
<img src="https://github.com/AkinCodes/SocialConnect/blob/main/Screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-03-17%20at%2014.22.09.png?raw=true" width="300">

### 🖼 Screenshot 4
<img src="https://github.com/AkinCodes/SocialConnect/blob/main/Screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-03-17%20at%2014.25.58.png?raw=true" width="300">

### 🖼 Screenshot 5
<img src="https://github.com/AkinCodes/SocialConnect/blob/main/Screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-03-17%20at%2014.26.09.png?raw=true" width="300">


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

### ✅ 5️⃣ **Ensure `.gitignore` is Configured**
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
✅ **If everything is set up correctly, the app should launch without API errors.**  

---

## 🤝 Contribution Guidelines
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

## 📝 License
This project is **MIT Licensed**.

---
