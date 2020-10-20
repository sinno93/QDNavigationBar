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
        print("respondsTO:\(aSelector!)")
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
        config.delegate = self
        if self.nav.isNavigationBarHidden != config.barHidden {
            self.nav.setNavigationBarHidden(config.barHidden, animated: animated)
        }
        // TODO: qd_eventThrough
        self.bgView.isHidden = false
        if navigationController.transitionCoordinator == nil {
            // 配置
            self.bgView.configView(config)
            return
        }
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
            if (self.shouldAnimate(fromConfig: fromConfig, fromVC: fromVC, toConfig: toConfig, toVC: toVC)) {
                // 动画
                self.divisionAnimate(from: fromView, fromConfig: fromConfig, to: toView, toConfig: toConfig, toRemoveViews: &toRemoveViews)
            } else {
                self.bgView.configView(toConfig)
            }
        }, completion: { (context) in
            self.isTransitioning = false
            for view in toRemoveViews {
                view.removeFromSuperview()
            }
            self.bgView.isHidden = false
            if let targetVC = context.viewController(forKey: context.isCancelled ? .from : .to) {
                let targetConfig = self.configWith(vc: targetVC)
                self.bgView.configView(targetConfig)
//                navigationController.navigationBar
            }
            
        })
    }

    
    func configWith(vc: UIViewController) -> QDNavigationBarConfig {
        return vc.qd_navConfig ?? self.nav.qd_defaultConfig!
    }
    
    func shouldAnimate(fromConfig: QDNavigationBarConfig, fromVC: UIViewController, toConfig: QDNavigationBarConfig, toVC: UIViewController) -> Bool {
        // 配置不相似， 则需要动画
        if !fromConfig.isSimilar(config: toConfig) {
            return true
        }
        // 配置相似,则默认不需要动画，但是则还有以下情况需要处理:
        // 1. 大标题模式下 除fromVC和toVC都是never模式外，需要动画
        // 2. fromVC或者toVC导航栏有搜索框，需要动画
        
        if #available(iOS 11.0, *) {
            if self.nav.navigationBar.prefersLargeTitles {
                let isFromVCNever = fromVC.navigationItem.largeTitleDisplayMode == .never
                let isToVCNever = toVC.navigationItem.largeTitleDisplayMode == .never
                if !(isFromVCNever && isToVCNever) {
                    return true
                }
            }
            if toVC.navigationItem.searchController != nil || fromVC.navigationItem.searchController != nil {
                return true
            }
        } else {
            
            // Fallback on earlier versions
        }
        return false
    }
    
    
    func configBgViewIfNeed() {
        
        if self.customNavContainerView.superview == nil {
            let containView = self.customNavContainerView
            guard let containSuperView = self.nav.navigationBar.subviews.first else {
                return
            }
            containSuperView.addSubview(containView)
            containView.qd_fullWithView(view: containSuperView)
            
            self.nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.nav.navigationBar.shadowImage = UIImage()
            self.nav.navigationBar.isTranslucent = true
        }
    }
    
    func divisionAnimate(from fromView: UIView, fromConfig: QDNavigationBarConfig, to toView:UIView, toConfig: QDNavigationBarConfig, toRemoveViews: inout [UIView]) {
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
            toView.layoutIfNeeded()
            print("\(toView)")
            print("\(toBgView)")
        }
        toRemoveViews.append(toBgView)
        toRemoveViews.append(fromBgView)
    }
    func navConfigChanged(vc: UIViewController) {
        guard let config = vc.qd_navConfig else {
            return
        }
        if vc == self.nav.topViewController && !self.isTransitioning {
            self.bgView.configView(config)
            // TODO: event_thought
//            self.nav.navigationBar.
            if self.nav.isNavigationBarHidden != config.barHidden {
                self.nav.setNavigationBarHidden(config.barHidden, animated: false)
            }
        }
    }
}

extension QDNavigationControllerHelper: QDNavigationBarConfigDelegate {
    func qdNavigationBarConfigChanged(config: QDNavigationBarConfig) {
        //TODO: 完成代理
    }
}


extension UIView {
    func qd_fullWithView(view: UIView) {
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true;
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

extension QDCustomNavFakeView {
    func configView(_ config: QDNavigationBarConfig) {
        self.backgroundColor = config.bgColor
        self.bottomLineView.backgroundColor = config.shadowLineColor
        self.effectView.alpha = config.translucent ? 1 : 0
    }
}
