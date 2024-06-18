//
//  UIViewController+QDNavigationBar.swift
//  QDNavigationBar
//
//  Created by Sinno on 2020/09/21.
//

import UIKit

extension UIViewController {
    
    static var qd_vdaKey: UInt8 = 0
    var qd_viewDidAppearFlag: Bool {
        get {
            objc_getAssociatedObject(self, &UIViewController.qd_vdaKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &UIViewController.qd_vdaKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    static var qd_navbarconfig_key: UInt8 = 0
    @objc public var navBarConfig: QDNavigationBarConfig? {
        get {
            let config = objc_getAssociatedObject(self, &UIViewController.qd_navbarconfig_key) as? QDNavigationBarConfig
            return config
        }
        set {
            if self.navBarConfig == newValue {
                return
            }
            if let preConfig = self.navBarConfig {
                // 从旧的配置的vcList里移除self
                preConfig.remove(vc: self)
            }
            objc_setAssociatedObject(self, &UIViewController.qd_navbarconfig_key, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            newValue?.add(vc: self)
            self.qd_updateNavIfNeed()
        }
    }
    
    var resolvedBarConfig: QDNavigationBarConfig? {
        if self.navBarConfig != nil {
            return self.navBarConfig
        }
        return self.navigationController?.navBarConfig
    }
    
    // 更新配置
    @objc func qd_updateNavIfNeed() {
        // vc didAppera后才刷新，避免重复刷新
        // 比如在push过程中，viewDidLoad方法里，修改了navConfig的hidden属性，如果不加此判断直接刷新的话导航栏会直接消失；修改其他属性也是同理。
        guard self.qd_viewDidAppearFlag,
              let _ = self.navigationController?.navBarConfig else {
            return
        }
        // 只要导航栏有设置config,不管当前self有无设置config 都应该刷新
        self.navigationController?.qd_updateNavIfNeed()
        // 这种情况理论上不会出现
        assert(self.navBarConfig == nil || self.navBarConfig!.contain(vc: self), "config不包含当前VC");
    }
}

extension UIViewController: QDSwizzlingProtocol {
    @objc class func qdSwizzling() {
        qdExchangeMethod(#selector(viewDidAppear(_:)), selector2: #selector(qd_viewDidAppear(animated:)))
        qdExchangeMethod(#selector(viewDidDisappear(_:)), selector2: #selector(qd_viewDidDisappear(animated:)))
        qdExchangeMethod(#selector(getter: preferredStatusBarStyle), selector2: #selector(qd_preferredStatusBarStyle))
        qdExchangeMethod(#selector(getter: prefersStatusBarHidden), selector2: #selector(qd_prefersStatusBarHidden))
    }
    
    
    @objc func qd_viewDidAppear(animated: Bool) {
        qd_viewDidAppearFlag = true
        qd_viewDidAppear(animated: animated)
        
        guard let _ = self.navigationController else {
            return
        }
        // 当viewDidAppear时，更新一下导航栏样式
        // 解决nav的rootVC是一个vc，该vc有个scrollView,并且在scrollViewDidScroll中对配置进行了修改，由于调用时机问题(nav代理的willShow不会走动画里，而该时机又在willShow之后)，所以此处在页面显示完成后，手动调用一下
        self.qd_updateNavIfNeed()
    }
    
    @objc func qd_viewDidDisappear(animated: Bool) {
        qd_viewDidAppearFlag = false
        qd_viewDidDisappear(animated: animated)
    }
    
    @objc func qd_preferredStatusBarStyle() -> UIStatusBarStyle {
        guard let config = self.resolvedBarConfig, let navConfig = self.navigationController?.navBarConfig, navConfig.needManagerStatusBar == true else {
            return qd_preferredStatusBarStyle()
        }
        return config.statusBarStyle
    }
    
    @objc func qd_prefersStatusBarHidden() -> Bool {
        guard let config = self.resolvedBarConfig, let navConfig = self.navigationController?.navBarConfig, navConfig.needManagerStatusBar == true else {
            return qd_prefersStatusBarHidden()
        }
        return config.statusBarHidden
    }
    
}
