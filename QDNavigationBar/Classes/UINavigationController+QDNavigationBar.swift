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
    
    public static var qd_globalDefaultConfig: QDNavigationBarConfig? {
        willSet {
            QDSwizzlingManger.justOne()
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
    public var qd_defaultConfig: QDNavigationBarConfig? {
            set {
                QDSwizzlingManger.justOne()
                objc_setAssociatedObject(self, &UINavigationController.qd_configKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                if qd_navhelper == nil {
                    qd_navhelper = QDNavigationControllerHelper.init(nav: self)
                }
                if !(self.delegate is QDNavigationControllerHelper) {
                    qd_navhelper?.navRealDelegate = delegate;
                }
                self.delegate = qd_navhelper
            }
            
            get {
                let result = objc_getAssociatedObject(self, &UINavigationController.qd_configKey) as? QDNavigationBarConfig
                return result
            }
        }
}

extension UINavigationController {
    func qd_navConfigChanged(vc: UIViewController) {
        self.qd_navhelper?.navConfigChanged(vc: vc)
    }
}

extension UINavigationController {
    override class func Swizzling() {
        exchangeMethod(#selector(viewDidLoad), selector2: #selector(qd_viewDidLoad))
        exchangeMethod(#selector(setter: delegate), selector2: #selector(qd_setDelegate(_:)))
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
        
        if self.qd_defaultConfig == nil && UINavigationController.qd_globalDefaultConfig != nil {
            self.qd_defaultConfig = UINavigationController.qd_globalDefaultConfig?.copy() as? QDNavigationBarConfig
        }
        qd_viewDidLoad()
    }
    
    
    
}
