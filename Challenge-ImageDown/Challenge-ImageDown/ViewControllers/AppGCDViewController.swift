//
//  AppGCDViewController.swift
//  Challenge-ImageDown
//
//  Created by Dannian Park on 2023/03/06.
//

import UIKit

fileprivate enum ImageURL {
    private static let imageIds: [String] = [
        "europe-4k-1369012",
        "europe-4k-1318341",
        "europe-4k-1379801",
        "cool-lion-167408",
        "iron-man-323408"
    ]
    
    static subscript(index: Int) -> URL {
        let id = imageIds[index]
        return URL(string: "https://wallpaperaccess.com/download/"+id)!
    }
    
    static var count: Int {
        imageIds.count
    }
}

final class AppGCDViewController: UIViewController {
    private var views: [DisplayedView] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewInit()
        
        views.forEach{ $0.reset() }
    }
    
    private func viewInit() {
        views.removeAll()
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        // stackView.backgroundColor = .gray
        stackView.axis = .vertical
        stackView.spacing = 10
        self.view.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        let heightAnchor = stackView.heightAnchor.constraint(equalToConstant: 0)
        heightAnchor.priority = .defaultLow
        heightAnchor.isActive = true
        stackView.bottomAnchor.constraint(lessThanOrEqualTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        for index in (0 ..< ImageURL.count) {
            let createdView = createDisplayedView(index)
            stackView.addArrangedSubview(createdView)
            // createdView.reset()
            self.views.append(createdView)
        }
        
        var configure = UIButton.Configuration.filled()
        configure.title = "Reload ALL Images"
        let action = UIAction { _ in
            self.views.forEach { $0.loadImage() }
        }
        let resetButton: UIButton = UIButton(configuration: configure, primaryAction: action)
        stackView.addArrangedSubview(resetButton)
        resetButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func createDisplayedView(_ index: Int) -> DisplayedView {
        let displayedView = DisplayedView(frame: .zero)
        displayedView.setTag(index)
        displayedView.translatesAutoresizingMaskIntoConstraints = false
        return displayedView
    }
    
    @IBAction private func actionLoadAllImageButton(_ sender: UIButton) {
        
    }
}


final class DisplayedView: UIView {
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.backgroundColor = .red
        return view
    }()
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        // view.backgroundColor = .green
        return view
    }()
    
    private lazy var loadButton: UIButton = {
        let view = UIButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        // view.backgroundColor = .blue
        // view.safeAreaInsets = .init(top: 10, left: 20, bottom: 10, right: 20)
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.filled()
            // configuration.title = "Title"
            // configuration.image = UIImage(systemName: "swift")
            // configuration.titlePadding = 10
            // configuration.imagePadding = 10
            configuration.baseBackgroundColor = .green
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
            view.configuration = configuration
        } else {
            view.contentEdgeInsets = .init(top: 10, left: 20, bottom: 10, right: 20)
        }
        return view
    }()
    
    // Progress 를 얻기 위한 Observer
    private var observation: NSKeyValueObservation!
    private var task: URLSessionDataTask!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.viewInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.viewInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.viewInit()
    }
    
    deinit {
        observation.invalidate()
        observation = nil
    }
    
    func viewInit() {
        self.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.35),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.8)
        ])
        
        self.addSubview(loadButton)
        NSLayoutConstraint.activate([
            loadButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            loadButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        self.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            progressView.trailingAnchor.constraint(equalTo: loadButton.leadingAnchor, constant: -10),
            progressView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        loadButton.setTitle("Stop", for: .selected)
        loadButton.setTitle("Load", for: .normal)
        loadButton.isSelected = false
        
        loadButton.addTarget(self, action: #selector(self.touchUpLoadButton(_:)), for: .touchUpInside)
    }
    
    public func setTag(_ tag: Int) {
        self.loadButton.tag = tag
    }
    
    func reset() {
        imageView.image = .init(systemName: "photo")
        progressView.progress = 0
        loadButton.isSelected = false
    }
    
    func loadImage() {
        loadButton.sendActions(for: .touchUpInside)
    }
    
    @objc private func touchUpLoadButton(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        guard sender.isSelected else {
            task.cancel()
            return
        }
        
        guard (0...4).contains(sender.tag) else {
            fatalError("버튼 태그를 확인해주세요")
        }
        let url = ImageURL[sender.tag]
        let request = URLRequest(url: url)
        
        task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                guard error.localizedDescription == "cancelled" else {
                    fatalError(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    self.reset()
                }
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.imageView.image = .init(systemName: "xmark")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.imageView.image = image
                self.loadButton.isSelected = false
            }
        }
        
        observation = task.progress.observe(\.fractionCompleted,
                                             options: [.new],
                                             changeHandler: { progress, change in
            DispatchQueue.main.async {
                self.progressView.progress = Float(progress.fractionCompleted)
            }
        })
        
        task.resume()
    }
}
