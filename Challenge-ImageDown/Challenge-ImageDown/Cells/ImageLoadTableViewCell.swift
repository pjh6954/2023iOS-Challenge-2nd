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
    private let defaultImage : UIImage? = .init(systemName: "photo.artframe")
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnLoad.addTarget(self, action: #selector(self.actionBtn(_:)), for: .touchUpInside)
        self.imgView.image = defaultImage
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imgView.image = defaultImage
        self.btnCallback = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setDatas(_ img: UIImage?, index: Int, progress: Float = 0.5) {
        self.imgView.image = img ?? defaultImage
        self.btnLoad.tag = index
        self.progressView.updateProgressZeroToOne(progress)
    }
    
    // photo.artframe
    @objc private func actionBtn(_ sender: UIButton) {
        self.btnCallback?(sender.tag)
    }
}
