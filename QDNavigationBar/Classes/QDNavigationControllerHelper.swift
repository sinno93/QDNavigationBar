//
//  QDNavigationControllerHelper.swift
//  QDNavigationBar
//
//  Created by Sinno on 2020/9/20.
//

import UIKit

class QDNavigationControllerHelper: NSObject {
    weak var nav: UINavigationController?
    weak var navRealDelegate: UINavigationControllerDelegate?
    var isTransitioning = false
    lazy var customNavContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgView)
        bgView.qd_fullWithView(view: view)
        return view
    }()
    
    lazy var bgView: QDCustomNavFakeView = {
        let view = QDCustomNavFakeView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(nav: UINavigationController) {
        self.nav = nav
        super.init()
    }
    override func responds(to aSelector: Selector!) -> Bool {
        if type(of: self).instancesRespond(to: aSelector) {
            return true
        }
        let navResult = self.navRealDelegate?.responds(to: aSelector) ?? false
        return navResult
    }
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return self.navRealDelegate
    }
}

extension QDNavigationControllerHelper: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // 传递事件给真实代理
        self.navRealDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
        guard let _ = navigationController.qd_navBarConfig else {
            return
        }
        let config = viewController.resolvedBarConfig ?? navigationController.qd_navBarConfig!
        self.configBgViewIfNeed()
        if navigationController.isNavigationBarHidden != config.barHidden {
            navigationController.setNavigationBarHidden(config.barHidden, animated: animated)
        }
        self.bgView.isHidden = false
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
                if navigationController.isNavigationBarHidden != targetConfig.barHidden {
                    navigationController.setNavigationBarHidden(targetConfig.barHidden, animated: false)
                }
            }
        })
    }

    
    func trisationStyle(fromConfig: QDNavigationBarConfig, fromVC: UIViewController, toConfig: QDNavigationBarConfig, toVC: UIViewController, operation: UINavigationController.Operation) -> QDNavigationBarConfig.TransitionStyle {
        guard let nav = self.nav else {
            return .none
        }
        let targetConfig = operation == .push ? toConfig : fromConfig;
        if targetConfig.transitionStyle != .automatic {
            return targetConfig.transitionStyle;
        }
        // automatic
        if #available(iOS 11.0, *) {
            if nav.navigationBar.prefersLargeTitles {
                if fromVC.navigationItem.largeTitleDisplayMode != .never || toVC.navigationItem.largeTitleDisplayMode !=  .never {
                    return .separate
                }
            }
            if fromVC.navigationItem.searchController != nil || toVC.navigationItem.searchController != nil {
                return .separate
            }
        }
        // 配置相似，则不需要动画
        if fromConfig.isSimilarStyle(config: toConfig) {
            return .none
        }
        return .separate
    }
    
    func configBgViewIfNeed() {
        guard self.customNavContainerView.superview == nil else {
            return
        }
        let containView = self.customNavContainerView
        guard let containSuperView = self.nav?.navigationBar.subviews.first else {
            return
        }
        containSuperView.addSubview(containView)
        NSLayoutConstraint.activate([
            containView.leadingAnchor.constraint(equalTo: containSuperView.leadingAnchor),
            containView.trailingAnchor.constraint(equalTo: containSuperView.trailingAnchor),
            containView.topAnchor.constraint(equalTo: containSuperView.topAnchor),
            containView.bottomAnchor.constraint(equalTo: self.nav!.navigationBar.bottomAnchor),
        ])
        
        self.nav?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.nav?.navigationBar.shadowImage = UIImage()
        self.nav?.navigationBar.isTranslucent = true
    }
    
    func fadeAnimate(from fromView: UIView, fromConfig: QDNavigationBarConfig, to toView:UIView, toConfig: QDNavigationBarConfig, toRemoveViews: inout [UIView]) {
        // 隐藏bgView
        self.bgView.isHidden = true
        let fromBgView = QDCustomNavFakeView()
        let toBgView = QDCustomNavFakeView()
        fromBgView.translatesAutoresizingMaskIntoConstraints = false
        toBgView.translatesAutoresizingMaskIntoConstraints = false
        if toView.isViewHigherThan(view: fromView) {
            self.customNavContainerView.addSubview(fromBgView)
            self.customNavContainerView.addSubview(toBgView)
            
        } else {
            self.customNavContainerView.addSubview(toBgView)
            self.customNavContainerView.addSubview(fromBgView)
        }
        UIView.performWithoutAnimation {
            NSLayoutConstraint.activate([
                fromBgView.leadingAnchor.constraint(equalTo: self.customNavContainerView.leadingAnchor),
                fromBgView.trailingAnchor.constraint(equalTo: self.customNavContainerView.trailingAnchor),
                fromBgView.topAnchor.constraint(equalTo: customNavContainerView.topAnchor),
                fromBgView.heightAnchor.constraint(equalToConstant: customNavContainerView.frame.size.height),
                
                toBgView.leadingAnchor.constraint(equalTo: customNavContainerView.leadingAnchor),
                toBgView.trailingAnchor.constraint(equalTo: customNavContainerView.trailingAnchor),
                toBgView.topAnchor.constraint(equalTo: customNavContainerView.topAnchor),
                toBgView.bottomAnchor.constraint(equalTo: customNavContainerView.bottomAnchor),
            ])
            fromBgView.configView(fromConfig)
            toBgView.configView(toConfig)
            customNavContainerView.layoutIfNeeded()
        }
        UIView.performWithoutAnimation {
            toBgView.alpha = 0
            fromBgView.alpha = 1
        }
        toBgView.alpha = 1
        fromBgView.alpha = 0
        fromBgView.backgroundColor = UIColor.white
        
        toRemoveViews.append(toBgView)
        toRemoveViews.append(fromBgView)
    }
    
    func separateAnimate(from fromView: UIView, fromConfig: QDNavigationBarConfig, to toView:UIView, toConfig: QDNavigationBarConfig, toRemoveViews: inout [UIView]) {
        // 隐藏bgView
        self.bgView.isHidden = true
        let fromBgView = QDCustomNavFakeView()
        let toBgView = QDCustomNavFakeView()
        fromBgView.translatesAutoresizingMaskIntoConstraints = false
        toBgView.translatesAutoresizingMaskIntoConstraints = false
        
        toView.addSubview(toBgView)
        fromView.addSubview(fromBgView)
        var toConstrainsView = toView
        var fromConstrainsView = fromView
        // 解决控制器为UITableViewController的情况下 约束后宽度为0的问题
        if toView is UITableView && toView.superview != nil {
            toConstrainsView = toView.superview!
        }
        if fromView is UITableView && fromView.superview != nil {
            fromConstrainsView = fromView.superview!
        }
        UIView.performWithoutAnimation {
            NSLayoutConstraint.activate([
                fromBgView.leadingAnchor.constraint(equalTo: fromConstrainsView.leadingAnchor),
                fromBgView.trailingAnchor.constraint(equalTo: fromConstrainsView.trailingAnchor),
                fromBgView.topAnchor.constraint(equalTo: customNavContainerView.topAnchor),
                fromBgView.heightAnchor.constraint(equalToConstant: customNavContainerView.frame.size.height),
                
                toBgView.leadingAnchor.constraint(equalTo: toConstrainsView.leadingAnchor),
                toBgView.trailingAnchor.constraint(equalTo: toConstrainsView.trailingAnchor),
                toBgView.topAnchor.constraint(equalTo: customNavContainerView.topAnchor),
                toBgView.bottomAnchor.constraint(equalTo: customNavContainerView.bottomAnchor),
            ])
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
            nav.setNeedsStatusBarAppearanceUpdate()
            if nav.isNavigationBarHidden != config.barHidden {
                nav.setNavigationBarHidden(config.barHidden, animated: UIView.areAnimationsEnabled)
            }
        }
    }
}


extension UIView {
    func qd_fullWithView(view: UIView) {
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    // 获取最近公共父视图
    func closetCommonSuperView(view: UIView) -> UIView? {
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
    func isViewHigherThan(view: UIView) -> Bool {
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

extension QDCustomNavFakeView {
    func configView(_ config: QDNavigationBarConfig) {
        self.imageView.backgroundColor = config.backgroundColor
        self.bottomLineView.backgroundColor = config.bottomLineColor
        self.blurEffectStyle = config.blurStyle
        self.effectView.isHidden = !config.needBlurEffect;
        self.imageView.image = config.backgroundImage
        self.alpha = config.alpha
    }
}

