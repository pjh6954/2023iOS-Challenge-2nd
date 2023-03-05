//
//  DownloadImageModel.swift
//  Challenge-ImageDown
//
//  Created by Dannian Park on 2023/03/05.
//

import UIKit
// https://stackoverflow.com/a/27712427/13049349
class DownloadImageModel {
    let urlStr : String
    var url: URL? { URL(string: urlStr) }
    var progress: Float { progressValue }
    private var progressValue: Float = 0.0
    var isLoading: Bool { loading }
    private var loading: Bool = false
    
    var image: UIImage? { imageData }
    private var imageData: UIImage?
    
    private var callback: ((String) -> Void)?
    private var progressCallback: ((Int) -> Void)?
    
    private let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        return formatter
    }()
    
    init(urlStr: String) {
        self.urlStr = urlStr
    }
    
    public func reloadData(callback: @escaping (String) -> Void, progressCallback: @escaping (Int) -> Void) {
        self.imageData = nil
        self.progressValue = 0.0
        self.loading = false
        self.callback = callback
        self.progressCallback = progressCallback
        self.startLoadData()
    }
    
    public func endReloadData() {
        self.progressValue = 1.0
        self.loading = false
        self.callback?(urlStr)
        self.callback = nil
        self.progressCallback = nil
    }
    
    private func startLoadData() {
        guard let url = self.url else { endReloadData(); return }
        /*
        // 간편 방식 - progress 확인 못하는 방식
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
            if let data = try? Data(contentsOf: url) {
                guard let img = UIImage(data: data) else {
                    self?.endReloadData()
                    return
                }
                self?.imageData = img
                self?.endReloadData()
            }
        }
        */
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
            self?.downloadImage(from: url)
        }
    }
    
    private func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            print("RESPONSE : \(response)")
            guard let data = data, error == nil else {
                self.endReloadData()
                return
            }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                self?.imageData = UIImage(data: data)
                self?.progressValue = 1.0
                self?.endReloadData()
            }
        }
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let written = byteFormatter.string(fromByteCount: totalBytesWritten)
        let expected = byteFormatter.string(fromByteCount: totalBytesExpectedToWrite)
        print("Downloaded \(written) / \(expected)")

        DispatchQueue.main.async {
            // self.progressView.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            self.progressValue = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // The location is only temporary. You need to read it or copy it to your container before
        // exiting this function. UIImage(contentsOfFile: ) seems to load the image lazily. NSData
        // does it right away.
        if let data = try? Data(contentsOf: location), let image = UIImage(data: data) {
            DispatchQueue.main.async {
                /*
                self.imageView.contentMode = .scaleAspectFit
                self.imageView.clipsToBounds = true
                self.imageView.image = image
                */
                self.imageData = image
            }
        } else {
            fatalError("Cannot load the image")
        }

    }
}
/*
class ViewController: UIViewController, URLSessionDelegate, URLSessionDownloadDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!

    private let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func downloadImage(sender : AnyObject) {
        // A 10MB image from NASA
        let url = URL(string: "https://photojournal.jpl.nasa.gov/jpeg/PIA08506.jpg")!

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)

        // Don't specify a completion handler here or the delegate won't be called
        session.downloadTask(with: url).resume()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let written = byteFormatter.string(fromByteCount: totalBytesWritten)
        let expected = byteFormatter.string(fromByteCount: totalBytesExpectedToWrite)
        print("Downloaded \(written) / \(expected)")

        DispatchQueue.main.async {
            self.progressView.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // The location is only temporary. You need to read it or copy it to your container before
        // exiting this function. UIImage(contentsOfFile: ) seems to load the image lazily. NSData
        // does it right away.
        if let data = try? Data(contentsOf: location), let image = UIImage(data: data) {
            DispatchQueue.main.async {
                self.imageView.contentMode = .scaleAspectFit
                self.imageView.clipsToBounds = true
                self.imageView.image = image
            }
        } else {
            fatalError("Cannot load the image")
        }

    }
}
*/
