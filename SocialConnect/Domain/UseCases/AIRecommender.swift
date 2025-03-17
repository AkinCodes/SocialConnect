import FirebaseRemoteConfigInternal

final class AIRecommender {
    
    static func sortPosts(_ posts: [Post]) -> [Post] {
        let sortedPosts = posts.sorted { postA, postB in
            let scoreA = aiScore(for: postA)
            let scoreB = aiScore(for: postB)
            return scoreA > scoreB
        }
        return sortedPosts
    }

    private static func aiScore(for post: Post) -> Double {
        let remoteConfig = RemoteConfig.remoteConfig()

        let likesWeight = remoteConfig["aiEngagementWeight"].numberValue.doubleValue
        let recencyWeight = remoteConfig["aiSortingWeight"].numberValue.doubleValue

        guard let createdAt = post.createdAt else {
            return Double(post.likes)
        }

        let hoursSincePosted = Date().timeIntervalSince(createdAt) / 3600

        let likesScore = likesWeight * Double(post.likes)
        let recencyScore = recencyWeight * (1 / (hoursSincePosted + 1))
        return likesScore + recencyScore
    }
}
