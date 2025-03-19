import UIKit
import GoogleSignIn
import Combine
import LocalAuthentication

@MainActor
final class LoginViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: LoginViewModel
    private var cancellables = Set<AnyCancellable>()
    
    var onLoginSuccess: (() -> Void)?
    var onNavigateToSignUp: (() -> Void)?

    private let loginView = LoginView()

    // MARK: - Initializer
    init(viewModel: LoginViewModel) {
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
        view.addSubview(loginView)
        
        loginView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loginView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        loginView.loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginView.googleSignInButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        loginView.signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        loginView.biometricLoginButton.addTarget(self, action: #selector(biometricLoginTapped), for: .touchUpInside)
    }

    @objc private func biometricLoginTapped() {
        AuthManager.shared.authenticateWithBiometrics { [weak self] success, error in
            if success {
                self?.onLoginSuccess?()
            } else {
                guard let self = self else { return }
                AlertManager.shared.showAlert(on: self, title: "Biometric Login Failed", message: error?.localizedDescription ?? "Please try again.")
            }
        }
    }

    @objc private func loginTapped() {
        view.endEditing(true) // Dismiss keyboard

        guard let email = loginView.emailTextField.text, !email.isEmpty,
              let password = loginView.passwordTextField.text, !password.isEmpty
        else {
            AlertManager.shared.showAlert(on: self, title: "Missing Credentials", message: "Please enter both email and password.")
            return
        }

        viewModel.email = email
        viewModel.password = password
        
        print("🔍 Email entered: \(loginView.emailTextField.text ?? "nil")")
        print("🔍 Email in ViewModel: \(viewModel.email)")

        Task {
            let success = await viewModel.login()
            if success { onLoginSuccess?() }
            else {
                AlertManager.shared.showAlert(on: self, title: "Login Failed", message: "Invalid email or password.")
            }
        }
    }


    @objc private func signUpTapped() {
        onNavigateToSignUp?()
    }
    
    @objc private func googleSignInTapped() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] signInResult, error in
            guard let self = self else { return }

            guard let signInResult = signInResult,
                  let idToken = signInResult.user.idToken?.tokenString, !idToken.isEmpty else {
                AlertManager.shared.showAlert(on: self, title: "Google Sign-In Failed", message: error?.localizedDescription ?? "Please try again.")
                return
            }

            let accessToken = signInResult.user.accessToken.tokenString

            Task {
                let success = await self.viewModel.loginWithGoogle(idToken: idToken, accessToken: accessToken)
                if success {
                    self.onLoginSuccess?()
                }
            }
        }
    }


    
    // MARK: - Bindings
    private func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loginView.setLoading(isLoading)
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
        
        loginView.emailTextField.publisher(for: \.text)
            .compactMap { $0 ?? "" } // Ensure non-nil values
            .assign(to: &viewModel.$email)
        
        loginView.passwordTextField.publisher(for: \.text)
            .compactMap { $0 ?? "" }
            .assign(to: &viewModel.$password)
    }
}
