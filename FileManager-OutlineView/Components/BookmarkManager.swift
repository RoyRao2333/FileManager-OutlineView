//
//  BookmarkManager.swift
//
//  Created by Roy Rao on 2021/4/26.
//

import Cocoa

class BookmarkManager {
    
    static let shared = BookmarkManager()
    
    /**
     Save bookmark for URL.
     */
    func saveBookmark(for url: URL) {

        guard let bookmarkDic = self.getBookmarkData(url: url),
              let bookmarkURL = getBookmarkURL()
        else {
            print("Error getting data or bookmarkURL")
            return
        }

        do {
            let data = try NSKeyedArchiver.archivedData(
                withRootObject: bookmarkDic,
                requiringSecureCoding: false
            )
            try data.write(to: bookmarkURL)
            print("Did save data to url")
        } catch {
            print("Couldn't save bookmarks")
        }
    }

    /**
     Load bookmarks.
    */
    func loadBookmarks() {

        guard let url = self.getBookmarkURL() else { return }

        if self.fileExists(url) {
            do {
                let fileData = try Data(contentsOf: url)
                if let fileBookmarks = try
                    NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as! [URL: Data]? {
                    for bookmark in fileBookmarks {
                        self.restoreBookmark(key: bookmark.key, value: bookmark.value)
                    }
                }
            } catch {
                print ("Couldn't load bookmarks")
            }
        }
    }

    private func restoreBookmark(key: URL, value: Data) {
        let restoredUrl: URL?
        var isStale = false

        print ("Restoring \(key)")
        do {
            restoredUrl = try URL(
                resolvingBookmarkData: value,
                options: NSURL.BookmarkResolutionOptions.withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
        } catch {
            print ("Error restoring bookmarks")
            restoredUrl = nil
        }

        if let url = restoredUrl {
            if isStale {
                print ("URL is stale")
            } else {
                if !url.startAccessingSecurityScopedResource() {
                    print ("Couldn't access: \(url.path)")
                }
            }
        }
    }
    
    private func getBookmarkData(url: URL) -> [URL: Data]? {
        let data = try? url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        
        if let data = data {
            return [url: data]
        }
        
        return nil
    }

    private func getBookmarkURL() -> URL? {
        let urls = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )
        
        if let appSupportURL = urls.last {
            let url = appSupportURL.appendingPathComponent("Bookmarks.dict")
            return url
        }
        
        return nil
    }

    private func fileExists(_ url: URL) -> Bool {
        var isDir = ObjCBool(false)
        let exists = FileManager.default.fileExists(
            atPath: url.path,
            isDirectory: &isDir
        )

        return exists
    }

}
