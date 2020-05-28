//
//  GpxFilesController.swift
//  AnalyzeGPX
//
//  Created by Manfred on 01.02.20.
//  Copyright © 2020 Manfred Kern. All rights reserved.
//

import Cocoa

class GpxFilesController: NSViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var listOfGpxFilesOutlineView: NSOutlineView!


    // MARK: - Start up
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Methods
    
    /// Searches for all Garmin/GPX folder on all mounted volumes case-insensitively and add them to treeview view
    func loadGarminDevices() {
        
        // Clear all table views of GpxContentViewController
        // --> Splitview Controller --> Mainview Controller
        guard let parentVC = self.parent?.parent as? MainViewController else { return }
        guard let vc = parentVC.gpxContentVC else { return }
        vc.clearTables()
        
        // collect devices/volumes which have GPX files in folder /Garmin/GPX
        let errors = GarminGpxFiles.loadGarminDevices()
        if errors.count > 0 {
            var errMsg = ""
            for error in errors {
                if !errMsg.isEmpty { errMsg.append("\n") }
                errMsg.append(error.localizedDescription)
            }
            let alert = NSAlert()
            alert.informativeText = errMsg
            alert.runModal()
            return
        }
        var index = 0
        
        // read GPX files for each volume/device
        while index < GarminGpxFiles.allGpxFiles.count {
            GarminGpxFiles.listGpxFiles(for: &GarminGpxFiles.allGpxFiles[index])
            index+=1
        }
        
        listOfGpxFilesOutlineView.reloadData()
    }

}

// MARK:- Extensions for NSOutlineView

extension GpxFilesController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            // Top level: list volumes (devices)
            return GarminGpxFiles.allGpxFiles.count
        }
        guard let item = item as? GarminGpxFiles.VolFileItem else { return 0}
        return item.files.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return GarminGpxFiles.allGpxFiles[index]
        } else {
            return (item as! GarminGpxFiles.VolFileItem).files[index]
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let item = item as? GarminGpxFiles.VolFileItem else {
            return false
        }
        return item.files.count > 0
    }
}

extension GpxFilesController: NSOutlineViewDelegate {
    
            
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?

        if tableColumn!.identifier.rawValue == "name" {
            view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "name"), owner: self) as? NSTableCellView
            if let textField = view?.textField {
                if let volume = item as? GarminGpxFiles.VolFileItem {
                    textField.stringValue = volume.name
                } else if let url = item as? URL {
                    textField.stringValue = url.lastPathComponent
                }
            }
        }
        if tableColumn!.identifier.rawValue == "path" {
            view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "path"), owner: self) as? NSTableCellView
            if let textField = view?.textField {
                if let volume = item as? GarminGpxFiles.VolFileItem {
                    textField.stringValue = volume.path.absoluteString
                } else if let url = item as? URL {
                    textField.stringValue = url.absoluteString
                }
            }
        }

      return view
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else {
            return
        }
        
        let item = outlineView.item(atRow: outlineView.selectedRow)
        if outlineView.isExpandable(item) {
            outlineView.expandItem(item)
        }
        
        guard let volFileItem = item as? GarminGpxFiles.VolFileItem  else { return }
        
        // --> Splitview Controller --> Mainview Controller
        guard let parentVC = self.parent?.parent as? MainViewController else { return }
        guard let vc = parentVC.gpxContentVC else { return }
        vc.fillTables(with: volFileItem.path)
    }
}
