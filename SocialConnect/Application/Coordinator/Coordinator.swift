import UIKit

@MainActor
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [any Coordinator] { get set }
    var parentCoordinator: (any Coordinator)? { get set }

    func start()
    
    func removeChildCoordinator(_ coordinator: any Coordinator)
}

extension Coordinator {
    func removeChildCoordinator(_ coordinator: any Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
