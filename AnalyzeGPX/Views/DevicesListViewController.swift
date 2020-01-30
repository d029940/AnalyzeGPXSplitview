//
//  DevicesListViewController.swift
//  AnalyzeGPX
//
//  Created by Manfred on 30.01.20.
//  Copyright © 2020 Manfred Kern. All rights reserved.
//

import Cocoa

class DevicesListViewController: NSViewController {

    var listOfVolumes = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func loadGarminDevices() {
        self.listOfVolumes.removeAll()
        guard let listOfVol = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeLocalizedNameKey], options: [.skipHiddenVolumes]) else { return }

        // TODO: go on here
        for url in listOfVol {
            let nameOfDriveRes = try? url.resourceValues(forKeys: [.localizedNameKey])
            if let nameOfDrive = nameOfDriveRes?.localizedName {
                self.listOfVolumes[url.path] = nameOfDrive
            } else {
                self.listOfVolumes[url.path] = ""
            }
        }
        print(listOfVolumes)
    }
    
}
