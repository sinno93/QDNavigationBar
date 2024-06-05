//
//  QDColorPickerController.swift
//  QDNavigationBar_Example
//
//  Created by zqd on 2024/6/5.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit

class QDColorPickerController: UIViewController {

    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 1.0 / UIScreen.main.scale
        view.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
        
        return view
    }()
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 1.0
        return stackView
    }()
    
    private lazy var redSliderView = {
        let view = QDColorSliderView()
        view.title = "Red"
        return view
    }()
    
    private var greenSliderView = {
        let view = QDColorSliderView()
        view.title = "Green"
        return view
    }()
    
    private var blueSliderView = {
        let view = QDColorSliderView()
        view.title = "Blue"
        return view
    }()
    
    private var alphaSliderView = {
        let view = QDColorSliderView()
        view.title = "Alpha"
        return view
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("确定", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(closeButtonClick(_:)), for: .primaryActionTriggered)
        return button
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "颜色选择器"
        return label
    }()
    
    var colorChanged: ((UIColor) -> Void)?
    var color: UIColor? {
        didSet {
            setData()
        }
    }

    // MARK: - Initialization

    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configSubviews()
        setData()
        containerView.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        show()
    }

    // MARK: - Actions

    @objc private func onColorChanged() {
        let red = redSliderView.value
        let green = greenSliderView.value
        let blue = blueSliderView.value
        let alpha = alphaSliderView.value
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        self.color = color
        setData()
        colorChanged?(color)
    }

    @objc private func closeButtonClick(_ button: UIButton) {
        dismiss()
    }

    @objc private func emptyTap(_ tap: UITapGestureRecognizer) {
        let point = tap.location(in: containerView)
        if !containerView.bounds.contains(point) {
            dismiss()
        }
    }

    // MARK: - Public Methods

    func show() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0)
        view.layoutIfNeeded()
        containerView.isHidden = false
        containerView.transform = CGAffineTransform(translationX: 0, y: containerView.frame.size.height)
        UIView.animate(withDuration: 0.35) {
            self.containerView.transform = .identity
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.35, animations: {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.containerView.frame.size.height)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }) { finished in
            self.dismiss(animated: false, completion: nil)
        }
    }

    private func setData() {
        guard let color = self.color else {
            return
        }
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        redSliderView.value = red
        greenSliderView.value = green
        blueSliderView.value = blue
        alphaSliderView.value = alpha
        
        redSliderView.colors = [colorWithRGB(0, green, blue), colorWithRGB(1, green, blue)]
        greenSliderView.colors = [colorWithRGB(red, 0, blue), colorWithRGB(red, 1, blue)]
        blueSliderView.colors = [colorWithRGB(red, green, 0), colorWithRGB(red, green, 1)]
        alphaSliderView.colors = [colorWithRGBA(0, 0, 0, 0), colorWithRGBA(0, 0, 0, 1)]
        colorView.backgroundColor = color
        
        // 计算反差色
        let contrastColor: UIColor
        let grayLevel = 0.299 * red + 0.587 * green + 0.114 * blue
        if grayLevel > 0.5 || alpha < 0.5 {
            contrastColor = .black
        } else {
            contrastColor = .white
        }
        titleLabel.textColor = contrastColor
        closeButton.setTitleColor(contrastColor, for: .normal)
        titleLabel.text = QDColorPickerController.hexString(from: color)
    }

    // MARK: - Private Methods

    private func configSubviews() {
        view.backgroundColor = .clear
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
                make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
                make.bottom.equalTo(view)
            } else {
                make.leading.trailing.equalTo(view)
                make.bottom.equalTo(view)
            }
        }
        
        let bgView = UIView()
        bgView.backgroundColor = .white
        containerView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view)
            make.top.bottom.equalTo(containerView)
        }
        
        containerView.addSubview(colorView)
        containerView.addSubview(closeButton)
        containerView.addSubview(stackView)
        
        colorView.snp.makeConstraints { make in
            make.top.equalTo(containerView)
            make.leading.trailing.equalTo(view)
            make.height.equalTo(44)
        }
        
        closeButton.snp.makeConstraints { make in
            make.right.equalTo(containerView.snp.right).offset(-15)
            make.centerY.equalTo(colorView)
        }
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(containerView)
            make.top.equalTo(colorView.snp.bottom).offset(15)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(containerView.safeAreaLayoutGuide.snp.bottom).offset(-15)
            } else {
                make.bottom.equalTo(containerView).offset(-15)
            }
        }
        
        let sliders = [redSliderView, greenSliderView, blueSliderView, alphaSliderView]
        sliders.forEach { slider in
            stackView.addArrangedSubview(slider)
            slider.snp.makeConstraints { make in
                make.height.equalTo(40)
            }
            slider.valueChanged = { [weak self] value in
                self?.onColorChanged()
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(emptyTap(_:)))
        view.addGestureRecognizer(tap)
    }

    private func colorWithRGB(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
        return colorWithRGBA(r, g, b, 1)
    }

    private func colorWithRGBA(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    // MARK: - Utility Methods

    private static func hexString(from color: UIColor) -> String {
        let colorSpace = color.cgColor.colorSpace!.model
        let components = color.cgColor.components!

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        if colorSpace == .monochrome {
            r = components[0]
            g = components[0]
            b = components[0]
            a = components[1]
        } else if colorSpace == .rgb {
            r = components[0]
            g = components[1]
            b = components[2]
            a = components[3]
        }

        return String(format: "#%02lX%02lX%02lX%02lX",
                      lroundf(Float(r * 255)),
                      lroundf(Float(g * 255)),
                      lroundf(Float(b * 255)),
                      lroundf(Float(a * 255)))
    }
}
