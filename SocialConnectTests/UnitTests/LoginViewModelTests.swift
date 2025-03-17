import XCTest
@testable import SocialConnect

@MainActor
final class LoginViewModelTests: XCTestCase {
    private var sut: LoginViewModel!

    override func setUp() async throws {
        try await super.setUp()
        sut = LoginViewModel(authManager: AuthManager.shared)
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    func testLogin_Failure_InvalidCredentials() async {
        let expectation = expectation(description: "Login should fail with invalid credentials")


        let success = await sut.login()
        XCTAssertFalse(success, "Login should fail with incorrect credentials")

        expectation.fulfill()
        await fulfillment(of: [expectation], timeout: 2.0)
    }
}

