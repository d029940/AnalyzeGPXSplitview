//
//  GarminGpxFiles.swift
//  AnalyzeGPX
//
//  Created by Manfred on 01.02.20.
//  Copyright © 2020 Manfred Kern. All rights reserved.
//

import Foundation

class GarminGpxFiles{
    
    // MARK: - Propertiey
    // Table model
    typealias VolumeEntry = (path: URL, name: String)
    static var listOfVolumes = [VolumeEntry]()
    
    static var listOfGpxFiles = [URL]()

    
    // MARK: - Methods
    
    static func listGpxFiles(for url: URL) -> [URL] {
        listOfGpxFiles.removeAll()
        
        let fm = FileManager.default
        guard let gpxFiles = try? fm.contentsOfDirectory(at: url,
                                                         includingPropertiesForKeys: [.isRegularFileKey],
                                                         options: [.skipsHiddenFiles])
            else { return listOfGpxFiles }
        listOfGpxFiles = gpxFiles.filter { ($0.pathExtension).lowercased() == "gpx"}
        return listOfGpxFiles
    }
    
    /// Searches for all Garmin/GPX folder on all mounted volumes case-insensitively and add them to the device table view
    /// If errors occur during reading the directories thery are returned in the errors parameter
    static func loadGarminDevices(errors: inout [NSError] ) -> [VolumeEntry] {
        listOfVolumes.removeAll()
        errors.removeAll()
        
        let fm = FileManager.default
        guard let listOfVol = fm.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeLocalizedNameKey], options: [.skipHiddenVolumes]) else { return listOfVolumes }

        // Search all mounted volumes
        for url in listOfVol {
            let nameOfDriveRes = try? url.resourceValues(forKeys: [.localizedNameKey])
            var volEntry: GarminGpxFiles.VolumeEntry
            if let nameOfDrive = nameOfDriveRes?.localizedName {
                volEntry.name = nameOfDrive
            } else {
                volEntry.name = ""
            }
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
                        volEntry.path = dir
                        self.listOfVolumes.append(volEntry)
                    }
                }
            }
        }
        return listOfVolumes
    }
}
