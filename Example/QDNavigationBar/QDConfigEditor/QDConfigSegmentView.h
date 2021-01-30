//
//  QDConfigSegmentView.h
//  QDNavigationBar_Example
//
//  Created by Sinno on 2021/1/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QDConfigSegmentView : UIView
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy, nullable) void (^valueChanged)(NSInteger selectedIndex);
- (instancetype)initWithItems:(NSArray <NSString *> *)items;
@end

NS_ASSUME_NONNULL_END
