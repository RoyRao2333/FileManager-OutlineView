//
//  LoadingViewController.swift
//  FileManager-OutlineView
//
//  Created by Roy on 2021/7/15.
//

import Cocoa

class LoadingViewController: NSViewController {
    @IBOutlet weak var indicator: NSProgressIndicator!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        indicator.startAnimation(self)
    }
    
    override func viewDidDisappear() {
        indicator.stopAnimation(nil)
    }
}
