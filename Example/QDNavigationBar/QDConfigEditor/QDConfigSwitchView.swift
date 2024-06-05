//
//  QDConfigSwitchView.swift
//  QDNavigationBar_Example
//
//  Created by zqd on 2024/6/5.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit

class QDConfigSwitchView: UIView {
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20.0)
        label.textColor = .black
        return label
    }()
    
    private var switchView: UISwitch = {
        let switchView = UISwitch()
        return switchView
    }()
    
    var valueChanged: ((Bool) -> Void)?
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    var on: Bool {
        get {
            return switchView.isOn
        }
        set {
            switchView.isOn = newValue
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configSubviews()
    }
    
    // MARK: - Private Methods
    
    private func configSubviews() {
        addSubview(titleLabel)
        addSubview(switchView)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
        }
        
        switchView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-25)
        }
        
        switchView.addTarget(self, action: #selector(onValueChanged), for: .valueChanged)
    }
    
    @objc private func onValueChanged() {
        valueChanged?(switchView.isOn)
    }
}

