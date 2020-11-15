//
//  SampleListViewController.swift
//  QDNavigationBar_Example
//
//  Created by sinno on 2020/10/19.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import QDNavigationBar

class SampleListViewController: UIViewController{
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        return tableView
    }()
    let str = NSStringFromClass(LargeTitleViewController.self)
    let search = NSStringFromClass(SearchBarTestViewController.self)
    let dark = NSStringFromClass(DarkModeTestViewController.self)
    lazy var dataList:[(String,String)] = {[("Large title", str), ("Search Bar",search), ("Dark Mode",dark)]}()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Special Case"
        let config = QDNavigationBarConfig()
        config.backgroundColor = UIColor.systemPink
        self.navigationController?.qd_navBarConfig = config
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        configSubviews()
        // Do any additional setup after loading the view.
    }
    
    func configSubviews() {
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

}

extension SampleListViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellId")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellId")
        }
        cell?.textLabel?.text = dataList[indexPath.row].0
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
        let a = dataList[indexPath.row].1
        guard let s = NSClassFromString(a) as? UIViewController.Type else {return}
        let vc = s.init()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

