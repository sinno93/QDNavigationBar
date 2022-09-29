//
//  QDISATest.swift
//  QDNavigationBar
//
//  Created by 郑庆登 on 2021/6/7.
//

import Foundation
import UIKit


public class QDISATest: NSObject, UINavigationControllerDelegate {
//    let delegateClass: AnyClass = navDelegate
//    let classname = NSStringFromClass(delegateClass)
   public static func inject(with navDelegate: NSObjectProtocol) {
//        navDelegate.
        let originClass = type(of: navDelegate)
        let className = "qdisa_\(NSStringFromClass(originClass))"
        // 初始化一个类
        let afterClass: AnyClass? = objc_allocateClassPair(originClass, className, 0)
        let selector = #selector(sayHi)
        // 添加方法
        if navDelegate.responds(to: selector) {
            // 添加一个调用父类的
            let method = class_getInstanceMethod(self, #selector(sayHi_callSuper))!
            class_addMethod(afterClass, selector, method_getImplementation(method), method_getTypeEncoding(method))
        } else {
            // 添加一个不调用父类的
            let method = class_getInstanceMethod(self, #selector(sayHi_notCall))!
            class_addMethod(afterClass, selector, method_getImplementation(method), method_getTypeEncoding(method))
        }
        objc_registerClassPair(afterClass!)
        object_setClass(navDelegate, afterClass!)
    }
    
    @objc func sayHi() {
        
    }
    
    @objc func sayHi_callSuper() {
        if let method = class_getInstanceMethod(self.superclass!, #selector(sayHi)) {
            let implementation = method_getImplementation(method)
            typealias Function = @convention(c) (AnyObject, Selector) -> Void
            let function = unsafeBitCast(implementation, to: Function.self)
            function(self, #selector(sayHi))
        }
//        super.sayHi()
        print("proxy_sayHi");
    }
    
    @objc func sayHi_notCall() {
        print("proxy_sayHi");
    }
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

    }
    
}
