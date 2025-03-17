import UIKit
import FirebaseAuth

final class SettingsCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators = [Coordinator]()
    weak var parentCoordinator: Coordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let settingsVC = SettingsViewController()
        settingsVC.onLogout = { [weak self] in self?.handleLogout() }
        navigationController.viewControllers = [settingsVC]
    }

    private func handleLogout() {
        Task {
            do {
                try Auth.auth().signOut()
                parentCoordinator?.removeChildCoordinator(self) 
                (UIApplication.shared.delegate as? AppDelegate)?.restartApp()
            } catch {
                print("❌ Error logging out: \(error)")
            }
        }
    }
}
