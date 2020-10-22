//
//  TempConfig.swift
//  QDNavigationBar_Example
//
//  Created by sinno on 2020/10/8.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import QDNavigationBar
/// 配置类
final public class TempConfig: NSObject {
    var realConfig: QDNavigationBarConfig
    /// 导航栏是否显示
    @objc public var barHidden: Bool = false {
        didSet {
            realConfig.barHidden = barHidden
        }
    }
    /// 导航栏背景颜色
    @objc public var bgColor: UIColor = UIColor.white {
        didSet {
            realConfig.bgColor = bgColor
        }
    }
    /// 是否有半透明效果
    @objc public var translucent: Bool = false {
        didSet {
            realConfig.translucent = translucent
        }
    }
    /// 线条
    @objc public var shadowLineColor: UIColor = UIColor.black {
        didSet {
            realConfig.shadowLineColor = shadowLineColor
        }
    }
    /// 否开启导航栏事件穿透
    @objc public var eventThrough: Bool = false {
        didSet {
            realConfig.eventThrough = eventThrough
        }
    }
    
    init(config: QDNavigationBarConfig) {
        realConfig = config
        barHidden = config.barHidden
        bgColor = config.bgColor
        translucent = config.translucent
        shadowLineColor = config.shadowLineColor
        eventThrough = config.eventThrough
    }
}
