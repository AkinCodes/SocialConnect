import UIKit

protocol AlertPresentable {}

extension AlertPresentable where Self: UIViewController {
    func showAlert(
        title: String,
        message: String,
        actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .default)],
        preferredStyle: UIAlertController.Style = .alert
    ) {
        // Check if an alert is already presented
        if self.presentedViewController is UIAlertController {
            print("An alert is already being presented. Skipping new alert.")
            return
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        actions.forEach { alert.addAction($0) }
        
        DispatchQueue.main.async { 
            self.present(alert, animated: true)
        }
    }
}
