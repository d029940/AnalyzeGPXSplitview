//
//  MainViewController.swift
//  AnalyzeGPX
//
//  Created by Manfred on 22.01.20.
//  Copyright © 2020 Manfred Kern. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    // MARK: - Links to the view / VC (of the storyboard)
    
    // Splitview controllers
    var gpxFilesVC: GpxFilesController?
    var gpxContentVC: GpxContentViewController?

    // MARK: Start up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destinationController
        
        // Get the VCs of the splitview items
        guard segue.identifier == MainViewController.splitViewSeque else { return }
        if let vc = destinationVC as? NSSplitViewController {
            let splitViewItems = vc.splitViewItems
            gpxFilesVC = splitViewItems.first?.viewController as? GpxFilesController
            gpxContentVC = splitViewItems.count > 1 ? splitViewItems[1].viewController as? GpxContentViewController : nil
        }
    }
    
    // MARK: - Actions
    
    /// Search GPX files in /Garmin/GPX places of attached volumes and shows them in the splitview
    /// - Parameter sender: Button in storyboard
    @IBAction func loadGarminDevicesButton(_ sender: NSButton) {
        guard let vc = gpxFilesVC else { return }
        vc.loadGarminDevices()
    }
    
    /// Presents an Open panel to the user to select a GPX file. The file will be parsed and
    /// the content is shown in tracks, routes & waypoints table views
    /// - Parameter sender: Button in storyboard
    @IBAction func openGpxButton(_ sender: NSButton) {
        
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
            guard let vc = gpxContentVC
                else { return }
            vc.fillGpxTables(with: filename)
        }
    }
    
    /// Forwards deletion request to Controller of the GpX-Outline-View
    /// - Parameter sender: Button in storyboard
    @IBAction func deleteGpxButton(_ sender: NSButton) {
        gpxFilesVC?.deleteGpxFile()
    }
    
    /// Exits the application
    /// - Parameter sender: Button in storyboard
    @IBAction func exitButton(_ sender: NSButton) {
        NSApp.terminate(self)
    }
}

// MARK: - Extension: Constants
extension MainViewController {
    
    // Identifier for sequeing to a split view (not to be translated)
    static let splitViewSeque = "SplitView"
}
