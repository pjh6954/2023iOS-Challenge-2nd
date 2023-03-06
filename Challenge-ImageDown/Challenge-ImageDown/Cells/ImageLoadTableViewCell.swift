//
//  ImageLoadTableViewCell.swift
//  Challenge-ImageDown
//
//  Created by Dannian Park on 2023/03/05.
//

import UIKit

class ImageLoadTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var btnLoad: UIButton!
    
    @IBOutlet weak var progressView: ProgressView!
    
    public var btnCallback: ((Int) -> Void)?
    
    // cell imageview에서 직접 처리하기 위한 데이터
    private var urlStr : String?
    
    private let defaultImage : UIImage? = .init(systemName: "photo.artframe")
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnLoad.addTarget(self, action: #selector(self.actionBtn(_:)), for: .touchUpInside)
        self.commonInit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.commonInit()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // 초기화
    private func commonInit() {
        self.imgView.image = defaultImage
        self.btnCallback = nil
    }
    
    public func setData(_ data: DownloadImageModel) {
        self.progressView.updateProgressZeroToOne(0.0)
        self.urlStr = data.urlStr.isEmpty ? nil : data.urlStr
        self.commonInit()
    }
    
    public func loadImage() {
        self.commonInit()
        guard let str = self.urlStr, !str.isEmpty, let url = URL(string: str) else {
            return
        }
        self.imgView.download(from: url) { error, progress in
            if let error {
                NSLog("ERROR Detected : \(error.localizedDescription)")
            }
            self.progressView.updateProgressZeroToOne(progress)
        }
    }
    
    // MVVM 또는 Controller에서 이미지 처리 후 사용하는 경우.
    public func setDatas(_ img: UIImage?, index: Int, progress: Float = 0.5) {
        self.imgView.image = img ?? defaultImage
        self.btnLoad.tag = index
        self.progressView.updateProgressZeroToOne(progress)
    }
    
    // photo.artframe
    @objc private func actionBtn(_ sender: UIButton) {
        if let btnCallback {
            btnCallback(sender.tag)
        } else {
            self.loadImage()
        }
    }
}
