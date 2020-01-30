//
//  DevicesListViewController.swift
//  AnalyzeGPX
//
//  Created by Manfred on 30.01.20.
//  Copyright © 2020 Manfred Kern. All rights reserved.
//

import Cocoa

class DevicesListViewController: NSViewController {
    
    // MARK:- Outlets
    
    @IBOutlet weak var xlistOfDevicesTableView: NSTableView!
    @IBOutlet weak var listOfDevicesTableView: NSTableView!
    // Table model
    typealias VolumeEntry = (path: String, name: String)
    var listOfVolumes = [VolumeEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect delegates to tableview
        listOfDevicesTableView.delegate = self
        listOfDevicesTableView.dataSource = self
    }
    
    func loadGarminDevices() {
        self.listOfVolumes.removeAll()
        guard let listOfVol = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeLocalizedNameKey], options: [.skipHiddenVolumes]) else { return }

        for url in listOfVol {
            let nameOfDriveRes = try? url.resourceValues(forKeys: [.localizedNameKey])
            let volEntry: VolumeEntry
            volEntry.path = url.path
            if let nameOfDrive = nameOfDriveRes?.localizedName {
                volEntry.name = nameOfDrive
            } else {
                volEntry.name = ""
            }
            self.listOfVolumes.append(volEntry)
        }
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
            cellView.textField?.stringValue = listOfVolumes[row].path
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
    
}

