import Foundation

class RecentFilesManager {
    static let shared = RecentFilesManager()

    private let maxRecentFiles = 10
    private let userDefaultsKey = "recentVideoFiles"

    var recentFiles: [URL] {
        get {
            guard let bookmarks = UserDefaults.standard.array(forKey: userDefaultsKey) as? [Data] else {
                return []
            }

            return bookmarks.compactMap { data in
                var isStale = false
                return try? URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            }
        }
        set {
            let bookmarks = newValue.compactMap { url -> Data? in
                try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            }
            UserDefaults.standard.set(Array(bookmarks.prefix(maxRecentFiles)), forKey: userDefaultsKey)
        }
    }

    func addRecentFile(_ url: URL) {
        var files = recentFiles.filter { $0 != url }
        files.insert(url, at: 0)
        recentFiles = Array(files.prefix(maxRecentFiles))
    }

    func removeRecentFile(_ url: URL) {
        recentFiles = recentFiles.filter { $0 != url }
    }

    func clearRecentFiles() {
        recentFiles = []
    }
}
