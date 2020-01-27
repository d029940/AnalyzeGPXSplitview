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
            let index = tabView.indexOfTabViewItem(withIdentifier: "GPX Content")
            if index == NSNotFound { return }
            let gpxContentTabViewItem = tabView.tabViewItem(at: index)
            guard let vc = gpxContentTabViewItem.viewController as? GpxContentViewController
                else { return }
            vc.loadView() // In case view has never been loaded
            if vc.fillTables(with: filename) == true {
                tabView.selectTabViewItem(at: index)
            }
        }
    }
    
    @IBAction func exitButton(_ sender: NSButton) {
        NSApp.terminate(self)
    }
}
