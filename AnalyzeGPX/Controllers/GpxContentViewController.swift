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
    let garminGpx = GarminGpx()
    
    // MARK:- Outlets
    @IBOutlet weak var routesTableView: NSTableView!
    @IBOutlet weak var waypointsTableView: NSTableView!
    @IBOutlet weak var tracksTableView: NSTableView!
    
    @IBOutlet var tableMenu: NSMenu!
    
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
    
    // MARK:- Methods
    
    @discardableResult
    func fillTables(with filename: URL) -> Bool {
        
        // clear current table view contents
        garminGpx.resetModel()
        
        do {
            try garminGpx.parse(gpxFile: filename)
        } catch GarminGpx.ParseErrors.badFilename {
            // TDOD: Alert
            print("Failed to open gpx file")
            return false
        } catch {
            // TDOD: Alert
            print("Unknown error")
        }
        
        // if table (trk, rte, wpt) are empty, just return this to caller
        if garminGpx.tracks.count == 0 &&
            garminGpx.routes.count == 0 &&
            garminGpx.waypoints.count == 0  {
            return false
        }
        refreshView()
        return true
    }
    
    func refreshView() {
        tracksTableView.reloadData()
        routesTableView.reloadData()
        waypointsTableView.reloadData()
    }
}

// MARK:- Extensions for NSTableView

extension GpxContentViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        // There is only one column in the table
        let column = tableView.tableColumns[0]
        if tableView == tracksTableView {
            let count = garminGpx.tracks.count
                if count == 0 {
                    column.title = tracksColumnText
                } else {
                    column.title = "\(tracksColumnText) (\(count))"
                }
            return count
        }
        if tableView == routesTableView {
            let count = garminGpx.routes.count
            if count == 0 {
                column.title = routesColumnText
            } else {
                column.title = "\(routesColumnText) (\(count))"
            }
            return count
        }
        if tableView == waypointsTableView {
            let count = garminGpx.waypoints.count
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


