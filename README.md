# 🌟 SocialConnect

🚀 **SocialConnect** is a modern social media app built with **Swift** and **Firebase**.  
It supports **authentication, real-time messaging, image uploads, and notifications** while following **secure development practices** to avoid exposing sensitive data.

---

## 🛠 Features
- 📝 **Post Creation & Sharing**
- 📢 **Push Notifications**
- 🔒 **Secure Firebase Authentication**
- 🛋 **Cloud Storage & Firestore Database**
- 📱 **Modern iOS UI with UIKit**
- 🌐 **OAuth 2.0 Google Authentication**

---

## 📸 Screenshots

### 🖼 Screenshot 1
![Screenshot 1](https://github.com/AkinCodes/SocialConnect/blob/main/Screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-03-17%20at%2014.22.00.png?raw=true)

### 🖼 Screenshot 2
![Screenshot 2](https://github.com/AkinCodes/SocialConnect/blob/main/Screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-03-17%20at%2014.22.06.png?raw=true)

### 🖼 Screenshot 3
![Screenshot 3](https://github.com/AkinCodes/SocialConnect/blob/main/Screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-03-17%20at%2014.22.09.png?raw=true)

### 🖼 Screenshot 4
![Screenshot 4](https://github.com/AkinCodes/SocialConnect/blob/main/Screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-03-17%20at%2014.25.58.png?raw=true)

### 🖼 Screenshot 5
![Screenshot 5](https://github.com/AkinCodes/SocialConnect/blob/main/Screenshots/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20Max%20-%202025-03-17%20at%2014.26.09.png?raw=true)


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
