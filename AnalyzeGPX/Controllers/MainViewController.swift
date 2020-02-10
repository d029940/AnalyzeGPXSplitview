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
    
    // MARK:- Actions
    
    @IBAction func loadGarminDevicesButton(_ sender: NSButton) {
        guard let vc = gpxFilesVC else { return }
        vc.loadGarminDevices()
//        tabView.selectTabViewItem(at: index)
    }
    
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
            vc.fillTables(with: filename)
        }
    }
    
    @IBAction func exitButton(_ sender: NSButton) {
        NSApp.terminate(self)
    }
}

// MARK: - Extension: Constants
extension MainViewController {
    
    // Identifiers of storyboard are not to be translated
    static let splitViewSeque = "SplitView"
}
