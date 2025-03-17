import UIKit
import Combine

@MainActor
final class SignUpViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: SignUpViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // Coordination Closures
    var onSignUpSuccess: (() -> Void)?
    var onNavigateToLogin: (() -> Void)?

    // MARK: - UI Components
    private let signUpView = SignUpView()

    // MARK: - Initializer
    init(viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupBindings()
        setupActions()
    }

    // MARK: - UI Setup
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(signUpView)
        
        signUpView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            signUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            signUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            signUpView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            signUpView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        signUpView.signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        signUpView.alreadyHaveAccountButton.addTarget(self, action: #selector(alreadyHaveAccountTapped), for: .touchUpInside)
    }

    
    @objc private func signUpTapped() {
        view.endEditing(true)

        guard let email = signUpView.emailTextField.text, !email.isEmpty,
              let password = signUpView.passwordTextField.text, !password.isEmpty,
              let confirmPassword = signUpView.confirmPasswordTextField.text, !confirmPassword.isEmpty
        else {
            AlertManager.shared.showAlert(on: self, title: "Missing Fields", message: "All fields are required.")
            return
        }

        guard password == confirmPassword else {
            print("❌ Password Mismatch")
            AlertManager.shared.showAlert(on: self, title: "Password Mismatch", message: "Passwords do not match.")
            return
        }

        viewModel.email = email
        viewModel.password = password
        viewModel.confirmPassword = confirmPassword

        Task {
            print("🔹 Attempting Sign-Up")
            let success = await viewModel.signUp()
            if success {
                print("✅ Sign-Up Successful")
                onSignUpSuccess?()
            } else {
                print("❌ Sign-Up Failed: \(viewModel.errorMessage ?? "Unknown error")")
                AlertManager.shared.showAlert(on: self, title: "Sign-Up Failed", message: viewModel.errorMessage ?? "Please try again.")
            }
        }
    }

    private func showVerificationAlert() {
        let alert = UIAlertController(
            title: "Verify Your Email",
            message: "A verification email has been sent to your inbox. Please check and verify before logging in.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.onNavigateToLogin?()
        }))

        present(alert, animated: true, completion: nil)
    }


    @objc private func alreadyHaveAccountTapped() {
        onNavigateToLogin?()
    }

    // MARK: - Bindings
    private func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.signUpView.setLoading(isLoading)
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    guard let self = self else { return }
                    AlertManager.shared.showAlert(on: self, title: "Error", message: error)
                }
            }
            .store(in: &cancellables)
    }
}

