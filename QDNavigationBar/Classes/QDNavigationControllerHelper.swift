//
//  QDNavigationControllerHelper.swift
//  QDNavigationBar
//
//  Created by Sinno on 2020/9/20.
//

import UIKit

class QDNavigationControllerHelper: NSObject {
    var nav: UINavigationController
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
        self.configBgViewIfNeed()
        let config = self.configWith(vc: viewController)
        if self.nav.isNavigationBarHidden != config.barHidden {
            self.nav.setNavigationBarHidden(config.barHidden, animated: animated)
        }
        self.bgView.isHidden = false
        if navigationController.transitionCoordinator == nil {
            // 配置
            navigationController.navigationBar.qd_eventThrough = config.eventThrough
            self.bgView.configView(config)
            return
        }
        self.bgView.configView(config)
        self.isTransitioning = true
        var toRemoveViews:[UIView] = []
        navigationController.transitionCoordinator?.animate(alongsideTransition: { (context) in
            guard let fromVC = context.viewController(forKey: .from), let toVC = context.viewController(forKey: .to) else {
                return
            }
            let fromConfig = self.configWith(vc: fromVC)
            let toConfig = self.configWith(vc: toVC)
            // 将要跳转的页面隐藏导航栏， 则不需要过渡处理
            if toConfig.barHidden {
                return
            }
            // 当前页面隐藏导航栏，则直接切换 不需要过渡
            if fromConfig.barHidden {
                UIView.performWithoutAnimation {
                    self.bgView.configView(toConfig)
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
                    self.bgView.configView(toConfig)
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
                self.bgView.configView(toConfig)
            case .separate:
                self.separateAnimate(from: fromView, fromConfig: fromConfig, to: toView, toConfig: toConfig, toRemoveViews: &toRemoveViews)
            case .fade:
                self.fadeAnimate(from: fromView, fromConfig: fromConfig, to: toView, toConfig: toConfig, toRemoveViews: &toRemoveViews)
            }
        }, completion: { (context) in
            self.isTransitioning = false
            for view in toRemoveViews {
                view.removeFromSuperview()
            }
            self.bgView.isHidden = false
            if let targetVC = context.viewController(forKey: context.isCancelled ? .from : .to) {
                let targetConfig = self.configWith(vc: targetVC)
                navigationController.navigationBar.qd_eventThrough = targetConfig.eventThrough
                self.bgView.configView(targetConfig)
                if self.nav.isNavigationBarHidden != targetConfig.barHidden {
                    self.nav.setNavigationBarHidden(targetConfig.barHidden, animated: false)
                }
            }
            
        })
    }
    
    
    func configWith(vc: UIViewController) -> QDNavigationBarConfig {
        return vc.qd_navConfig ?? self.nav.qd_defaultConfig!
    }
    
    func trisationStyle(fromConfig: QDNavigationBarConfig, fromVC: UIViewController, toConfig: QDNavigationBarConfig, toVC: UIViewController, operation: UINavigationController.Operation) -> QDNavigationBarConfig.TransitionStyle {
        if #available(iOS 11.0, *) {
            if self.nav.navigationBar.prefersLargeTitles {
                if fromVC.navigationItem.largeTitleDisplayMode != .never || toVC.navigationItem.largeTitleDisplayMode !=  .never {
                    return .separate
                }
            }
            if fromVC.navigationItem.searchController != nil || toVC.navigationItem.searchController != nil {
                return .separate
            }
        }
        // 配置相似，则不需要动画
        if fromConfig.isSimilar(config: toConfig) {
            return .none
        }
        // 配置不相似
        if operation == .push {
            return toConfig.transitionStyle
        } else {
            return fromConfig.transitionStyle
        }
    }
    
    func configBgViewIfNeed() {
        
        if self.customNavContainerView.superview == nil {
            let containView = self.customNavContainerView
            guard let containSuperView = self.nav.navigationBar.subviews.first else {
                return
            }
            containSuperView.addSubview(containView)
            NSLayoutConstraint.activate([
                    containView.leadingAnchor.constraint(equalTo: containSuperView.leadingAnchor),
                    containView.trailingAnchor.constraint(equalTo: containSuperView.trailingAnchor),
                    containView.topAnchor.constraint(equalTo: containSuperView.topAnchor),
                    containView.bottomAnchor.constraint(equalTo: self.nav.navigationBar.bottomAnchor),
            ])
            
            self.nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.nav.navigationBar.shadowImage = UIImage()
            self.nav.navigationBar.isTranslucent = true
        }
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
            fromBgView.leadingAnchor.constraint(equalTo: self.customNavContainerView.leadingAnchor).isActive = true
            fromBgView.trailingAnchor.constraint(equalTo: self.customNavContainerView.trailingAnchor).isActive = true
            fromBgView.topAnchor.constraint(equalTo: customNavContainerView.topAnchor).isActive = true
            fromBgView.heightAnchor.constraint(equalToConstant: customNavContainerView.frame.size.height).isActive = true
            fromBgView.configView(fromConfig)
            
            toBgView.leadingAnchor.constraint(equalTo: customNavContainerView.leadingAnchor).isActive = true
            toBgView.trailingAnchor.constraint(equalTo: customNavContainerView.trailingAnchor).isActive = true
            toBgView.topAnchor.constraint(equalTo: customNavContainerView.topAnchor).isActive = true
            toBgView.bottomAnchor.constraint(equalTo: customNavContainerView.bottomAnchor).isActive = true
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
            fromBgView.leadingAnchor.constraint(equalTo: fromConstrainsView.leadingAnchor).isActive = true
            fromBgView.trailingAnchor.constraint(equalTo: fromConstrainsView.trailingAnchor).isActive = true
            fromBgView.topAnchor.constraint(equalTo: customNavContainerView.topAnchor).isActive = true
            fromBgView.heightAnchor.constraint(equalToConstant: customNavContainerView.frame.size.height).isActive = true
            fromBgView.configView(fromConfig)
            
            toBgView.leadingAnchor.constraint(equalTo: toConstrainsView.leadingAnchor).isActive = true
            toBgView.trailingAnchor.constraint(equalTo: toConstrainsView.trailingAnchor).isActive = true
            toBgView.topAnchor.constraint(equalTo: customNavContainerView.topAnchor).isActive = true
            toBgView.bottomAnchor.constraint(equalTo: customNavContainerView.bottomAnchor).isActive = true
            toBgView.configView(toConfig)
        }
        toRemoveViews.append(toBgView)
        toRemoveViews.append(fromBgView)
    }
    func navConfigChanged(vc: UIViewController) {
        guard let config = vc.qd_navConfig else {
            return
        }
        if vc == self.nav.topViewController && !self.isTransitioning {
            self.nav.navigationBar.qd_eventThrough = config.eventThrough
            self.bgView.configView(config)
            if self.nav.isNavigationBarHidden != config.barHidden {
                self.nav.setNavigationBarHidden(config.barHidden, animated: false)
            }
        }
    }
}


extension UIView {
    func qd_fullWithView(view: UIView) {
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true;
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
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

extension QDCustomNavFakeView {
    func configView(_ config: QDNavigationBarConfig) {
        self.backgroundColor = config.bgColor
        self.bottomLineView.backgroundColor = config.shadowLineColor
        self.effectView.alpha = config.translucent ? 1 : 0
    }
}

