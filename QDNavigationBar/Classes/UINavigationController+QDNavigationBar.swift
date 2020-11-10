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
    
    @objc public static var qd_globalDefaultConfig: QDNavigationBarConfig? {
        willSet {
            QDSwizzlingManger.runOnce()
        }
    }
    var qd_navhelper: QDNavigationControllerHelper? {
        set {
            objc_setAssociatedObject(self, &UINavigationController.qd_helperKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let result = objc_getAssociatedObject(self, &UINavigationController.qd_helperKey) as? QDNavigationControllerHelper
            return result
        }
    }
    @objc public override var qd_navConfig: QDNavigationBarConfig? {
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
    func qd_navConfigChanged(vc: UIViewController) {
        self.qd_navhelper?.navConfigChanged(vc: vc)
    }
    override func qd_updateNavIfNeed() {
        guard let config = self.qd_navConfig, config.viewController == self else {return}
        self.qd_navConfigChanged(vc: self.topViewController ?? self)
    }
}

extension UINavigationController {
    override class func qdSwizzling() {
        qdExchangeMethod(#selector(viewDidLoad), selector2: #selector(qd_viewDidLoad))
        qdExchangeMethod(#selector(setter: delegate), selector2: #selector(qd_setDelegate(_:)))
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
    @objc func qd_viewDidLoad() {
        
        if self.qd_navConfig == nil && UINavigationController.qd_globalDefaultConfig != nil {
            self.qd_navConfig = UINavigationController.qd_globalDefaultConfig?.copy() as? QDNavigationBarConfig
        }
        qd_viewDidLoad()
    }
    
    
    
}
