import Foundation
import FirebaseFirestore

struct UserDTO: Codable {
    let id: String
    let name: String
    let email: String
    let profileImageUrl: String?
    let bio: String?

    func toDomainModel() -> User {
        return User(
            id: id,
            name: name,
            email: email,
            profileImageUrl: profileImageUrl,
            bio: bio
        )
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "email": email,
            "profileImageUrl": profileImageUrl,
            "bio": bio
        ].compactMapValues { $0 }
    }
}
