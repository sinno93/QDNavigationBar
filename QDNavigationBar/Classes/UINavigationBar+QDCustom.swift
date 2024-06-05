//
//  UINavigationBar+QDCustom.swift
//  QDNavigationBar
//
//  Created by sinno on 2020/10/8.
//

import UIKit

extension UINavigationBar {
    static var qd_eventThroughKey: UInt8 = 0
    var qd_eventThrough: Bool {
        get {
           objc_getAssociatedObject(self, &UINavigationBar.qd_eventThroughKey) as? Bool ?? false
        }
        
        set {
            objc_setAssociatedObject(self, &UINavigationBar.qd_eventThroughKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


extension UINavigationBar: QDSwizzlingProtocol {
    @objc class func qdSwizzling() {
        qdExchangeMethod(#selector(hitTest(_:with:)), selector2: #selector(qd_hitTest(_:with:)))
    }
    
    @objc func qd_hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = qd_hitTest(point, with: event)
        guard let hitView = view else {
            return nil
        }
        
        if !self.qd_eventThrough {
            return hitView
        }
        
        if hitView is UIControl {
            return hitView
        }
        
        if NSStringFromClass(type(of: hitView)).contains("UISearchBar") {
            return hitView
        }
        
        if #available(iOS 11.0, *) {
            // use iOS 11-only feature
        } else {
            // iOS10上，即使点击按钮，hitView也为UINavigationBar
            // 此处判断点击处是否有元素
            if hitView == self {
                for item in self.subviews.reversed() {
                    guard !item.isHidden, item.alpha > 0.01, item.frame.size.width < self.bounds.size.width * 0.85 else {
                        continue
                    }
                    let itemP = self.convert(point, to: item)
                    if item.point(inside: itemP, with: event) {
                        return hitView
                    }
                }
            }
        }
        
        if hitView.frame.size.width > self.bounds.size.width * 0.85 {
            return nil;
        }
        
        return view
    }
}
