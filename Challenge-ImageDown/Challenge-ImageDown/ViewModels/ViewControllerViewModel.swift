//
//  ViewControllerViewModel.swift
//  Challenge-ImageDown
//
//  Created by Dannian Park on 2023/03/05.
//

import Foundation
import UIKit

protocol ViewControllerViewModelInput {
    // LoadData(with optional index array)
    func reloadData(_ array: [Int]?)
    func loadImageStart(_ index: Int?)
    func sessionSetting(_ session: URLSession)
    // Progress 사용을 위해 아래 추가
    // func progressValueSend()
    func progressValue(_ downloadTask: URLSessionDownloadTask, value: Float)
    func downloadComplete(_ downloadTask: URLSessionDownloadTask, img: UIImage?)
}

protocol ViewControllerViewModelOutput {
    
    var tableReloadCallback: ((_ index : [Int]?) -> Void)? { get set }
}

protocol ViewControllerViewModelType {
    var input : ViewControllerViewModelInput { get }
    var output : ViewControllerViewModelOutput { get }
}

class ViewControllerViewModel : ViewControllerViewModelInput, ViewControllerViewModelOutput, ViewControllerViewModelType {
    // Public
    public let isUsingProgress = true
    public var data: [DownloadImageModel] { self.imageLoadedData }
    private let imageLoadedData : Array<DownloadImageModel> = [
        .init(urlStr: "https://images.unsplash.com/photo-1677552929439-082dabf4e88f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2370&q=80"), // https://unsplash.com/ko/%EC%82%AC%EC%A7%84/vk_Z_ya4u14
        .init(urlStr: "https://images.unsplash.com/photo-1677549254885-cf55be3e552b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=987&q=80"), // https://unsplash.com/ko/%EC%82%AC%EC%A7%84/VOYv0cDl_Uo
        .init(urlStr: "https://images.unsplash.com/photo-1677472423915-0cc46eb36685?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1335&q=80"), // https://unsplash.com/ko/%EC%82%AC%EC%A7%84/TtGYrK3WYFY
        .init(urlStr: "https://images.unsplash.com/photo-1675679620439-bacfc67a669a?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2370&q=80"), // https://unsplash.com/ko/%EC%82%AC%EC%A7%84/gmejHJ6k-VY
        .init(urlStr: "https://images.unsplash.com/photo-1677455104504-364b0e16ef39?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2370&q=80") // https://unsplash.com/ko/%EC%82%AC%EC%A7%84/KvXQBeoolwU
    ]
    
    // Progress, non-progress 공통
    private var isLoading: Bool = false
    
    // Progress 사용 안하는 방식
    private var loadingDataWithoutProgress : [String: DownloadImageModel] = [:]
    private var completeDataURLQueue: ArrayQueue<String> = .init()
    
    // Progress 사용
    private var loadingData : [String: (DownloadImageModel, URLSessionDownloadTask)] = [:]
    private var taskResumeURLSet: Set<String> = .init()
    private var session : URLSession!
    private let downloadQueue = DispatchQueue(label: "downloadImg", qos: .background, attributes: .concurrent)
    
    // Input
    // 특정 인덱스 완료 후 reload 하도록 하거나, 모든 것들을 reload 하는데 사용되는 함수
    func reloadData(_ array: [Int]? = nil) {
        self.tableReloadCallback?(array)
    }
    
    /// nil인 경우 모두 load
    func loadImageStart(_ index: Int? = nil) {
        if let index = index {
            guard let reloadData = imageLoadedData[safe: index] else { return }
            reloadData.reloadAllData()
            self.setImgDataLoad(data: reloadData)
        } else {
            for element in imageLoadedData.reversed() {
                element.reloadAllData()
                self.setImgDataLoad(data: element)
            }
        }
        self.reloadData()
    }
    
    // Progress 사용 할 때 쓰기위한 것.
    func sessionSetting(_ session: URLSession) {
        self.session = session
    }
    
    // Progress 사용 할 때 쓰기위한 것.
    func progressValue(_ downloadTask: URLSessionDownloadTask, value: Float) {
        for (_, dataValue) in self.loadingData {
            guard downloadTask.isEqual(dataValue.1) else { continue }
            dataValue.0.setProgress(value)
            self.reloadData()
            break
        }
        
    }
    
    // Progress 사용 할 때 쓰기위한 것.
    func downloadComplete(_ downloadTask: URLSessionDownloadTask ,img: UIImage?) {
        var completeKey : String!
        for (key, dataValue) in self.loadingData {
            guard downloadTask.isEqual(dataValue.1) else { continue }
            completeKey = self.taskResumeURLSet.remove(key)
            dataValue.0.setImage(img)
            
            
        }
        guard !completeKey.isEmpty else { self.isLoading = false; return }
        self.loadingData.removeValue(forKey: completeKey)
        self.reloadData()
        self.isLoading = false
        self.startDownload()
    }
    
    // Output
    var tableReloadCallback: (([Int]?) -> Void)?
    
    var input: ViewControllerViewModelInput { self }
    var output: ViewControllerViewModelOutput { self }
}

extension ViewControllerViewModel {
    private func setImgDataLoad(data: DownloadImageModel) {
        if isUsingProgress {
            // Progress 추가버전
            guard let session else { return }
            guard let url = data.url else { return }
            // session.downloadTask(with: url).resume()
            if self.taskResumeURLSet.contains(data.urlStr) {
                return
            }
            let downloadTask = session.downloadTask(with: url)
            
            self.loadingData[data.urlStr] = (data, downloadTask)
            self.startDownload()
        } else {
            data.reloadData(callback: reloadDataCallback(_:), progressCallback: reloadProgressCallback(_:))
            self.loadingDataWithoutProgress[data.urlStr] = data
        }
    }
    
    // PROGRESS 추가하면서 추가된 함수
    private func startDownload() {
        print("CHECK!!!1  : \(self.loadingData)")
        downloadQueue.async { [weak self] in
            guard let `self` = self else { return }
            guard !self.loadingData.isEmpty else {
                self.isLoading = false
                return
            }
            guard !self.isLoading else { return }
            self.isLoading = true
            for element in self.loadingData {
                print("taskResumeURLSettaskResumeURLSet :: \(self.taskResumeURLSet)")
                guard !self.taskResumeURLSet.contains(element.key) else {
                    continue
                }
                element.value.1.resume()
                self.taskResumeURLSet.insert(element.key)
                break
            }
        }
    }
    
    // Progress 사용 안할 때 쓰기위한 것.
    private func reloadProgressCallback(_ index: Int) {
        self.reloadData(nil)
    }
    
    // Progress 사용 안할 때 쓰기위한 것.
    private func reloadDataCallback(_ str: String) {
        self.completeDataURLQueue.enqueue(str)
        guard !isLoading else { return }
        self.loadingWithQueue()
    }
    
    // Progress 사용 안할 때 쓰기위한 것.
    private func loadingWithQueue() {
        isLoading = true
        guard !completeDataURLQueue.isEmpty else {
            isLoading = false
            return
        }
        var tempQueue = completeDataURLQueue
        print("!TEMP QUEUE 1: \(tempQueue)")
        guard let first = tempQueue.dequeue() else {
            self.loadingWithQueue()
            return
        }
        print("!TEMP QUEUE 3: \(completeDataURLQueue)")
        for (_, element) in self.imageLoadedData.enumerated() {
            guard element.urlStr.elementsEqual(first) else {
                continue
            }
            _ = self.completeDataURLQueue.dequeue()
            self.reloadData(nil)
            print("!TEMP QUEUE 2: \(completeDataURLQueue)")
            break
        }
        self.loadingWithQueue()
    }
}
