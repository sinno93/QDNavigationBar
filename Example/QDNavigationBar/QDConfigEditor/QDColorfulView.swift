//
//  QDColorfulView.swift
//  QDNavigationBar_Example
//
//  Created by zqd on 2024/6/5.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit

class QDColorfulView: UIView {
    
    // MARK: - Properties
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.spacing = 10.0
        stackView.backgroundColor = .gray
        return stackView
    }()
    
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
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 13, bottom: 8, right: 13))
        }
        
        let colorArray: [UIColor] = [.red, .green, .blue, .cyan, .magenta]
        for color in colorArray {
            let view = UIView()
            view.backgroundColor = color
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 30, height: 30))
                // Uncomment below lines if you want to make width equal to height
                // make.width.equalTo(view.snp.height)
                // make.height.equalTo(30)
            }
        }
        
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1.0 / UIScreen.main.scale
        layer.cornerRadius = 15.0
    }
}

