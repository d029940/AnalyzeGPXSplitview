//
//  MainViewController.swift
//  AnalyzeGPX
//
//  Created by Manfred on 22.01.20.
//  Copyright © 2020 Manfred Kern. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    var tabView: NSTabView!
    
    // MARK:- Model
    let garminGpx = GarminGpx()
    
    // MARK: Start up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destinationController
        guard segue.identifier == "Embed TabView" else { return }
        if let tabVC = destinationVC as? NSTabViewController {
            tabView = tabVC.tabView
        }
    }
    
    // MARK:- Actions
    
    @IBAction func loadGarminDevicesButton(_ sender: NSButton) {
    }
    
    @IBAction func openGpxButton(_ sender: NSButton) {
        
        // clear current table view contents
        garminGpx.resetModel()
        
        let openPanel = NSOpenPanel()
        openPanel.title = "Open Garmin GPX"
        openPanel.message = "Open Garmin gpx file"
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["gpx", "GPX"]
        if openPanel.runModal() == .OK {
            guard let filename = openPanel.urls.first else {
                // TDOD: Alert
                print("Failed to open gpx file")
                return
            }
            
            do {
                try garminGpx.parse(gpxFile: filename)
            } catch GarminGpx.ParseErrors.badFilename {
                // TDOD: Alert
                print("Failed to open gpx file")
                return
            } catch {
                // TDOD: Alert
                print("Unknown error")
            }
            
            // if any table (trk, rte, wpt) is not empty switch to GPX content tab
            if garminGpx.tracks.count > 0 ||
                garminGpx.routes.count > 0 ||
                garminGpx.waypoints.count > 0  {
                
                let index = tabView.indexOfTabViewItem(withIdentifier: "GPX Content")
                if index != NSNotFound {
                    let gpxContentItem = tabView.tabViewItem(at: index)

                    tabView.selectTabViewItem(at: index)
                    if let vc = gpxContentItem.viewController as? GpxContentViewController {
                        vc.garminGpx = garminGpx
                        vc.tracksTableView.reloadData()
                        vc.routesTableView.reloadData()
                        vc.waypointsTableView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func exitButton(_ sender: NSButton) {
        NSApp.terminate(self)
    }
}
