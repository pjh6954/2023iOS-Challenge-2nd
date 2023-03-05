//
//  ViewControllerViewModel.swift
//  Challenge-ImageDown
//
//  Created by Dannian Park on 2023/03/05.
//

import Foundation

protocol ViewControllerViewModelInput {
    // LoadData(with optional index array)
    func reloadData(_ array: [Int]?)
    func loadImageStart(_ index: Int?)
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
    public var data: [DownloadImageModel] { self.imageLoadedData }
    private let imageLoadedData : Array<DownloadImageModel> = [
        .init(urlStr: "https://images.unsplash.com/photo-1677552929439-082dabf4e88f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2370&q=80"), // https://unsplash.com/ko/%EC%82%AC%EC%A7%84/vk_Z_ya4u14
        .init(urlStr: "https://images.unsplash.com/photo-1677549254885-cf55be3e552b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=987&q=80"), // https://unsplash.com/ko/%EC%82%AC%EC%A7%84/VOYv0cDl_Uo
        .init(urlStr: "https://images.unsplash.com/photo-1677472423915-0cc46eb36685?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1335&q=80"), // https://unsplash.com/ko/%EC%82%AC%EC%A7%84/TtGYrK3WYFY
        .init(urlStr: "https://images.unsplash.com/photo-1675679620439-bacfc67a669a?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2370&q=80"), // https://unsplash.com/ko/%EC%82%AC%EC%A7%84/gmejHJ6k-VY
        .init(urlStr: "https://images.unsplash.com/photo-1677455104504-364b0e16ef39?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2370&q=80") // https://unsplash.com/ko/%EC%82%AC%EC%A7%84/KvXQBeoolwU
    ]
    
    // private var waitQueue: Queue<DownloadImageModel> = .init()
    private var isLoading: Bool = false
    private var loadingData : [String: DownloadImageModel] = [:]
    private var completeDataURLQueue: ArrayQueue<String> = .init()
    // Input
    // 특정 인덱스 완료 후 reload 하도록 하거나, 모든 것들을 reload 하는데 사용되는 함수
    func reloadData(_ array: [Int]? = nil) {
        
        self.tableReloadCallback?(array)
    }
    
    /// nil인 경우 모두 load
    func loadImageStart(_ index: Int? = nil) {
        if let index = index {
            guard let reloadData = imageLoadedData[safe: index] else { return }
            self.setImgDataLoad(data: reloadData)
        } else {
            for element in imageLoadedData.reversed() {
                self.setImgDataLoad(data: element)
            }
        }
        self.reloadData()
    }
    
    // Output
    var tableReloadCallback: (([Int]?) -> Void)?
    
    
    var input: ViewControllerViewModelInput { self }
    var output: ViewControllerViewModelOutput { self }
}

extension ViewControllerViewModel {
    private func setImgDataLoad(data: DownloadImageModel) {
        data.reloadData(callback: reloadDataCallback(_:), progressCallback: reloadProgressCallback(_:))
        self.loadingData[data.urlStr] = data
    }
    
    private func reloadProgressCallback(_ index: Int) {
        self.reloadData(nil)
    }
    
    private func reloadDataCallback(_ str: String) {
        self.completeDataURLQueue.enqueue(str)
        guard !isLoading else { return }
        self.loadingWithQueue()
    }
    
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
