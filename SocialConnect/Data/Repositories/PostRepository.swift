import Foundation
import FirebaseFirestore
import Combine

protocol PostRepository {
    func fetchPostsWithPagination(limit: Int, cursor: String?) async throws -> PaginatedResponse<Post>
    func observeRealtimePosts() async -> AnyPublisher<[Post], Error>
}

final class PostRepositoryImpl: PostRepository {
    private let apiClient: APIClient
    private let firebaseDB = FirebaseDatabaseManager.shared

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func fetchPostsWithPagination(limit: Int, cursor: String?) async throws -> PaginatedResponse<Post> {
        
        let cacheKey = "paginated_posts_\(cursor ?? "first_page")"

        if let cachedResponse: PaginatedResponse<Post> = CacheManager.shared.get(cacheKey) {
            return cachedResponse
        }

        do {
            let posts = try await FirebaseDatabaseManager.shared.fetchPosts()

            if !posts.isEmpty {
                let paginatedResponse = PaginatedResponse(
                    data: posts,
                    nextCursor: nil,
                    totalItems: posts.count
                )

                CacheManager.shared.set(paginatedResponse, forKey: cacheKey)
                return paginatedResponse
            }
        } catch {
            print("❌ Firestore fetch failed: \(error.localizedDescription), falling back to API...")
        }

        let endpoint = "/posts?limit=\(limit)&cursor=\(cursor ?? "")"
        let response: PaginatedResponse<PostDTO> = try await apiClient.fetch(endpoint: endpoint)

        let transformedPosts = response.data.map { $0.toDomainModel() }

        let paginatedResponse = PaginatedResponse(
            data: transformedPosts,
            nextCursor: response.nextCursor,
            totalItems: response.totalItems
        )

        CacheManager.shared.set(paginatedResponse, forKey: cacheKey)

        return paginatedResponse
    }

    
    func observeRealtimePosts() async -> AnyPublisher<[Post], Error> {
        let cacheKey = "realtime_posts"

        return Future { promise in
            Task {
                do {
                    if let cachedPosts: [Post] = CacheManager.shared.get(cacheKey) {
                        promise(.success(cachedPosts))
                    }

                    let posts = try await self.fetchPostsWithPagination(limit: 10, cursor: nil)
                    CacheManager.shared.set(posts.data, forKey: cacheKey)

                    promise(.success(posts.data))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
