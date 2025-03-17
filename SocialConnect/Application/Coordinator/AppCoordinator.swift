import UIKit
import FirebaseAuth

@MainActor
final class AppCoordinator: Coordinator {
    let window: UIWindow
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    var parentCoordinator: (any Coordinator)?
    let diContainer: DIContainer
    private var authStateListener: AuthStateDidChangeListenerHandle?

    static var shared: AppCoordinator?

    static func initialize(with window: UIWindow, diContainer: DIContainer) {
        shared = AppCoordinator(window: window, diContainer: diContainer)
    }
    
    init(window: UIWindow, diContainer: DIContainer) {
        self.window = window
        self.diContainer = diContainer
        self.navigationController = UINavigationController()
    }


    func start() {
        guard Auth.auth().currentUser?.isEmailVerified == true else {
            showAuthFlow()
            return
        }

        setupSplashScreen()
        listenForAuthChanges()
    }

    private func setupSplashScreen() {
        window.rootViewController = SplashScreenViewController()
        window.makeKeyAndVisible()
    }

    private func listenForAuthChanges() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }

            Task {
                do {
                    try await user?.reload()
                    self.showMainApp()
                } catch {
                    print("❌ Error reloading user session: \(error.localizedDescription)")
                    self.showAuthFlow()
                }
            }
        }
    }

    private func showMainApp() {
        let mainNavigationController = UINavigationController()
        let mainCoordinator = MainCoordinator(navigationController: mainNavigationController, diContainer: diContainer)
        mainCoordinator.parentCoordinator = self
        childCoordinators.append(mainCoordinator)
        mainCoordinator.start()

        DispatchQueue.main.async {
            self.window.rootViewController = mainNavigationController
            self.window.makeKeyAndVisible()
        }
    }

    private func showAuthFlow() {
        childCoordinators.removeAll(where: { $0 is AuthCoordinator })
        let authNavigationController = UINavigationController()
        let authCoordinator = AuthCoordinator(navigationController: authNavigationController, diContainer: diContainer)
        authCoordinator.parentCoordinator = self

        authCoordinator.onAuthSuccess = { [weak self] in
            self?.showMainApp()
        }

        childCoordinators.append(authCoordinator)
        authCoordinator.start()

        self.window.rootViewController = authNavigationController
        self.window.makeKeyAndVisible()
    }

    func handleLogout() {
        childCoordinators.removeAll()
        self.showAuthFlow()
    }

    // MARK: - Deep Link Navigation
        func routeDeepLink(path: String, parameters: [String: String]) {
            print("🔀 Routing Deep Link: \(path) with Parameters: \(parameters)")

            DispatchQueue.main.async {
                switch path {
                case "post":
                    print("📄 Navigating to Post screen")
                    self.navigateToPostScreen()

                case "profile":
                    print("👤 Navigating to Profile screen")
                    self.navigateToProfileScreen()

                case "settings":
                    print("⚙️ Navigating to Settings screen")
                    self.navigateToSettings()

                default:
                    self.handleFallbackDeepLink(host: path, parameters: parameters)
                }
            }
        }


    private func handleFallbackDeepLink(host: String, parameters: [String: String]) {
        print("🛑 No specific navigation found for: \(host).")
        print("📌 Deep link parameters: \(parameters)")
    }

    func navigateToProfile() {
        let viewModel: ProfileViewModel = DIContainer.shared.resolve()
        let profileVC = ProfileViewController(viewModel: viewModel)
        navigate(to: profileVC)
    }


    func navigateToPost(postId: String) {
        let viewModel: HomeViewModel = DIContainer.shared.resolve()
        let homeVC = HomeViewController(viewModel: viewModel)
        navigate(to: homeVC)
    }
    
    func navigateToChat(chatId: String) {
        let viewModel: HomeViewModel = DIContainer.shared.resolve()
        let homeVC = HomeViewController(viewModel: viewModel)
        navigate(to: homeVC)
    }
    
    func  navigateToSettings() {
        let settingsVC = SettingsViewController()
        navigate(to: settingsVC)
    }
    
    func navigateToPostScreen() {
        let viewModel: HomeViewModel = DIContainer.shared.resolve()
        let homeVC = HomeViewController(viewModel: viewModel)
        navigate(to: homeVC)
    }

    func navigateToChatScreen() {
        let viewModel: HomeViewModel = DIContainer.shared.resolve()
        let homeVC = HomeViewController(viewModel: viewModel)
        navigate(to: homeVC)
    }
    
    
    func navigateToProfileScreen() {
        let viewModel: ProfileViewModel = .init(authManager: diContainer.authManager)
        let profileVC = ProfileViewController(viewModel: viewModel)
        navigate(to: profileVC)
    }
    
     func navigateToProfile(userId: String) {
         let viewModel: ProfileViewModel = .init(authManager: diContainer.authManager)
         let profileVC = ProfileViewController(viewModel: viewModel)
         navigate(to: profileVC)
     }
    
    private func navigate(to viewController: UIViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            print("⚠️ No key window found for navigation")
            return
        }

        if let navController = window.rootViewController as? UINavigationController {
            if navController.viewControllers.last != viewController {
                navController.pushViewController(viewController, animated: true)
            } else {
                print("⚠️ Prevented duplicate push of ViewController")
            }
        } else {
            let navController = UINavigationController(rootViewController: viewController)
            window.rootViewController = navController
            window.makeKeyAndVisible()
        }
    }
}
