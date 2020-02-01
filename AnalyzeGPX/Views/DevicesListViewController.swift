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
    // Table model
    typealias VolumeEntry = (path: String, name: String)
    var listOfVolumes = [VolumeEntry]()
    
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
        self.listOfVolumes.removeAll()
        
        let fm = FileManager.default
        guard let listOfVol = fm.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeLocalizedNameKey], options: [.skipHiddenVolumes]) else { return }

        // Search all mounted volumes
        for url in listOfVol {
            let nameOfDriveRes = try? url.resourceValues(forKeys: [.localizedNameKey])
            var volEntry: VolumeEntry
            // volEntry.path = url.path
            if let nameOfDrive = nameOfDriveRes?.localizedName {
                volEntry.name = nameOfDrive
            } else {
                volEntry.name = ""
            }
            // Find Garmin folder on mounted volume
            var topLevelDirs = [URL]()
            do {
                try
                topLevelDirs = fm.contentsOfDirectory(at: url,
                                                      includingPropertiesForKeys: [.isDirectoryKey],
                                                      options: [.skipsHiddenFiles])
            } catch let error as NSError {
                let alert = NSAlert(error: error)
                alert.runModal()
                continue
            }
            
            var garminVolumes = [URL]()
            for dir in topLevelDirs {
                if dir.lastPathComponent.lowercased() == "garmin" {
                    garminVolumes.append(dir)
                }
            }
            if garminVolumes.isEmpty { continue }
            
            // Find GPX folder in Garmin folder
            for garmin in garminVolumes {
                guard let gpxFolders = try? fm.contentsOfDirectory(at: garmin,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]) else {
                    continue
                }
                // Is there a GPX folder
                for dir in gpxFolders {
                    if dir.lastPathComponent.lowercased() == "gpx" {
                        volEntry.path = dir.absoluteString
                        self.listOfVolumes.append(volEntry)
                    }
                }
            }
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
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = self.listOfDevicesTableView.selectedRow
        let url = URL(fileURLWithPath: listOfVolumes[row].path)
        // TODO: Go on here
    }
}

