//
//  DisplayItem.swift
//  FileManager-OutlineView
//
//  Created by Roy on 2021/7/12.
//

import Cocoa

class DisplayItem: Hashable {
    
    static func == (lhs: DisplayItem, rhs: DisplayItem) -> Bool {
        return lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
    
    var name: String
    var size: String
    var url: URL
    var icon: NSImage
    var isDirectory: Bool
    var children: [DisplayItem]
    
    init(
        name: String,
        size: String = "",
        url: URL,
        icon: NSImage = NSImage(),
        isDirectory: Bool = false,
        children: [DisplayItem] = []
    ) {
        self.name = name
        self.size = size
        self.url = url
        self.icon = icon
        self.isDirectory = isDirectory
        self.children = children
    }
}
