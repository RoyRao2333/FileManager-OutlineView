//
//  CustomFileManager.swift
//  FileManager-OutlineView
//
//  Created by Roy on 2021/7/12.
//

import Cocoa

class CustomFileManager {
    static let shared = CustomFileManager()
    private let manager = FileManager.default
    
    var chosenURL: URL? {
        didSet {
            NotificationCenter.default.post(name: .refresh, object: nil)
        }
    }
    
    
    // Hide Initializer
    private init() {}
}


// MARK: Public Methods -
extension CustomFileManager {
    
    func open() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.begin { [unowned self] response in
            if response == .OK {
                if let url = openPanel.url {
                    chosenURL = url
                }
            }
        }
    }
}


extension Notification.Name {
    static let refresh = Notification.Name("RefreshName")
    static let removeRow = NSNotification.Name("RemoveRow")
}
