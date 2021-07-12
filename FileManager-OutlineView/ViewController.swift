//
//  ViewController.swift
//  FileManager-OutlineView
//
//  Created by Roy on 2021/7/12.
//

import Cocoa

class ViewController: NSViewController {
    private var outlineView: NSOutlineView!
    
    
    // MARK: Initializers
    
    init(frame frameRect: NSRect) {
        super.init(nibName: nil, bundle: nil)
        
        let view = NSView(frame: frameRect)
        self.view = view
        
        outlineView = NSOutlineView(frame: view.bounds)
        outlineView.delegate = self
        outlineView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension ViewController: NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    
}

