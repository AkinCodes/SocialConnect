import UIKit

@MainActor
final class ProfileCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    weak var parentCoordinator: (any Coordinator)? 
    let diContainer: DIContainer

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        let profileVC = ProfileViewController(viewModel: ProfileViewModel(authManager: .shared, userRepository: diContainer.userRepository))
        profileVC.onEditProfile = { [weak self] in self?.showEditProfile() }
        navigationController.viewControllers = [profileVC]
    }

    private func showEditProfile() {
        let editProfileVC = EditProfileViewController(viewModel: EditProfileViewModel(userRepository: diContainer.userRepository))
        editProfileVC.modalPresentationStyle = .formSheet
        navigationController.present(editProfileVC, animated: true)
    }
}
