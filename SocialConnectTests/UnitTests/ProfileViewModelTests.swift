import XCTest
import FirebaseAuth
@testable import SocialConnect

@MainActor
final class ProfileViewModelTests: XCTestCase {
    private var sut: ProfileViewModel!
    private var authManager: AuthManager!
    private var mockUserRepository: MockUserRepository!

    override func setUp() async throws {
        try await super.setUp()
        authManager = AuthManager.shared
        mockUserRepository = MockUserRepository()
        sut = ProfileViewModel(authManager: authManager, userRepository: mockUserRepository)
    }

    override func tearDown() async throws {
        sut = nil
        authManager = nil
        mockUserRepository = nil
        try await super.tearDown()
    }

    func testFetchUserProfile_Success() async {
        let expectation = expectation(description: "User profile should be fetched successfully")

        mockUserRepository.mockUser = User(id: "123", name: "John Doe", email: "john@example.com", profileImageUrl: nil, bio: nil)

        let user = await sut.fetchUserProfile()

        XCTAssertNotNil(user, "User profile should be fetched")
        XCTAssertEqual(user?.name, "John Doe", "User name should match")
        XCTAssertEqual(user?.email, "john@example.com", "User email should match")

        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 2.0)
    }
}








//
//import XCTest
//
//final class SimpleTests: XCTestCase {
//    
//    func testArrayInitialization() {
//        // Initialize an empty array
//        let numbers: [Int] = []
//        
//        // Assert that the array is empty initially
//        XCTAssertTrue(numbers.isEmpty, "The array should be empty initially.")
//    }
//    
//    func testArrayAddingElements() {
//        // Initialize an empty array
//        var numbers: [Int] = []
//        
//        // Add elements to the array
//        numbers.append(1)
//        numbers.append(2)
//        
//        // Assert that the array has 2 elements now
//        XCTAssertEqual(numbers.count, 2, "The array should contain 2 elements after appending.")
//        
//        // Assert that the first element is 1
//        XCTAssertEqual(numbers[0], 1, "The first element in the array should be 1.")
//        
//        // Assert that the second element is 2
//        XCTAssertEqual(numbers[1], 2, "The second element in the array should be 2.")
//    }
//}
