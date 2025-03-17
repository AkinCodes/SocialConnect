import UIKit
import FirebaseDynamicLinks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    var diContainer: DIContainer?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let diContainer = DIContainer.shared
        let appCoordinator = AppCoordinator(window: window, diContainer: diContainer)
        self.appCoordinator = appCoordinator
        AppCoordinator.shared = appCoordinator

        window.rootViewController = UINavigationController()
        window.makeKeyAndVisible()

        appCoordinator.start()
        
        if let urlContext = connectionOptions.urlContexts.first {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                DeepLinkHandler.shared.handle(url: urlContext.url)
            }
        }

    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let webpageURL = userActivity.webpageURL {
            print("🔗 Received Firebase Dynamic Link: \(webpageURL)")

            DynamicLinks.dynamicLinks().handleUniversalLink(webpageURL) { dynamicLink, error in
                if let error = error {
                    print("❌ Firebase Dynamic Link Error: \(error.localizedDescription)")
                    return
                }

                if let deepLink = dynamicLink?.url {
                    print("🚀 Extracted Deep Link from Firebase: \(deepLink.absoluteString)")
                    
                    DeepLinkHandler.shared.handle(url: deepLink)
                }
            }
        }
    }
}
