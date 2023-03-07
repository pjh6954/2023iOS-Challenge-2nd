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
    
    var progress: Float {
        var value = progressValue
        if value < 0.0 {
            value = 0.0
        } else if value > 1.0 {
            value = 1.0
        }
        return value
    }
    private var progressValue: Float = 0.0 {
        didSet {
            guard index != nil else { return }
            self.progressCallback?(index)
        }
    }
    
    private var index: Int!
    
    var isLoading: Bool { loading }
    private var loading: Bool = false
    
    var image: UIImage? { imageData ?? UIImage.init(systemName: "photo.artframe") }
    private var imageData: UIImage?
    
    private var callback: ((String) -> Void)?
    private var progressCallback: ((Int) -> Void)?
    
    private var observation: NSKeyValueObservation!
    
    init(urlStr: String) {
        self.urlStr = urlStr
    }
    
    deinit {
        self.observerRelease()
    }
    
    private func observerRelease() {
        if observation != nil {
            observation.invalidate()
        }
        observation = nil
    }
    
    public func reloadData(_ index: Int, callback: @escaping (String) -> Void, progressCallback: @escaping (Int) -> Void) {
        self.reloadAllData()
        self.callback = callback
        self.progressCallback = progressCallback
        self.index = index
        self.startLoadData()
    }
    
    public func reloadAllData() {
        self.index = nil
        self.imageData = nil
        self.progressValue = 0.0
        self.loading = false
        self.callback = nil
        self.progressCallback = nil
        self.observerRelease()
    }
    
    public func endReloadData() {
        self.progressValue = 1.0
        self.loading = false
        self.callback?(urlStr)
        self.callback = nil
        self.progressCallback = nil
        self.observerRelease()
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
        let task = URLSession.shared.dataTask(with: url, completionHandler: completion)
        self.observation = task.progress.observe(\.fractionCompleted, options: [.new]) { progress, change in
            DispatchQueue.main.async {
                print("PROGRESS?? \(Float(progress.fractionCompleted))")
                self.progressValue = Float(progress.fractionCompleted)
            }
        }
        task.resume()
    }
}
