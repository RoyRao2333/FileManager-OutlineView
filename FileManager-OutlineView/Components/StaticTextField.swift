//
//  StaticTextField.swift
//  FileManager-OutlineView
//
//  Created by Roy on 2021/7/13.
//

import Cocoa

class StaticTextField: NSTextField {
    
    override func textShouldBeginEditing(_ textObject: NSText) -> Bool {
        return false
    }
}
