//
//  QDConfigEditorView.h
//  QDCustomNavigation_Example
//
//  Created by Sinno on 2020/8/5.
//  Copyright © 2020 sinno93. All rights reserved.
//

#import <UIKit/UIKit.h>
@import QDNavigationBar;

NS_ASSUME_NONNULL_BEGIN

@interface QDConfigEditorView : UIView
@property (nonatomic, strong)  QDNavigationBarConfig *config;
@end

NS_ASSUME_NONNULL_END
