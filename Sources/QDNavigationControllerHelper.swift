//
//  QDNavigationControllerHelper.swift
//  QDNavigationBar
//
//  Created by Sinno on 2020/9/20.
//

import UIKit

class QDNavigationControllerHelper: NSObject {
    
    var lastStatusBarHidden: Bool?
    lazy var puppet: QDNavigationDelegatePuppet = QDNavigationDelegatePuppet()
    
    private weak var nav: UINavigationController?
    private var isTransitioning = false
    
    private lazy var customNavContainerView: QDMonitorView = {
        let view = QDMonitorView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgView)
        bgView.qd_fullWithView(view: view)
        return view
    }()
    
    private lazy var bgView: QDCustomNavFakeView = {
        let view = QDCustomNavFakeView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(nav: UINavigationController) {
        self.nav = nav
        super.init()
    }
}

extension QDNavigationControllerHelper: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let _ = navigationController.navBarConfig else {
            return
        }
        let config = viewController.resolvedBarConfig ?? navigationController.navBarConfig!
        configBgViewIfNeed()
        if navigationController.isNavigationBarHidden != config.barHidden {
            navigationController.setNavigationBarHidden(config.barHidden, animated: animated)
        }
        self.bgView.isHidden = false
        self.updateStatusBar(config)
        
        if navigationController.transitionCoordinator == nil {
            // 配置
            self.navBarConfigView(config)
            return
        } else {
            if !config.barHidden {
                self.navBarConfigView(config)
            }
        }
        self.isTransitioning = true
        var toRemoveViews:[UIView] = []
        navigationController.transitionCoordinator?.animate(alongsideTransition: { (context) in
            // present一个导航控制器+VC时，toVC!=viewController
            guard let fromVC = context.viewController(forKey: .from), let toVC = context.viewController(forKey: .to), toVC == viewController else {
                return
            }
            guard let fromConfig = fromVC.resolvedBarConfig, let toConfig = toVC.resolvedBarConfig else {return}
            // 将要跳转的页面隐藏导航栏， 则不需要过渡处理
            if toConfig.barHidden {
                return
            }
            // 当前页面隐藏导航栏，则直接切换 不需要过渡
            if fromConfig.barHidden {
                UIView.performWithoutAnimation {
                    self.navBarConfigView(toConfig)
                }
                return;
            }
            let containerView = context.containerView
            guard let toView = context.view(forKey: .to), let fromView = context.view(forKey: .from) else {
                return
            }
            let isAllInContainerView = toView.isDescendant(of: containerView) && fromView.isDescendant(of: containerView)
            if !isAllInContainerView {
                // 在iOS11上 第一次push时toView不在containerView上
                // 这里为避免问题(添加约束闪退)，在这种情况下直接不需要动画
                UIView.performWithoutAnimation {
                    self.navBarConfigView(toConfig)
                }
                return
            }
            // 判断是否需要动画
            var operation: UINavigationController.Operation!
            if toView.isViewHigherThan(view: fromView) {
                operation = .push
            } else {
                operation = .pop
            }
            let style = self.trisationStyle(fromConfig: fromConfig, fromVC: fromVC, toConfig: toConfig, toVC: toVC, operation: operation)
            switch style {
                case .none:
                    self.navBarConfigView(toConfig)
                case .separate:
                    self.separateAnimate(from: fromView, fromConfig: fromConfig, to: toView, toConfig: toConfig, toRemoveViews: &toRemoveViews)
                case .fade:
                    self.fadeAnimate(from: fromView, fromConfig: fromConfig, to: toView, toConfig: toConfig, toRemoveViews: &toRemoveViews)
                case .automatic: break
            }
        }, completion: { (context) in
            self.isTransitioning = false
            for view in toRemoveViews {
                view.removeFromSuperview()
            }
            self.bgView.isHidden = false
            guard let targetVC = context.viewController(forKey: context.isCancelled ? .from : .to) else {
                return
            }
            // 处理present一个导航控制器+VC时，targetVC=UINavigationController的情况
            var targetConfig: QDNavigationBarConfig? = targetVC.resolvedBarConfig
            if !navigationController.viewControllers.contains(targetVC) {
                targetConfig = navigationController.topViewController?.resolvedBarConfig
            }
            if let targetConfig = targetConfig {
                self.navBarConfigView(targetConfig)
                self.updateStatusBar(targetConfig)
                if navigationController.isNavigationBarHidden != targetConfig.barHidden {
                    navigationController.setNavigationBarHidden(targetConfig.barHidden, animated: false)
                }
            }
        })
    }

    
    private func trisationStyle(fromConfig: QDNavigationBarConfig, fromVC: UIViewController, toConfig: QDNavigationBarConfig, toVC: UIViewController, operation: UINavigationController.Operation) -> QDNavigationBarConfig.TransitionStyle {
        guard let nav = self.nav else {
            return .none
        }
        let targetConfig = operation == .push ? toConfig : fromConfig;
        if targetConfig.transitionStyle != .automatic {
            return targetConfig.transitionStyle;
        }
        // 配置相似，则不需要动画
        if fromConfig.isSimilarStyle(config: toConfig) {
            return .none
        }
        return .separate
    }
    
    private func configBgViewIfNeed() {
        guard self.customNavContainerView.superview == nil else {
            return
        }
        guard let navbar = self.nav?.navigationBar, let barBackgroundView = navbar.subviews.first else {
            assert(false)
            return
        }
        
        let containView = self.customNavContainerView
        barBackgroundView.addSubview(containView)
        
        let leadingCons = containView.leadingAnchor.constraint(equalTo: navbar.leadingAnchor)
        let trailingCons = containView.trailingAnchor.constraint(equalTo: navbar.trailingAnchor)
        let topCons = containView.topAnchor.constraint(equalTo: barBackgroundView.topAnchor)
        let bottomCons = containView.bottomAnchor.constraint(equalTo: navbar.bottomAnchor)
        NSLayoutConstraint.activate([
            leadingCons,
            trailingCons,
            topCons,
            bottomCons,
        ])
        // 在navBar隐藏时，barBackgroundView会从父视图移除导致约束失效
        // 这里保存约束，在添加到父视图时恢复约束
        containView.cons = [leadingCons, trailingCons, bottomCons]
        self.nav?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.nav?.navigationBar.shadowImage = UIImage()
        self.nav?.navigationBar.isTranslucent = true
    }
    
   private func fadeAnimate(from fromView: UIView, fromConfig: QDNavigationBarConfig, to toView:UIView, toConfig: QDNavigationBarConfig, toRemoveViews: inout [UIView]) {
        // 隐藏bgView
        self.bgView.isHidden = true
       let fromBgView = QDCustomNavFakeView()
       let toBgView = QDCustomNavFakeView()
       
       if toView.isViewHigherThan(view: fromView) {
           self.customNavContainerView.addSubview(fromBgView)
           self.customNavContainerView.addSubview(toBgView)
       } else {
           self.customNavContainerView.addSubview(toBgView)
           self.customNavContainerView.addSubview(fromBgView)
       }
       
       UIView.performWithoutAnimation {
           
           fromBgView.frame = self.customNavContainerView.bounds
           toBgView.frame = self.customNavContainerView.bounds
           fromBgView.configView(fromConfig)
           toBgView.configView(toConfig)
           
           toBgView.alpha = 0
           fromBgView.alpha = 1
           toBgView.layoutIfNeeded()
           fromBgView.layoutIfNeeded()
       }
        
        toBgView.alpha = 1
        fromBgView.alpha = 0
        fromBgView.backgroundColor = UIColor.white
        
        toRemoveViews.append(toBgView)
        toRemoveViews.append(fromBgView)
    }
    
     private func separateAnimate(from fromView: UIView, fromConfig: QDNavigationBarConfig, to toView:UIView, toConfig: QDNavigationBarConfig, toRemoveViews: inout [UIView]) {
        // 隐藏bgView
        self.bgView.isHidden = true
        let fromBgView = QDCustomNavFakeView()
        let toBgView = QDCustomNavFakeView()
        
        toView.addSubview(toBgView)
        fromView.addSubview(fromBgView)
         if toView is UIScrollView {
             toView.superview?.addSubview(toBgView)
         }
         
         if fromView is UIScrollView {
             fromView.superview?.addSubview(fromBgView)
         }

        UIView.performWithoutAnimation {
            fromBgView.frame = CGRect(x: 0, y: 0, width: customNavContainerView.frame.size.width, height: customNavContainerView.frame.size.height)
            toBgView.frame = CGRect(x: 0, y: 0, width: customNavContainerView.frame.size.width, height: customNavContainerView.frame.size.height)
            fromBgView.configView(fromConfig)
            toBgView.configView(toConfig)
        }
        toRemoveViews.append(toBgView)
        toRemoveViews.append(fromBgView)
    }
    
    func navConfigChanged(vc: UIViewController) {
        guard let config = vc.resolvedBarConfig, let nav = self.nav else {
            return
        }
        let isTopVC = vc == nav.topViewController
        let isEmptyNav = nav.topViewController == nil && self.nav == vc
        if (isTopVC || isEmptyNav) && !self.isTransitioning {
            self.navBarConfigView(config)
            self.updateStatusBar(config)
            if nav.isNavigationBarHidden != config.barHidden {
                nav.setNavigationBarHidden(config.barHidden, animated: UIView.areAnimationsEnabled)
            }
        }
    }
    
    // 更新状态栏样式
    private func updateStatusBar(_ config: QDNavigationBarConfig) {
        // 只有开启了导航栏管理功能才更新导航栏样式
        guard let config = self.nav?.navBarConfig, config.needManagerStatusBar == true else {
            return
        }
        self.nav?.setNeedsStatusBarAppearanceUpdate()
    }
}


extension UIView {
    
    fileprivate func qd_fullWithView(view: UIView) {
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    // 获取最近公共父视图
    private func closetCommonSuperView(view: UIView) -> UIView? {
        if self.isDescendant(of: view) {
            return view
        }
        if view.isDescendant(of: self) {
            return self
        }
//        var view:UIView? = nil
        var selfSuperView = self.superview
        while selfSuperView != nil {
            if view.isDescendant(of: selfSuperView!) {
                return selfSuperView
            } else {
                selfSuperView = selfSuperView?.superview
            }
        }
        return nil
    }
    // self是否在view上层
    fileprivate func isViewHigherThan(view: UIView) -> Bool {
        guard let commonview = self.closetCommonSuperView(view: view) else {
            return false
        }
//        var subviews = commonview.subviews
        for view in commonview.subviews.reversed() {
            if self.isDescendant(of: view) {
                return true
            } else if view.isDescendant(of: view) {
                return false
            }
        }
        return false
    }
}

extension QDNavigationControllerHelper {
    func navBarConfigView(_ config: QDNavigationBarConfig) {
        self.bgView.configView(config)
        self.nav?.navigationBar.qd_eventThrough = config.eventThrough
    }
}

class QDNavigationDelegatePuppet: NSObject, UINavigationControllerDelegate {
//    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        print("viewwillshow")
//    }
}


class QDMonitorView: UIView {
    var cons: [NSLayoutConstraint] = []
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if self.window != nil {
            cons.forEach { $0.isActive = true }
        }
    }
}
