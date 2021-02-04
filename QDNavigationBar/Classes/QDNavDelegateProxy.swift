//
//  QDNavDelegateProxy.swift
//  QDNavigationBar
//
//  Created by Sinno on 2021/2/3.
//

import UIKit

class QDNavDelegateProxySuper: NSObject, UINavigationControllerDelegate {
    dynamic func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

    }
    
}


class QDNavDelegateProxy: QDNavDelegateProxySuper {
    static var injectedDict: Set<String> = []
    // 为navDelegate注入方法
    static func inject(with navDelegate: UINavigationControllerDelegate) {
        let delegateClass: AnyClass = type(of: navDelegate)
        let classname = NSStringFromClass(delegateClass)
        if injectedDict.contains(classname) {
            return
        }
        injectedDict.insert(classname)
        let originSel = #selector(navigationController(_:willShow:animated:))
        
        let originMethod = class_getInstanceMethod(delegateClass, originSel)
        if originMethod == nil {
            // 该类没有实现
            let addsel = #selector(qdadd_navigationController(_:willShow:animated:))
            let addmethod = class_getInstanceMethod(self, addsel)
            assert(addmethod != nil, "qdadd_navigationController(_:willShow:animated:)不存在")
            if let  addmethod = addmethod {
                let result = class_addMethod(delegateClass, originSel, method_getImplementation(addmethod), method_getTypeEncoding(addmethod))
                assert(result)
                print("\(classname)类没有实现:\(originSel), 已添加方法:\(addsel)")
            }
            return
        }
        
        
        let replaceSel = #selector(qdreplace_navigationController(_:willShow:animated:))
        guard let noimp_addmethod = class_getInstanceMethod(self, originSel), let selfReplaceMethod = class_getInstanceMethod(self, replaceSel)  else {
            assert(false)
            return
        }
        
        // 为代理类添加replacemethod,为下一步交换做准备
        let addreplaceSuccess = class_addMethod(delegateClass, replaceSel, method_getImplementation(selfReplaceMethod), method_getTypeEncoding(selfReplaceMethod))
        if !addreplaceSuccess {
            // 添加失败，说明已经有此方法，为防止多次交换应直接退出
            return
        }
        // 已实现，要判断是当前类还是父类实现：
        // 尝试添加originSel, 如果当前类(而非父类)已经实现，则会添加不成功，此时直接交换方法即可
        // 若当前未实现，则我们给当前类加上了一个实现，也直接交换即可
        let addOriSuccess = class_addMethod(delegateClass, originSel, method_getImplementation(noimp_addmethod), method_getTypeEncoding(noimp_addmethod))
//        let
        if addOriSuccess {
            // 添加成功，说明该类本身没有实现，现在我们已经为它加了一个实现，直接交换
            guard let originMethod = class_getInstanceMethod(delegateClass, originSel), let replaceMethod = class_getInstanceMethod(delegateClass, replaceSel) else {
                assert(false)
                return
            }
            method_exchangeImplementations(originMethod, replaceMethod)
        } else {
            // 添加失败，说明该类本身已经实现，我们也可以直接交换
            guard let originMethod = class_getInstanceMethod(delegateClass, originSel), let replaceMethod = class_getInstanceMethod(delegateClass, replaceSel) else {
                assert(false)
                return
            }
            method_exchangeImplementations(originMethod, replaceMethod)
        }
        
    }
    // 在原代理没有实现时，添加此方法
    @objc dynamic func qdadd_navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let delegate = navigationController.delegate, delegate.isEqual(self), let _ = navigationController.navBarConfig, let helper = navigationController.qd_navhelper {
            helper.navigationController(navigationController, willShow: viewController, animated: animated)
        }
    }
    
    // 在原代理仅父类实现时，添加此方法
    @objc dynamic override func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let delegate = navigationController.delegate, delegate.isEqual(self), let _ = navigationController.navBarConfig, let helper = navigationController.qd_navhelper {
            helper.navigationController(navigationController, willShow: viewController, animated: animated)
        }
        // 调用super
        if super.responds(to: #selector(navigationController(_:willShow:animated:))) {
            super.navigationController(navigationController, willShow: viewController, animated: animated)
        }
    }
    
    // 在原代理有实现时，使用此方法替换
    @objc dynamic  func qdreplace_navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let delegate = navigationController.delegate, delegate.isEqual(self), let _ = navigationController.navBarConfig, let helper = navigationController.qd_navhelper {
            helper.navigationController(navigationController, willShow: viewController, animated: animated)
        }
        self.qdreplace_navigationController(navigationController, willShow: viewController, animated: animated)
    }
}
