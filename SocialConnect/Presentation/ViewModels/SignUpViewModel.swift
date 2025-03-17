import Foundation
import Combine
import FirebaseAuth

@MainActor
final class SignUpViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let authManager: AuthManager
    private let userRepository: UserRepositoryProtocol

    init(
        userRepository: UserRepositoryProtocol = UserRepository(apiClient: APIClient.shared) 
    ) {
        self.authManager = AuthManager.shared
        self.userRepository = userRepository
    }

    func signUp() async -> Bool {
         guard validateInputs() else { return false }

         isLoading = true
         defer { isLoading = false }

         do {
             // Returns the User object
             let user = try await authManager.signUp(email: email, password: password)
             try await userRepository.createUserProfile(userId: user.uid, email: email)
             return true
         } catch {
             handleError(error)
             return false
         }
     }

    private func validateInputs() -> Bool {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "All fields are required."
            return false
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return false
        }

        return true
    }

    private func handleError(_ error: Error) {
        errorMessage = "Sign-up failed: \(error.localizedDescription)"
    }
}
