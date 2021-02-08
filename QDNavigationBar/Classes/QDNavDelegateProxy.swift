//
//  QDNavDelegateProxy.swift
//  QDNavigationBar
//
//  Created by Sinno on 2021/2/3.
//

import UIKit


class QDNavDelegateProxy: NSObject, UINavigationControllerDelegate {
    static var injectedDict: Set<String> = []
    // 为navDelegate注入方法
    static func inject(with navDelegate: AnyClass) {
        let delegateClass: AnyClass = navDelegate
        let classname = NSStringFromClass(delegateClass)
        if injectedDict.contains(classname) {
            return
        }
        injectedDict.insert(classname)
        
        let originSel = #selector(navigationController(_:willShow:animated:))
        if class_getInstanceMethod(delegateClass, originSel) == nil {
            // 该类没有实现originSel, 为其添加originSel，对应的实现为qdadd_navigationController
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
        
        // 该类有实现originSel,我们需要判断是该类自身实现的，还是父类实现的
        if let delegateClass = delegateClass as? NSObject.Type, let impleClass = delegateClass.lastClassImple(instanceSelector: originSel) {
            if impleClass != delegateClass {
                inject(with: impleClass)
                return
            }
        } else {
            return
        }
       
        let replaceSel = #selector(qdreplace_navigationController(_:willShow:animated:))
        guard let selfReplaceMethod = class_getInstanceMethod(self, replaceSel)  else {
            assert(false)
            return
        }
        
        // 为代理类添加replacemethod,为下一步交换做准备
        let delegateReplaceSel = Selector("qdrepl%@29302)(++||[ace_\(classname):willShow:animated:")
        
        let replaceCloure: @convention(block) (UINavigationControllerDelegate, UINavigationController, UIViewController, Bool) -> Void = { receiver, nav, vc, animated in
            // 1. let delegate = nav.delegate, delegate.isEqual(receiver): 确保当前receiver是navigationController的delegate,解决有些实现(比如hero)可能会在设置delegate前持有原delegate，然后在代理方法里再调用原delegate相应方法，导致helper被执行两次的问题
            // 2.let _ = nav.navBarConfig, let helper = nav.qd_navhelper 确保不影响未使用QDNavigationBar的navigationController
            // 3.classname == NSStringFromClass(type(of: receiver)) 确保在同时hook了父类和子类的情况下，一次代理方法调用，helper也只执行一次。
            
            let lastImpleClass: AnyClass? = (type(of: receiver) as? NSObject.Type)?.lastClassImple(instanceSelector: originSel)
            
            if let delegate = nav.delegate, delegate.isEqual(receiver), let _ = nav.navBarConfig, let helper = nav.qd_navhelper, delegateClass == lastImpleClass {
                helper.navigationController(nav, willShow: vc, animated: animated)
            }
            
            if let method = class_getInstanceMethod(type(of: receiver), delegateReplaceSel) {
                let implementation = method_getImplementation(method)
                typealias Function = @convention(c) (AnyObject, Selector, UINavigationController, UIViewController, Bool) -> Void
                let function = unsafeBitCast(implementation, to: Function.self)
                function(receiver, delegateReplaceSel, nav, vc, animated)
            }
        }
        let replaceImp = imp_implementationWithBlock(replaceCloure)
        let addreplaceSuccess = class_addMethod(delegateClass, delegateReplaceSel, replaceImp, method_getTypeEncoding(selfReplaceMethod))
        if !addreplaceSuccess {
            // 添加失败，说明已经有此方法，为防止多次交换应直接退出
            return
        }
        
        guard let originMethod = class_getInstanceMethod(delegateClass, originSel), let replaceMethod = class_getInstanceMethod(delegateClass, delegateReplaceSel) else {
            assert(false)
            return
        }
        method_exchangeImplementations(originMethod, replaceMethod)
        
    }
    // 在原代理没有实现时，添加此方法
    @objc dynamic func qdadd_navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let delegate = navigationController.delegate, delegate.isEqual(self), let _ = navigationController.navBarConfig, let helper = navigationController.qd_navhelper {
            helper.navigationController(navigationController, willShow: viewController, animated: animated)
        }
    }
    
    // 仅用于占位，避免警告和报错
    @objc dynamic func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
    }
    
    // 在原代理有实现时，使用此方法替换
    @objc dynamic  func qdreplace_navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
    }
}


extension NSObject {
    /// 获取类的最后一个实现实例方法instanceSelector的类
    ///
    /// 将会顺着类继承链一直往上找，直到找到第一个实现该Selector的类或者superClass为nil为止
    static func lastClassImple(instanceSelector: Selector) -> AnyClass? {
        guard self.instancesRespond(to: instanceSelector), let lastImp = self.instanceMethod(for: instanceSelector) else {
            return nil
        }
        var superclass: AnyClass? = self.superclass()
        while superclass != nil {
            if let superclass = superclass, superclass.instancesRespond(to: instanceSelector), let superIMP = superclass.instanceMethod(for: instanceSelector) {
                if lastImp == superIMP {
                    return superclass
                }
            }
            superclass = superclass?.superclass()
        }
        return self
    }
}
