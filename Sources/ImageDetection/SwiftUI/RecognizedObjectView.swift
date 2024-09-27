//
//  RecognizedObjectView.swift
//
//
//  Created by Russell Zarse on 9/26/24.
//

import SwiftUI
import Vision

public struct RecognizedObjectView: View {
    
    static let colors: [Color] = [
        .red,
        .orange,
        .blue,
        .green,
        .cyan,
        .brown,
        .purple,
        .green,
        .indigo,
        .mint,
        .teal,
        .pink
    ]
    
    let recognizedObject: RecognizedObjectInfo
    
    public var body: some View {
        GeometryReader { geoProxy in
            ZStack {
                makeBoundingBox(for: recognizedObject, inFrame: geoProxy.size)
            }
        }
    }
    
    func makeBoundingBox(for prediction: RecognizedObjectInfo, inFrame viewBounds: CGSize) -> some View {
        
        let rect = prediction.boundingBoxTranslatedTo(frame: viewBounds)
        // The labels array is a list of VNClassificationObservation objects,
        // with the highest scoring class first in the list.
        let bestClass = prediction.labels[0].identifier
        let confidence = prediction.labels[0].confidence
        
        // Show the bounding box.
        let label = String(format: "%@ %.1f", bestClass, confidence * 100)
        let colorsCount = Self.colors.count
        let colorIdx = bestClass.hashValue % colorsCount
        let color = Color.blue //colorsCount > colorIdx ? Self.colors[colorIdx] : .black
        
        //boundingBoxViews[i].show(frame: rect, label: label, color: color)
        return ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 6)
                .stroke(color, lineWidth: 2)
                .frame(width: rect.size.width, height: rect.size.height)
                .offset(x: rect.origin.x, y: rect.origin.y)
            Text(label)
                .font(.caption)
                .foregroundStyle(color)
                .padding(2)
                .background(.white.opacity(0.3))
                .cornerRadius(4.0)
                .offset(x: rect.origin.x - 1, y: rect.origin.y - 20)
               
        }
        .frame(width: viewBounds.width, height: viewBounds.height, alignment: .topLeading)
        .border(.pink)
    }
}

#Preview {
    let recognizedObject = RecognizedObjectInfo(
        boundingBox: CGRect(x: 0.06, y: 0.23, width: 0.45, height: 0.42),
        labels: [
            .init(identifier: "Elephant", confidence: 99.4)
        ]
    )
    return ZStack {
        Image(packageResource: "elephant", ofType: "jpg")
        RecognizedObjectView(recognizedObject: recognizedObject)
    }
    .frame(width: 275, height: 183)
    .background(.gray)
}
