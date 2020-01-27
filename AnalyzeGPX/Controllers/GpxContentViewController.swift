//
//  ViewController.swift
//  AnalyzeGPX
//
//  Created by Manfred on 07.01.20.
//  Copyright © 2020 Manfred Kern. All rights reserved.
//

import Cocoa

class GpxContentViewController: NSViewController {

    // MARK:- Model
    var garminGpx: GarminGpx?
    
    // MARK:- Outlets
    @IBOutlet weak var routesTableView: NSTableView!
    @IBOutlet weak var waypointsTableView: NSTableView!
    @IBOutlet weak var tracksTableView: NSTableView!
    
    // MARK:- local variables
    
    // TDOD: Localize
    private var tracksColumnText: String = ""
    private var routesColumnText: String = ""
    private var waypointsColumnText: String = ""
    
    // MARK:- Startup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get title from columns stored in the nib
        // Needs to be set before func numberOfRows will be called
        tracksColumnText = tracksTableView.tableColumns[0].title
        routesColumnText = routesTableView.tableColumns[0].title
        waypointsColumnText = waypointsTableView.tableColumns[0].title
        
        // Connect delegates to tableview
        tracksTableView.delegate = self
        tracksTableView.dataSource = self
        routesTableView.delegate = self
        routesTableView.dataSource = self
        waypointsTableView.delegate = self
        waypointsTableView.dataSource = self
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

// MARK:- Extensions for NSTableView

extension GpxContentViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        // There is only one column in the table
        let column = tableView.tableColumns[0]
        if tableView == tracksTableView {
            let count = garminGpx?.tracks.count ?? 0
                if count == 0 {
                    column.title = tracksColumnText
                } else {
                    column.title = "\(tracksColumnText) (\(count))"
                }
            return count
        }
        if tableView == routesTableView {
            let count = garminGpx?.routes.count ?? 0
            if count == 0 {
                column.title = routesColumnText
            } else {
                column.title = "\(routesColumnText) (\(count))"
            }
            return count
        }
        if tableView == waypointsTableView {
            let count = garminGpx?.waypoints.count ?? 0
            if count == 0 {
                column.title = waypointsColumnText
            } else {
                column.title = "\(waypointsColumnText) (\(count))"
            }
            return count
        }
        return 0
    }
}

extension GpxContentViewController: NSTableViewDelegate  {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let element: String
        guard let garminGpx = garminGpx else { return nil }
        if tableView == tracksTableView {
            element = garminGpx.tracks[row]
        } else if tableView == routesTableView {
            element = garminGpx.routes[row]
        } else if tableView == waypointsTableView {
            element = garminGpx.waypoints[row]
        } else {
            return nil
        }
        
        let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "cell")
        guard let cellView = tableView.makeView(withIdentifier: cellIdentifier,
                                                owner: self) as? NSTableCellView else {
            return nil
        }
        cellView.textField?.stringValue = element
        return cellView
    }
}


