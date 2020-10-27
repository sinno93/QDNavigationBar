//
//  ViewController.swift
//  QDCustomNavigationSwift
//
//  Created by sinno on 2020/10/19.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import QDNavigationBar

class ViewController: UIViewController {
    lazy var colorfulView: QDColorfulView = {
        QDColorfulView()
    }()
    lazy var editorView: QDConfigEditorView = {
        QDConfigEditorView()
    }()
    lazy var nextEditorView: QDConfigEditorView = {
       QDConfigEditorView()
    }()
    lazy var pushButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("PUSH新页面", for: .normal)
        button.addTarget(self, action: #selector(pushButtonClick(button:)), for: .touchUpInside)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1)
        button.layer.cornerRadius = 8.0
        return button
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
        view.delegate = self
        return view
    }()
    lazy var nextConfig: QDNavigationBarConfig = {
        if let config = self.navigationController?.qd_defaultConfig {
            let nextConfig = config.copy() as! QDNavigationBarConfig
            nextConfig.bgColor = UIColor.red
            nextConfig.eventThrough = true
            nextConfig.transitionStyle = .fade
            return nextConfig
        } else {
            return QDNavigationBarConfig()
        }
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.navigationController?.qd_defaultConfig == nil {
            let config = QDNavigationBarConfig()
            config.bgColor = UIColor.green
            self.navigationController?.qd_defaultConfig = config
        }
        self.title = "Demo"
        self.configSubviews()
        if let config = self.qd_navConfig {
            self.editorView.config = TempConfig(config: config)
        }
        self.nextEditorView.config = TempConfig(config: self.nextConfig)
    }
    
    ///
    @objc func pushButtonClick(button:UIButton) {
//        let vc = ViewController()
//        vc.qd_navConfig = self.nextConfig
//        vc.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(vc, animated: true)
//        return;
        let nav = UINavigationController(rootViewController: ViewController())
//        nav.modalPresentationStyle = .fullScreen
        nav.qd_defaultConfig = QDNavigationBarConfig()
        nav.qd_defaultConfig?.bgColor = UIColor.yellow
        self.present(nav, animated: true, completion: nil)
    }
    
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
        let viewList = [colorfulView,
                        editorView,
                        currentTipLabel,
                        nextEditorView,
                        nextTipLabel,
                        pushButton]
        for view in viewList {
            containerView.addSubview(view)
        }
        colorfulView.mas_makeConstraints { (make) in
            make?.leading.equalTo()(containerView)?.offset()(10)
            make?.trailing.equalTo()(containerView)?.offset()(-10)
            make?.top.equalTo()(containerView)?.offset()(10)
//            make?.height.equalTo()(40)
        }
        
        editorView.mas_makeConstraints { (make) in
            make?.top.equalTo()(colorfulView.mas_bottom)?.offset()(25)
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
        
        pushButton.mas_makeConstraints { (make) in
            make?.leading.equalTo()(containerView)?.offset()(20)
            make?.trailing.equalTo()(containerView)?.offset()(-20)
            make?.height.equalTo()(40)
            make?.top.equalTo()(self.nextEditorView.mas_bottom)?.offset()(15)
            make?.bottom.equalTo()(containerView)?.offset()(-800)
        }
        
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        var alpha:CGFloat = 0
        switch offsetY {
        case  _ where offsetY < -88:
            alpha = 0
        case -88...100:
            alpha = (88 + offsetY)/188.0
        case _ where offsetY > 100:
            alpha = 1
        default:
            alpha = 1
        }
//        self.qd_navConfig?.alpha = alpha

        print(offsetY)
    }
}
