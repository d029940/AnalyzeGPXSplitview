//
//  GarminFit.swift
//  AnalyzeGPX
//
//  Created by Manfred on 21.03.22.
//  Copyright © 2022 Manfred Kern. All rights reserved.
//

import Foundation

class GarminFit: NSObject {
       
    // MARK: - Model
    
    var courses: [String] = []
    
    // MARK: - Init
    override init() {
        super.init()
    }
    
    func add(fitFile: URL) {
        courses.append(fitFile.deletingLastPathComponent().lastPathComponent)
    }
    
    func resetModel() {
        courses.removeAll()
    }
}
