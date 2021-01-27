//
//  QDSwizzlingManger.swift
//  QDNavigationBar
//
//  Created by Sinno on 2020/9/20.
//

import UIKit

protocol QDSwizzlingProtocol where Self: NSObject {
    static func qdSwizzling()
    static func qdExchangeMethod(_ selector1: Selector, selector2: Selector);
}

extension QDSwizzlingProtocol {
    static func qdExchangeMethod(_ selector1:Selector, selector2:Selector) {
        guard let method1 = class_getInstanceMethod(self, selector1) else {return}
        guard let method2 = class_getInstanceMethod(self, selector2) else {return}
        if (class_addMethod(self, selector1, method_getImplementation(method2), method_getTypeEncoding(method2))) {
            class_replaceMethod(self, selector2, method_getImplementation(method1), method_getTypeEncoding(method1))
        } else {
            method_exchangeImplementations(method1, method2)
        }
    }
}

class QDSwizzlingManger {
    //只会调用一次的方法,实现了交换的类需要在这里执行一下
    private static let doOnce: Any? = {
        UIViewController.qdSwizzling()
        UINavigationController.qdSwizzling()
        UINavigationBar.qdSwizzling()
        return nil
    }()
    
    static func runOnce() {
        _ = QDSwizzlingManger.doOnce
    }
}

