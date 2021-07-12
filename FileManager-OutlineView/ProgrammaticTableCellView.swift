//
//  ProgrammaticTableCellView.swift
//  FileManager-OutlineView
//
//  Created by Roy on 2021/7/12.
//

import Cocoa

class ProgrammaticTableCellView: NSTableCellView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        self.autoresizingMask = .width
        let iv: NSImageView = NSImageView(frame: NSMakeRect(0, 6, 16, 16))
        let tf: NSTextField = NSTextField(frame: NSMakeRect(21, 6, 200, 14))
        iv.imageScaling = .scaleProportionallyUpOrDown
        iv.imageAlignment = .alignCenter
        tf.isBordered = false
        tf.drawsBackground = false

        self.imageView = iv
        self.textField = tf
        self.addSubview(iv)
        self.addSubview(tf)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var button: NSButton {
        get {
            return self.subviews[2] as! NSButton
        }
    }
}
