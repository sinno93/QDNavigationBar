//
//  UINavigationController+QDNavigationBar.swift
//  QDNavigationBar
//
//  Created by Sinno on 2020/9/18.
//

import UIKit

extension UINavigationController {
    static var qd_configKey = "qd_configkey"
    static var qd_helperKey = "qd_helperKey"
    
    var qd_navhelper: QDNavigationControllerHelper? {
        set {
            objc_setAssociatedObject(self, &UINavigationController.qd_helperKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let result = objc_getAssociatedObject(self, &UINavigationController.qd_helperKey) as? QDNavigationControllerHelper
            return result
        }
    }
    @objc public override var qd_navBarConfig: QDNavigationBarConfig? {
        willSet {
            guard newValue != nil else {return}
            QDSwizzlingManger.runOnce()
            if qd_navhelper == nil {
                qd_navhelper = QDNavigationControllerHelper.init(nav: self)
            }
            if !(self.delegate is QDNavigationControllerHelper) {
                qd_navhelper?.navRealDelegate = delegate;
            }
            self.delegate = qd_navhelper
        }
    }
}

extension UINavigationController {
    func qd_navBarConfigChanged(vc: UIViewController) {
        self.qd_navhelper?.navConfigChanged(vc: vc)
    }
    override func qd_updateNavIfNeed() {
        guard let config = self.qd_navBarConfig else {return}
        assert(config.contain(vc: self), "config不包含当前VC") // 理论上不会出现
        self.qd_navBarConfigChanged(vc: self.topViewController ?? self)
    }
}

extension UINavigationController {
    override class func qdSwizzling() {
        qdExchangeMethod(#selector(setter: delegate), selector2: #selector(qd_setDelegate(_:)))
        qdExchangeMethod(#selector(getter: preferredStatusBarStyle), selector2: #selector(qd_preferredStatusBarStyle))
        qdExchangeMethod(#selector(getter: prefersStatusBarHidden), selector2: #selector(qd_prefersStatusBarHidden))
        qdExchangeMethod(#selector(getter:childForStatusBarHidden), selector2: #selector(qd_childForStatusBarHidden))
        qdExchangeMethod(#selector(getter:childForStatusBarStyle), selector2: #selector(qd_childForStatusBarStyle))
    }
    @objc func qd_setDelegate(_ delegate: UINavigationControllerDelegate?) {
        if delegate is QDNavigationControllerHelper {
            qd_setDelegate(delegate)
        } else if qd_navhelper == nil {
            qd_setDelegate(delegate)
        } else {
            qd_navhelper?.navRealDelegate = delegate
            // 在设置delegate时，系统会调用respondToSelector来判断这个delegate支持哪些协议方法,并且进行缓存
            // 这里先置nil再重新设置代理避免这个缓存
            qd_setDelegate(nil)
            qd_setDelegate(qd_navhelper)
        }
    }
    
    @objc override func qd_preferredStatusBarStyle() -> UIStatusBarStyle {
        guard let config = self.qd_navBarConfig else {
            return qd_preferredStatusBarStyle()
        }
        if let topVCConfig = self.topViewController?.resolvedBarConfig {
            return topVCConfig.statusBarStyle
        }
        return config.statusBarStyle
    }
    
    @objc override func qd_prefersStatusBarHidden() -> Bool {
        guard let config = self.qd_navBarConfig else {
            return qd_prefersStatusBarHidden()
        }
        if let topVCConfig = self.topViewController?.resolvedBarConfig {
            return topVCConfig.statusBarHidden
        }
        return config.statusBarHidden
    }
    
    @objc func qd_childForStatusBarStyle() -> UIViewController? {
        guard let _ = self.qd_navBarConfig else {
            return qd_childForStatusBarStyle()
        }
        return nil
    }
    // 交换了UIViewController的prefersStatusBarHidden后，即使UINavigationController的childForStatusBarHidden方法返回topViewController(当导航栏隐藏时，这是默认行为)，该topViewController的prefersStatusBarHidden也不会被调用，导致导航栏隐藏时，通过config设置状态栏隐藏无效；
    //  奇怪的是，如果topViewController(UIViewController子类)实现了prefersStatusBarHidden，此时prefersStatusBarHidden又会被调用
    // 猜测是iOS系统判断了真实的ViewController有没有实现prefersStatusBarHidden方法...
    //  所以，此处直接让UINavigationController的childForStatusBarHidden返回nil, 避免这个问题
    @objc func qd_childForStatusBarHidden() -> UIViewController? {
        guard let _ = self.qd_navBarConfig else {
            return qd_childForStatusBarHidden()
        }
        return nil
    }
}
