//
//  UIViewController+QDNavigationBar.swift
//  QDNavigationBar
//
//  Created by Sinno on 2020/09/21.
//

import Foundation


extension UIViewController {
    static var qd_vdaKey = "qd_viewDidApperaFlag_key"
    var qd_viewDidApperaFlag: Bool {
        get {
           objc_getAssociatedObject(self, &UIViewController.qd_vdaKey) as? Bool ?? false
        }
        
        set {
            objc_setAssociatedObject(self, &UIViewController.qd_vdaKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
    }
    
    static var qd_navconfig_key = "qd_navconfig_key"
    public var qd_navConfig: QDNavigationBarConfig? {
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
        guard let config = self.qd_navConfig else {
            return
        }
        if config.viewController != self {
            return
        }
        self.navigationController?.qd_navConfigChanged(vc: self)
    }
}

extension UIViewController: QDSwizzlingProtocol {
    @objc class func Swizzling() {
        exchangeMethod(#selector(viewDidLoad), selector2: #selector(hzj_viewDidLoad))
        exchangeMethod(#selector(viewDidAppear(_:)), selector2: #selector(qd_viewDidAppear(animated:)))
        exchangeMethod(#selector(viewDidDisappear(_:)), selector2: #selector(qd_viewDidDisappear(animated:)))
    }
    
    @objc func hzj_viewDidLoad() {
        print("viewdidload1:\(self)")
        hzj_viewDidLoad()
    }
    
    
    @objc func qd_viewDidAppear(animated: Bool) {
        qd_viewDidApperaFlag = true
        qd_viewDidAppear(animated: animated)
    }
    
    @objc func qd_viewDidDisappear(animated: Bool) {
        qd_viewDidApperaFlag = false
        qd_viewDidDisappear(animated: animated)
    }
}

