import Foundation

enum APIEnvironment: String {
    case development = "https://dev.your-api.com/api"
    case staging = "http://127.0.0.1:3000/api"
    case production = "https://your-api.com/api"

    static let current: APIEnvironment = .staging 
}

struct Endpoints {
    
    static let baseURL = APIEnvironment.current.rawValue

    struct Auth {
        static let login = "\(baseURL)/auth/login"
        static let register = "\(baseURL)/auth/register"
        static let logout = "\(baseURL)/auth/logout"
        static let refreshToken = "\(baseURL)/auth/refresh"
    }

    struct User {
        static let profile = "\(baseURL)/user/profile"
        static let updateProfile = "\(baseURL)/user/update"
        
        static func userDetails(userId: String) -> String {
            return "\(baseURL)/user/\(userId)"
        }
        
        static func followUser(userId: String) -> String {
            return "\(baseURL)/user/\(userId)/follow"
        }
        
        static func userPosts(userId: String) -> String {
            return "\(baseURL)/user/\(userId)/posts"
        }
    }

    struct Posts {
        static let fetchPosts = "\(baseURL)/posts"
        static let createPost = "\(baseURL)/posts/create"
        static let trendingPosts = "\(baseURL)/posts/trending"
        static let likedPosts = "\(baseURL)/posts/liked"

        static func postDetails(postId: String) -> String {
            return "\(baseURL)/posts/\(postId)"
        }
        
        static func likePost(postId: String) -> String {
            return "\(baseURL)/posts/\(postId)/like"
        }
        
        static func deletePost(postId: String) -> String {
            return "\(baseURL)/posts/\(postId)"
        }
    }

    struct Notifications {
        static let fetchNotifications = "\(baseURL)/notifications"
        static let markAsRead = "\(baseURL)/notifications/read"
        
        static func notificationDetails(notificationId: String) -> String {
            return "\(baseURL)/notifications/\(notificationId)"
        }
    }

    // Push Notifications & Device Registration
    struct Push {
        static let registerDevice = "\(baseURL)/push/register"
        static let unregisterDevice = "\(baseURL)/push/unregister"
    }
}
