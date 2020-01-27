//
//  GarminGpx.swift
//  AnalyzeGPX
//
//  Created by Manfred on 07.01.20.
//  Copyright © 2020 Manfred Kern. All rights reserved.
//

import Foundation

class GarminGpx: NSObject {
    
    // MARK:- file and XML parsing properties
    
    var filename: URL?
    var parser: XMLParser?
    enum ParseErrors: Error {
        case badFilename
    }
    
    // MARK:- GPX definitions
    
    enum CurrentXmlTagEnum {
        case empty
        case metadata
        case name
    }
    enum GpxTypes {
        case empty
        case trk    // Tracks
        case rte    // Routes
        case wpt    // Waypoints
    }
    var gpxType: GpxTypes = .empty
    
    var currentXmlTag: CurrentXmlTagEnum = .empty
    
    // MARK:- Model
    
    var tracks: [String] = []
    var routes: [String] = []
    var waypoints: [String] = []
    
    // MARK: Helper vars
    
    var buffer: String = ""
    
    // MARK:- Init
    override init() {
        super.init()
    }
    
    func resetModel() {
        tracks.removeAll()
        routes.removeAll()
        waypoints.removeAll()
    }
    
    // MARK:- Parsing file
    
    func parse(gpxFile: URL) throws {
        self.filename = gpxFile
        guard let parser = XMLParser(contentsOf: gpxFile) else {
            print("Failed to open gpx file")
            throw ParseErrors.badFilename
        }
        self.parser = parser
          self.parser?.delegate = self
          parser.parse()
    }
}

// MARK:- XML Parser Delegates

extension GarminGpx: XMLParserDelegate {
  
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        if elementName == "trk" {
            gpxType = .trk
        } else if elementName == "wpt" {
            gpxType = .wpt
        } else if elementName == "rte" {
            gpxType = .rte
        }
        
        if elementName == "name" &&
        (gpxType == .trk || gpxType == .rte || gpxType == .wpt) {
            currentXmlTag = .name
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentXmlTag = .empty
        if elementName == "name" {
            switch gpxType {
            case .trk:
                tracks.append(buffer)
            case .rte:
                routes.append(buffer)
            case .wpt:
                waypoints.append(buffer)
            default:
                break
                
            }
            gpxType = .empty
            buffer = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters: String) {
        if currentXmlTag == .name &&
        (gpxType == .trk || gpxType == .rte || gpxType == .wpt) {
            buffer += foundCharacters
        }
    }
}
