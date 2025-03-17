import XCTest
@testable import SocialConnect

@MainActor
final class HomeViewModelTests: XCTestCase {
    private var sut: HomeViewModel!
    private var mockPostRepository: MockPostRepository!
    private var mockFetchPaginatedPostsUseCase: MockFetchPaginatedPostsUseCase!

    override func setUp() {
        super.setUp()
        mockPostRepository = MockPostRepository()
        mockFetchPaginatedPostsUseCase = MockFetchPaginatedPostsUseCase()
        sut = HomeViewModel(fetchPaginatedPostsUseCase: mockFetchPaginatedPostsUseCase, postRepository: mockPostRepository)
    }

    override func tearDown() {
        sut = nil
        mockPostRepository = nil
        mockFetchPaginatedPostsUseCase = nil
        super.tearDown()
    }

    func testFetchPosts_Success() async {
        let expectation = expectation(description: "Fetch posts successfully")

        mockFetchPaginatedPostsUseCase.mockPosts = [
            Post(id: "1", content: "Post 1", userId: "user123", likes: 5),
            Post(id: "2", content: "Post 2", userId: "user123", likes: 10)
        ]

        await sut.fetch()
        XCTAssertEqual(sut.state.posts.count, 2, "Should load 2 posts")

        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 2.0)
    }
}
