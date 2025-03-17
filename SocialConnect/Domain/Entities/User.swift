import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let email: String
    let profileImageUrl: String?
    let bio: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email, profileImageUrl, bio
    }
    
    init(id: String?, name: String, email: String, profileImageUrl: String?, bio: String?) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.bio = bio 
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decodeIfPresent(String.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .name)
        self.email = try values.decode(String.self, forKey: .email)
        self.profileImageUrl = try values.decodeIfPresent(String.self, forKey: .profileImageUrl)
        self.bio = try values.decodeIfPresent(String.self, forKey: .bio)
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "email": email,
            "profileImageUrl": profileImageUrl ?? "",
            "bio": bio ?? ""
        ]
    }
}

