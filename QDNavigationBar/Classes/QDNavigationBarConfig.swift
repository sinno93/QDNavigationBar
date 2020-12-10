//
//  QDNavigationBarConfig.swift
//  QDNavigationBar
//
//  Created by Sinno on 2020/9/16.
//

import UIKit

/// 配置类
final public class QDNavigationBarConfig: NSObject {
    
    /// 导航栏切换动画样式
    @objc public enum TransitionStyle: Int {
        case none // 没有动画
        case separate // 分离
        case fade // 淡入淡出
    }
    /// 导航栏背景颜色
    /// 默认白色(UIColor.white)
    @objc public var backgroundColor: UIColor = UIColor.white {
        didSet {
            guard !backgroundColor.isEqual(oldValue) else {return}
            refreshIfNeed()
        }
    }
    /// 导航栏背景图片
    /// 默认nil
    @objc public var backgroundImage: UIImage? = nil {
        didSet {
            if backgroundImage == oldValue {
                return
            }
            guard let bgImage = backgroundImage,let preBgImage = oldValue,preBgImage.isEqual(bgImage) else {return}
            refreshIfNeed()
        }
    }
    
    /// 导航栏透明度
    /// 默认1.0
    /// 注意此属性仅影响导航栏的透明度，不会影响导航栏上的控件
    @objc public var alpha: CGFloat = 1.0 {
        didSet {
            assert(alpha>=0 && alpha<=1, "alpha必须在[0,1]区间")
            var targetAlpha: CGFloat = CGFloat.maximum(0, alpha)
            targetAlpha = CGFloat.minimum(1, alpha)
            if targetAlpha != alpha {
                alpha = targetAlpha
            }
            guard oldValue != alpha else {return}
            refreshIfNeed()
        }
    }
    /// 是否有半透明效果
    /// 默认false，即无半透明效果
    @objc public var translucent: Bool = false {
        didSet {
            guard translucent != oldValue  else {return}
            refreshIfNeed()
        }
    }
    /// 导航栏底部线条颜色
    /// 默认灰色(UIColor.gray)
    @objc public var shadowLineColor: UIColor = UIColor.gray {
        didSet {
            guard !shadowLineColor.isEqual(oldValue) else {return}
            refreshIfNeed()
        }
    }
    
    /// 导航栏是否隐藏
    /// 默认false，即不隐藏
    @objc public var barHidden: Bool = false {
        didSet {
            guard barHidden != oldValue else {return}
            self.refreshIfNeed()
        }
    }
    
    /// 否开启导航栏事件穿透，
    /// 默认为NO
    /// 为YES时，点击导航栏的事件会透到下层视图
    /// 注意，如果导航栏上有标题、返回按钮等时，点击这些控件的事件不会被穿透
    @objc public var eventThrough: Bool = false {
        didSet {
            guard eventThrough != oldValue else {return}
            refreshIfNeed()
        }
    }
    
    /// 两个视图控制器切换(push/pop)时的样式
    /// 默认为.separate
    /// 具体切换样式遵循以下规则:
    /// 1.当前后两个VC的barConfig配置相同(相同的定义见isSimilar(config:))时，不会有切换动画
    /// 2.当前后两个VC的barConfig配置不同时，切换样式属性在Push时取toVC的transitionStyle,在Pop时取fromVC的transitionStyle
    /// 3.当前后两个VC任意一个为large title模式，或者任意一个的navigationItem.searchController有值，则一定有动画且为.separate
    @objc public var transitionStyle: TransitionStyle = .separate {
        didSet {
            guard transitionStyle != oldValue else {return}
        }
    }
    
    weak var viewController: UIViewController?
    
    func refreshIfNeed() {
        if viewController?.qd_navBarConfig == self {
            viewController?.qd_updateNavIfNeed()
        }
    }
    
}

extension QDNavigationBarConfig: NSCopying {
    public func copy(with zone: NSZone? = nil) -> Any {
        let theCopyObj = type(of: self).init(config: self)
        return theCopyObj
    }
    
    convenience init(config: QDNavigationBarConfig) {
        self.init()
        barHidden = config.barHidden
        backgroundColor = config.backgroundColor
        backgroundImage = config.backgroundImage
        translucent = config.translucent
        shadowLineColor = config.shadowLineColor
        eventThrough = config.eventThrough
        alpha = config.alpha
    }
}


extension QDNavigationBarConfig {
    /// 判断两个配置是否相似(注意这里没有比较shadowLineColor)
    func isSimilar(config: QDNavigationBarConfig) -> Bool {
        if barHidden != config.barHidden {
            return false
        }
        if translucent != config.translucent {
            return false
        }
        if abs(alpha - config.alpha) > 0.01 {
            return false
        }
        if (backgroundImage != nil && config.backgroundImage == nil) || (backgroundImage == nil && config.backgroundImage != nil) {
            return false
        }
        
        if let bgImage = backgroundImage, let image = config.backgroundImage {
            if !bgImage.isEqual(image) {
                return false
            }
        }
        return backgroundColor.isSimilar(color: config.backgroundColor, tolerance: 0.1);
    }
    
}

extension UIColor {
    /// 判断颜色是否类似
    func isSimilar(color: UIColor, tolerance: CGFloat = 0.1) -> Bool {
        var r1:CGFloat = 0, g1:CGFloat = 0, b1:CGFloat = 0, a1:CGFloat = 0
        var r2:CGFloat = 0, g2:CGFloat = 0, b2:CGFloat = 0, a2:CGFloat = 0
        
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return      abs(r1 - r2) <= tolerance &&
                    abs(g1 - g2) <= tolerance &&
                    abs(b1 - b2) <= tolerance &&
                    abs(a1 - a2) <= tolerance
    }
}
