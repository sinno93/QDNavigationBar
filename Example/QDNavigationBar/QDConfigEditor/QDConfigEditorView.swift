//
//  QDConfigEditorView.swift
//  QDNavigationBar_Example
//
//  Created by zqd on 2024/6/5.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit
import QDNavigationBar

class QDConfigEditorView: UIView {
    
    private var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.spacing = 1.0
        return view
    }()
    
    private lazy var bgColorView: QDConfigColorView = {
        let view = QDConfigColorView()
        view.title = "backgroundColor"
        view.color = .white
        view.colorChanged = { [weak self] in
            self?.config?.backgroundColor = $0
        }
        
        return view
    }()
    
    private lazy var bottomLineColorView: QDConfigColorView = {
        let view = QDConfigColorView()
        view.title = "bottomLineColor"
        view.color = .red
        
        view.colorChanged = { [weak self] in
            self?.config?.bottomLineColor = $0
        }
        
        
        return view
    }()
    
    private lazy var barHiddenView: QDConfigSwitchView = {
        let view = QDConfigSwitchView()
        view.title = "barHidden"
        view.on = true
        
        view.valueChanged = { [weak self] in
            self?.config?.barHidden = $0
        }
        
        return view
    }()
    
    private lazy var translucentView: QDConfigSwitchView = {
        let view = QDConfigSwitchView()
        view.title = "needBlurEffect"
        view.on = true
        view.valueChanged = { [weak self] in
            self?.config?.needBlurEffect = $0
        }
        return view
    }()
    
    private lazy var statusBarHiddenView: QDConfigSwitchView = {
        let view = QDConfigSwitchView()
        view.title = "statusBarHidden"
        view.on = true
        
        view.valueChanged = { [weak self] in
            self?.config?.statusBarHidden = $0
        }
        
        return view
    }()
    
    private lazy var statusBarStyleView: QDConfigSegmentView = {
        let items: [String]
        if #available(iOS 13.0, *) {
            items = ["Default", "Light", "Dark"]
        } else {
            items = ["Default", "Light"]
        }
        let view = QDConfigSegmentView(items: items)
        view.title = "statusBarStyle"
        view.selectedIndex = 0
                
        view.valueChanged = { [weak self] selectedIndex in
            let styles = [UIStatusBarStyle.default, .lightContent, .darkContent]
            let selectedStyle = styles[selectedIndex]
            self?.config?.statusBarStyle = selectedStyle
        }
        
        return view
    }()
    
    private lazy var bgImageView: QDConfigSegmentView = {
        let sunImage = UIImage(named: "sun_thumb")?.withRenderingMode(.alwaysOriginal)
        let rainImage = UIImage(named: "rain_thumb")?.withRenderingMode(.alwaysOriginal)
        let view = QDConfigSegmentView(items: ["none", sunImage as Any, rainImage as Any])
        view.title = "backgroundImage"
        view.selectedIndex = 0
        
        view.valueChanged = { [weak self] selectedIndex in
            let images: [UIImage?] = [nil, self?.sunBgImage, self?.rainBgImage]
            self?.config?.backgroundImage = images[selectedIndex]
        }
        return view
    }()
    
    private var sunBgImage: UIImage?
    private var rainBgImage: UIImage?
    
    var config: QDNavigationBarConfig? {
        didSet {
            updateView()
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sunBgImage = UIImage(named: "sun_nav")
        rainBgImage = UIImage(named: "rain_nav")
        configSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sunBgImage = UIImage(named: "sun_nav")
        rainBgImage = UIImage(named: "rain_nav")
        configSubviews()
    }
    
    // MARK: - Private Methods
    
    private func configSubviews() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 0, bottom: 5, right: 0))
        }
        
        let views: [UIView] = [
            bgColorView,
            bottomLineColorView,
            barHiddenView,
            translucentView,
            statusBarHiddenView,
            statusBarStyleView,
            bgImageView
        ]
        
        for view in views {
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints { make in
                make.height.equalTo(48)
            }
        }
        
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1.0 / UIScreen.main.scale
        layer.cornerRadius = 15
    }
    
    private func updateView() {
        guard let config = config else { return }
        
        bgColorView.color = config.backgroundColor
        bottomLineColorView.color = config.bottomLineColor
        barHiddenView.on = config.barHidden
        translucentView.on = config.needBlurEffect
        statusBarHiddenView.on = config.statusBarHidden
        
        statusBarStyleView.selectedIndex = {
            switch config.statusBarStyle {
            case .default:
                return 0
            case .lightContent:
                return 1
            case .darkContent:
                return 2
            @unknown default:
                return 0
            }
        }()
        
        bgImageView.selectedIndex = {
            if config.backgroundImage == nil {
                return 0
            } else if config.backgroundImage == sunBgImage {
                return 1
            } else {
                return 2
            }
        }()
    }
    
    // MARK: - Getter & Setter
    
    private func setupColorView(_ view: QDConfigColorView, title: String, defaultColor: UIColor, colorChangedHandler: @escaping (UIColor) -> Void) -> QDConfigColorView {
        view.title = title
        view.color = defaultColor
        view.colorChanged = { color in
            colorChangedHandler(color)
        }
        return view
    }
    
    private func setupSwitchView(_ view: QDConfigSwitchView, title: String, defaultOn: Bool, valueChangedHandler: @escaping (Bool) -> Void) -> QDConfigSwitchView {
        view.title = title
        view.on = defaultOn
        view.valueChanged = { on in
            valueChangedHandler(on)
        }
        return view
    }
    
    private func setupSegmentView(_ view: QDConfigSegmentView, title: String, defaultIndex: Int, valueChangedHandler: @escaping (Int) -> Void) -> QDConfigSegmentView {
        view.title = title
        view.selectedIndex = defaultIndex
        view.valueChanged = { selectedIndex in
            valueChangedHandler(selectedIndex)
        }
        return view
    }
    
    // MARK: - View Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configSubviews()
    }
}

