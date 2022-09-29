//
//  QDISAInjectTool.swift
//  QDNavigationBar
//
//  Created by 郑庆登 on 2021/6/8.
//

import Foundation

extension NSObject {
    static var qd_navigationBar_class_key = "qd_navigationBar_isa_inject_class"
}

extension NSObjectProtocol {
    
    var qd_isaClass: AnyClass? {
        get {
            objc_getAssociatedObject(self, &NSObject.qd_navigationBar_class_key) as? AnyClass
        }
        set {
            objc_setAssociatedObject(self, &NSObject.qd_navigationBar_class_key, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

public class QDISAInjectTool: NSObject, UINavigationControllerDelegate {
    
    static let originSelector: Selector = #selector(navigationController(_:willShow:animated:))
    static let callSuperSelector: Selector = #selector(navigationController_callSuper(_:willShow:animated:))
    static let notcallSuperSelector: Selector = #selector(navigationController_notCall(_:willShow:animated:))
    static let injectFlagSelector: Selector = #selector(QDISA_inject_flag)
    
    static let removeObserverSelector: Selector = #selector(removeObserver(_:forKeyPath:))
    static let removeObserverContextSelector: Selector = #selector(removeObserver(_:forKeyPath:context:))
    
    public static func inject(with navDelegate: NSObjectProtocol) {
        // 判断是否已经处理过了，在KVO的情况下，此方法比navDelegate.responds(to: injectFlagSelector) 准确
        // kvo后的类，navDelegate.responds(to: injectFlagSelector)总是返回false
        if class_getInstanceMethod(object_getClass(navDelegate), injectFlagSelector) != nil {
            return;
        }
        
        // 判断是否是kvo过的对象
        
        // 1. 判断该对象是否被inject过
        // 2. 判断该对象类是否曾经生成过
        let originClass = type(of: navDelegate)
        let realOriginClass: AnyClass = object_getClass(navDelegate)!
        // 判断是否是KVO
        if originClass == class_getSuperclass(realOriginClass) {
            // 1.添加方法
            self.test(afterClass: realOriginClass, callSuper: navDelegate.responds(to: originSelector));
            {
                // 2. hook removeObserver(_:forKeyPath:)
                let removeMethod = class_getInstanceMethod(realOriginClass, removeObserverSelector)!
                let toFakeRemoveMethod = class_getInstanceMethod(self, #selector(qd_KVO_original_removeObserver(_:forKeyPath:)))!
                
                class_addMethod(realOriginClass, #selector(qd_KVO_original_removeObserver(_:forKeyPath:)), method_getImplementation(removeMethod), method_getTypeEncoding(removeMethod))
                
                class_replaceMethod(realOriginClass, removeObserverSelector, method_getImplementation(toFakeRemoveMethod), method_getTypeEncoding(removeMethod))
            }();
            
            {
                // 3 hook removeObserver(_:forKeyPath:context:)
                let replaceSelector = #selector(qd_KVO_original_removeObserver(_:forKeyPath:context:))
                let removeContextMethod = class_getInstanceMethod(realOriginClass, removeObserverContextSelector)!
                let toFakeRemoveContextMethod = class_getInstanceMethod(self, replaceSelector)!
                
                class_addMethod(realOriginClass, replaceSelector, method_getImplementation(removeContextMethod), method_getTypeEncoding(removeContextMethod))
                
                class_replaceMethod(realOriginClass, removeObserverContextSelector, method_getImplementation(toFakeRemoveContextMethod), method_getTypeEncoding(removeContextMethod))
            }();
            
            {
                // 4. hook respon
                let replaceSelector = #selector(qd_original_responds(to:))
                let respondMethod = class_getInstanceMethod(realOriginClass, #selector(responds(to:)))!
                let toFakerespondMethod = class_getInstanceMethod(self, replaceSelector)!
                
                class_addMethod(realOriginClass, replaceSelector, method_getImplementation(respondMethod), method_getTypeEncoding(respondMethod))
                
                let p = class_replaceMethod(realOriginClass, #selector(responds(to:)), method_getImplementation(toFakerespondMethod), method_getTypeEncoding(respondMethod))
            }()
            
        } else {
            let className = "qdisa_\(NSStringFromClass(originClass))"
            if let injectedClass = NSClassFromString(className) {
                object_setClass(navDelegate, injectedClass)
                navDelegate.qd_isaClass = originClass
                return;
            }
            // 初始化一个类
            guard let afterClass = objc_allocateClassPair(originClass, className, 0) else {
                assert(false, "生成新类\(className)失败！")
                return
            }
            
            self.test(afterClass: afterClass, callSuper: navDelegate.responds(to: originSelector))
            
            let classMethod = class_getInstanceMethod(self, #selector(QDISA_class))!
            class_addMethod(afterClass, Selector("class"), method_getImplementation(classMethod), method_getTypeEncoding(classMethod));
            
            {
                // 4. hook respon
                let replaceSelector = #selector(qd_original_responds(to:))
                let respondMethod = class_getInstanceMethod(afterClass, #selector(responds(to:)))!
                let toFakerespondMethod = class_getInstanceMethod(self, replaceSelector)!
                
                class_addMethod(afterClass, replaceSelector, method_getImplementation(respondMethod), method_getTypeEncoding(respondMethod))
                
                let p = class_replaceMethod(afterClass, #selector(responds(to:)), method_getImplementation(toFakerespondMethod), method_getTypeEncoding(respondMethod))
            }()
            
            
            objc_registerClassPair(afterClass)

            object_setClass(navDelegate, afterClass)
            navDelegate.qd_isaClass = originClass
        }
    }
    
    static func test(afterClass: AnyClass, callSuper: Bool) {
        let method = callSuper ? class_getInstanceMethod(self, callSuperSelector)! : class_getInstanceMethod(self, notcallSuperSelector)!
        let flagMethod = class_getInstanceMethod(self, injectFlagSelector)!
        // 加入navigation代理方法
        class_addMethod(afterClass, originSelector, method_getImplementation(method), method_getTypeEncoding(method))
        // 加入inject_flag方法
        let addresult = class_addMethod(afterClass, injectFlagSelector, method_getImplementation(flagMethod), method_getTypeEncoding(flagMethod))
        print("加入flag:\(addresult)")
    }
    
    @objc func QDISA_class() -> AnyClass? {
        return self.qd_isaClass
    }
    
    @objc func QDISA_inject_flag() {
        return
    }
    
    @objc  public  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
    }
    
    @objc public func navigationController_callSuper(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let method = class_getInstanceMethod(self.qd_isaClass ?? class_getSuperclass(object_getClass(self)), QDISAInjectTool.originSelector) {
            let implementation = method_getImplementation(method)
            typealias Function = @convention(c) (AnyObject, Selector, UINavigationController, UIViewController, Bool) -> Void
            let function = unsafeBitCast(implementation, to: Function.self)
            function(self, QDISAInjectTool.originSelector, navigationController, viewController, animated)
        }
        if let delegate = navigationController.delegate, delegate.isEqual(self), let _ = navigationController.navBarConfig, let helper = navigationController.qd_navhelper {
            helper.navigationController(navigationController, willShow: viewController, animated: animated)
        }
    }
    
    @objc public func navigationController_notCall(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let delegate = navigationController.delegate, delegate.isEqual(self), let _ = navigationController.navBarConfig, let helper = navigationController.qd_navhelper {
            helper.navigationController(navigationController, willShow: viewController, animated: animated)
        }
    }
    
    @objc func qd_KVO_original_removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
        // 1.调用真实方法
        if let method = class_getInstanceMethod(object_getClass(self), #selector(qd_KVO_original_removeObserver(_:forKeyPath:))) {
            let implementation = method_getImplementation(method)
            typealias Function = @convention(c) (AnyObject, Selector, NSObject, String) -> Void
            let function = unsafeBitCast(implementation, to: Function.self)
            function(self, #selector(removeObserver(_:forKeyPath:)), observer, keyPath)
        }
        // 2.确保正确注入
        QDISAInjectTool.inject(with: self)
    }
    
    @objc func qd_KVO_original_removeObserver(_ observer: NSObject, forKeyPath keyPath: String, context: UnsafeMutableRawPointer?) {
        // 1.调用真实方法
        if let method = class_getInstanceMethod(object_getClass(self), #selector(qd_KVO_original_removeObserver(_:forKeyPath:context:))) {
            let implementation = method_getImplementation(method)
            typealias Function = @convention(c) (AnyObject, Selector, NSObject, String, UnsafeMutableRawPointer?) -> Void
            let function = unsafeBitCast(implementation, to: Function.self)
            function(self, #selector(removeObserver(_:forKeyPath:)), observer, keyPath, context)
        }
        // 2.确保正确注入
        QDISAInjectTool.inject(with: self)
    }
    
    @objc func qd_original_responds(to: Selector) -> Bool {
        var respondResult = false
        if let method = class_getInstanceMethod(object_getClass(self), #selector(qd_original_responds(to:))) {
            let implementation = method_getImplementation(method)
            typealias Function = @convention(c) (AnyObject, Selector, Selector) -> Bool
            let function = unsafeBitCast(implementation, to: Function.self)
            respondResult = function(self, #selector(responds(to:)), to)
        }
        if respondResult == false && to == #selector(navigationController(_:willShow:animated:)) {
            respondResult = true
        }
        return respondResult
    }
}
