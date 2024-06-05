//
//  QDColorSliderView.swift
//  QDNavigationBar_Example
//
//  Created by zqd on 2024/6/5.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class QDColorGradientView: UIView {
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var colors: [UIColor] = [] {
        didSet {
            guard let layer = layer as? CAGradientLayer else { return }
            var cgColors: [CGColor] = []
            for color in colors {
                cgColors.append(color.cgColor)
            }
            layer.startPoint = CGPoint(x: 0.0, y: 0.5)
            layer.endPoint = CGPoint(x: 1.0, y: 0.5)
            layer.colors = cgColors
        }
    }
}

class QDColorSliderView: UIView {
    
    // MARK: - Properties
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    private var sliderView: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .clear
        slider.maximumTrackTintColor = .clear
        slider.addTarget(self, action: #selector(onValueChange(_:)), for: .valueChanged)
        return slider
    }()
    
    private var gradientView: QDColorGradientView = {
        let gradientView = QDColorGradientView()
        let color1 = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        let color2 = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        gradientView.colors = [color1, color2]
        return gradientView
    }()
    
    private var bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "opacityImage")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var valueChanged: ((CGFloat) -> Void)?
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    var value: CGFloat {
        get {
            return CGFloat(sliderView.value)
        }
        set {
            let value = max(newValue, 0)
            sliderView.value = Float(min(value, 1))
        }
    }
    
    var colors: [UIColor] {
        get {
            return gradientView.colors
        }
        set {
            gradientView.colors = newValue
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configSubviews()
    }
    
    // MARK: - Private Methods
    
    private func configSubviews() {
        addSubview(titleLabel)
        addSubview(bgImageView)
        addSubview(gradientView)
        addSubview(sliderView)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
        }
        
        sliderView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(1)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        gradientView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(sliderView)
            make.centerY.equalToSuperview()
            make.height.equalTo(10)
        }
        
        bgImageView.snp.makeConstraints { make in
            make.edges.equalTo(gradientView)
        }
        
        gradientView.layer.cornerRadius = 5
        bgImageView.layer.cornerRadius = 5
        bgImageView.layer.masksToBounds = true
        gradientView.layer.borderColor = UIColor.lightGray.cgColor
        gradientView.layer.borderWidth = 1.0 / UIScreen.main.scale
    }
    
    // MARK: - Action Methods
    
    @objc private func onValueChange(_ slider: UISlider) {
        valueChanged?(CGFloat(slider.value))
    }
}

