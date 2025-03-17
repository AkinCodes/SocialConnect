import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var profileItems: [ProfileItem] = []

    // MARK: - Dependencies
    private let authManager: AuthManager
    private let userRepository: UserRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer
    init(authManager: AuthManager, userRepository: UserRepositoryProtocol = UserRepository(apiClient: APIClient.shared)) {
        self.authManager = authManager
        self.userRepository = userRepository
        observeAuthChanges()
    }

    // MARK: - Fetch User Profile
    func fetchUserProfile() async -> User? {
        print("🔥 fetchUserProfile() CALLED") // Debug log

        guard let currentUser = authManager.currentUser else {
            errorMessage = "No authenticated user found."
            print("❌ No authenticated user found.")
            return nil
        }

        print("🔍 Checking Firestore for user with ID: \(currentUser.uid)")

        isLoading = true
        defer { isLoading = false }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)

        // ✅ First, force fetch from Firestore server (avoid stale cache)
        do {
            let document = try await userRef.getDocument(source: .server)
            if document.exists {
                print("✅ Retrieved latest user data from Firestore:", document.data() ?? "No Data")
            } else {
                print("❌ No user document found on the server")
            }
        } catch {
            print("❌ Error fetching user document from server:", error.localizedDescription)
        }


        do {
            let docSnapshot = try await userRef.getDocument()
            if docSnapshot.exists {
                // ✅ User exists: Fetch data
                let fetchedUser = try await userRepository.fetchUser(userId: currentUser.uid)
                print("✅ User found in Firestore:", fetchedUser)

                user = fetchedUser
            } else {
                print("❌ User not found in Firestore. Creating profile...")

                // ✅ Create new profile only if it doesn’t exist
                let newUser = User(
                    id: currentUser.uid,
                    name: currentUser.displayName ?? "New User",
                    email: currentUser.email ?? "user email",
                    profileImageUrl: currentUser.photoURL?.absoluteString,
                    bio: "Software Developer" // 🔥 Default bio
                )

                try await userRef.setData(newUser.toDictionary())
                print("✅ New user profile created in Firestore!")

                user = newUser
            }
        } catch {
            print("❌ Failed to fetch user profile:", error.localizedDescription)
            handleError(error)
            return nil
        }

        let profileImageUrl = user?.profileImageUrl.flatMap { URL(string: $0) }

        let bio = user?.bio
        let finalBio = (bio?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) ? bio! : "Software Developer"

        let userInfo = ProfileItem.userInfo(
            name: user?.name ?? "Unknown",
            bio: finalBio,
            imageUrl: profileImageUrl
        )

        await MainActor.run {
            self.profileItems = [userInfo]
        }

        return user
    }


    // MARK: - Logout User
    func logout() {
        do {
            try authManager.signOut()
            user = nil
            profileItems.removeAll()
            try KeychainService.shared.delete("authToken")
        } catch {
            errorMessage = "Failed to logout: \(error.localizedDescription)"
        }
    }

    // MARK: - Observe Authentication Changes
    private func observeAuthChanges() {
        authManager.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentUser in
                Task {
                    if currentUser != nil {
                        await self?.fetchUserProfile()
                    } else {
                        self?.user = nil
                        self?.profileItems.removeAll()
                    }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Error Handling
    private func handleError(_ error: Error) {
        errorMessage = "Something went wrong. Please try again later."
        print("Error: \(error.localizedDescription)")
    }
}
