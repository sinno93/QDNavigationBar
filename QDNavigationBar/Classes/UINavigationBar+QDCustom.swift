//
//  UINavigationBar+QDCustom.swift
//  QDNavigationBar
//
//  Created by sinno on 2020/10/8.
//

import UIKit

extension UINavigationBar {
    static var qd_eventThroughKey = "qd_eventThrough_key"
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
        
        if hitView.frame.size.width > self.bounds.size.width * 0.85 {
            return nil;
        }
        return view
    }
}
