//
//  TestHelper.swift
//
//
//  Created by Russell Zarse on 9/26/24.
//

import UIKit

enum TestHelperError: Error {
    case fileNotFound
}

struct TestHelper {
    
    func testImage(fileName: String) throws -> UIImage {
        let url = Bundle.module.bundleURL
            .appendingPathComponent("TestResources")
            .appendingPathComponent("images")
            .appendingPathComponent(fileName)
        
        let imagePath = url.path()
        let itsThere = FileManager.default.fileExists(atPath: imagePath)
        guard let image = UIImage(contentsOfFile: imagePath) else {
            throw TestHelperError.fileNotFound
        }
        
        return image
    }
    
//    func testImage(named: String, withExtension: String) throws -> UIImage {
//        let imageUrl = Bundle.module.url(forResource: named, withExtension: withExtension, subdirectory: "TestResources/images")
//
//        guard let url = imageUrl else {
//            throw TestHelperError.fileNotFound
//        }
//
//        // Load the UIImage from the URL
//        guard let image = UIImage(contentsOfFile: url.path) else {
//            throw TestHelperError.fileNotFound
//        }
//        
//        return image
//    }
}

//#if XCODE_BUILD
//extension Foundation.Bundle {
//    
//    /// Returns resource bundle as a `Bundle`.
//    /// Requires Xcode copy phase to locate files into `ExecutableName.bundle`;
//    /// or `ExecutableNameTests.bundle` for test resources
//    static var module: Bundle = {
//        var thisModuleName = "ImageDetection"
//        var url = Bundle.main.bundleURL
//        
//        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
//            url = bundle.bundleURL.deletingLastPathComponent()
//            thisModuleName = thisModuleName.appending("Tests")
//        }
//        
//        url = url.appendingPathComponent("\(thisModuleName).bundle")
//        
//        guard let bundle = Bundle(url: url) else {
//            fatalError("Foundation.Bundle.module could not load resource bundle: \(url.path)")
//        }
//        
//        return bundle
//    }()
//    
//    /// Directory containing resource bundle
//    static var moduleDir: URL = {
//        var url = Bundle.main.bundleURL
//        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
//            // remove 'ExecutableNameTests.xctest' path component
//            url = bundle.bundleURL.deletingLastPathComponent()
//        }
//        return url
//    }()
//    
//}
//#endif
