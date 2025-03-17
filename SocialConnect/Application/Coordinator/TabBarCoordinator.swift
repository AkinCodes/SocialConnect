import UIKit

final class TabBarCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    weak var parentCoordinator: (any Coordinator)?
    let tabBarController = UITabBarController()
    let diContainer: DIContainer

    init(navigationController: UINavigationController, diContainer: DIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        let homeCoordinator = HomeCoordinator(navigationController: UINavigationController(), diContainer: diContainer)
        let profileCoordinator = ProfileCoordinator(navigationController: UINavigationController(), diContainer: diContainer)
        let settingsCoordinator = SettingsCoordinator(navigationController: UINavigationController())

        homeCoordinator.parentCoordinator = self
        profileCoordinator.parentCoordinator = self
        settingsCoordinator.parentCoordinator = self

        homeCoordinator.start()
        profileCoordinator.start()
        settingsCoordinator.start()

        tabBarController.viewControllers = [
            homeCoordinator.navigationController,
            profileCoordinator.navigationController,
            settingsCoordinator.navigationController
        ]

        homeCoordinator.navigationController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        profileCoordinator.navigationController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), tag: 1)
        settingsCoordinator.navigationController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 2)

        childCoordinators.append(contentsOf: [
            homeCoordinator as any Coordinator,
            profileCoordinator as any Coordinator,
            settingsCoordinator as any Coordinator
        ])

        navigationController.setViewControllers([tabBarController], animated: false)
    }
}
