import XCTest
@testable import ImageDetection

final class ModelLoaderTests: XCTestCase {
    func testDownloadModel() async throws {
        let modelType = ModelType.yoloV8x
        let temporaryDirectoryUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let saveUrl = temporaryDirectoryUrl.appending(path: modelType.fileName)
        try await ModelLoader.downloadModel(modelType: modelType, saveUrl: saveUrl)
        XCTAssert(FileManager.default.fileExists(atPath: saveUrl.path))

    }
}
