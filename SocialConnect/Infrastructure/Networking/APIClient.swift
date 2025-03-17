import Foundation
import FirebaseAuth
import Combine
import CoreData

actor APIClient {
    static let shared = APIClient()
    private let session: URLSession
    private let baseURL: String
    private let retryLimit = 3

    init(session: URLSession = .shared) {
        self.session = session
        self.baseURL = APIEnvironment.current.rawValue
        print("🌍 APIClient initialized with baseURL: \(baseURL)") // Debugging Log
        print("🌍 API Base URL: \(baseURL)")

    }

    func fetch<T: Codable>(
        endpoint: String,
        method: String = "GET",
        headers: [String: String] = [:],
        body: Data? = nil
    ) async throws -> T {
        var request = try createRequest(endpoint: endpoint, method: method, headers: headers, body: body)

        if let token = try? await fetchAuthToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let responseData: Data = try await fetchWithRetry(request: request)
        return try JSONDecoder().decode(T.self, from: responseData)
    }

    func post<T: Decodable>(
        endpoint: String,
        headers: [String: String] = [:],
        body: [String: Any]
    ) async throws -> T {
        var request = try createRequest(
            endpoint: endpoint,
            method: "POST",
            headers: headers,
            body: try JSONSerialization.data(withJSONObject: body)
        )

        if let token = try? await fetchAuthToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let responseData: Data = try await fetchWithRetry(request: request)
        return try JSONDecoder().decode(T.self, from: responseData)
    }

    private func fetchWithRetry(request: URLRequest) async throws -> Data {
        var attempt = 0
        var lastError: Error?

        while attempt < retryLimit {
            do {
                let (data, response) = try await session.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw APIClientError.badResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
                }
                return data
            } catch {
                lastError = error
                attempt += 1
                try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt)) * 1_000_000_000))
            }
        }

        throw lastError ?? APIClientError.unknown
    }

    private func createRequest(endpoint: String, method: String, headers: [String: String], body: Data?) throws -> URLRequest {
        guard let url = URL(string: baseURL + endpoint) else { throw APIClientError.badURL }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }

    private func fetchAuthToken() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw APIClientError.unauthorized
        }
        return try await user.getIDToken()
    }
}

enum APIClientError: Error, LocalizedError {
    case badURL
    case badResponse(statusCode: Int)
    case decodingFailed
    case unauthorized
    case unknown

    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Invalid URL."
        case .badResponse(let statusCode):
            return "Bad response from server. Status code: \(statusCode)."
        case .decodingFailed:
            return "Failed to decode the response."
        case .unauthorized:
            return "User is not authenticated."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
