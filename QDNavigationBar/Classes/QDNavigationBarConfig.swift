//
//  QDNavigationBarConfig.swift
//  QDNavigationBar
//
//  Created by Sinno on 2020/9/16.
//

import UIKit

/// 配置类
final public class QDNavigationBarConfig: NSObject {
    
    /// 在页面切换(Push或Pop)时，导航栏切换的动画样式
    ///
    /// * .none: 样式直接变化，没有动画
    ///
    /// * .separate:随着页面分离
    /// * .fade: 渐变效果
    /// * .automatic: 会根据情况选择上面合适的切换样式:
    ///    - 1.前后两个VC任意一个为largetitle模式，则取`.separate`
    ///    - 2.前后两个VC任意一个导航栏上有搜索框(navigationItem.searchController != nil),则取`.separate`
    ///    - 3.前后两个VC的barConfig相同，则取`.none`
    ///    - 4.前后两个VC的barConfig不同，则取`.separate`
    @objc public enum TransitionStyle: Int {
        case none
        case separate
        case fade
        case automatic
    }
    /// 导航栏背景颜色
    /// 默认白色(UIColor.white)
    @objc public var backgroundColor: UIColor = UIColor.white {
        didSet {
            guard backgroundColor != oldValue else {return}
            refreshIfNeed()
        }
    }
    /// 导航栏背景图片
    /// 默认nil
    @objc public var backgroundImage: UIImage? = nil {
        didSet {
            guard backgroundImage != oldValue else {return}
            refreshIfNeed()
        }
    }
    
    /// 导航栏背景透明度
    /// 默认1.0
    ///
    /// 注意此属性仅影响导航栏背景的透明度，不会影响导航栏上的控件(比如标题、返回键...)
    @objc public var alpha: CGFloat = 1.0 {
        didSet {
            guard oldValue != alpha else {return}
            assert(alpha>=0 && alpha<=1, "alpha必须在[0,1]区间")
            var targetAlpha: CGFloat = CGFloat.maximum(0, alpha)
            targetAlpha = CGFloat.minimum(1, alpha)
            if targetAlpha != alpha {
                alpha = targetAlpha
            }
            refreshIfNeed()
        }
    }
    
    /// 是否需要模糊效果
    /// 默认false，即不需要
    ///
    /// 设置为true后，可通过blurStyle控制模糊效果样式
    @objc public var needBlurEffect: Bool = false {
        didSet {
            guard needBlurEffect != oldValue  else {return}
            refreshIfNeed()
        }
    }
    /// 模糊效果样式
    /// 默认.light
    ///
    /// 在needBlurEffect为true时，此属性有效
    @objc public var blurStyle: UIBlurEffect.Style = .light {
        didSet {
            guard blurStyle != oldValue  else {return}
            refreshIfNeed()
        }
    }
    
    /// 导航栏底部线条颜色
    /// 默认透明(UIColor.clear)
    @objc public var bottomLineColor: UIColor = UIColor.clear {
        didSet {
            guard bottomLineColor != oldValue else {return}
            refreshIfNeed()
        }
    }
    
    /// 是否需要管理状态栏
    /// 该属性仅对UINavigationController的config有效，默认true；
    ///
    /// 对于一个UINavigationController来说，其config的needManagerStatusBar值：
    /// * 为true时，QDNavigationBar会根据topViewController的config的statusBarStyle、statusBarHidden的值来修改状态栏样式
    /// * 为false时，此时QDNavigationBar不会对状态栏进行任何设置和更改，也即 statusBarStyle、statusBarHidden的值无效；
    @objc public var needManagerStatusBar: Bool = true {
        didSet {
            guard needManagerStatusBar != oldValue else {return}
            refreshIfNeed()
        }
    }
    
    /// 状态栏样式
    /// 默认.default
    @objc public var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            // 不同 则刷新
            if statusBarStyle != oldValue {
                self.refreshIfNeed()
            }
        }
    }
    /// 状态栏是否隐藏
    /// 默认false,即不隐藏
    @objc public var statusBarHidden: Bool = false {
        didSet {
            if statusBarHidden != oldValue {
                self.refreshIfNeed()
            }
        }
    }
    
    /// 导航栏是否隐藏
    /// 默认false,即不隐藏
    @objc public var barHidden: Bool = false {
        didSet {
            guard barHidden != oldValue else {return}
            self.refreshIfNeed()
        }
    }
    
    /// 否开启导航栏事件穿透，
    /// 默认为false, 为true时，点击导航栏的事件会透到下层视图
    ///
    /// 注意，如果导航栏上有标题、返回按钮等时，点击这些控件的事件不会被穿透
    @objc public var eventThrough: Bool = false {
        didSet {
            guard eventThrough != oldValue else {return}
            refreshIfNeed()
        }
    }
    
    /// 两个视图控制器切换(push/pop)时,导航栏转场样式,默认为.automatic
    ///
    /// push时: 切换样式取toVC的transitionStyle，比如A push B，此时toVC为B,取B的切换样式
    ///
    /// pop时: 切换样式取fromVC的transitionStyle，比如A pop, 此时fromVC为A,取A的切换样式
    ///
    /// ## 具体切换样式表现，见TransitionStyle注释
    @objc public var transitionStyle: TransitionStyle = .automatic {
        didSet {
            guard transitionStyle != oldValue else {return}
        }
    }
    
    private class WeakContainer<T>:Equatable where T:AnyObject, T:Equatable {
        static func == (lhs: QDNavigationBarConfig.WeakContainer<T>, rhs: QDNavigationBarConfig.WeakContainer<T>) -> Bool {
            return lhs.value == rhs.value
        }
        
        private(set) weak var value:T?
        init(value:T) {
            self.value = value
        }
    }
    
    // config可以被多个vc设置为navBarConfig
    // 此时当config被修改时，多个vc的样式都要同步进行修改
    private var vcList:[WeakContainer<UIViewController>] = []
    
    func add(vc: UIViewController) {
        self.remove(vc: nil)
        let item = WeakContainer(value: vc)
        if !vcList.contains(item) {
            vcList.append(item)
        }
    }
    
    func remove(vc: UIViewController?) {
        vcList.removeAll { (item) -> Bool in
            item.value == vc
        }
    }
    
    func contain(vc: UIViewController) -> Bool {
        vcList.contains(WeakContainer(value: vc))
    }
    
    private func refreshIfNeed() {
        for item in vcList {
            if let vc = item.value, vc.navBarConfig == self {
                vc.qd_updateNavIfNeed()
            }
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
        backgroundColor = config.backgroundColor
        backgroundImage = config.backgroundImage
        needBlurEffect  = config.needBlurEffect
        blurStyle       = config.blurStyle
        alpha           = config.alpha
        bottomLineColor = config.bottomLineColor
        statusBarStyle  = config.statusBarStyle
        statusBarHidden = config.statusBarHidden
        barHidden       = config.barHidden
        eventThrough    = config.eventThrough
        transitionStyle = config.transitionStyle
    }
}


extension QDNavigationBarConfig {
    /// 判断两个配置的样式是否相似
    /// transitionStyle、bottomLineColor、eventThrough被忽略，不做比较
    func isSimilarStyle(config: QDNavigationBarConfig) -> Bool {
        if barHidden != config.barHidden {
            return false
        }
        if needBlurEffect != config.needBlurEffect {
            return false
        }
        
        if blurStyle != config.blurStyle {
            return false
        }
    
        if abs(alpha - config.alpha) > 0.01 {
            return false
        }
        if backgroundImage != config.backgroundImage {
            return false
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
