
import UIKit

@MainActor
final class HomeCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    weak var parentCoordinator: (any Coordinator)?
    let diContainer: DIContainer

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }
    
    func start() {
        let postRepository: PostRepository = diContainer.resolve()
        let fetchPaginatedPostsUseCase = FetchPaginatedPostsUseCaseImpl(postRepository: postRepository)

        let homeVM = HomeViewModel(fetchPaginatedPostsUseCase: fetchPaginatedPostsUseCase, postRepository: postRepository)
        let homeVC = HomeViewController(viewModel: homeVM)

        homeVC.onPostSelected = { [weak self] post in
            self?.navigateToMediaDetail(post: post)
        }
        homeVC.onProfileSelected = { [weak self] in
            self?.navigateToProfile()
        }
        homeVC.onCreatePost = { [weak self] in
            self?.didCreatePost()
        }
        
        navigationController.viewControllers = [homeVC]
    }

    
    private func navigateToProfile() {
        if let tabBarController = navigationController.tabBarController {
            tabBarController.selectedIndex = 1
        }
    }
    
    private func navigateToMediaDetail(post: Post) {
        let mediaDetailVC = MediaDetailViewController(media: post)
        mediaDetailVC.onBackToHome = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(mediaDetailVC, animated: true)
    }

    func didCreatePost() {
        let createPostVC = CreatePostViewController()
        navigationController.present(createPostVC, animated: true)
    }
    
}





