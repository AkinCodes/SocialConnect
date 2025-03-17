import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    private let fetchPaginatedPostsUseCase: FetchPaginatedPostsUseCase
    private let postRepository: PostRepository
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var posts: [Post] = []
    @Published private(set) var errorMessage: String?
    @Published var isLoading = false
    @Published var hasNextPage = true
    private var nextCursor: String?
    
    @Published private(set) var state = HomeViewState()


    init(fetchPaginatedPostsUseCase: FetchPaginatedPostsUseCase, postRepository: PostRepository) {
        self.fetchPaginatedPostsUseCase = fetchPaginatedPostsUseCase
        self.postRepository = postRepository
    }
    
    func fetch() async {
        guard !state.isLoading, state.hasNextPage else { return }

        if state.isInitialLoad {
            state.isLoading = true
        }

        defer {
            state.isLoading = false
            state.isInitialLoad = false
        }

        let cacheKey = "paginated_posts_\(nextCursor ?? "first_page")"

        if let cachedResponse: PaginatedResponse<Post> = CacheManager.shared.get(cacheKey) {
            print("✅ Loaded posts from cache")
            state.posts.append(contentsOf: cachedResponse.data)
            nextCursor = cachedResponse.nextCursor
            state.hasNextPage = state.posts.count < cachedResponse.totalItems
            return
        }

        do {
            let result = try await fetchPaginatedPostsUseCase.execute(limit: 10, cursor: nextCursor)

            if result.data.isEmpty {
                state.hasNextPage = false
                return
            }

            state.posts.append(contentsOf: result.data)
            nextCursor = result.nextCursor
            state.hasNextPage = state.posts.count < result.totalItems

            CacheManager.shared.set(result, forKey: cacheKey)

        } catch {
            print("❌ Error fetching posts: \(error.localizedDescription)")
        }
    }

    func observeRealtimePosts() {
        Task {
            let cacheKey = "realtime_posts"

            if let cachedPosts: [Post] = CacheManager.shared.get(cacheKey) {
                print("✅ Loaded real-time posts from cache")
                DispatchQueue.main.async {
                    self.posts = cachedPosts
                }
            }

            let publisher = await postRepository.observeRealtimePosts()
            publisher
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Failed to load posts: \(error.localizedDescription)"
                    }
                }, receiveValue: { [weak self] newPosts in
                    self?.posts = newPosts
                    CacheManager.shared.set(newPosts, forKey: cacheKey)
                })
                .store(in: &cancellables)
        }
    }

    private func handleError(_ error: Error) {
        errorMessage = "An error occurred: \(error.localizedDescription)"
        hasNextPage = false
    }
}


struct HomeViewState {
    var posts: [Post] = []
    var isLoading: Bool = false
    var isInitialLoad: Bool = true
    var hasNextPage: Bool = true
}
