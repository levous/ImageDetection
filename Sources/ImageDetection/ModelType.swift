//
//  File.swift
//  
//
//  Created by Russell Zarse on 9/25/24.
//

import Foundation

public enum ModelType: String, Codable {
    case yoloV8x = "yolov8x.mlpackage"
}

public extension ModelType {
   struct ModelSource {
        /// URL to the zip containing the model file
        let zipUrl: URL
        /// Path from the expanded zip root folder to the model file
        let pathFromZipRoot: String
    }
    
    var fileName: String {
        self.rawValue
    }
    
    var source: ModelSource {
        switch self {
        case .yoloV8x:
            return ModelSource (
                zipUrl: URL(string: "https://github.com/ultralytics/yolo-ios-app/releases/download/v8.2.0/Models.zip")!,
                pathFromZipRoot: "yolov8x.mlpackage"
                /*
                 nano    yolov8n.mlpackage
                 small   yolov8s.mlpackage
                 medium  yolov8m.mlpackage
                 large   yolov8l.mlpackage
                 x-large yolov8x.mlpackage
                 */
            )
        }
    }
}
