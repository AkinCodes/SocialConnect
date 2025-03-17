import Foundation

@MainActor
final class EditProfileViewModel {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func updateProfile() async throws {
        // Simulated profile update logic
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1-second delay
    }
}
