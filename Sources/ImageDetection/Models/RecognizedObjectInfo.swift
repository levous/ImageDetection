//
//  RecognizedObjectInfo.swift
//
//
//  Created by Russell Zarse on 9/26/24.
//

import Foundation
import Vision

public struct RecognizedObjectInfo {
    let boundingBox: CGRect
    let labels: [ObjectLabelInfo]
}

public struct ObjectLabelInfo {
    let identifier: String
    let confidence: Float
}

public extension RecognizedObjectInfo {
    
    init(with prediction: VNRecognizedObjectObservation) {
        self.boundingBox = prediction.boundingBox
        self.labels = prediction.labels.map { vnLabel in
            ObjectLabelInfo(
                identifier: vnLabel.identifier,
                confidence: vnLabel.confidence
            )
        }
    }

    func boundingBoxTranslatedTo(frame: CGSize) -> CGRect {
        /*
         The predicted bounding box is in normalized image coordinates, with
         the origin in the lower-left corner.
         
         Scale the bounding box to the coordinate system of the view,
         */
        
        /* Smart people do it this way but it wasn't working
        let width = bounds.width
        let aspectRatio = width / bounds.height
        let height = width * aspectRatio
        let offsetY = (bounds.height - height) / 2
        let scale = CGAffineTransform.identity.scaledBy(x: width, y: height)
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -height - offsetY)
        let rect = prediction.boundingBox.applying(scale).applying(transform)
        */
        
        let height = frame.height * boundingBox.size.height
        // prediction bounding box origin Y is 0...1 originating from lower left
        // translate to view coordinate originating top left
        let originY = (frame.height -
                       (frame.height * boundingBox.origin.y)
                       - height)
        // the rest is simply multiplication
        let originX = frame.width * boundingBox.origin.x
        let width = frame.width * boundingBox.size.width
        
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
}

extension RecognizedObjectInfo: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.labels)
        hasher.combine(self.boundingBox.origin.x)
        hasher.combine(self.boundingBox.origin.y)
    }
}

extension ObjectLabelInfo: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.confidence)
        hasher.combine(self.identifier)
    }
}
