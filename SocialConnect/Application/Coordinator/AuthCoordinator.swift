import UIKit
import FirebaseAuth

@MainActor
final class AuthCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators = [Coordinator]()
    weak var parentCoordinator: Coordinator?
    private let diContainer: DIContainer

    var onAuthSuccess: (() -> Void)?

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    @MainActor
    func start() {
        navigateToLogin()
    }

    func navigateToLogin() {
        let loginVC = LoginViewController(viewModel: LoginViewModel(authManager: diContainer.authManager))
        loginVC.onLoginSuccess = { [weak self] in
            guard let self = self else { return }

            Task {
                try? await Auth.auth().currentUser?.reload()

                if Auth.auth().currentUser != nil {
                    self.parentCoordinator?.removeChildCoordinator(self)
                    self.onAuthSuccess?()
                } else {
                    print("❌ Login failed or user session missing.")
                }
            }
        }
        loginVC.onNavigateToSignUp = { [weak self] in self?.navigateToSignUp() }
        navigationController.setViewControllers([loginVC], animated: false)
    }

    func navigateToSignUp() {
        let signUpVC = SignUpViewController(viewModel: SignUpViewModel(userRepository: diContainer.userRepository))
        signUpVC.onSignUpSuccess = { [weak self] in self?.navigateToLogin() }
        navigationController.pushViewController(signUpVC, animated: true)
    }
}
