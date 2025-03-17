import Foundation

protocol FetchPaginatedPostsUseCase {
    func execute(limit: Int, cursor: String?) async throws -> PaginatedResponse<Post>
}

final class FetchPaginatedPostsUseCaseImpl: FetchPaginatedPostsUseCase {
    private let postRepository: PostRepository

    init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    func execute(limit: Int, cursor: String?) async throws -> PaginatedResponse<Post> {
        return try await postRepository.fetchPostsWithPagination(limit: limit, cursor: cursor)
    }
}

struct PaginatedResponse<T: Codable>: Codable {
    let data: [T]
    let nextCursor: String?
    let totalItems: Int
}
