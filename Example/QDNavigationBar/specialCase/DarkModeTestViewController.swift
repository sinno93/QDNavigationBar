//
//  DarkModeTestViewController.swift
//  QDNavigationBar_Example
//
//  Created by sinno on 2020/10/19.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import QDNavigationBar

class DarkModeTestViewController: UITableViewController {
    var tipTitle = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dark Mode Test"
        self.view.backgroundColor = UIColor.white
        if #available(iOS 13.0, *) {
            let config = self.navigationController?.navBarConfig?.copy() as? QDNavigationBarConfig
            config?.backgroundColor = UIColor(dynamicProvider: { (traitEnv) -> UIColor in
                if traitEnv.userInterfaceStyle == .dark {
                    return UIColor.black
                }
                return UIColor.white
            })
            self.tipTitle = "打开/关闭Dark Mode，查看导航栏效果"
            self.navBarConfig = config
        } else {
            let config = self.navigationController?.navBarConfig?.copy() as? QDNavigationBarConfig
            config?.transitionStyle = .none
            self.navBarConfig = config
            self.tipTitle = "iOS13.0以下系统不支持设置Dark Mode"
        }
        // Do any additional setup after loading the view.
    }

}

// MARK: - Delegates
// 实现遵循的代理方法
extension DarkModeTestViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId") ?? UITableViewCell(style: .default, reuseIdentifier: "cellId")
        if indexPath.row == 0 {
            cell.textLabel?.text = tipTitle
        } else {
            cell.textLabel?.text = ""
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
    }
    
}
