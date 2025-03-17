import UIKit

@MainActor
final class CreatePostCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    weak var parentCoordinator: (any Coordinator)?

    init(navigationController: UINavigationController, parentCoordinator: any Coordinator) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
    }

    @MainActor
    func start() {
        let createPostVC = CreatePostViewController()
        createPostVC.onPostCreated = { [weak self] in
            (self?.parentCoordinator as? HomeCoordinator)?.didCreatePost() 
            self?.navigationController.dismiss(animated: true)
            self?.parentCoordinator?.removeChildCoordinator(self!)
        }
        navigationController.present(createPostVC, animated: true)
    }

    func removeChildCoordinator(_ coordinator: any Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}

