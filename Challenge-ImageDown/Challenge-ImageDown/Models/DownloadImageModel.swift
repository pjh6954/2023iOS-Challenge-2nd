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
    
    var image: UIImage? { imageData ?? UIImage.init(systemName: "photo.artframe") }
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
        self.reloadAllData()
        self.callback = callback
        self.progressCallback = progressCallback
        self.startLoadData()
    }
    
    public func reloadAllData() {
        self.imageData = nil
        self.progressValue = 0.0
        self.loading = false
        self.callback = nil
        self.progressCallback = nil
    }
    
    public func endReloadData() {
        self.progressValue = 1.0
        self.loading = false
        self.callback?(urlStr)
        self.callback = nil
        self.progressCallback = nil
    }
    
    public func setProgress(_ float: Float) {
        self.progressValue = float
    }
    
    public func setImage(_ img: UIImage?) {
        self.imageData = img
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
        Constants.bgQueue.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
            self?.downloadImage(from: url)
        }
    }
    
    private func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            // print("RESPONSE : \(response)")
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
}
