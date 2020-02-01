//
//  DevicesListViewController.swift
//  AnalyzeGPX
//
//  Created by Manfred on 30.01.20.
//  Copyright © 2020 Manfred Kern. All rights reserved.
//

import Cocoa

class DevicesListViewController: NSViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var listOfDevicesTableView: NSTableView!
    
    // MARK: - Propertiey
    // Model
    var listOfVolumes = GarminGpxFiles.listOfVolumes
    
    // MARK: - Start up
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect delegates to tableview
        listOfDevicesTableView.delegate = self
        listOfDevicesTableView.dataSource = self
    }
    
    //MARK: - Methods
    
    /// Searches for all Garmin/GPX folder on all mounted volumes case-insensitively and add them to the device table view
    func loadGarminDevices() {
        
        let errors = GarminGpxFiles.loadGarminDevices(volumes: &listOfVolumes)
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
        
        // refresh table view
        listOfDevicesTableView.reloadData()
    }
}

// MARK:- Extensions for NSTableView

extension DevicesListViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let count: Int = listOfVolumes.count
        return count
    }
}

extension DevicesListViewController: NSTableViewDelegate  {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let col = tableColumn?.identifier.rawValue else { return nil }
        if col == "path" {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "path")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier,
                                                    owner: self) as? NSTableCellView else {
                                                        return nil
            }
            cellView.textField?.stringValue = listOfVolumes[row].path.absoluteString
            return cellView
        } else if col == "name" {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "name")
            guard let cellView = tableView.makeView(withIdentifier: cellIdentifier,
                                                    owner: self) as? NSTableCellView else {
                                                        return nil
            }
            cellView.textField?.stringValue = listOfVolumes[row].name
            return cellView
        } else {
            return nil
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = self.listOfDevicesTableView.selectedRow
        let url = listOfVolumes[row].path
        
        // find parent tabview controller
        guard let parentVC = self.parent as? NSTabViewController else {
            return
        }
        let tabView = parentVC.tabView
        let index = tabView.indexOfTabViewItem(withIdentifier: MainViewController.listOfGpxFilesIdentifier)
        if index == NSNotFound { return }
        guard let vc = tabView.tabViewItem(at: index).viewController
            as? ListOfGpxFilesController else { return }
        
        // populate "List GPX files" tabview with GPX files
        if !vc.isViewLoaded { vc.loadView() }
        vc.listGpxFiles(for: url)
        tabView.selectTabViewItem(at: index)
    }
}

