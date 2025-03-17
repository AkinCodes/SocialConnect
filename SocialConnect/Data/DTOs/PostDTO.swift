import Foundation
import FirebaseFirestore

struct PostDTO: Codable {
    @DocumentID var id: String?
    let content: String
    let userId: String
    var likes: Int
    var title: String?
    var imageUrl: String?
    var description: String? 
    
    var createdAt: Timestamp?


    enum CodingKeys: String, CodingKey {
        case id
        case content
        case userId
        case likes
        case title
        case imageUrl
        case description
        
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        userId = try container.decode(String.self, forKey: .userId)
        likes = try container.decode(Int.self, forKey: .likes)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        createdAt = try container.decodeIfPresent(Timestamp.self, forKey: .createdAt)
        

    }

    func toDomainModel() -> Post {
        return Post(
            id: id ?? UUID().uuidString, // Default to a UUID if the ID is missing
            content: content,
            userId: userId,
            likes: likes,
            optionalTitle: title, // Map `title` to `optionalTitle`
            optionalImageUrl: imageUrl, // Map `imageUrl` to `optionalImageUrl`
            optionalDescription: description, // Map `description` to `optionalDescription`
            
            createdAt: createdAt?.dateValue()

        )
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": id ?? UUID().uuidString,
            "content": content,
            "userId": userId,
            "likes": likes,
            "title": title ?? "",
            "imageUrl": imageUrl ?? "",
            "description": description ?? "No description available",
            "createdAt": createdAt ?? Timestamp(date: Date())

        ]
    }
}
