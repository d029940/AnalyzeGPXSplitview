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
    
    // Model
    var listOfGpxFiles = GarminGpxFiles.listOfGpxFiles

    // MARK: - Start up
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect delegates to tableview
        listOfGpxFilesTableView.delegate = self
        listOfGpxFilesTableView.dataSource = self
    }
    
    // MARK: - Methods
    
    func listGpxFiles(for url: URL) {
        listOfGpxFiles = GarminGpxFiles.listGpxFiles(for: url)
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
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = listOfGpxFilesTableView.selectedRow

        // find parent tabview controller
        guard let parentVC = self.parent as? NSTabViewController else {
            return
        }
        let tabView = parentVC.tabView
        let index = tabView.indexOfTabViewItem(withIdentifier: MainViewController.gpxContentTabIdentifier)
        if index == NSNotFound { return }
        let gpxContentTabViewItem = tabView.tabViewItem(at: index)
        guard let vc = gpxContentTabViewItem.viewController as? GpxContentViewController
            else { return }
        if vc.isViewLoaded == false {
            vc.loadView()
        }
        vc.fillTables(with: listOfGpxFiles[row])
        tabView.selectTabViewItem(at: index)
    }
}
