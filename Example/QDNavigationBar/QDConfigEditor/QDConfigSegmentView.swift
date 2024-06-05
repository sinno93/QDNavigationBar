//
//  QDConfigSegmentView.swift
//  QDNavigationBar_Example
//
//  Created by zqd on 2024/6/5.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit

class QDConfigSegmentView: UIView {
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20.0)
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    private var segmentControl: UISegmentedControl!
    private var items: [Any]
    
    var valueChanged: ((Int) -> Void)?
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    var selectedIndex: Int {
        get {
            return segmentControl.selectedSegmentIndex
        }
        set {
            segmentControl.selectedSegmentIndex = newValue
        }
    }
    
    // MARK: - Initialization
    
    init(items: [Any]) {
        self.items = items
        super.init(frame: .zero)
        configSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func configSubviews() {
        segmentControl = UISegmentedControl(items: items)
        segmentControl.apportionsSegmentWidthsByContent = true
        segmentControl.addTarget(self, action: #selector(onValueChanged), for: .valueChanged)
        
        addSubview(titleLabel)
        addSubview(segmentControl)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.trailing.lessThanOrEqualTo(segmentControl.snp.leading).offset(-15)
        }
        
        segmentControl.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
        }
    }
    
    @objc private func onValueChanged() {
        valueChanged?(segmentControl.selectedSegmentIndex)
    }
}

