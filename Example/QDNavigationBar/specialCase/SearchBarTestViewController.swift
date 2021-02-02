//
//  SearchBarTestViewController.swift
//  QDNavigationBar_Example
//
//  Created by sinno on 2020/10/19.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import QDNavigationBar

class SearchBarTestViewController: UIViewController {
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Search bar"
        
        // 设置自定义的导航栏样式
        let config = self.navigationController?.navBarConfig?.copy() as? QDNavigationBarConfig
        config?.backgroundColor = UIColor.systemOrange
        self.navBarConfig = config
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = UISearchController()
            tipTitle = "↓↓↓ 下拉查看导航栏带search bar效果 ↓↓↓"
        } else {
            tipTitle = "iOS11.0以下系统不支持设置searchController~ "
        }
        
        configSubviews()
    }
    
    // MARK: - Private method
    // 控制器的一些私有的辅助方法
    func configSubviews() {
        self.view.backgroundColor = .lightGray
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    // MARK: - Getter & Setter
    // 属性的Getter/Setter方法
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    var tipTitle = ""
}

// MARK: - Delegates
// 实现遵循的代理方法
extension SearchBarTestViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId") ?? UITableViewCell(style: .default, reuseIdentifier: "cellId")
        if indexPath.row == 0 {
            cell.textLabel?.text = self.tipTitle
        } else {
            cell.textLabel?.text = "\(indexPath.row)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
    }
    
}
