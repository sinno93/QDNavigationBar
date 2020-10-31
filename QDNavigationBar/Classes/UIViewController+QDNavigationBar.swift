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
    
    static var qd_navconfig_key = "qd_navconfig_key"
    @objc public var qd_navConfig: QDNavigationBarConfig? {
        get {
            var config = objc_getAssociatedObject(self, &UIViewController.qd_navconfig_key) as? QDNavigationBarConfig
            if config == nil {
                config = self.navigationController?.qd_defaultConfig?.copy() as? QDNavigationBarConfig
                if config != nil {
                    self.qd_navConfig = config
                }
            }
            return config
        }
        
        set {
            objc_setAssociatedObject(self, &UIViewController.qd_navconfig_key, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            // 在合适的时候要更新导航栏
            if newValue != nil {
                newValue?.viewController = self
                self.qd_updateNavIfNeed()
            }
        }
    }
    // 更新配置
    func qd_updateNavIfNeed() {
        guard let config = self.qd_navConfig, let _ = self.navigationController else {
            return
        }
        if config.viewController != self {
            return
        }
        // vc didAppera后才刷新，避免重复刷新
        // 比如在push过程中，viewDidLoad方法里，修改了navConfig的hidden属性，如果不加此判断直接刷新的话导航栏会直接消失；修改其他属性也是同理。
        if !self.qd_viewDidAppearFlag {
            return
        }
        self.navigationController?.qd_navConfigChanged(vc: self)
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
