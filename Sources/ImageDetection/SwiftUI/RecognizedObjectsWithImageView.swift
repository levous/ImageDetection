//
//  SwiftUIView.swift
//  
//
//  Created by Russell Zarse on 9/26/24.
//

import SwiftUI

public struct RecognizedObjectsWithImageView: View {
    
    public let uiImage: UIImage
    public let recognizedObjects: [RecognizedObjectInfo]
    
    public init(uiImage: UIImage, recognizedObjects: [RecognizedObjectInfo]) {
        self.uiImage = uiImage
        self.recognizedObjects = recognizedObjects
    }
    
    public var body: some View {
        return ZStack {
            Image(uiImage: uiImage)
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            ForEach(recognizedObjects, id: \.self) { recognizedObject in
                RecognizedObjectView(recognizedObject: recognizedObject)
            }
        }
    }
}

#Preview {
    RecognizedObjectsWithImageView(
        uiImage: UIImage(named: "elephant")!,
        recognizedObjects: [
            RecognizedObjectInfo(
                boundingBox: CGRect(x: 0.2, y: 0.2, width: 0.3, height: 0.3),
                labels: [
                    ObjectLabelInfo(identifier: "Elephant", confidence: 99.0)
                ]
            )
        ]
    )
}
