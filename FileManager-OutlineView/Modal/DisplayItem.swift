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
    var path: String
    var icon: NSImage
    var children: [DisplayItem]
    
    init(
        name: String,
        size: String,
        path: String,
        icon: NSImage,
        children: [DisplayItem] = []
    ) {
        self.name = name
        self.size = size
        self.path = path
        self.icon = icon
        self.children = children
    }
}
