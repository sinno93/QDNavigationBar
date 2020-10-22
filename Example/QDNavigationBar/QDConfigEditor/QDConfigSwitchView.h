//
//  QDConfigSwitchView.h
//  QDCustomNavigation_Example
//
//  Created by Sinno on 2020/8/5.
//  Copyright © 2020 sinno93. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QDConfigSwitchView : UIView
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL on;
@property (nonatomic, copy, nullable) void (^valueChanged)(BOOL on);
@end

NS_ASSUME_NONNULL_END
