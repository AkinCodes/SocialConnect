import Foundation

enum ProfileSection {
    case main
}

enum ProfileItem: Hashable {
    case userInfo(name: String, bio: String, imageUrl: URL?)
    case post(media: Media)
}

extension ProfileItem: Equatable {
    static func == (lhs: ProfileItem, rhs: ProfileItem) -> Bool {
        switch (lhs, rhs) {
        case let (.userInfo(lhsName, lhsBio, lhsImageUrl), .userInfo(rhsName, rhsBio, rhsImageUrl)):
            return lhsName == rhsName && lhsBio == rhsBio && lhsImageUrl == rhsImageUrl
        case let (.post(lhsMedia), .post(rhsMedia)):
            return lhsMedia == rhsMedia
        default:
            return false
        }
    }
}
