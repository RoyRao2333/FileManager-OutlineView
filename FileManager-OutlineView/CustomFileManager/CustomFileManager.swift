//
//  CustomFileManager.swift
//  FileManager-OutlineView
//
//  Created by Roy on 2021/7/12.
//

import Foundation

class CustomFileManager {
    static let shared = CustomFileManager()
    private let manager = FileManager.default
    
    
    // Hide Initializer
    private init() {}
}


extension CustomFileManager {
    
    func open(_ filePath: String) {
        let url = URL(fileURLWithPath: filePath)
    }
}
