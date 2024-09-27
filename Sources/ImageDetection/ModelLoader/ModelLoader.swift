//
//  File.swift
//  
//
//  Created by Russell Zarse on 9/25/24.
//

import Foundation
import CoreML
import Logging
import Vision
import ZIPFoundation

public enum ModelLoaderError: Error {
    case documentsDirectoryUnavailable
    case failedDownload(httpStatusCode: HTTPStatusCode)
}

private struct ModelFileInfo: Codable {
    let modelType: ModelType
    let sourceFileLocalUrl: URL
    let compiledModelLocalUrl: URL
    let storedAt: Date
}

public class ModelLoader {
    
    private static let fileManager: FileManager = FileManager.default
    
    private let modelType: ModelType
    
    private let modelFilesManifestUrl: URL
    
    private var modelFilesManifest: [ModelFileInfo]
    
    private var fileManager: FileManager { Self.fileManager }
    
    private var modelFileInfo: ModelFileInfo? {
        modelFilesManifest.first { $0.modelType == self.modelType }
    }
    
    public init(modelType: ModelType) throws {
        self.modelType = modelType
        self.modelFilesManifestUrl = try Self.getModelsDirectoryUrl().appendingPathComponent("manifest.json")
        self.modelFilesManifest = []
        do {
            self.modelFilesManifest = try self.loadManifest(from: modelFilesManifestUrl)
        } catch {
            Logger.package.warning("Failed to load manifest at \(modelFilesManifestUrl)")
        }
    }
    
    private func loadManifest(from url: URL) throws -> [ModelFileInfo] {
        let jsonDecoder = JSONDecoder()
        let data = try Data(contentsOf: url, options: [])
        let manifest = try jsonDecoder.decode([ModelFileInfo].self, from: data)
        return manifest
    }
    
    private func saveManifest(_ fileInfoList: [ModelFileInfo], to url: URL) throws {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let data = try jsonEncoder.encode(fileInfoList)
        try data.write(to: url)
    }
    
    public func loadModel() async throws -> VNCoreMLModel {
        // load locally if it already exists
        if let modelFileInfo,
           fileManager.fileExists(atPath: modelFileInfo.compiledModelLocalUrl.path) {
            return try await loadLocalModel(from: modelFileInfo.compiledModelLocalUrl)
        } else {
            let localModelUrl = try Self.getModelsDirectoryUrl().appendingPathComponent("\(modelType.rawValue)")
            try await Self.downloadModel(modelType: self.modelType, saveUrl: localModelUrl)
            let compiledUrl = try await MLModel.compileModel(at: localModelUrl)
            let fileInfo = ModelFileInfo(
                modelType: self.modelType,
                sourceFileLocalUrl: localModelUrl,
                compiledModelLocalUrl: compiledUrl,
                storedAt: Date()
            )
            self.modelFilesManifest.removeAll(where: { $0.modelType == self.modelType })
            self.modelFilesManifest.append(fileInfo)
            try self.saveManifest(self.modelFilesManifest, to: self.modelFilesManifestUrl)
            return try await self.loadLocalModel(from: compiledUrl)
        }
    }

    /// Load the model from a local `URL`
    private func loadLocalModel(from url: URL) async throws -> VNCoreMLModel {
        let coreMLModel = try MLModel(contentsOf: url)
        return try VNCoreMLModel(for: coreMLModel)
    }

    /// Download the model from a remote `URL`
    /// - Parameters:
    ///   - modelType: The `ModelType` to download
    ///   - saveUrl: A **local**  file `URL` to save the downloaded model to
    public static func downloadModel(modelType: ModelType, saveUrl: URL) async throws {
        let (tempLocalUrl, urlResponse) = try await URLSession.shared.download(from: modelType.source.zipUrl)
        
        if let statusCode = (urlResponse as? HTTPURLResponse)?.statusCode,
           let httpStatusCode = HTTPStatusCode(rawValue: statusCode) {
            switch httpStatusCode {
            case .ok:
                break
            default:
                Logger.package.error("Unexpected status \(httpStatusCode) from url \(modelType.source.zipUrl)")
                throw ModelLoaderError.failedDownload(httpStatusCode: httpStatusCode)
            }
        }
            
        // remove existing file if necessary
        if fileManager.fileExists(atPath: saveUrl.path) {
            try fileManager.removeItem(at: saveUrl)
        }
        
        // extract model from zip file
        try extract(modelType: modelType, fromZipUrl: tempLocalUrl, toSaveUrl: saveUrl)
    }
    
    private static func extract(modelType: ModelType, fromZipUrl zipUrl: URL, toSaveUrl saveUrl: URL) throws {
        let temporaryDirectoryUrl = try fileManager.url(
            for: .itemReplacementDirectory,
            in: .userDomainMask,
            appropriateFor: saveUrl,
            create: true
        )
        
        let zipFileNameWithoutExt = zipUrl.deletingPathExtension().lastPathComponent
        
        let localUnzipUrl = temporaryDirectoryUrl.appendingPathComponent(zipFileNameWithoutExt)
        // remove previous files if present (shouldn't be)
        if fileManager.fileExists(atPath: localUnzipUrl.path) {
            try fileManager.removeItem(at: localUnzipUrl)
        }
        
        // unzip to temp directory
        try fileManager.unzipItem(at: zipUrl, to: localUnzipUrl)
        
        let targetModelUrl = localUnzipUrl.appending(path: modelType.source.pathFromZipRoot)
        try fileManager.copyItem(at: targetModelUrl, to: saveUrl)
    }
    
    private static func getModelsDirectoryUrl() throws -> URL {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw ModelLoaderError.documentsDirectoryUnavailable
        }
        let modelsDirectoryUrl = documentsDirectory.appending(component: "models")
        try fileManager.ensureDirectory(url: modelsDirectoryUrl)
        return modelsDirectoryUrl
    }
}
