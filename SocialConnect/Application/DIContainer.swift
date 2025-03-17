import Foundation

@MainActor
final class DIContainer {
    static let shared = DIContainer()

    let apiClient: APIClient
    let authManager: AuthManager
    let userRepository: UserRepository
    let postRepository: PostRepositoryImpl
    let fetchPaginatedPostsUseCase: FetchPaginatedPostsUseCase

    private init() {
        self.apiClient = APIClient()
        self.authManager = AuthManager.shared
        self.userRepository = UserRepository(apiClient: apiClient)
        self.postRepository = PostRepositoryImpl(apiClient: apiClient)
        self.fetchPaginatedPostsUseCase = FetchPaginatedPostsUseCaseImpl(postRepository: postRepository)
    }


    func resolve<T>() -> T {
        if T.self == PostRepository.self {
            return postRepository as! T
        } else if T.self == FetchPaginatedPostsUseCase.self {
            return fetchPaginatedPostsUseCase as! T
        } else {
            fatalError("Dependency not found for type: \(T.self)")
        }
    }

}

