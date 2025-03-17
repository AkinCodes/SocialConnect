import Foundation

@MainActor
class DeepLinkHandler {
    static let shared = DeepLinkHandler()
    
    private init() {}

    func handle(url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }

        let path = urlComponents.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let parameters = urlComponents.queryItems?.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        } ?? [:]

        DispatchQueue.main.async {
            if let coordinator = AppCoordinator.shared {
                coordinator.routeDeepLink(path: path, parameters: parameters)
            } else {
                print("❌ AppCoordinator is nil, cannot handle deep link!")
            }
        }
    }
}
