//
//  UIViewController+QDNavigationBar.swift
//  QDNavigationBar
//
//  Created by Sinno on 2020/09/21.
//

import Foundation


extension UIViewController {
    static var qd_vdaKey = "qd_viewDidAppearFlag_key"
    var qd_viewDidAppearFlag: Bool {
        get {
            objc_getAssociatedObject(self, &UIViewController.qd_vdaKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &UIViewController.qd_vdaKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
    }
    
    static var qd_navbarconfig_key = "qd_navbarconfig_key"
    @objc public var qd_navBarConfig: QDNavigationBarConfig? {
        get {
            let config = objc_getAssociatedObject(self, &UIViewController.qd_navbarconfig_key) as? QDNavigationBarConfig
            return config
        }
        
        set {
            objc_setAssociatedObject(self, &UIViewController.qd_navbarconfig_key, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            newValue?.viewController = self
            self.qd_updateNavIfNeed()
        }
    }
    
    var resolvedBarConfig: QDNavigationBarConfig? {
        if self.qd_navBarConfig != nil {
            return self.qd_navBarConfig
        }
        return self.navigationController?.qd_navBarConfig
    }
    // 更新配置
    @objc func qd_updateNavIfNeed() {
        // vc didAppera后才刷新，避免重复刷新
        // 比如在push过程中，viewDidLoad方法里，修改了navConfig的hidden属性，如果不加此判断直接刷新的话导航栏会直接消失；修改其他属性也是同理。
        if !self.qd_viewDidAppearFlag {
            return
        }
        if self.qd_navBarConfig == nil && self.navigationController != nil {
            self.navigationController?.qd_navBarConfigChanged(vc: self)
            return
        }
        
        guard let config = self.qd_navBarConfig, config.viewController == self, let _ = self.navigationController else {
            return
        }
        self.navigationController?.qd_navBarConfigChanged(vc: self)
    }
}

extension UIViewController: QDSwizzlingProtocol {
    @objc class func qdSwizzling() {
        qdExchangeMethod(#selector(viewDidAppear(_:)), selector2: #selector(qd_viewDidAppear(animated:)))
        qdExchangeMethod(#selector(viewDidDisappear(_:)), selector2: #selector(qd_viewDidDisappear(animated:)))
    }
    
    
    @objc func qd_viewDidAppear(animated: Bool) {
        qd_viewDidAppearFlag = true
        qd_viewDidAppear(animated: animated)
        self.qd_updateNavIfNeed()
    }
    
    @objc func qd_viewDidDisappear(animated: Bool) {
        qd_viewDidAppearFlag = false
        qd_viewDidDisappear(animated: animated)
    }
}
