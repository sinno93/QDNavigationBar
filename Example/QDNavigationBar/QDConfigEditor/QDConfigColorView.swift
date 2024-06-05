//
//  QDConfigColorView.swift
//  QDNavigationBar_Example
//
//  Created by zqd on 2024/6/5.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit

class QDConfigColorView: UIView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20.0)
        label.textColor = .black
        return label
    }()
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 1.0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(colorTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "expand_icon")?.withRenderingMode(.alwaysTemplate)
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        return view
    }()
    
    private lazy var bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "alphaImage")
        return imageView
    }()
    
    var color: UIColor = .white {
        didSet {
            colorView.backgroundColor = color
            updateTintColor()
        }
    }
    
    var title: String {
        get {
            titleLabel.text ?? ""
        }
        
        set {
            titleLabel.text = newValue
        }
    }
    
    var colorChanged: ((UIColor) -> Void)?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configSubviews()
    }
    
    // MARK: - Actions
    @objc private func colorTap(_ tap: UITapGestureRecognizer) {
        let vc = QDColorPickerController()
        vc.color = self.color
        
        getViewController()?.present(vc, animated: false, completion: nil)
        vc.colorChanged = { [weak self] color in
            self?.color = color
            self?.colorChanged?(color)
        }
    }
    
    // MARK: - Private Methods
    private func configSubviews() {
        addSubview(titleLabel)
        addSubview(bgImageView)
        addSubview(colorView)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.leading.equalTo(self).offset(15)
        }
        
        colorView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).offset(-25)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        bgImageView.snp.makeConstraints { make in
            make.edges.equalTo(colorView)
        }
    }
    
    private func updateTintColor() {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let grayLevel = (0.299 * red + 0.587 * green + 0.114 * blue)
        colorView.tintColor = (grayLevel > 0.5 || alpha < 0.5) ? .black : .white
    }
    
    private func getViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
    
}

