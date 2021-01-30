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
    
    // MARK: - Properties stored for convenience
    var gpxContentVC: GpxContentViewController?
    
    // MARK: - Start up
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let parentVC = self.parent?.parent as? MainViewController else { return }
        gpxContentVC = parentVC.gpxContentVC
    }
    
    // MARK: - Methods
    
    /// Searches for all Garmin/GPX folder on all mounted volumes case-insensitively and add them to treeview view
    func loadGarminDevices() {
        
        // First Clear all table views of the GpxContentViewController
        guard let vc = gpxContentVC else { return }
        vc.clearTables()
        
        // collect devices/volumes which have GPX files in folder /Garmin/GPX
        // error domain: "NSCocoaErrorDomain" - code: 257 (NSFileReadNoPermissionError)
        // at least for Time Machine Volume
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
            // Go on - only print error messages, because there might be still gpx-files to show
        }
        var index = 0
        
        // read GPX files for each volume/device
        while index < GarminGpxFiles.allGpxFiles.count {
            GarminGpxFiles.listGpxFiles(for: &GarminGpxFiles.allGpxFiles[index])
            index+=1
        }
        
        listOfGpxFilesOutlineView.reloadData()
    }
    
    /// Forwards delete request to model and updates outline view
    func deleteGpxFile() {
        
        // Check if anything is selected at all?
        let index = listOfGpxFilesOutlineView.selectedRow
        if index == -1 {
            return
        }
        // Forwad deletion to model
        guard let item = listOfGpxFilesOutlineView.item(atRow: index) as? GarminGpxFiles.VolFileItem
        else {
            return
        }
        
        let alert = NSAlert()
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "OK")
        alert.messageText = "Do you really want to delete?"
        let response = alert.runModal()
        if response != NSApplication.ModalResponse.alertSecondButtonReturn {
            // OK has not been pressed
            return
        }
        
        do {
            try GarminGpxFiles.deleteGpxFile(path: item.path)
        } catch let error as NSError {
            let alert = NSAlert()
            alert.informativeText = error.localizedDescription
            alert.runModal()
        }
        
        // Reload model (needs display)
        listOfGpxFilesOutlineView.reloadData()
        // Clear all table views of the GpxContentViewController
        guard let vc = gpxContentVC else { return }
        vc.clearTables()
    }

}

// MARK: - Extensions for NSOutlineView

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
            // swiftlint:disable force_cast
            return (item as! GarminGpxFiles.VolFileItem).files[index]
            // swiftlint:enable force_cast
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
