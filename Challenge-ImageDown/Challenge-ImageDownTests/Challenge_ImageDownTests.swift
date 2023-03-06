//
//  Challenge_ImageDownTests.swift
//  Challenge-ImageDownTests
//
//  Created by Dannian Park on 2023/03/05.
//

import XCTest
@testable import Challenge_ImageDown

final class Challenge_ImageDownTests: XCTestCase {
    
    var viewControllerViewModel: ViewControllerViewModel!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        viewControllerViewModel = .init()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewControllerViewModel = nil
        try super.tearDownWithError()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testUsingProgress() throws {
        viewControllerViewModel.forTestIsUsingProgress(true)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        viewControllerViewModel.sessionSetting(session)
        
        viewControllerViewModel.loadImageStart(nil)
    }
    
    func testNotUsingProgress() throws {
        viewControllerViewModel.forTestIsUsingProgress(false)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        viewControllerViewModel.sessionSetting(session)
        
        viewControllerViewModel.loadImageStart(nil)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension Challenge_ImageDownTests : URLSessionDelegate, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let data = try? Data(contentsOf: location), let image = UIImage(data: data) {
            DispatchQueue.main.async {
                // self.imageView.contentMode = .scaleAspectFit
                // self.imageView.clipsToBounds = true
                // self.imageView.image = image
                self.viewControllerViewModel.downloadComplete(downloadTask, img: image)
            }
        } else {
            fatalError("Cannot load the image")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let written = Constants.byteFormatter.string(fromByteCount: totalBytesWritten)
        let expected = Constants.byteFormatter.string(fromByteCount: totalBytesExpectedToWrite)
        print("Downloaded \(written) / \(expected)")

        DispatchQueue.main.async {
            // self.progressView.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            self.viewControllerViewModel.progressValue(downloadTask, value: Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
        }
    }
    
}
