import Foundation

final class CacheManager {
    // MARK: - Singleton Instance
    static let shared = CacheManager()

    // MARK: - Properties
    private let nsCache = NSCache<NSString, CachedItem>()
    private var cachedKeys = Set<NSString>()
    private let fileManager = FileManager.default
    private let diskCacheDirectory: URL
    private let cacheExpirationTime: TimeInterval = 60 * 30

    // MARK: - Initializer
    private init() {
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheDirectory = cacheDirectory.appendingPathComponent("AppCache", isDirectory: true)

        try? fileManager.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true)

        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            Task { await self.purgeExpiredCache() }
        }
    }

    // MARK: - Cache Operations

    // Save Data to Cache with Expiration
    func setData(_ data: Data, for key: String) {
        let nsKey = key as NSString
        let expirationDate = Date().addingTimeInterval(cacheExpirationTime)

        //  Save in-memory cache with expiration
        let cachedItem = CachedItem(data: data, expirationDate: expirationDate)
        nsCache.setObject(cachedItem, forKey: nsKey)
        cachedKeys.insert(nsKey)

        // Save to disk asynchronously
        DispatchQueue.global(qos: .background).async {
            let fileURL = self.diskCacheDirectory.appendingPathComponent(nsKey as String)
            let cacheItem = CacheItem(data: data, expirationDate: expirationDate)
            if let encodedData = try? JSONEncoder().encode(cacheItem) {
                try? encodedData.write(to: fileURL)
            }
        }
    }

    //Retrieve Data from Cache (Memory + Disk with Expiration Check)
    func getData(for key: String) -> Data? {
        let nsKey = key as NSString

        // Check in-memory cache first
        if let cachedItem = nsCache.object(forKey: nsKey), !cachedItem.isExpired {
            return cachedItem.data
        }

        // Check disk cache
        let fileURL = diskCacheDirectory.appendingPathComponent(nsKey as String)
        if let encodedData = try? Data(contentsOf: fileURL),
           let cachedItem = try? JSONDecoder().decode(CacheItem.self, from: encodedData),
           !cachedItem.isExpired {

            let newCachedItem = CachedItem(data: cachedItem.data, expirationDate: cachedItem.expirationDate)
            nsCache.setObject(newCachedItem, forKey: nsKey)
            cachedKeys.insert(nsKey)
            return cachedItem.data
        }

        return nil
    }

    func set<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            setData(data, for: key)
        }
    }

    func get<T: Codable>(_ key: String) -> T? {
        if let data = getData(for: key) {
            return try? JSONDecoder().decode(T.self, from: data)
        }
        return nil
    }

    func remove(forKey key: String) {
        let nsKey = key as NSString
        nsCache.removeObject(forKey: nsKey)
        cachedKeys.remove(nsKey)

        let fileURL = diskCacheDirectory.appendingPathComponent(nsKey as String)
        try? fileManager.removeItem(at: fileURL)
    }

    // MARK: - Expired Cache Management

    func purgeExpiredCache() async {
        for key in cachedKeys {
            if let cachedItem = nsCache.object(forKey: key), cachedItem.isExpired {
                nsCache.removeObject(forKey: key)
                cachedKeys.remove(key)
            }
        }

        let cachedFiles = (try? fileManager.contentsOfDirectory(at: diskCacheDirectory, includingPropertiesForKeys: nil)) ?? []
        for fileURL in cachedFiles {
            if let data = try? Data(contentsOf: fileURL),
               let cachedItem = try? JSONDecoder().decode(CacheItem.self, from: data),
               cachedItem.isExpired {
                try? fileManager.removeItem(at: fileURL)
            }
        }
    }
}

// MARK: - Supporting Classes

private final class CachedItem {
    let data: Data
    let expirationDate: Date

    var isExpired: Bool {
        return Date() > expirationDate
    }

    init(data: Data, expirationDate: Date) {
        self.data = data
        self.expirationDate = expirationDate
    }
}

private struct CacheItem: Codable {
    let data: Data
    let expirationDate: Date

    var isExpired: Bool {
        return Date() > expirationDate
    }
}
