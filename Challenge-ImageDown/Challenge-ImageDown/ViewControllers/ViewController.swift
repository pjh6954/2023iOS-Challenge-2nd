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
    
    // private let loadingData: [Int] = [0,1,2,3,4]
    
    private let viewModel : ViewControllerViewModel = .init()
    
    private let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.viewInit()
        self.viewModelInit()
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
        self.btnLoadAll.addTarget(self, action: #selector(self.actionBtnReloadAll(_:)), for: .touchUpInside)
    }
    
    
    private func viewModelInit() {
        self.urlSessionSetting()
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
        self.viewModel.loadImageStart(index)
    }
    
    @objc private func actionBtnReloadAll(_ sender: UIButton) {
        self.viewModel.loadImageStart(nil)
    }
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ImageLoadTableViewCell else {
            return ImageLoadTableViewCell(frame: .zero)
        }
        guard let data = self.viewModel.data[safe: indexPath.row] else { return cell }
        print("DATA PROGRESS : \(data.progress)")
        cell.setDatas(data.image, index: indexPath.row, progress: data.progress)
        cell.btnCallback = self.cellCallback
        return cell
    }
    
    
}

extension ViewController : UITableViewDelegate {
    
}

extension ViewController : URLSessionDelegate, URLSessionDownloadDelegate {
    private func urlSessionSetting() {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)

        // Don't specify a completion handler here or the delegate won't be called
        // session.downloadTask(with: url).resume()
        // Session을 viewmodel에 전달.
        self.viewModel.sessionSetting(session)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("CHECK  : \(session) , \(downloadTask)")
        print("CHECK_ : \(downloadTask)")
        let written = byteFormatter.string(fromByteCount: totalBytesWritten)
        let expected = byteFormatter.string(fromByteCount: totalBytesExpectedToWrite)
        print("Downloaded \(written) / \(expected)")

        DispatchQueue.main.async {
            // self.progressView.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            self.viewModel.progressValue(downloadTask, value: Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
            
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
                self.viewModel.downloadComplete(downloadTask, img: image)
            }
        } else {
            fatalError("Cannot load the image")
        }

    }
}
