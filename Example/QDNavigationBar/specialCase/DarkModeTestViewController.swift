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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dark Mode Test"
        self.view.backgroundColor = UIColor.lightGray
        if #available(iOS 13.0, *) {
            let config = self.navigationController?.navBarConfig?.copy() as? QDNavigationBarConfig
            config?.backgroundColor = UIColor(dynamicProvider: { (traitEnv) -> UIColor in
                if traitEnv.userInterfaceStyle == .dark {
                    return UIColor.black
                }
                return UIColor.white
            })
            self.navBarConfig = config
        } else {
            
        }
        // Do any additional setup after loading the view.
    }
    

}
