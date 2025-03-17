import BackgroundTasks
import UIKit

final class BackgroundFetchManager {
    static let shared = BackgroundFetchManager()
    
    private init() {}

    func registerBackgroundFetch() {
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.socialconnect.fetch", using: nil) { task in
                self.handleBackgroundFetch(task: task as? BGAppRefreshTask)
            }
        }
    }

    func scheduleNextFetch() {
        if #available(iOS 13.0, *) {
            let request = BGAppRefreshTaskRequest(identifier: "com.socialconnect.fetch")
            request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)

            do {
                try BGTaskScheduler.shared.submit(request)
                print("📅 Scheduled next background fetch.")
            } catch {
                print("❌ Failed to schedule background fetch: \(error.localizedDescription)")
            }
        } else {
            // Legacy Support for iOS 12 and earlier
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        }
    }

    // Handle background fetch (iOS 13+)**
    private func handleBackgroundFetch(task: BGAppRefreshTask?) {
        Task {
            do {
                let newPosts = try await fetchNewPosts()
                print("📡 Fetched \(newPosts.count) new posts in background.")

                scheduleNextFetch()
                task?.setTaskCompleted(success: true)
            } catch {
                print("❌ Background fetch failed: \(error.localizedDescription)")
                task?.setTaskCompleted(success: false)
            }
        }
    }

    // ✅ Handle background fetch for iOS 12 and earlier
    func performLegacyFetch(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        Task {
            do {
                let posts = try await fetchNewPosts()
                print("📡 Legacy fetch completed with \(posts.count) new posts.")
                completion(.newData)
            } catch {
                print("❌ Legacy fetch failed: \(error.localizedDescription)")
                completion(.failed)
            }
        }
    }

    // Example function to simulate post fetching
    func fetchNewPosts() async throws -> [String] {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // Simulate delay
        return ["Post 1", "Post 2", "Post 3"]
    }
}

