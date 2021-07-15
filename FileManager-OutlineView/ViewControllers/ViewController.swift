//
//  ViewController.swift
//  FileManager-OutlineView
//
//  Created by Roy on 2021/7/12.
//

import Cocoa

class ViewController: NSViewController {
    private var fileObserver: FileObserver!
    private var outlineView: NSOutlineView!
    private var contextMenu: NSMenu!
    private var items: [DisplayItem] = []
    private var indices: IndexSet!
    
    
    // MARK: Initializers
    
    init(size frameSize: NSSize) {
        super.init(nibName: nil, bundle: nil)
        
        contextMenu = NSMenu(title: "Context")
        contextMenu.delegate = self
        
        outlineView = NSOutlineView()
        outlineView.allowsColumnResizing = true
        outlineView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        outlineView.autosaveName = .init("OutlineViewAutosaveName")
        outlineView.autosaveExpandedItems = true
        outlineView.delegate = self
        outlineView.dataSource = self
        let column1 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("FileNameColumn"))
        column1.headerCell.title = "FileName"
        let column2 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("FileSizeColumn"))
        column2.headerCell.title = "FileSize"
        let column3 = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("FilePathColumn"))
        column3.headerCell.title = "FilePath"
        outlineView.addTableColumn(column1)
        outlineView.addTableColumn(column2)
        outlineView.addTableColumn(column3)
        outlineView.menu = contextMenu
        
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
        
        // Add File Change Observation
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reload),
            name: .fileDidChange,
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
        
        fileObserver = FileObserver(url, queue: .main)
        
        items.removeAll()
        
        do {
            let resource = try url.resourceValues(forKeys: [.nameKey, .pathKey])
            let rootSize = try FileManager.default.allocatedSizeOfDirectory(at: url)
            
            if let fileName = resource.name {
                let item = DisplayItem(
                    name: fileName,
                    size: Units(rootSize).getReadableUnit(),
                    url: url,
                    icon: NSImage(systemSymbolName: "folder", accessibilityDescription: nil)!,
                    isDirectory: true
                )
                items.append(item)
                
                reloadDataKeepingSelection()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc private func move2Trash() {
        var urls: [URL] = []
        
        indices.forEach {
            guard let url = (outlineView.item(atRow: $0) as? DisplayItem)?.url else { return }
            
            urls.append(url)
        }
        
        NSWorkspace.shared.recycle(urls) { _, error in
            if let error = error { print(error.localizedDescription) }
        }
    
        reload()
    }
    
    private func loadDirWith(_ parent: DisplayItem) {
        
        do {
            let resourceKeys : [URLResourceKey] = [
                .fileSizeKey,
                .nameKey,
                .pathKey,
                .isDirectoryKey
            ]
            
            let enumerator = FileManager.default.enumerator(
                at: parent.url,
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
                    let fileName = resource.name
                {
                    let fileSize = UInt64(resource.fileSize ?? 0)
                    let item = DisplayItem(
                        name: fileName,
                        url: fileURL
                    )
                    
                    if isDirectory {
                        // Directory
                        do {
                            let folderSize = try FileManager.default.allocatedSizeOfDirectory(at: fileURL)
                            item.size = Units(folderSize).getReadableUnit()
                        } catch {
                            item.size = ""
                            print(error.localizedDescription)
                        }
                        item.icon = NSImage(systemSymbolName: "folder", accessibilityDescription: nil)!
                        item.isDirectory = true
                        
                        parent.children.append(item)
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
    
    private func reloadDataKeepingSelection() {
        let selectedRowIndexes = outlineView.selectedRowIndexes
        outlineView.reloadData()
        outlineView.selectRowIndexes(selectedRowIndexes, byExtendingSelection: false)
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
            text = item.url.path
            
        default:
            break
        }
        
        let cell = ProgrammaticTableCellView()
        cell.identifier = NSUserInterfaceItemIdentifier("OutlineViewCell")
        cell.imageView?.image = isFirstColumn ? item.icon : nil
        cell.textField?.stringValue = text
        
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
        // Invoke When Expand
        if item == nil {
            // Root
            return items.count
        } else if let item = item as? DisplayItem {
            if item.children.isEmpty {
                // Fetch Subitems
                loadDirWith(item)
            }
            
            return item.children.count
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let item = item as? DisplayItem {
            return item.isDirectory
        }
        
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
        guard
            let managedObjectID = (object as? NSManagedObject)?.objectID
        else { return nil }
        
        return managedObjectID.uriRepresentation().absoluteString
    }
}


// MARK: Menu Delegate
extension ViewController: NSMenuDelegate {
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        indices = outlineView.contextMenuRowIndexes
        menu.removeAllItems()
        
        let deleteItem = NSMenuItem(
            title: "Move To Trash",
            action: #selector(move2Trash),
            keyEquivalent: ""
        )
        
        menu.addItem(deleteItem)
    }
}


extension NSTableView {

    var contextMenuRowIndexes: IndexSet {
        var indexes = selectedRowIndexes

        // The blue selection box should always reflect the returned row indexes.
        if clickedRow >= 0
            && (selectedRowIndexes.isEmpty || !selectedRowIndexes.contains(clickedRow)) {
            indexes = [clickedRow]
        }

        return indexes
    }
}
