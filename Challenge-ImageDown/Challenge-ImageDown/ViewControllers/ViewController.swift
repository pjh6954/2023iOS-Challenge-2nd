//
//  ViewController.swift
//  Challenge-ImageDown
//
//  Created by Dannian Park on 2023/03/05.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnLoadAll: UIButton!
    
    // MVVM 사용할지 여부. true인 경우 ViewModel 사용해서 처리. false인 경우 datas를 사용해서 각 셀의 imageView에서 다운로드 처리
    private var isUsingVM: Bool { self.isUsingVMValue }
    // UI 또는 Unit 테스트 때만 코드로 변경할 수 있도록 하기위한 변수 추가.
    private var isUsingVMValue: Bool = true
    private var datas: [DownloadImageModel] {
        if isUsingVM {
            return []
        } else {
            return Constants.imageLoadedData
        }
    }
    private let viewModel : ViewControllerViewModel = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.viewInit()
        if self.isUsingVM {
            self.viewModelInit()
        } else {
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func viewInit() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib(nibName: String(describing: ImageLoadTableViewCell.self), bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "cell")
        
        // self.tableView.reloadData()
        self.btnLoadAll.accessibilityIdentifier = "btnLoadAll"
        self.btnLoadAll.addTarget(self, action: #selector(self.actionBtnReloadAll(_:)), for: .touchUpInside)
    }
    
    
    private func viewModelInit() {
        if self.viewModel.isUsingProgress {
            self.urlSessionSetting()
        }
        self.viewModel.tableReloadCallback = { [weak self] arr in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                if let arr = arr, !arr.isEmpty {
                    var indexList : [IndexPath] = []
                    for index in arr {
                        indexList.append(.init(row: index, section: 0))
                    }
                    self.tableView.reloadRows(at: indexList, with: .automatic)
                } else {
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
    private func cellCallback(_ index: Int) {
        if self.isUsingVM {
            self.viewModel.loadImageStart(index)
        }
    }
    
    // Test일 때만 할 수 있도록 하자.
    // https://stackoverflow.com/a/29991529
    public func forTestUsingVM(_ value: Bool) {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            self.isUsingVMValue = value
        }
        #endif
    }
    
    public func reloadAll() {
        if self.isUsingVM {
            self.viewModel.loadImageStart(nil)
        } else {
            for index in 0..<self.datas.count {
                guard let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ImageLoadTableViewCell else { continue }
                cell.loadImage()
            }
        }
    }
    
    @objc private func actionBtnReloadAll(_ sender: UIButton) {
        self.reloadAll()
    }
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isUsingVM {
            return viewModel.data.count
        } else {
            return self.datas.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ImageLoadTableViewCell else {
            return ImageLoadTableViewCell(frame: .zero)
        }
        if self.isUsingVM {
            guard let data = self.viewModel.data[safe: indexPath.row] else { return cell }
            print("DATA PROGRESS : \(data.progress)")
            cell.setDatas(data.image, index: indexPath.row, progress: data.progress)
            cell.btnCallback = self.cellCallback
        } else {
            guard let data = self.datas[safe: indexPath.row] else { return cell }
            cell.setData(data)
        }
        return cell
    }
    
    
}

extension ViewController : UITableViewDelegate {
    
}

// 아래는 Progress 사용할 때 이용.
extension ViewController : URLSessionDelegate, URLSessionDownloadDelegate {
    private func urlSessionSetting() {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)

        // Don't specify a completion handler here or the delegate won't be called
        // session.downloadTask(with: url).resume()
        // Session을 viewmodel에 전달.
        if self.isUsingVM {
            self.viewModel.sessionSetting(session)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        NSLog("downloadTask.response : \(String(describing: downloadTask.response))")
        // request url에 header를 추가했음에도 expected 쪽에 -1이 나오는 경우가 있다. 이경우, https://stackoverflow.com/a/33372970 다음 링크 참고
        // 문제는 Content-Length 헤더도 없는 경우...이 경우는 어쩔 수 없다. 다 되면 그냥 1로 강제할 수 밖에
        let response: URLResponse? = downloadTask.response
        // TODO: -1오는 값 확인 중이다... content-length 자체가 없는 경우 해결 법 확인 필요
        if let httpResponse = response as? HTTPURLResponse {
            let allHeaderFields = httpResponse.allHeaderFields
            let contentLengthString = allHeaderFields["Content-Length"]
            var contentLengthDouble: Double = 0.0
            if let str = contentLengthString as? String {
                print("STR! : \(str)")
            }
        }
        
        print("CHECK  : \(session) , \(downloadTask)")
        print("CHECK_ : \(downloadTask)")
        let written = Constants.byteFormatter.string(fromByteCount: totalBytesWritten)
        let expected = Constants.byteFormatter.string(fromByteCount: totalBytesExpectedToWrite)
        
        print("Downloaded \(written) / \(expected)")

        DispatchQueue.main.async {
            // self.progressView.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            if self.isUsingVM {
                self.viewModel.progressValue(downloadTask, value: Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("CHECK2 : \(session) , \(downloadTask)")
        // The location is only temporary. You need to read it or copy it to your container before
        // exiting this function. UIImage(contentsOfFile: ) seems to load the image lazily. NSData
        // does it right away.
        if let data = try? Data(contentsOf: location), let image = UIImage(data: data) {
            DispatchQueue.main.async {
                // self.imageView.contentMode = .scaleAspectFit
                // self.imageView.clipsToBounds = true
                // self.imageView.image = image
                if self.isUsingVM {
                    self.viewModel.progressValue(downloadTask, value: Float(1))
                    self.viewModel.downloadComplete(downloadTask, img: image)
                }
            }
        } else {
            fatalError("Cannot load the image")
        }

    }
}
