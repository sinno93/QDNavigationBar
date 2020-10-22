//
//  QDColorPickerController.h
//  QDCustomNavigation_Example
//
//  Created by Sinno on 2020/8/5.
//  Copyright © 2020 sinno93. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QDColorPickerController : UIViewController
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, copy, nullable) void (^colorChanged)(UIColor *color);
- (void)show;
@end

NS_ASSUME_NONNULL_END
