//
//  ProgressView.swift
//  Challenge-ImageDown
//
//  Created by Dannian Park on 2023/03/05.
//

import UIKit

class ProgressView: UIView {
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    private lazy var progressBar: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = self.progressBarColor
        return view
    }()
    
    public var progressBgColor: UIColor = .gray
    public var progressBarColor: UIColor = .blue
    
    private var widthConstraint : NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColorSetting()
        self.setDefaultProgress()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColorSetting()
        self.setDefaultProgress()
    }
    
    private func backgroundColorSetting() {
        self.backgroundColor = progressBgColor
    }
    
    private func setDefaultProgress() {
        self.addSubview(progressBar)
        if let _ = self.widthConstraint {
            self.widthConstraint = nil
        }
        let widthConst = NSLayoutConstraint(item: progressBar, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.0, constant: 0)
        widthConst.priority = .defaultLow
        // self.widthConstraint = widthConst
        NSLayoutConstraint.activate([
            widthConst,
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: progressBar, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: progressBar, attribute: .leading, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: progressBar, attribute: .bottom, multiplier: 1.0, constant: 0)
        ])
    }
    
    // Value 1.0 ~ 0.0
    public func updateProgressZeroToOne(_ value: Float) {
        guard value >= 0.0 && value <= 1.0 else { return }
        guard let _ = self.widthConstraint else {
            let widthConst = NSLayoutConstraint(item: progressBar, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.0, constant: 0)
            widthConst.priority = .required
            self.widthConstraint = widthConst
            NSLayoutConstraint.activate([self.widthConstraint])
            return
        }
        // print("FLOOAT? \(CGFloat(value))")
        NSLayoutConstraint.deactivate([
            self.widthConstraint
        ])
        self.widthConstraint = NSLayoutConstraint(item: progressBar, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: CGFloat(value), constant: 0)
        NSLayoutConstraint.activate([
            self.widthConstraint
        ])
        
    }
}
