//
//  DarkModeTestViewController.swift
//  QDNavigationBar_Example
//
//  Created by sinno on 2020/10/19.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class DarkModeTestViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dark Mode Test"
        self.view.backgroundColor = UIColor.lightGray
        if #available(iOS 13.0, *) {
            self.qd_navConfig?.bgColor = UIColor (dynamicProvider: { (traitEnv) -> UIColor in
                if traitEnv.userInterfaceStyle == .dark {
                    return UIColor.black
                }
                return UIColor.white
            })
        } else {
            // Fallback on earlier versions
        }
        // Do any additional setup after loading the view.
    }
    

}
