import Foundation
import LocalAuthentication
@preconcurrency import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import Combine

@MainActor
final class AuthManager: NSObject, ObservableObject {
    static let shared = AuthManager()
    
    @Published var currentUser: FirebaseAuth.User?
    @Published var isAuthenticated = false
    private var authStateListener: AuthStateDidChangeListenerHandle?
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        listenForAuthChanges()
    }
    
     var isUserLoggedIn: Bool {
         return currentUser != nil
     }

    func authenticateWithBiometrics(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        var error: NSError?

        // Check if device supports biometrics
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your account"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluateError in
                DispatchQueue.main.async {
                    completion(success, evaluateError)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(false, error)
            }
        }
    }
    
    private func listenForAuthChanges() {
        authStateListener = Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                self.currentUser = user
                print("✅ Auth state changed: \(user?.uid ?? "No User")")
            }
        }
    }
    
    /// ✅ **Silent Login using Firebase Token**
    func restoreSession() async throws {
        guard let user = Auth.auth().currentUser else {
            print("🔴 No user session found")
            return
        }
        
        try await user.reload()

        let token = try await user.getIDToken()
        try KeychainService.shared.save(token, for: "authToken")

        DispatchQueue.main.async {
            self.currentUser = user
        }
        print("✅ User session restored")
    }

    
    
    // Check if User is Logged In
        func checkUserSession() -> Bool {
            if let user = Auth.auth().currentUser {
                self.currentUser = user
                print("✅ User is already signed in: \(user.uid)")
                return true
            } else {
                print("🔴 No active session found")
                return false
            }
        }

    
    @MainActor
    private func configureAuthPersistence() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                if let user = user {
                    print("✅ User session restored: \(user.uid)")
                } else {
                    print("🔴 No active session found, redirecting to login.")
                }
            }
        }
    }

    func signInWithCredential(_ credential: AuthCredential) async throws {
        do {
            let result = try await Auth.auth().signIn(with: credential)
            self.currentUser = result.user
            try await storeToken()
            print("✅ Signed in successfully with credential: \(result.user.uid)")
        } catch let error as NSError {
            if error.code == AuthErrorCode.accountExistsWithDifferentCredential.rawValue {
                print("⚠️ This account exists with a different sign-in method.")
            } else {
                print("❌ Credential sign-in error: \(error.localizedDescription)")
            }
            throw error
        }
    }
    
        func signInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Bool) -> Void) {
            GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { signInResult, error in
                guard let signInResult = signInResult, let idToken = signInResult.user.idToken?.tokenString else {
                    print("❌ Google Sign-In failed: \(error?.localizedDescription ?? "Unknown error")")
                    completion(false)
                    return
                }

                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: signInResult.user.accessToken.tokenString)

                Task {
                    do {
                        try await self.signInWithCredential(credential)
                        self.isAuthenticated = true
                        completion(true)
                    } catch {
                        print("❌ Google Sign-In error: \(error.localizedDescription)")
                        completion(false)
                    }
                }
            }
        }
    
    
    func signUp(email: String, password: String) async throws -> FirebaseAuth.User {
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            let result = try await Auth.auth().createUser(withEmail: cleanedEmail, password: password)
            let user = result.user
            print("✅ User Created: \(user.uid), Email: \(user.email ?? "Unknown Email")")

            if !user.isEmailVerified {
                try await user.sendEmailVerification()
                print("Verification email sent.")
            }

            try await storeToken()
            return user
        } catch let error as NSError {
            if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                print("⚠️ Email already in use. Suggest user sign in instead.")
            } else {
                print("❌ Sign-up error: \(error.localizedDescription)")
            }
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            let result = try await Auth.auth().signIn(withEmail: cleanedEmail, password: password)
            print("✅ Login successful: \(result.user.uid)")
            print("✅ User email: \(result.user.email ?? "Unknown Email")")
            print("✅User providers: \(result.user.providerData.map { $0.providerID })")

            DispatchQueue.main.async {
                self.currentUser = result.user
            }
            try await storeToken()
        } catch let error as NSError {
            if error.code == AuthErrorCode.userNotFound.rawValue {
                print("⚠️ No user found. Suggest signing up instead.")
            } else if error.code == AuthErrorCode.wrongPassword.rawValue {
                print("⚠️ Incorrect password. Ask user to try again.")
            } else {
                print("❌ Firebase Login Error: \(error.code) - \(error.localizedDescription)")
            }
            throw error
        }
    }

    
    func signInAnonymously() async throws {
        let result = try await Auth.auth().signInAnonymously()
        DispatchQueue.main.async {
            self.currentUser = result.user
        }
        try await storeToken()
    }
    
    func upgradeAnonymousUser(email: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else { throw AuthError.notAuthenticated }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        _ = try await user.link(with: credential)
        DispatchQueue.main.async {
            self.currentUser = user
        }
        try await storeToken()
    }
    
    func sendEmailVerification() async throws {
        guard let user = Auth.auth().currentUser, !user.isEmailVerified else { return }
        try await user.sendEmailVerification()
    }
    
    private func verifyEmailBeforeLogin() async throws {
        guard let user = Auth.auth().currentUser else { throw AuthError.notAuthenticated }
        try await user.reload()
        guard user.isEmailVerified else { throw AuthError.emailNotVerified }
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { throw AuthError.notAuthenticated }
        try await user.delete()
        DispatchQueue.main.async {
            self.currentUser = nil
        }
        try KeychainService.shared.delete("authToken")
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
            }
            try KeychainService.shared.delete("authToken")
        } catch {
            print("❌ Failed to sign out: \(error)")
            throw error
        }
    }
    
    
    func fetchAuthToken() async throws -> String {
        guard let user = Auth.auth().currentUser else { throw AuthError.notAuthenticated }
        let token = try await user.getIDToken()
        try KeychainService.shared.save(token, for: "authToken")
        return token
    }
    
    private func storeToken() async throws {
        let token = try await fetchAuthToken()
        try KeychainService.shared.save(token, for: "authToken", useBiometrics: true)
    }
}

enum AuthError: Error, LocalizedError {
    case notAuthenticated
    case emailNotVerified
    case missingGoogleClientID
    case googleSignInFailed
    case appleSignInFailed

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User is not authenticated."
        case .emailNotVerified:
            return "Email is not verified. Please check your inbox and verify your email."
        case .missingGoogleClientID:
            return "Google Client ID is missing."
        case .googleSignInFailed:
            return "Google Sign-In failed."
        case .appleSignInFailed:
            return "Apple Sign-In failed."
        }
    }
}
