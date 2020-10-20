//
//  QDCustomNavFakeView.swift
//  QDNavigationBar
//
//  Created by Sinno on 2020/9/16.
//

import UIKit

class QDCustomNavFakeView: UIView {
    lazy var bottomLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var effectView: UIVisualEffectView = {
        let view = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func configSubviews() {
        
        self.addSubview(self.bottomLineView)
        self.addSubview(self.effectView)
        
        self.bottomLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.bottomLineView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        let onePixel = 1.0/UIScreen.main.scale
        self.bottomLineView.heightAnchor.constraint(equalToConstant: onePixel).isActive = true
        self.bottomLineView.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.effectView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.effectView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.effectView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.effectView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}
