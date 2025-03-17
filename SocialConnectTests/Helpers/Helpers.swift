@testable import SocialConnect
import Foundation
import Combine

class MockUserRepository: UserRepositoryProtocol {
    var mockUser: SocialConnect.User?
    var shouldReturnError = false

    func fetchUser(userId: String) async throws -> SocialConnect.User {
        if shouldReturnError {
            throw NSError(domain: "UserRepositoryError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch user"])
        }
        guard let user = mockUser else {
            throw NSError(domain: "UserRepositoryError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        return user
    }

    func createUserProfile(userId: String, email: String) async throws {
        if shouldReturnError {
            throw NSError(domain: "UserRepositoryError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to create user profile"])
        }
        mockUser = User(id: userId, name: "", email: email, profileImageUrl: nil, bio: nil)
    }

    func updateUserProfile(userId: String, name: String?, profileImageUrl: String?, bio: String?) async throws {
        if shouldReturnError {
            throw NSError(domain: "UserRepositoryError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to update user profile"])
        }

        guard var user = mockUser, user.id == userId else {
            throw NSError(domain: "UserRepositoryError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }

        user = User(
            id: userId,
            name: name ?? user.name,
            email: user.email,
            profileImageUrl: profileImageUrl ?? user.profileImageUrl,
            bio: bio ?? user.bio
        )
        mockUser = user
    }

    func deleteUser(userId: String) async throws {
        if shouldReturnError {
            throw NSError(domain: "UserRepositoryError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to delete user"])
        }
        mockUser = nil
    }

    func logout() throws {
        if shouldReturnError {
            throw NSError(domain: "UserRepositoryError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to log out"])
        }
        mockUser = nil
    }
}



class MockPostRepository: PostRepository {
    private let postsSubject = PassthroughSubject<[Post], Never>()

    func fetchPostsWithPagination(limit: Int, cursor: String?) async throws -> PaginatedResponse<Post> {
        if shouldReturnError {
            throw NSError(domain: "PostRepositoryError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch posts"])
        }

        let startIndex = cursor.flatMap { id in mockPosts.firstIndex { $0.id == id } } ?? 0
        let endIndex = min(startIndex + limit, mockPosts.count)
        
        let paginatedData = Array(mockPosts[startIndex..<endIndex])
        let nextCursor = (endIndex < mockPosts.count) ? mockPosts[endIndex].id : nil
        
        return PaginatedResponse(data: paginatedData, nextCursor: nextCursor, totalItems: mockPosts.count)
    }

    

    func observeRealtimePosts() async -> AnyPublisher<[Post], any Error> {
        return postsSubject
            .mapError { _ in NSError(domain: "PostRepositoryError", code: 500, userInfo: nil) as Error }
            .eraseToAnyPublisher()
    }


    // Call this whenever you want to simulate a new post being added
    func addPostForRealtimeUpdate(_ post: Post) {
        mockPosts.append(post)
        postsSubject.send(mockPosts)
    }

    
    var mockPosts: [Post] = []
    var shouldReturnError = false

    func fetchPosts() async throws -> [Post] {
        if shouldReturnError {
            throw NSError(domain: "PostRepositoryError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch posts"])
        }
        return mockPosts
    }

    func createPost(content: String, userId: String) async throws -> Post {
        if shouldReturnError {
            throw NSError(domain: "PostRepositoryError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to create post"])
        }
        let newPost = Post(id: UUID().uuidString, content: content, userId: userId, likes: 0)
        mockPosts.append(newPost)
        return newPost
    }

    func deletePost(postId: String) async throws {
        if shouldReturnError {
            throw NSError(domain: "PostRepositoryError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to delete post"])
        }
        mockPosts.removeAll { $0.id == postId }
    }
}



class MockFetchPaginatedPostsUseCase: FetchPaginatedPostsUseCase {  // ✅ Now fully conforms to FetchPaginatedPostsUseCase
    var mockPosts: [Post] = []
    var shouldReturnError = false

    func execute(limit: Int, cursor: String?) async throws -> SocialConnect.PaginatedResponse<SocialConnect.Post> {
        if shouldReturnError {
            throw NSError(domain: "PaginationError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch paginated posts"])
        }
        
        let paginatedPosts = Array(mockPosts.prefix(limit)) // ✅ Fetch correct data slice
        
        return SocialConnect.PaginatedResponse(
            data: paginatedPosts,         // ✅ Provide required `data` parameter
            nextCursor: cursor,           // ✅ Keep `nextCursor` as is
            totalItems: mockPosts.count   // ✅ Provide `totalItems`
        )
    }

    func fetchPaginatedPosts(page: Int, limit: Int) async throws -> [Post] {
        if shouldReturnError {
            throw NSError(domain: "PaginationError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch paginated posts"])
        }
        let startIndex = (page - 1) * limit
        let endIndex = min(startIndex + limit, mockPosts.count)
        return Array(mockPosts[startIndex..<endIndex])
    }
}




