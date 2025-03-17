import FirebaseFirestore
import FirebaseRemoteConfigInternal
import Foundation

final class FirebaseDatabaseManager {
    static let shared = FirebaseDatabaseManager()
    private let db = Firestore.firestore()
    private let remoteConfig = RemoteConfig.remoteConfig()


    private init() {}

    func savePost(_ post: Post) async throws {
        let postRef = db.collection("posts").document(post.id)
        try await postRef.setData(post.toDictionary())
    }

    func fetchPosts() async throws -> [Post] {
        let snapshot = try await db.collection("posts")
            .order(by: "createdAt", descending: true)
            .getDocuments()

        var posts = snapshot.documents.compactMap { Post.fromFirestore(document: $0) }

        let uniquePosts = Array(Set(posts))

        let feedSortingType = remoteConfig["feedSortingType"].stringValue

        switch feedSortingType {
            case "engagement":
                posts.sort { $0.likes > $1.likes }
            case "ai":
                posts = AIRecommender.sortPosts(uniquePosts)
            default:
                break
        }

        return posts
    }

    
    func fetchUser(userId: String) async throws -> User {
        let docRef = db.collection("users").document(userId)
        let snapshot = try await docRef.getDocument()
        
        guard let userDTO = try? snapshot.data(as: UserDTO.self) else {
            throw NSError(domain: "FirestoreError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        return userDTO.toDomainModel()
    }
    
    func updateUserProfile(userId: String, name: String?, profileImageUrl: String?, bio: String?) async throws {
        var updates: [String: Any] = [:]
        if let name = name { updates["name"] = name }
        if let profileImageUrl = profileImageUrl { updates["profileImageUrl"] = profileImageUrl }
        if let bio = bio { updates["bio"] = bio }
        
        let docRef = db.collection("users").document(userId)
        try await docRef.updateData(updates)
    }
}
