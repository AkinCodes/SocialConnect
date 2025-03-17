import XCTest
@testable import SocialConnect

@MainActor
final class SignUpViewModelTests: XCTestCase {
    private var sut: SignUpViewModel!
    private var mockUserRepository: MockUserRepository!

    override func setUp() {
        super.setUp()
        mockUserRepository = MockUserRepository()
        sut = SignUpViewModel(userRepository: mockUserRepository)
    }

    override func tearDown() {
        sut = nil
        mockUserRepository = nil
        super.tearDown()
    }

    func testSignUp_FailsWithEmptyFields() async {
        sut.email = ""
        sut.password = ""
        sut.confirmPassword = ""

        let result = await sut.signUp()
        XCTAssertFalse(result, "Sign-up should fail due to empty fields")
    }

    func testSignUp_FailsWithMismatchedPasswords() async {
        sut.email = "test@email.com"
        sut.password = "password123"
        sut.confirmPassword = "differentPassword"

        let result = await sut.signUp()
        XCTAssertFalse(result, "Sign-up should fail due to mismatched passwords")
    }
}



