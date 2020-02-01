//
//  MainViewController.swift
//  AnalyzeGPX
//
//  Created by Manfred on 22.01.20.
//  Copyright © 2020 Manfred Kern. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    // MARK: - Links to the view (of the storyboard)
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
        let index = tabView.indexOfTabViewItem(withIdentifier: MainViewController.devicesTabIdentifer)
        if index == NSNotFound { return }
        let devicesTabViewItem = tabView.tabViewItem(at: index)
        guard let vc = devicesTabViewItem.viewController as? DevicesListViewController else { return }
        if vc.isViewLoaded == false {
            vc.loadView()
        }
        vc.loadGarminDevices()
        tabView.selectTabViewItem(at: index)
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
            let index = tabView.indexOfTabViewItem(withIdentifier: MainViewController.gpxContentTabIdentifier)
            if index == NSNotFound { return }
            let gpxContentTabViewItem = tabView.tabViewItem(at: index)
            guard let vc = gpxContentTabViewItem.viewController as? GpxContentViewController
                else { return }
            if vc.isViewLoaded == false {
                vc.loadView()
            }
            vc.fillTables(with: filename)
            tabView.selectTabViewItem(at: index)
        }
    }
    
    @IBAction func exitButton(_ sender: NSButton) {
        NSApp.terminate(self)
    }
}

// MARK: - Extension: Constants
extension MainViewController {
    
    // Identifiers of storyboard are not to be translated
    static let devicesTabIdentifer = "Devices"
    static let gpxContentTabIdentifier = "GPX Content"
    static let listOfGpxFilesIdentifier = "List GPX files"
}
