//
//  SampleListViewController.swift
//  QDNavigationBar_Example
//
//  Created by sinno on 2020/10/19.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import QDNavigationBar

extension SampleListViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        print("will show")
    }
}

class SampleListViewController: UIViewController{
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Special Case"
        
        // 为导航控制器开启QDNavigationBar样式管理功能
        let config = QDNavigationBarConfig()
        config.backgroundColor = UIColor.systemPink
        self.navigationController?.navBarConfig = config
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationItem.largeTitleDisplayMode = .never
        }
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        
        let a = NSClassFromString("NSKVONotifying_QDNavigationBar_Example.SampleListViewController");
        printClass(info: "addObserver前")
        self.addObserver(self, forKeyPath: "title", options: .new, context: nil);
        self.addObserver(self, forKeyPath: "view", options: .new, context: nil)
        printClass(info: "addObserver后")
        
        self.navigationController?.delegate = self
        printMethods(info: "添加Observer后")
        printClass(info: "设置delegate后")
        self.removeObserver(self, forKeyPath: "title", context: nil)
        self.removeObserver(self, forKeyPath: "view", context: nil)
        printMethods(info: "remove-Observer title后")
        printMethods(info: "remove-Observer title后", NSClassFromString("NSKVONotifying_QDNavigationBar_Example.SampleListViewController"))
        printClass(info: "removeObserver后")
        let b = NSClassFromString("NSKVONotifying_QDNavigationBar_Example.SampleListViewController");
        self.addObserver(self, forKeyPath: "title", options: .new, context: nil);
        printClass(info: "再次addObserver后")
//        print(self.class)
        configSubviews()
    }
    
    func printClass(info: String) {
        let classname = String(cString: class_getName(object_getClass(self)))
        let outClassName = NSStringFromClass(type(of: self))
        print("\(info): \(classname) = \(outClassName)")
    }
    
    func printMethods(info: String, _ toClass: AnyClass? = nil) {
        return
        let realClass: AnyClass? = toClass ?? object_getClass(self)
        var count:UInt32 = 0
        
        let me = class_copyMethodList(realClass, &count)
        print("\(info)----Start")
        for i in 0..<count {
            let str = String(cString:sel_getName(method_getName(me![Int(i)])))
            print("\(str)")
        }
        print("\(info)----End")
    }
    // MARK: - Private method
    // 控制器的一些私有的辅助方法
    func configSubviews() {
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
    
    
    lazy var dataList:[(String,UIViewController.Type)] = {
            [("Large title", LargeTitleViewController.self),
//            ("Search Bar",SearchBarTestViewController.self),
            ("Dark Mode",DarkModeTestViewController.self),
            ("Wechat效果", ScrollChangeAlphaViewController.self)]
    }()
    
}

// MARK: - Delegates
// 实现遵循的代理方法
extension SampleListViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId") ?? UITableViewCell(style: .default, reuseIdentifier: "cellId")
        cell.textLabel?.text = dataList[indexPath.row].0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
        let vcclass = dataList[indexPath.row].1
        let vc = vcclass.init()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension SampleListViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.navigationController?.viewControllers.count ?? 0 > 1;
    }
}
