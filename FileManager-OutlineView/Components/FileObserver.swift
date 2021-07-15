//
//  FileObserver.swift
//  FileManager-OutlineView
//
//  Created by Roy on 2021/7/15.
//

import Foundation

class FileObserver: NSObject, NSFilePresenter {
    var fileURL: URL
    var operationQueue: OperationQueue
    
    var presentedItemURL: URL? {
        return fileURL
        
    }
    var presentedItemOperationQueue: OperationQueue {
        return operationQueue
    }
    
    
    init(_ url: URL, queue: OperationQueue) {
        fileURL = url
        operationQueue = queue
        
        super.init()
        
        NSFileCoordinator.addFilePresenter(self)
    }
    
    deinit {
        NSFileCoordinator.removeFilePresenter(self)
    }
    
    func presentedSubitemDidChange(at url: URL) {
        NotificationCenter.default.post(name: .fileDidChange, object: nil)
    }
}
