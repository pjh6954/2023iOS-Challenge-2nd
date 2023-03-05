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
