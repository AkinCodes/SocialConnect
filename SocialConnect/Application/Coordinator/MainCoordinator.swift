import UIKit
import FirebaseAuth

@MainActor
final class MainCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    weak var parentCoordinator: (any Coordinator)?
    let diContainer: DIContainer

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        if FirebaseAuth.Auth.auth().currentUser != nil {
            showMainApp()
        } else {
            showAuthFlow()
        }
    }

    private func showMainApp() {
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController, diContainer: diContainer)
        tabBarCoordinator.parentCoordinator = self
        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()
    }

    private func showAuthFlow() {
        let authCoordinator = AuthCoordinator(navigationController: navigationController, diContainer: diContainer)
        authCoordinator.parentCoordinator = self
        authCoordinator.onAuthSuccess = { [weak self] in
            self?.childCoordinators.removeAll()
            self?.showMainApp()
        }
        childCoordinators.append(authCoordinator)
        authCoordinator.start()
    }

    func logout() {
        childCoordinators.removeAll()
        parentCoordinator?.removeChildCoordinator(self)
        showAuthFlow()
    }
}
