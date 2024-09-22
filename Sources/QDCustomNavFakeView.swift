//
//  QDCustomNavFakeView.swift
//  QDNavigationBar
//
//  Created by Sinno on 2020/9/16.
//

import UIKit

class QDCustomNavFakeView: UIView {
    
    private var blurEffectStyle: UIBlurEffect.Style = .light {
        didSet {
            guard blurEffectStyle != oldValue else {return}
            self.effectView.effect = UIBlurEffect(style: blurEffectStyle)
        }
    }
    
    private lazy var bottomLineView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var effectView: UIVisualEffectView = {
        let view = UIVisualEffectView.init(effect: UIBlurEffect.init(style: self.blurEffectStyle))
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
        self.effectView.frame = self.bounds
        
        let onePixel = 1.0 / UIScreen.main.scale
        bottomLineView.frame = CGRect(x: 0, y: self.bounds.size.height, width: self.bounds.size.width, height: onePixel)
    }
    
    private func configSubviews() {
        self.addSubview(self.bottomLineView)
        self.addSubview(self.imageView)
        self.addSubview(self.effectView)
    }
}

extension QDCustomNavFakeView {
    func configView(_ config: QDNavigationBarConfig) {
        self.backgroundColor = config.backgroundColor
        self.bottomLineView.backgroundColor = config.bottomLineColor
        self.blurEffectStyle = config.blurStyle
        self.effectView.isHidden = !config.needBlurEffect;
        self.imageView.image = config.backgroundImage
        self.alpha = config.alpha
    }
}
