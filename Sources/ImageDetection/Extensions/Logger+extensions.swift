//
//  Logger+extensions.swift
//
//
//  Created by Russell Zarse on 9/26/24.
//

import Foundation
import Logging

extension Logger {
    /// use bundle identifier  to ensure a unique identifier.
    private static var subsystem = "com.levous.ImageDetection"

    /// Logs the view cycles like a view that appeared.
    static let package = Logger(label: subsystem)

}
