import UIKit
import Firebase
import FirebaseMessaging
import FirebaseRemoteConfigInternal
import FirebaseAuth
import FirebaseInstallations
import FirebaseAppCheck
import FirebaseCore
import GoogleSignIn
import BackgroundTasks
import FirebaseFirestore
import UserNotifications
import OSLog


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    static let bgAppTaskId = "com.socialconnect.fetch"
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        os_log("SNYDER CUT AKINOLA")
        
        // ✅ Set AppCheck Provider
        #if DEBUG
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #else
        let providerFactory = YourProductionAppCheckProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
        
        FirebaseApp.configure()
        
        Task {
            await clearFirestoreCache()
        }
        
        Auth.auth().currentUser?.getIDToken { token, error in
            if let error = error {
                print("❌ Firebase Auth Token Error: \(error)")
            } else {
                print("✅ Firebase Auth Token: \(token ?? "No Token")")
            }
        }
        
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true) { token, error in
            if let error = error {
                print("❌ Firebase Auth Token Refresh Error: \(error)")
            } else {
                print("✅ Firebase Auth Token Refreshed: \(token ?? "No Token")")
            }
        }
        
        registerForPushNotifications(application)
        PushNotificationManager.shared.configureFirebaseMessaging()
        
        // Check if launched from notification deep link
        if let notification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            PushNotificationManager.shared.handleDeepLink(notification)
        }

        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let user = user {
                print("User signed in: \(user.profile?.email ?? "")")
            }
        }
        
        registerBackgroundTask()
        fetchRemoteConfig()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleBackgroundFetch()
    }
    
    // ✅ Request Push Notification Permission & Register for APNs
    private func registerForPushNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            print(granted ? "✅ Notifications permission granted" : "❌ Notifications permission denied")
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error {
                print("❌ Error retrieving FCM token: \(error.localizedDescription)")
            } else if let token = token {
                print("🚀 New FCM token: \(token)")
            }
        }
    }
    
    // ❌ Handle APNs Registration Failure
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for APNs: \(error.localizedDescription)")
    }

    // ✅ Register Background Fetch
    private func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: AppDelegate.bgAppTaskId, using: nil) { task in
            self.handleBackgroundFetch(task: task as? BGAppRefreshTask)
        }
    }

    func fetchRemoteConfig() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings

        remoteConfig.fetchAndActivate { status, error in
            if let error = error {
                print("❌ Remote Config Fetch Failed: \(error.localizedDescription)")
            } else {
                print("✅ Remote Config Fetched! Sorting Mode: \(remoteConfig["feedSortingType"].stringValue)")
                print("✅ AI Weights -> Engagement: \(remoteConfig["aiEngagementWeight"].numberValue.doubleValue), Recency: \(remoteConfig["aiSortingWeight"].numberValue.doubleValue)")
            }
        }
    }
    
    // ✅ Schedule Background Fetch
    private func scheduleBackgroundFetch() {
        let request = BGAppRefreshTaskRequest(identifier: AppDelegate.bgAppTaskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Run every 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("📅 Scheduled Background Fetch")
        } catch {
            print("❌ Failed to Schedule Background Fetch: \(error)")
        }
    }
    
    // ✅ Handle Background Fetch Task
    private func handleBackgroundFetch(task: BGAppRefreshTask?) {
        task?.expirationHandler = {
            task?.setTaskCompleted(success: false)
        }
        
        Task {
            do {
                let newPosts = try await BackgroundFetchManager.shared.fetchNewPosts()
                // Schedule the next fetch
                scheduleBackgroundFetch()
                task?.setTaskCompleted(success: true)
            } catch {
                print("🔥 Background Fetch Failed: \(error)")
                task?.setTaskCompleted(success: false)
            }
        }
    }
    
    // ✅ Handle Google Sign-In
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    // ✅ Restart App Function
    func restartApp() {
        guard let window = UIApplication.shared
            .connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else {
            return
        }

        let diContainer = DIContainer.shared
        
        let appCoordinator = AppCoordinator(window: window, diContainer: diContainer)
        self.appCoordinator = appCoordinator
        AppCoordinator.shared = appCoordinator
        
        let splashScreen = SplashScreenViewController()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = splashScreen
        }) { _ in
            Task {
                AppCoordinator.shared?.start()
            }
        }
    }
    
    func clearFirestoreCache() async {
        do {
            try await Firestore.firestore().clearPersistence()
            print("✅ Firestore cache cleared")
        } catch {
            print("❌ Failed to clear Firestore cache: \(error.localizedDescription)")
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("📩 Received Notification: \(notification.request.content.userInfo)")
        completionHandler([.banner, .sound])
    }
}

extension AppDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("📲 Notification Tapped! UserInfo: \(userInfo)")
        
        if let category = userInfo["category"] as? String,
           let deepLinkURL = createDeepLinkURL(category: category, userInfo: userInfo) {
            DispatchQueue.main.async {
                DeepLinkHandler.shared.handle(url: deepLinkURL)
            }
        } else {
            print("⚠️ No category found in push notification!")
        }
        
        completionHandler()
    }

    private func createDeepLinkURL(category: String, userInfo: [AnyHashable: Any]) -> URL? {
        var urlString = "socialconnect://app/"

        switch category {
        case "POST":
            if let postId = userInfo["postId"] as? String {
                urlString += "post?postId=\(postId)"
            } else {
                urlString += "post"
            }
        case "PROFILE":
            if let userId = userInfo["userId"] as? String {
                urlString += "profile?userId=\(userId)"
            } else {
                urlString += "profile"
            }
        case "SETTINGS":
            urlString += "settings"
        default:
            print("⚠️ Unknown category: \(category)")
            return nil
        }

        return URL(string: urlString)
    }
}
