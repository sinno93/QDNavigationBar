//
//  ViewController.swift
//  QDNavigationBar
//
//  Created by sinno93 on 10/20/2020.
//  Copyright (c) 2020 sinno93. All rights reserved.
//

import UIKit
import QDNavigationBar

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.qd_defaultConfig = QDNavigationBarConfig()
        self.navigationController?.qd_defaultConfig?.bgColor = UIColor.red
        let config = self.navigationController?.qd_defaultConfig
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute:
        {
            self.qd_navConfig?.bgColor = UIColor.yellow
        })
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

