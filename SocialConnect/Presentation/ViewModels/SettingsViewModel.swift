import Foundation
import UIKit
import Combine
import FirebaseAuth

@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isDarkModeEnabled: Bool
    @Published var isNotificationsEnabled: Bool
    @Published var selectedLanguage: String
    @Published var errorMessage: String?
    @Published var settings: [SettingOption] = []

    // MARK: - Dependencies
    private let userDefaults = UserDefaults.standard
    private let authManager: AuthManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer
    init(authManager: AuthManager) {
        self.authManager = AuthManager.shared
        self.isDarkModeEnabled = userDefaults.bool(forKey: "isDarkModeEnabled")
        self.isNotificationsEnabled = userDefaults.bool(forKey: "isNotificationsEnabled")
        self.selectedLanguage = userDefaults.string(forKey: "selectedLanguage") ?? "English"
        loadSettings()
    }

    // MARK: - Public Methods

    func toggleDarkMode() {
        isDarkModeEnabled.toggle()
        userDefaults.set(isDarkModeEnabled, forKey: "isDarkModeEnabled")
    }

    func toggleNotifications() {
        isNotificationsEnabled.toggle()
        userDefaults.set(isNotificationsEnabled, forKey: "isNotificationsEnabled")
    }

    func updateLanguage(to language: String) {
        selectedLanguage = language
        userDefaults.set(language, forKey: "selectedLanguage")
    }

    func deleteAccount() async {
        do {
            try await authManager.deleteAccount()
        } catch {
            errorMessage = "Failed to delete account: \(error.localizedDescription)"
        }
    }

    private func loadSettings() {
        settings = [
            .editProfile(title: "Edit Profile"),
            .notifications(title: "Notifications"),
            .darkMode(title: "Dark Mode"),
            .language(title: "Language: \(selectedLanguage)"),
            .logout(title: "Logout"),
            .deleteAccount(title: "Delete Account")
        ]
    }

    func handleOptionSelection(_ option: SettingOption) async {
        switch option {
        case .editProfile:
            print("Navigate to Edit Profile")
        case .notifications:
            toggleNotifications()
        case .darkMode:
            toggleDarkMode()
        case .language:
            print("Navigate to Language Selection")
        case .logout:
            logout()
        case .deleteAccount:
            await deleteAccount()
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()

            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = scene.delegate as? SceneDelegate {
                sceneDelegate.appCoordinator?.handleLogout()
            } else {
                print("❌ Could not access SceneDelegate for logout.")
            }

        } catch {
            print("❌ Logout failed: \(error.localizedDescription)")
        }
    }

}

// MARK: - SettingOption Model
enum SettingOption: Hashable {
    case editProfile(title: String)
    case notifications(title: String)
    case darkMode(title: String)
    case language(title: String)
    case logout(title: String)
    case deleteAccount(title: String)
}
