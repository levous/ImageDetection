//
//  ObjectDetector.swift
//
//
//  Created by Russell Zarse on 9/25/24.
//

import UIKit
import CoreML
import Vision

public enum ObjectDetectionServiceError: Error {
    case invalidImage
}

public class ObjectDetectionService {
    private let model: VNCoreMLModel
    private let cropAndScaleOption: VNImageCropAndScaleOption
    
    public init(model: VNCoreMLModel, cropAndScaleOption: VNImageCropAndScaleOption = .centerCrop) {
        self.model = model
        self.cropAndScaleOption = cropAndScaleOption
    }

    // Perform object detection on a given image
    public func detectObjects(in image: UIImage) async throws -> [VNRecognizedObjectObservation] {

        // Convert UIImage to CIImage
        guard let ciImage = CIImage(image: image) else {
            throw ObjectDetectionServiceError.invalidImage
        }

        // Create a request handler with the input image
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        // Create the object detection request
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { (request, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // Process the results
                if let results = request.results as? [VNRecognizedObjectObservation] {
                    continuation.resume(returning: results)
                } else {
                    continuation.resume(returning: [])
                }
            }
            
            request.imageCropAndScaleOption = self.cropAndScaleOption
            
            // Perform the request in the background
            DispatchQueue.global().async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
