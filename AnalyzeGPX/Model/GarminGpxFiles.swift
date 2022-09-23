//
//  GarminGpxFiles.swift
//  AnalyzeGPX
//
//  Created by Manfred on 01.02.20.
//  Copyright © 2020 Manfred Kern. All rights reserved.
//
// Layout of file structure
//      Volume
//          -> "Garmin"
//                  -> "Activities"
//                  -> "Courses"
//                  -> "GPX"
//

import Foundation

class GarminGpxFiles {
        
    /// Item of a tree node for GPX files
    struct VolFileItem {
        var name: String   // Name of volume or file
        var path: URL      // full path
        var files: [VolFileItem]   // GPX files - for the level of volumes = 0
    }
    typealias AllGpxFiles = [VolFileItem]
    static var allGpxFiles = [VolFileItem]()
    static var allCourseFiles = [VolFileItem]()
    
    // MARK: - Methods
    
    /// List all GPX files for a given item and add them to its files property
    /// - Parameter item: to look for GPX files and return them in the files property
    static func listGpxFiles(for item: inout VolFileItem) {
        item.files.removeAll()
        
        let fileManager = FileManager.default
        guard let gpxFiles = try? fileManager.contentsOfDirectory(at: item.path,
                                                         includingPropertiesForKeys: [.isRegularFileKey],
                                                         options: [.skipsHiddenFiles])
            else { return }
        
        for file in gpxFiles.filter({ ($0.pathExtension).lowercased() == "gpx"}) {
            item.files.append(VolFileItem(name: file.lastPathComponent,
                                          path: file,
                                          files: []))
        }
    }
    
    /// List all FIT files for a given item and add them to its files property
    /// - Parameter item: to look for FIT files and return them in the files property
    static func listFitFiles(for item: inout VolFileItem) {
        item.files.removeAll()
        
        let fileManager = FileManager.default
        guard let fitFiles = try? fileManager.contentsOfDirectory(at: item.path,
                                                                  includingPropertiesForKeys: [.isRegularFileKey],
                                                                  options: [.skipsHiddenFiles])
        else { return }
        
        for file in fitFiles.filter({ ($0.pathExtension).lowercased() == "fit"}) {
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
        allCourseFiles.removeAll()
        errors.removeAll()
        
        let fileManager = FileManager.default
        guard let listOfVol =
                fileManager.mountedVolumeURLs(includingResourceValuesForKeys: [.volumeLocalizedNameKey], options: [.skipHiddenVolumes])
        else { return errors }

        // Search all mounted volumes
        for url in listOfVol {
            let nameOfDriveRes = try? url.resourceValues(forKeys: [.localizedNameKey])
            var name: String = ""
            if let nameOfDrive = nameOfDriveRes?.localizedName { name = nameOfDrive }
                
            // Find Garmin folder on mounted volume
            var topLevelDirs = [URL]()
            do {
                try
                topLevelDirs = fileManager.contentsOfDirectory(at: url,
                                                      includingPropertiesForKeys: [.isDirectoryKey],
                                                      options: [.skipsHiddenFiles])
            } catch let error as NSError {
                errors.append(error)
                continue
            }
            
            var garminVolumes = [URL]()
            for dir in topLevelDirs where dir.lastPathComponent.lowercased() == "garmin" {
                garminVolumes.append(dir)
            }
            if garminVolumes.isEmpty { continue }
            
            // Find GPX folder in Garmin folder
            for garmin in garminVolumes {
                guard let garminFolders = try? fileManager.contentsOfDirectory(at: garmin,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]) else {
                    continue
                }
                for dir in garminFolders {
                    // Is there a GPX folder
                    if dir.lastPathComponent.lowercased() == "gpx" {
                        let volFileItem = VolFileItem(name: name, path: dir, files: [])
                        self.allGpxFiles.append(volFileItem)
                    }
                    // Is there a Courses folder
                    if dir.lastPathComponent.lowercased() == "courses" {
                        let volFileItem = VolFileItem(name: name, path: dir, files: [])
                        self.allCourseFiles.append(volFileItem)
                    }
                }
            }
        }
        return errors
    }
    
    /// Deletes given file
    /// - Parameter file: Complete path of file
    /// - Throws: errors from FileManager and Searching file in internal collection "allGpxFiles"
    static func deleteGpxFile(path: URL) throws {
        let fileManger = FileManager.default
        
        if !fileManger.fileExists(atPath: path.path) {
            return
        }
        guard let attr = try? fileManger.attributesOfItem(atPath: path.path) as NSDictionary else { return }
        guard let filetype = attr.fileType(), filetype == FileAttributeType.typeRegular.rawValue else {
            return
        }
        
        // Get index of volume / device
        
        let volIndex = allGpxFiles.firstIndex { (volFileItem) -> Bool in
            return volFileItem.path == path.deletingLastPathComponent()
        }
        if volIndex == nil { return }
        
        // Now for the full path
        let listOfGpxFiles = allGpxFiles[volIndex!].files
    
        let fileIndex = listOfGpxFiles.firstIndex { (volFileItem) -> Bool in
            return volFileItem.name == path.lastPathComponent
        }
        if fileIndex == nil { return }
        
        // Delete file from internal collection "allGpxFiles"
        allGpxFiles[volIndex!].files.remove(at: fileIndex!)
        
        // Delete file from file system
        try fileManger.removeItem(at: path)
    }

}
