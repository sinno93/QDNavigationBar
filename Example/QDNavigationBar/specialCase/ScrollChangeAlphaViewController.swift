//
//  ScrollChangeAlphaViewController.swift
//  QDNavigationBar_Example
//
//  Created by Sinno on 2021/2/1.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import QDNavigationBar

class ScrollChangeAlphaViewController: UIViewController {
    // MARK: - Initialization
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.cameraButton)
        self.navigationItem.titleView = self.titleLabel;
        
        let config = self.navigationController?.navBarConfig?.copy() as? QDNavigationBarConfig
        config?.backgroundColor = UIColor.init(white: 1, alpha: 0.8)
        config?.needBlurEffect = true
        config?.statusBarStyle = .lightContent
        config?.alpha = 0
        self.navBarConfig = config
        configSubviews()
    }
    
    // MARK: - Actions
    // view的一些事件比如按钮点击、手势事件处理、通知处理
    @objc func backClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Private method
    // 控制器的一些私有的辅助方法
    func configSubviews() {
        self.view.backgroundColor = .lightGray
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
            self.navigationItem.largeTitleDisplayMode = .never
        }
    }
    // MARK: - Getter & Setter
    // 属性的Getter/Setter方法
    lazy var backButton: UIButton = {
        let frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let button = UIButton(frame: frame)
        button.setImage(UIImage(named: "backicon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        if #available(iOS 11.0, *) {
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: frame.width),
                button.heightAnchor.constraint(equalToConstant: frame.height),
            ])
        }
        button.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        return button
    }()
    
    lazy var cameraButton: UIButton = {
        let frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let button = UIButton(frame: frame)
        button.setImage(UIImage(named: "cameraicon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        if #available(iOS 11.0, *) {
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: frame.width),
                button.heightAnchor.constraint(equalToConstant: frame.height),
            ])
        }
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17.9)
        label.textColor = .black
        label.text = "朋友圈"
        label.isHidden = true
        return label
    }()
    
    lazy var headerImageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 375, height: 400))
        view.image = UIImage(named: "alphaVC_bgimage")
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true;
        return view;
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = headerImageView
        tableView.backgroundColor = .black
        return tableView
    }()
}

// MARK: - Delegates
// 实现遵循的代理方法
extension ScrollChangeAlphaViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellId")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellId")
        }
        var str: String = "\(indexPath.row)"
        if indexPath.row == 0 {
            str = "↑↑↑ 上滑查看效果(类似微信朋友圈) ↑↑↑"
        }
        cell?.textLabel?.text = str
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        var alpha:CGFloat = 0
        switch offsetY {
        case  _ where offsetY <= 280:
            alpha = 0
        case 280...312:
            alpha = (offsetY-280)/(312-280)
        case _ where offsetY > 312:
            alpha = 1
        default:
            alpha = 1
        }
        self.navBarConfig?.alpha = alpha
        self.titleLabel.alpha = alpha
        self.titleLabel.isHidden = alpha <= 0
        if alpha > 0.1 {
            self.navBarConfig?.statusBarStyle = .default
            self.backButton.tintColor = .black
            self.cameraButton.tintColor = .black
        } else {
            self.navBarConfig?.statusBarStyle = .lightContent
            self.backButton.tintColor = .white
            self.cameraButton.tintColor = .white
        }
    }
    
}
