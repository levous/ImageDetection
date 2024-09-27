//
//  ObjectDetectorTests.swift
//  
//
//  Created by Russell Zarse on 9/26/24.
//

@testable import ImageDetection
import XCTest
import Vision

final class ObjectDetectorTests: XCTestCase {

    func testDetectObjects() async throws {
        let modelWrapper = try yolov8n()
        let vnCoreMLModel = try VNCoreMLModel(for: modelWrapper.model)
        let objectDetector = ObjectDetectionService(model: vnCoreMLModel)
       
        let uiImage = try TestHelper().testImage(fileName: "christmas-decorations.jpg")
        
        let shit = try await objectDetector.detectObjects(in: uiImage)
        print(shit)
    }
    
    func testDetectObjectsUsingDownloadedModel() async throws {
        let loader = try ModelLoader(modelType: .yoloV8x)
        let model = try await loader.loadModel()
        let objectDetector = ObjectDetectionService(model: model)
       
        let uiImage = try TestHelper().testImage(fileName: "christmas-decorations.jpg")
        
        let stuff = try await objectDetector.detectObjects(in: uiImage)
        print(stuff)
    }

}
