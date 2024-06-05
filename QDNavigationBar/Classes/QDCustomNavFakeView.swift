//
//  QDCustomNavFakeView.swift
//  QDNavigationBar
//
//  Created by Sinno on 2020/9/16.
//

import UIKit

class QDCustomNavFakeView: UIView {
    
    var blurEffectStyle: UIBlurEffect.Style = .light {
        didSet {
            guard blurEffectStyle != oldValue else {return}
            self.effectView.effect = UIBlurEffect(style: blurEffectStyle)
        }
    }
    
    lazy var bottomLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var effectView: UIVisualEffectView = {
        let view = UIVisualEffectView.init(effect: UIBlurEffect.init(style: self.blurEffectStyle))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configSubviews()
    }
    
    public func configSubviews() {
        self.addSubview(self.bottomLineView)
        self.addSubview(self.imageView)
        self.addSubview(self.effectView)
        let onePixel = 1.0/UIScreen.main.scale
        
        NSLayoutConstraint.activate([
            self.bottomLineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.bottomLineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.bottomLineView.heightAnchor.constraint(equalToConstant: onePixel),
            self.bottomLineView.topAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        self.imageView.qd_fullWithView(view: self)
        self.effectView.qd_fullWithView(view: self)
    }
}
