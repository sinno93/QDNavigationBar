//
//  ViewController.swift
//  QDCustomNavigationSwift
//
//  Created by sinno on 2020/10/19.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import QDNavigationBar

class ViewController: UIViewController, UINavigationControllerDelegate {
    // MARK: - Initialization
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.navigationController?.navBarConfig == nil {
            let config = QDNavigationBarConfig()
            config.backgroundColor = UIColor.green
            config.bottomLineColor = UIColor.red
            self.navigationController?.navBarConfig = config
        }
        if self.navBarConfig == nil {
            self.navBarConfig = self.navigationController?.navBarConfig?.copy() as? QDNavigationBarConfig
        }
        
        self.title = "Demo"
        self.configSubviews()
        if let config = self.navBarConfig {
            self.editorView.config = config
        }
        self.nextEditorView.config = self.nextConfig
        if self.navigationController?.viewControllers.count == 1 {
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self;
        }
        self.navigationController?.delegate = self
        self.navigationController?.delegate = self;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.nextEditorView.config = self.nextConfig
    }
    
    // MARK: - Actions
    // view的一些事件比如按钮点击、手势事件处理、通知处理
    @objc func pushButtonClick(button:UIButton) {
        let vc = ViewController()
        vc.navBarConfig = self.nextConfig
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Private method
    // 控制器的一些私有的辅助方法
    func configSubviews() {
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(scrollView)
        scrollView.mas_makeConstraints { (maker) in
            maker?.top.equalTo()(self.view)
            maker?.bottom.equalTo()(self.view)
            if #available(iOS 11.0, *) {
                maker?.left.equalTo()(self.view.mas_safeAreaLayoutGuideLeft)
                maker?.right.equalTo()(self.view.mas_safeAreaLayoutGuideRight)
            } else {
                maker?.leading.equalTo()(self.view)
                maker?.trailing.equalTo()(self.view)
            }
        }
        let containerView = UIView()
        scrollView.addSubview(containerView)
        containerView.mas_makeConstraints { (maker) in
            maker?.edges.equalTo()(scrollView)
            maker?.width.equalTo()(scrollView)
        }
        let viewList = [editorView,
                        currentTipLabel,
                        nextEditorView,
                        nextTipLabel,
                        pushButtonPlaceHolder,
                        pushButton]
        for view in viewList {
            containerView.addSubview(view)
        }
        
        editorView.mas_makeConstraints { (make) in
            make?.top.equalTo()(containerView)?.offset()(25)
            make?.leading.equalTo()(containerView)?.offset()(10)
            make?.trailing.equalTo()(containerView)?.offset()(-10)
            
        }
        
        currentTipLabel.mas_makeConstraints { (make) in
            make?.centerX.equalTo()(containerView)
            make?.centerY.equalTo()(editorView.mas_top)
        }
        
        nextEditorView.mas_makeConstraints { (make) in
            make?.top.equalTo()(editorView.mas_bottom)?.offset()(25)
            make?.leading.equalTo()(containerView)?.offset()(10)
            make?.trailing.equalTo()(containerView)?.offset()(-10)
        }
        
        nextTipLabel.mas_makeConstraints { (make) in
            make?.centerX.equalTo()(containerView)
            make?.centerY.equalTo()(nextEditorView.mas_top)
        }
        
        pushButtonPlaceHolder.mas_makeConstraints { (make) in
            make?.leading.equalTo()(containerView)?.offset()(40)
            make?.trailing.equalTo()(containerView)?.offset()(-40)
            make?.height.equalTo()(40)
            make?.top.equalTo()(self.nextEditorView.mas_bottom)?.offset()(15)
            make?.bottom.equalTo()(containerView)?.offset()(-400)
        }
        pushButton.mas_makeConstraints { (make) in
            make?.leading.equalTo()(pushButtonPlaceHolder)
            make?.trailing.equalTo()(pushButtonPlaceHolder)
            make?.height.equalTo()(pushButtonPlaceHolder)
            make?.bottom.lessThanOrEqualTo()(self.mas_bottomLayoutGuideTop)?.offset()(-15)
            make?.top.equalTo()(pushButtonPlaceHolder.mas_top)?.priorityLow()()
        }
    }
    // MARK: - Getter & Setter
    // 属性的Getter/Setter方法
    
    lazy var nextConfig: QDNavigationBarConfig = {
        if let config = self.navigationController?.navBarConfig {
            let nextConfig = config.copy() as! QDNavigationBarConfig
            nextConfig.backgroundColor = UIColor.red
            return nextConfig
        } else {
            return QDNavigationBarConfig()
        }
    }()
    
    lazy var editorView: QDConfigEditorView = QDConfigEditorView()
    
    lazy var nextEditorView: QDConfigEditorView = QDConfigEditorView()
    
    lazy var pushButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("PUSH新页面", for: .normal)
        button.addTarget(self, action: #selector(pushButtonClick(button:)), for: .touchUpInside)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1)
        button.layer.cornerRadius = 8.0
        button.layer.shadowOffset = CGSize(width: 3, height: 3);
        button.layer.shadowOpacity = 0.3;
        button.layer.shadowRadius = 8.0;
        return button
    }()
    
    lazy var pushButtonPlaceHolder: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var currentTipLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.white
        label.textColor = UIColor.black
        label.text = "当前页面设置"
        return label
    }()
    
    lazy var nextTipLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.white
        label.textColor = UIColor.black
        label.text = "新页面设置"
        return label
    }()
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = true
        return view
    }()

}

// MARK: - Delegates
// 实现遵循的代理方法
extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.navigationController?.viewControllers.count ?? 0 > 1;
    }
}
