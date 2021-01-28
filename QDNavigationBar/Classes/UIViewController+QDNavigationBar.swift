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
        guard self.qd_viewDidAppearFlag, self.navigationController != nil else {
            return
        }
        // 为nil时也可以刷新，此时取导航栏的config
        if self.qd_navBarConfig == nil {
            self.navigationController?.qd_navBarConfigChanged(vc: self)
            return
        }

        if let config = self.qd_navBarConfig, config.viewController == self {
            self.navigationController?.qd_navBarConfigChanged(vc: self)
        }
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
        
        guard let _ = self.navigationController else {
            return
        }
        // 当viewDidAppear时，更新一下导航栏样式
        // 解决nav的rootVC是一个vc，该vc有个scorllView,并且在scrollViewDidScroll中对配置进行了修改，由于调用时机问题(nav代理的willShow不会走动画里，而该时机又在willShow之后)，所以此处在页面显示完成后，手动调用一下
        self.qd_updateNavIfNeed()
    }
    
    @objc func qd_viewDidDisappear(animated: Bool) {
        qd_viewDidAppearFlag = false
        qd_viewDidDisappear(animated: animated)
    }
}
