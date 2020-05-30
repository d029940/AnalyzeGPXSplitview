//
//  GarminGpxFiles.swift
//  AnalyzeGPX
//
//  Created by Manfred on 01.02.20.
//  Copyright © 2020 Manfred Kern. All rights reserved.
//

import Foundation

class GarminGpxFiles{
        
    /// Item of a tree node
    struct VolFileItem {
        var name: String   // Name of volume or file
        var path: URL      // full path
        var files: [VolFileItem]   // GPX files - for the level of volumes = 0
    }
    typealias AllGpxFiles = [VolFileItem]
    static var allGpxFiles = [VolFileItem]()
    
    // MARK: - Methods
    
    /// List all GPX files for a given item and add them to its files property
    /// - Parameter item: to look for GPX files and return them in the files property
    static func listGpxFiles(for item: inout VolFileItem) {
        item.files.removeAll()
        
        let fm = FileManager.default
        guard let gpxFiles = try? fm.contentsOfDirectory(at: item.path,
                                                         includingPropertiesForKeys: [.isRegularFileKey],
                                                         options: [.skipsHiddenFiles])
            else { return }
        
        for file in gpxFiles.filter({ ($0.pathExtension).lowercased() == "gpx"}) {
            item.files.append(VolFileItem(name: file.lastPathComponent,
                                          path: file,
                                          files: []))
        }
    }
    
    /// Searches for "Garmin/GPX" folder on all mounted volumes case-insensitively and add them to property "allGpxFiles"
    /// - seealso:: allGpxFiles
    /// - returns: A list of errors occur during reading the directories

    static func loadGarminDevices() -> [NSError] {
        var errors = [NSError]()
        allGpxFiles.removeAll()
        errors.removeAll()
        
        let fm = FileManager.default
        guard let listOfVol = fm.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeLocalizedNameKey], options: [.skipHiddenVolumes]) else { return errors }

        // Search all mounted volumes
        for url in listOfVol {
            let nameOfDriveRes = try? url.resourceValues(forKeys: [.localizedNameKey])
            var name: String = ""
            if let nameOfDrive = nameOfDriveRes?.localizedName { name = nameOfDrive }
                
            // Find Garmin folder on mounted volume
            var topLevelDirs = [URL]()
            do {
                try
                topLevelDirs = fm.contentsOfDirectory(at: url,
                                                      includingPropertiesForKeys: [.isDirectoryKey],
                                                      options: [.skipsHiddenFiles])
            } catch let error as NSError {
                errors.append(error)
                continue
            }
            
            var garminVolumes = [URL]()
            for dir in topLevelDirs {
                if dir.lastPathComponent.lowercased() == "garmin" {
                    garminVolumes.append(dir)
                }
            }
            if garminVolumes.isEmpty { continue }
            
            // Find GPX folder in Garmin folder
            for garmin in garminVolumes {
                guard let gpxFolders = try? fm.contentsOfDirectory(at: garmin,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]) else {
                    continue
                }
                // Is there a GPX folder
                for dir in gpxFolders {
                    if dir.lastPathComponent.lowercased() == "gpx" {
                        let volFileItem = VolFileItem(name: name, path: dir, files: [])
                        self.allGpxFiles.append(volFileItem)
                    }
                }
            }
        }
        return errors
    }

}
