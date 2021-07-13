//
//  AppDelegate.swift
//  FileManager-OutlineView
//
//  Created by Roy on 2021/7/12.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var mainWindow: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        mainWindow = NSWindow(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: 500,
                height: 380
            ),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: true
        )
        mainWindow.contentViewController = ViewController(size: mainWindow.frame.size)
        mainWindow.center()
        
        CustomFileManager.shared.open()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

