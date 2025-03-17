import Foundation
import FirebaseFirestore
import FirebaseAuth

final class UserRepository: UserRepositoryProtocol {
    private let db = Firestore.firestore()
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func authenticate(username: String, password: String) async throws -> Bool {
        let result = try await Auth.auth().signIn(withEmail: username, password: password)
        return result.user.uid.isEmpty == false
    }


    func registerUser(email: String, password: String, name: String) async throws {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = authResult.user

        let userDTO = UserDTO(
            id: user.uid,
            name: name,
            email: email,
            profileImageUrl: nil,
            bio: nil
        )

        try await db.collection("users").document(user.uid).setData(userDTO.toDictionary())
    }

    func fetchUser(userId: String) async throws -> User {
        let docRef = db.collection("users").document(userId)
        let snapshot = try await docRef.getDocument()

        guard let userDTO = try? snapshot.data(as: UserDTO.self) else {
            throw NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }

        return userDTO.toDomainModel()
    }

    func fetchUserFromAPI(userId: String) async throws -> User {
        let url = URL(string: "https://your-api.com/users/\(userId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let userDTO = try JSONDecoder().decode(UserDTO.self, from: data)
        return userDTO.toDomainModel()
    }
    
    func updateUserProfile(userId: String, name: String?, profileImageUrl: String?, bio: String?) async throws {
        var updates: [String: Any] = [:]
        let userRef = db.collection("users").document(userId)

        let document = try await userRef.getDocument()
        guard document.exists, let existingData = document.data() else {
            return
        }

        if let name = name, !name.isEmpty {
            updates["name"] = name
        } else if let existingName = existingData["name"] as? String {
            updates["name"] = existingName
        }

        if let bio = bio, !bio.isEmpty {
            updates["bio"] = bio
        } else if let existingBio = existingData["bio"] as? String {
            updates["bio"] = existingBio
        }

        if let profileImageUrl = profileImageUrl, !profileImageUrl.isEmpty {
            updates["profileImageUrl"] = profileImageUrl
        } else if let existingProfileImage = existingData["profileImageUrl"] as? String {
            updates["profileImageUrl"] = existingProfileImage
        } else {
            updates["profileImageUrl"] = "https://picsum.photos/200/300?random=8"
        }

        guard !updates.isEmpty else { return }

        try await userRef.updateData(updates)
    }

    func logout() throws {
        try Auth.auth().signOut()
    }
}

extension UserRepository {
    func createUserProfile(userId: String, email: String) async throws {
        let userDTO = [
            "userId": userId,
            "email": email
        ] as [String: Any]

        try await db.collection("users").document(userId).setData(userDTO)
    }
}

