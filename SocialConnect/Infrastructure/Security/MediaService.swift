import Foundation

class MediaService {
    private let cacheManager = CacheManager.shared

    func fetchMedia() async throws -> [Media] {
        if let cachedMedia: [Media] = cacheManager.get("media_cache") {
            return cachedMedia
        }

        let response: [Media] = try await APIClient.shared.fetch(endpoint: Endpoints.Posts.fetchPosts)
        cacheManager.set(response, forKey: "media_cache")
        return response
    }

    func updateFavoriteStatus(mediaId: String, isFavorite: Bool) async throws -> Media {
        CacheManager.shared.set(isFavorite, forKey: "favorite_\(mediaId)")

        let updatedMedia: Media = try await APIClient.shared.post(
            endpoint: Endpoints.Posts.likePost(postId: mediaId),
            body: ["isFavorite": isFavorite]
        )
        return updatedMedia
    }

    func fetchMediaDetails(mediaId: String) async throws -> Media {
        if let cachedMedia: Media = cacheManager.get("media_\(mediaId)") {
            return cachedMedia
        }

        let response: Media = try await APIClient.shared.fetch(endpoint: Endpoints.Posts.postDetails(postId: mediaId))
        cacheManager.set(response, forKey: "media_\(mediaId)")
        return response
    }
}

struct Media: Codable, Identifiable, Equatable, Hashable, MediaRepresentable {
    let id: String
    let title: String
    let url: String
    let thumbnailUrl: String
    let description: String

    var imageUrl: String {
        thumbnailUrl
    }
}

extension Media {
    var isFavorite: Bool {
        return CacheManager.shared.get("favorite_\(id)") ?? false
    }
}
