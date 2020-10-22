//
//  SearchBarTestViewController.swift
//  QDNavigationBar_Example
//
//  Created by sinno on 2020/10/19.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class SearchBarTestViewController: UIViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        self.qd_navConfig?.bgColor = UIColor.systemOrange
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = UISearchController()
        } else {
            // Fallback on earlier versions
        }
        configSubviews()
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

extension SearchBarTestViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellId")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellId")
        }
        cell?.textLabel?.text = "\(indexPath.row)"
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
    }
    
}
