//
//  QDColorSliderView.h
//  QDCustomNavigation_Example
//
//  Created by Sinno on 2020/8/5.
//  Copyright © 2020 sinno93. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QDColorSliderView : UIView
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, copy, nullable) void (^valueChanged)(CGFloat value);
@property (nonatomic, strong) NSArray <UIColor *> *colors;
@end

NS_ASSUME_NONNULL_END
