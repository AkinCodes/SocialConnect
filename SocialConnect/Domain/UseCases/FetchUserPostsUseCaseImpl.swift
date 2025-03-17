import Foundation

protocol FetchUserPostsUseCase {
    func execute(userId: String) async throws -> [Post]
}

struct FetchUserPostsUseCaseImpl: FetchUserPostsUseCase {
    private let postRepository: PostRepository

    init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }
    
    func execute(userId: String) async throws -> [Post] {
        let response = try await postRepository.fetchPostsWithPagination(limit: 10, cursor: nil)
        return response.data
    }
}

