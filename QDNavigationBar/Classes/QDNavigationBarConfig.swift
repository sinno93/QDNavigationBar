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
    public enum TransitionStyle {
        case none // 没有动画
        case separate // 分离
        case fade // 淡入淡出
    }
    /// 导航栏是否显示
    public var barHidden: Bool = false {
        didSet {
            if barHidden != oldValue {
                refreshIfNeed()
            }
        }
    }
    /// 导航栏背景颜色
    public var bgColor: UIColor = UIColor.white {
        didSet {
            if !bgColor.isEqual(oldValue) {
                refreshIfNeed()
            }
        }
    }
    /// 是否有半透明效果
    public var translucent: Bool = false {
        didSet {
            if translucent != oldValue {
                refreshIfNeed()
            }
        }
    }
    /// 线条
    public var shadowLineColor: UIColor = UIColor.black {
        didSet {
            if !shadowLineColor.isEqual(oldValue) {
                refreshIfNeed()
            }
        }
    }
    /// 否开启导航栏事件穿透，为YES时，点击导航栏的事件会透到下层视图 默认为NO
    /// 注意，如果导航栏上有标题、返回按钮等时，点击这些控件的事件不会被穿透
    public var eventThrough: Bool = false {
        didSet {
            if eventThrough != oldValue {
                refreshIfNeed()
            }
        }
    }
    
    /// 两个视图控制器切换(push/pop)时的样式
    /// 具体切换样式遵循以下规则:
    /// 1.当前后两个VC的barConfig配置相同(相同的定义见isSimilar(config:))时，不会有切换动画
    /// 2.当前后两个VC的barConfig配置不同时，切换样式属性在Push时取toVC的transitionStyle,在Pop时取fromVC的transitionStyle
    /// 3.当前后两个VC任意一个为large title模式，或者任意一个的navigationItem.searchController有值，则一定有动画且为.separate
    public var transitionStyle: TransitionStyle = .separate
    
    weak var viewController: UIViewController?
    
    func refreshIfNeed() {
        if viewController?.qd_navConfig == self {
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
        bgColor = config.bgColor
        translucent = config.translucent
        shadowLineColor = config.shadowLineColor
        eventThrough = config.eventThrough
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
        return bgColor.isSimilar(color: config.bgColor, tolerance: 0.1);
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
