import UIKit


final class AlertManager {
    static let shared = AlertManager()

    private var isAlertBeingPresented = false
    private var alertQueue: [UIAlertController] = []

    private init() {}

    func showAlert(
        on viewController: UIViewController,
        title: String = "Error",
        message: String,
        actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .default)],
        preferredStyle: UIAlertController.Style = .alert
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        actions.forEach { alert.addAction($0) }

        if isAlertBeingPresented {
            alertQueue.append(alert)
        } else {
            isAlertBeingPresented = true
            viewController.present(alert, animated: true) {
                self.isAlertBeingPresented = false
                self.showNextAlert(on: viewController)
            }
        }
    }

    private func showNextAlert(on viewController: UIViewController) {
        guard !alertQueue.isEmpty else { return }
        let nextAlert = alertQueue.removeFirst()
        showAlert(on: viewController, title: nextAlert.title ?? "", message: nextAlert.message ?? "", actions: nextAlert.actions)
    }
}
