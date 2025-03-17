import Foundation
import Combine
import LocalAuthentication
import FirebaseAuth

@MainActor
final class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isLoggedIn: Bool = false

    // MARK: - Dependencies
    private let authManager: AuthManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer
    init(authManager: AuthManager) {
        self.authManager = AuthManager.shared
        observeAuthChanges()
    }

    // MARK: - Public Methods

    /// Handles user login with email and password
    func login() async -> Bool {
        isLoading = true
        defer { isLoading = false }

        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        // 🔥 Ensure email is not empty before attempting login
        guard !cleanedEmail.isEmpty else {
            errorMessage = "Email cannot be empty."
            print("❌ Email is empty! Login aborted.")
            return false
        }

        print("🔍 Attempting login with email: '\(cleanedEmail)'")

        do {
            try await authManager.signIn(email: cleanedEmail, password: password)
            isLoggedIn = true
            print("✅ Login successful: \(Auth.auth().currentUser?.uid ?? "No UID")")
            return true
        } catch {
            isLoggedIn = false
            handleError(error)
            print("❌ Login failed: \(error.localizedDescription)")
            return false
        }
    }

    /// Handles user registration with email and password
    func register() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await authManager.signUp(email: email, password: password) // ✅ Capture the user object
            isLoggedIn = true
            print("✅ Registration successful: \(user.uid)")

            // ✅ Optional: Check email verification
            if !user.isEmailVerified {
                print("📩 Email verification required. Sending verification email...")
                try await authManager.sendEmailVerification()
            }
        } catch {
            handleError(error)
        }
    }

    /// Handles user sign-out
    func logout() {
        do {
            try authManager.signOut()
            isLoggedIn = false
        } catch {
            errorMessage = "Failed to logout: \(error.localizedDescription)"
        }
    }
    
    func loginWithGoogle(idToken: String, accessToken: String) async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            try await authManager.signInWithCredential(credential)
            isLoggedIn = true
            return true
        } catch {
            handleError(error)
            return false
        }
    }

    func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Login with Face ID / Touch ID") { success, authError in
                DispatchQueue.main.async {
                    if success {
                        Task {
                            do {
                                let token = try await KeychainService.shared.retrieve(for: "authToken")
                                if token != nil {
                                    self.isLoggedIn = true
                                    completion(true)
                                } else {
                                    self.errorMessage = "No saved credentials found."
                                    completion(false)
                                }
                            } catch {
                                self.errorMessage = "Failed to retrieve token."
                                completion(false)
                            }
                        }
                    } else {
                        self.errorMessage = "Biometric authentication failed."
                        completion(false)
                    }
                }
            }
        } else {
            errorMessage = "Biometric authentication not available."
            completion(false)
        }
    }

    // MARK: - Private Methods

    private func observeAuthChanges() {
        authManager.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.isLoggedIn = user != nil
            }
            .store(in: &cancellables)
    }

    private func handleError(_ error: Error) {
        errorMessage = "An error occurred: \(error.localizedDescription)"
    }
}

