import Foundation
import Security
import LocalAuthentication

final class KeychainService {
    static let shared = KeychainService()
    
    private init() {}

    // MARK: - Save Data to Keychain
    func save(_ data: String, for key: String, useBiometrics: Bool = false, syncAcrossDevices: Bool = false) throws {
        guard let data = data.data(using: .utf8) else { throw KeychainError.invalidData }
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
        ]
        
        if useBiometrics {
            guard let accessControl = SecAccessControlCreateWithFlags(
                nil,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                [.biometryAny, .devicePasscode],
                nil
            ) else {
                throw KeychainError.invalidAccessControl
            }
            query[kSecAttrAccessControl as String] = accessControl
        } else {
            query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
        }
        
        query[kSecAttrSynchronizable as String] = syncAcrossDevices ? kCFBooleanTrue : kCFBooleanFalse

        let existingQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        var existingItem: CFTypeRef?
        let status = SecItemCopyMatching(existingQuery as CFDictionary, &existingItem)
        
        if status == errSecSuccess {
            // 🔄 Update Existing Entry Instead of Deleting
            let updateQuery: [String: Any] = [kSecValueData as String: data]
            let updateStatus = SecItemUpdate(existingQuery as CFDictionary, updateQuery as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(updateStatus)
            }
        } else {
            let addStatus = SecItemAdd(query as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                print("🔴 Keychain Save Error: \(SecCopyErrorMessageString(addStatus, nil) ?? "Unknown Error" as CFString)")
                throw KeychainError.unexpectedStatus(addStatus)
            }
        }
    }


    // MARK: - Retrieve Data from Keychain
    func retrieve(for key: String, useBiometrics: Bool = false, reason: String? = nil) async throws -> String? {
        let context = LAContext()
        if useBiometrics, let reason = reason {
            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
                throw KeychainError.biometricNotAvailable
            }
            context.localizedReason = reason
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationContext as String: context
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess, let data = dataTypeRef as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Delete Data from Keychain
    func delete(_ key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: - Check Keychain Item Exists
    func exists(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        return SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess
    }

    // MARK: - Update Keychain Item
    func update(_ data: String, for key: String) throws {
        guard let updatedData = data.data(using: .utf8) else { throw KeychainError.invalidData }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: updatedData
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
    }

    // MARK: - Synchronization Check
    func isSynchronized(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrSynchronizable as String: kCFBooleanTrue!,
            kSecReturnData as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        return SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess
    }
}

// MARK: - Keychain Errors
enum KeychainError: Error, LocalizedError {
    case unexpectedStatus(OSStatus)
    case invalidAccessControl
    case biometricNotAvailable
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .unexpectedStatus(let status):
            return "Unexpected status code: \(status)"
        case .invalidAccessControl:
            return "Failed to create access control for Keychain."
        case .biometricNotAvailable:
            return "Biometric authentication is not available."
        case .invalidData:
            return "Invalid data format."
        }
    }
}
