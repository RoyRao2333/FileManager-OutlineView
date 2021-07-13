//
//  ViewController.swift
//  FileManager-OutlineView
//
//  Created by Roy on 2021/7/12.
//

import Cocoa

class ViewController: NSViewController {
    private var outlineView: NSOutlineView!
    private var items: [DisplayItem] = []
    
    
    // MARK: Initializers
    
    init(size frameSize: NSSize) {
        super.init(nibName: nil, bundle: nil)
        
        outlineView = NSOutlineView()
        outlineView.allowsColumnResizing = true
        outlineView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        outlineView.delegate = self
        outlineView.dataSource = self
        let column1 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("FileNameColumn"))
        column1.headerCell.title = "FileName"
        column1.resizingMask = [.autoresizingMask]
        let column2 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("FileSizeColumn"))
        column2.headerCell.title = "FileSize"
        column2.resizingMask = [.autoresizingMask]
        let column3 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("FilePathColumn"))
        column3.headerCell.title = "FilePath"
        column3.resizingMask = [.autoresizingMask]
        outlineView.addTableColumn(column1)
        outlineView.addTableColumn(column2)
        outlineView.addTableColumn(column3)
        
        let scrollView = NSScrollView(frame: NSRect(origin: .zero, size: frameSize))
        scrollView.documentView = outlineView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        
        view = scrollView
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reload),
            name: .refresh,
            object: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: Private Mothods
extension ViewController {
    
    @objc func reload() {
        guard let url = CustomFileManager.shared.chosenURL else { return }
        
        do {
            let resource = try url.resourceValues(forKeys: [.nameKey, .pathKey])
            
            if
                let fileName = resource.name,
                let filePath = resource.path
            {
                let item = DisplayItem(
                    name: fileName,
                    size: "",
                    path: filePath,
                    icon: NSImage(systemSymbolName: "folder", accessibilityDescription: nil)!
                )
                items.append(item)
                
                loadDir(url, parent: item)
                outlineView.reloadData()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func loadDir(_ url: URL, parent: DisplayItem) {
        
        do {
            let resourceKeys : [URLResourceKey] = [.fileSizeKey, .nameKey, .pathKey, .isDirectoryKey]
            let enumerator = FileManager.default.enumerator(
                at: url,
                includingPropertiesForKeys: resourceKeys,
                options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants],
                errorHandler: { (url, error) -> Bool in
                    print("directoryEnumerator error at \(url): ", error)
                    return true
            })!

            for case let fileURL as URL in enumerator {
                let resource = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                
                if
                    let isDirectory = resource.isDirectory,
                    let fileName = resource.name,
                    let filePath = resource.path
                {
                    let fileSize = Int64(resource.fileSize ?? 0)
                    let item = DisplayItem(
                        name: fileName,
                        size: "",
                        path: filePath,
                        icon: NSImage()
                    )
                    
                    if isDirectory {
                        // Directory
                        item.size = ""
                        item.icon = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)!
                        
                        parent.children.append(item)
                        
                        loadDir(fileURL, parent: item)
                    } else {
                        // File
                        item.size = Units(fileSize).getReadableUnit()
                        item.icon = NSImage(systemSymbolName: "doc", accessibilityDescription: nil)!
                        
                        parent.children.append(item)
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    private func getPaths(_ url: URL) -> [String]? {
        do {
            return try FileManager.default.contentsOfDirectory(atPath: url.path)
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
}


extension ViewController: NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    // MARK: Delegate -
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard
            let colunmID = tableColumn?.identifier.rawValue,
            let item = item as? DisplayItem
        else { return nil }
        
        var text = ""
        var isFirstColumn = false
        
        switch colunmID {
        case "FileNameColumn":
            text = item.name
            isFirstColumn = true
            
        case "FileSizeColumn":
            text = item.size
            
        case "FilePathColumn":
            text = item.path
            
        default:
            break
        }
        
        let cell = ProgrammaticTableCellView()
        cell.identifier = NSUserInterfaceItemIdentifier("OutlineViewCell")
        cell.textField?.stringValue = text
        cell.imageView?.image = isFirstColumn ? item.icon : nil
        cell.autoresizingMask = [.width]
        
        return cell
    }
    

    // MARK: DataSource -
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            // Root
            return items[index]
        } else if let item = item as? DisplayItem {
            return item.children[index]
        }
        
        return NSNull()
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            // Root
            return items.count
        } else if let item = item as? DisplayItem {
            return item.children.count
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? DisplayItem {
            return !item.children.isEmpty
        }
        
        return false
    }
}
