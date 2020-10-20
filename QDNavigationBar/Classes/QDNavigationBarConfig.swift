//
//  QDNavigationBarConfig.swift
//  QDNavigationBar
//
//  Created by Sinno on 2020/9/16.
//

import UIKit

protocol QDNavigationBarConfigDelegate: class {
    func qdNavigationBarConfigChanged(config: QDNavigationBarConfig);
}

/// 配置类
final public class QDNavigationBarConfig: NSObject {
    
    /// 导航栏是否显示
    @objc public var barHidden: Bool = false {
        didSet {
            if barHidden != oldValue {
                refreshIfNeed()
            }
        }
    }
    /// 导航栏背景颜色
    @objc public var bgColor: UIColor = UIColor.white {
        didSet {
            if !bgColor.isEqual(oldValue) {
                refreshIfNeed()
            }
        }
    }
    /// 是否有半透明效果
    @objc public var translucent: Bool = true {
        didSet {
            if translucent != oldValue {
                refreshIfNeed()
            }
        }
    }
    /// 线条
    @objc public var shadowLineColor: UIColor = UIColor.black {
        didSet {
            if !shadowLineColor.isEqual(oldValue) {
                refreshIfNeed()
            }
        }
    }
    /// 否开启导航栏事件穿透，为YES时，点击导航栏的事件会透到下层视图 默认为NO
    /// 注意，如果导航栏上有标题、返回按钮等时，点击这些控件的事件不会被穿透
    @objc public var eventThrough: Bool = false {
        didSet {
            if eventThrough != oldValue {
                refreshIfNeed()
            }
        }
    }
    weak var viewController: UIViewController?
    weak var delegate: QDNavigationBarConfigDelegate?
    
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
