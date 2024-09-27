//
//  File.swift
//  
//
//  Created by Russell Zarse on 9/26/24.
//

import Foundation

internal extension FileManager {
    func ensureDirectory(url: URL) throws {
        if !self.fileExists(atPath: url.path) {
            try self.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
        }
    }
}
