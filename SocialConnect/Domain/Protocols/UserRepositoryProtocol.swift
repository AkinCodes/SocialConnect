import Foundation

protocol UserRepositoryProtocol {
    func fetchUser(userId: String) async throws -> User
    func createUserProfile(userId: String, email: String) async throws
    func updateUserProfile(userId: String, name: String?, profileImageUrl: String?, bio: String?) async throws
    func logout() throws
}
