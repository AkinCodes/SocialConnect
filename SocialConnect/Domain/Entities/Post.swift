import Foundation
import FirebaseFirestore

struct Post: Codable, Identifiable, Hashable, MediaRepresentable {
    var id: String
    let content: String
    let userId: String
    var likes: Int
    var optionalTitle: String?
    var optionalImageUrl: String?
    var optionalDescription: String?
    
    var createdAt: Date?


    var title: String { optionalTitle ?? "Untitled" }
    var description: String { optionalDescription ?? "No description available" }
    var thumbnailUrl: String { optionalImageUrl ?? "" }

    enum CodingKeys: String, CodingKey {
        case id, content, userId, likes
        case optionalTitle = "title"
        case optionalImageUrl = "imageUrl"
        case optionalDescription = "description"
        
        case createdAt = "createdAt"

    }
    
        init(
            id: String,
            content: String,
            userId: String,
            likes: Int,
            optionalTitle: String? = nil,
            optionalImageUrl: String? = nil,
            optionalDescription: String? = nil,
            
            createdAt: Date? = nil

        ) {
            self.id = id
            self.content = content
            self.userId = userId
            self.likes = likes
            self.optionalTitle = optionalTitle
            self.optionalImageUrl = optionalImageUrl
            self.optionalDescription = optionalDescription
            
            self.createdAt = createdAt

        }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        userId = try container.decode(String.self, forKey: .userId)
        likes = try container.decode(Int.self, forKey: .likes)
        optionalTitle = try container.decodeIfPresent(String.self, forKey: .optionalTitle)
        optionalImageUrl = try container.decodeIfPresent(String.self, forKey: .optionalImageUrl)
        optionalDescription = try container.decodeIfPresent(String.self, forKey: .optionalDescription)
        
        if let timestamp = try container.decodeIfPresent(Timestamp.self, forKey: .createdAt) {
            createdAt = timestamp.dateValue()
        } else {
            createdAt = nil
        }
    }

    static func fromFirestore(document: QueryDocumentSnapshot) -> Post? {
        let data = document.data()

        guard let content = data["content"] as? String,
              let userId = data["userId"] as? String,
              let likes = data["likes"] as? Int else { return nil }
                
             let createdAt: Date?
             if let timestamp = data["createdAt"] as? Timestamp {
                 createdAt = timestamp.dateValue()
             } else {
                 createdAt = nil
             }


        return Post(
            id: document.documentID,
            content: content,
            userId: userId,
            likes: likes,
            optionalTitle: data["title"] as? String,
            optionalImageUrl: data["imageUrl"] as? String,
            optionalDescription: data["description"] as? String,
            
            createdAt: createdAt

        )
    }
}



extension Post {
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "content": content,
            "userId": userId,
            "likes": likes,
            "title": optionalTitle ?? "",
            "imageUrl": optionalImageUrl ?? "",
            "description": optionalDescription ?? "No description available",
            
            
            "createdAt": createdAt ?? Timestamp(date: Date())

        ]
    }
}
