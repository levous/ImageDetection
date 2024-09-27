//
//  ContentView.swift
//  ImageDetectionExample
//
//  Created by Russell Zarse on 9/26/24.
//

import SwiftUI
import SwiftData
import ImageDetection

struct ContentView: View {
    
    private static let imageAssetName = "tools"
    @State var objectDetector: ObjectDetectionService?
    @State var uiImage: UIImage? = UIImage(named: Self.imageAssetName)
   
    var body: some View {
        VStack {
            if let objectDetector, let uiImage {
                ImageDetectionView(
                    objectDetector: objectDetector,
                    uiImage: uiImage
                )
            } else {
                Text("Loading...")
            }
            
            if uiImage == nil {
                Text("The expected \"\(Self.imageAssetName)\" image was not found in the image assets.")
                    .foregroundStyle(.red)
            }
        }.onAppear {
            loadModel()
        }
    }
    
    private func loadModel() {
        Task {
            do {
                let modelLoader = try ModelLoader(modelType: .yoloV8x)
                let model = try await modelLoader.loadModel()
                self.objectDetector = ObjectDetectionService(model: model)
            } catch {
                print("Failed to load model \(error)")
            }
        }
    }
   
}

struct ImageDetectionView: View {
    
    @State private var observations: [RecognizedObjectInfo] = []
    
    let objectDetector: ObjectDetectionService
    let uiImage: UIImage
    
    var body: some View {
        GeometryReader { geoProxy in
            ScrollView {
                RecognizedObjectsWithImageView(
                    uiImage: uiImage,
                    recognizedObjects: observations
                )
                .frame(
                    width: geoProxy.size.width,
                    height: geoProxy.size.width * (uiImage.size.height / uiImage.size.width)
                )
            }
            .onAppear {
                self.detectObjects()
            }
        }
    }
    
    private func detectObjects() {
        Task {
            do {
                self.observations = try await objectDetector.detectObjects(in: uiImage)
                    .map { vnObservation in
                        RecognizedObjectInfo.init(with: vnObservation)
                    }
            } catch {
                print("Failed to make observations. erro: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
