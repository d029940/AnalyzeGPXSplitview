//
//  ListOfGpxFilesController.swift
//  AnalyzeGPX
//
//  Created by Manfred on 01.02.20.
//  Copyright © 2020 Manfred Kern. All rights reserved.
//

import Cocoa

class ListOfGpxFilesController: NSViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var listOfGpxFilesTableView: NSTableView!
    
    // MARK: - Propertiey
    // Table model
    var listOfGpxFiles = [URL]()

    // MARK: - Start up
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect delegates to tableview
        listOfGpxFilesTableView.delegate = self
        listOfGpxFilesTableView.dataSource = self
    }
    
    // MARK: - Methods
    
    func listGpxFiles(for url: URL) {
        listOfGpxFiles.removeAll()
        
        let fm = FileManager.default
        guard let gpxFiles = try? fm.contentsOfDirectory(at: url,
                                                         includingPropertiesForKeys: [.isRegularFileKey],
                                                         options: [.skipsHiddenFiles])
            else { return }
        listOfGpxFiles = gpxFiles.filter { ($0.pathExtension).lowercased() == "gpx"}
        listOfGpxFilesTableView.reloadData()
    }
    
}

// MARK:- Extensions for NSTableView

extension ListOfGpxFilesController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let count: Int = listOfGpxFiles.count
        return count
    }
}

extension ListOfGpxFilesController: NSTableViewDelegate  {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "cell")
        guard let cellView = tableView.makeView(withIdentifier: cellIdentifier,
                                                owner: self) as? NSTableCellView else {
                                                    return nil
        }
        cellView.textField?.stringValue = listOfGpxFiles[row].lastPathComponent
        return cellView
    }
    
    func ListOfGpxFiles(_ notification: Notification) {
        // TODO: Go on here
    }
}
