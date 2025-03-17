import Foundation
import FirebaseMessaging
import UserNotifications
import UIKit
import FirebaseAuth

final class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
    static let shared = PushNotificationManager()
    
    private override init() {}

    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]

        center.requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
                return
            }
            print(granted ? "✅ Notifications allowed" : "⚠️ Notifications denied")

            if granted {
                DispatchQueue.main.async {
                    self.registerForRemoteNotifications()
                }
            }
        }
        
        // Register notification categories
        setupNotificationCategories()
    }

    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    func configureFirebaseMessaging() {
        Messaging.messaging().delegate = self
    }

    // MARK: -  Handle APNs Token Registration
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        updateAPNSToken(deviceToken: deviceToken)
    }

    func updateAPNSToken(deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("APNs Token: \(tokenString)")

        // Forward APNs token to Firebase
        Messaging.messaging().apnsToken = deviceToken
    }

    private func setupNotificationCategories() {
        let center = UNUserNotificationCenter.current()

        let viewNow = UNNotificationAction(identifier: "VIEW_POST_ACTION", title: "View Now", options: [.foreground])
        let remindLater = UNNotificationAction(identifier: "REMIND_LATER_ACTION", title: "Remind Me Later", options: [])
        let newContentCategory = UNNotificationCategory(identifier: "NEW_CONTENT",
                                                        actions: [viewNow, remindLater],
                                                        intentIdentifiers: [],
                                                        options: [])

        let acknowledge = UNNotificationAction(identifier: "ACKNOWLEDGE_ACTION", title: "Acknowledge", options: [])
        let reviewAccount = UNNotificationAction(identifier: "REVIEW_ACCOUNT_ACTION", title: "Review Account", options: [.foreground])
        let securityCategory = UNNotificationCategory(identifier: "SECURITY_ALERT",
                                                      actions: [acknowledge, reviewAccount],
                                                      intentIdentifiers: [],
                                                      options: [])

        let dismiss = UNNotificationAction(identifier: "DISMISS_ACTION", title: "Dismiss", options: [])
        let learnMore = UNNotificationAction(identifier: "LEARN_MORE_ACTION", title: "Learn More", options: [.foreground])
        let generalUpdatesCategory = UNNotificationCategory(identifier: "GENERAL_UPDATE",
                                                            actions: [dismiss, learnMore],
                                                            intentIdentifiers: [],
                                                            options: [])

        center.setNotificationCategories([newContentCategory, securityCategory, generalUpdatesCategory])
    }

    // MARK: - Handle Notification Received
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier
        
        print("✅ User tapped notification: \(userInfo) | Action: \(actionIdentifier)")

        switch response.notification.request.content.categoryIdentifier {
        case "NEW_CONTENT":
            if actionIdentifier == "VIEW_POST_ACTION" {
                navigateToPost(userInfo)
            } else if actionIdentifier == "REMIND_LATER_ACTION" {
                scheduleReminder(userInfo)
            }

        case "SECURITY_ALERT":
            if actionIdentifier == "ACKNOWLEDGE_ACTION" {
                print("🛡️ Security alert acknowledged.")
            } else if actionIdentifier == "REVIEW_ACCOUNT_ACTION" {
                navigateToSecurityPage()
            }

        case "GENERAL_UPDATE":
            if actionIdentifier == "LEARN_MORE_ACTION" {
                navigateToUpdatesPage()
            }

        default:
            print("⚠️ Unknown action: \(actionIdentifier)")
        }

        handleDeepLink(userInfo)
        completionHandler()
    }

    // MARK: -  Handle Deep Links
    func handleDeepLink(_ userInfo: [AnyHashable: Any]) {
        if let deepLinkURLString = userInfo["deeplink_url"] as? String,
           let deepLinkURL = URL(string: deepLinkURLString) {
            print("🔗 Received Deep Link: \(deepLinkURLString)")
            NotificationCenter.default.post(name: Notification.Name("DeepLinkReceived"), object: deepLinkURL)
        } else {
            print("⚠️ No valid deep link found in notification.")
        }
    }

    // MARK: - Firebase Messaging Delegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )

        if let token = fcmToken {
            sendTokenToBackend(token)
        }
    }

    private func sendTokenToBackend(_ token: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let url = URL(string: "https://your-backend-api.com/api/save-token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "userId": userID,
            "fcmToken": token
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Failed to send FCM token: \(error.localizedDescription)")
                return
            }
            print("✅ Successfully sent FCM token to backend")
        }
        
        task.resume()
    }

    // MARK: - Handle Foreground Notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("📩 Received notification in foreground: \(notification.request.content.userInfo)")
        completionHandler([.banner, .sound])
    }

    // MARK: - 🔀 Navigation & Actions
    private func navigateToPost(_ userInfo: [AnyHashable: Any]) {
        // TODO: Extract post ID and navigate user to post screen
    }
    
    private func scheduleReminder(_ userInfo: [AnyHashable: Any]) {
        print("Scheduling Reminder")
        // TODO: Implement scheduling logic
    }
    
    private func navigateToSecurityPage() {
        print("Navigating to Security Settings")
        // TODO: Implement navigation to security settings
    }
    
    private func navigateToUpdatesPage() {
        print("Navigating to Updates Page")
        // TODO: Implement navigation to system updates
    }

    // MARK: - 🛠 Test Local Notification
    func sendTestLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🔔 Test Notification"
        content.body = "This is a local test notification."
        content.sound = .default
        content.categoryIdentifier = "NEW_CONTENT"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Local notification failed: \(error.localizedDescription)")
            } else {
                print("✅ Local notification scheduled successfully.")
            }
        }
    }
}

// MARK: - Empty Response for APIClient
struct EmptyResponse: Decodable {}
