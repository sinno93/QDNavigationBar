//
//  QDConfigEditorView.m
//  QDCustomNavigation_Example
//
//  Created by Sinno on 2020/8/5.
//  Copyright © 2020 sinno93. All rights reserved.
//

#import "QDConfigEditorView.h"
#import "QDConfigColorView.h"
#import "QDConfigSwitchView.h"
#import "QDConfigSegmentView.h"

#import <Masonry/Masonry.h>
#import <QDNavigationBar_Example-Swift.h>

@interface QDConfigEditorView ()
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) QDConfigColorView *bgColorView;
@property (nonatomic, strong) QDConfigColorView *bottomLineColorView;
@property (nonatomic, strong) QDConfigSwitchView *barHiddenView;
@property (nonatomic, strong) QDConfigSwitchView *translucentView;
@property (nonatomic, strong) QDConfigSwitchView *statusBarHiddenView;
@property (nonatomic, strong) QDConfigSegmentView *statusBarStyleView;
@end

@implementation QDConfigEditorView
#pragma mark - Initialization
// 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configSubviews];
    }
    return self;
}

#pragma mark - Super methods

#pragma mark - Public Methods
// 公开的方法
- (void)setConfig:(QDNavigationBarConfig *)config {
    _config = config;
    [self updateView];
}


#pragma mark - Private Methods
// 私有的方法
- (void)configSubviews {
    [self addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(8, 0, 5, 0));
    }];
    NSArray *array = @[self.bgColorView,
                       self.bottomLineColorView,
                       self.barHiddenView,
                       self.translucentView,
                       self.statusBarHiddenView,
                       self.statusBarStyleView,
                    ];
    for (UIView *view in array) {
        [self.stackView addArrangedSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@48);
        }];
    }
    self.layer.borderColor = UIColor.lightGrayColor.CGColor;
    self.layer.borderWidth = 1.0/UIScreen.mainScreen.scale;
    self.layer.cornerRadius = 15;
}

- (void)updateView {
    self.bgColorView.color = self.config.backgroundColor;
    self.bottomLineColorView.color = self.config.bottomLineColor;
    self.barHiddenView.on = self.config.barHidden;
    self.translucentView.on = self.config.needBlurEffect;
    self.statusBarHiddenView.on = self.config.statusBarHidden;
    self.statusBarStyleView.selectedIndex = ({
        NSInteger index = 0;
        switch (self.config.statusBarStyle) {
            case UIStatusBarStyleDefault:
                index = 0;
                break;
            case UIStatusBarStyleLightContent:
                index = 1;
                break;
            case UIStatusBarStyleDarkContent:
                index = 2;
                break;
            default:
                break;
        }
        index;
    });
}

#pragma mark - Getter && Setter
// Getter和Setter方法
- (UIStackView *)stackView {
    if (!_stackView) {
        UIStackView *view = [[UIStackView alloc] init];
        view.axis = UILayoutConstraintAxisVertical;
        view.alignment = UIStackViewAlignmentFill;
        view.spacing = 1.0f;
        _stackView = view;
    }
    return _stackView;
}
- (QDConfigColorView *)bgColorView {
    if (!_bgColorView) {
        QDConfigColorView *view = [[QDConfigColorView alloc] init];
        view.title = @"backgroundColor";
        view.color = UIColor.whiteColor;
        __weak __typeof(self)weakSelf = self;
        view.colorChanged = ^(UIColor * _Nonnull color) {
            weakSelf.config.backgroundColor = color;
        };
        _bgColorView = view;
    }
    return _bgColorView;
}

- (QDConfigColorView *)bottomLineColorView {
    if (!_bottomLineColorView) {
        QDConfigColorView *view = [[QDConfigColorView alloc] init];
        view.title = @"bottomLineColor";
        view.color = UIColor.redColor;
        __weak __typeof(self)weakSelf = self;
        view.colorChanged = ^(UIColor * _Nonnull color) {
            weakSelf.config.bottomLineColor = color;
        };
        _bottomLineColorView = view;
    }
    return _bottomLineColorView;
}


- (QDConfigSwitchView *)barHiddenView {
    if (!_barHiddenView) {
        QDConfigSwitchView *view = [[QDConfigSwitchView alloc] init];
        view.title = @"barHidden";
        view.on = YES;
        __weak __typeof(self)weakSelf = self;
        view.valueChanged = ^(BOOL on) {
            weakSelf.config.barHidden = on;
        };
        _barHiddenView = view;
    }
    return _barHiddenView;
}

- (QDConfigSwitchView *)translucentView {
    if (!_translucentView) {
        QDConfigSwitchView *view = [[QDConfigSwitchView alloc] init];
        view.title = @"needBlurEffect";
        view.on = YES;
        __weak __typeof(self)weakSelf = self;
        view.valueChanged = ^(BOOL on) {
            weakSelf.config.needBlurEffect = on;
        };
        _translucentView = view;
    }
    return _translucentView;
}

- (QDConfigSwitchView *)statusBarHiddenView {
    if (!_statusBarHiddenView) {
        QDConfigSwitchView *view = [[QDConfigSwitchView alloc] init];
        view.title = @"statusBarHidden";
        view.on = YES;
        __weak __typeof(self)weakSelf = self;
        view.valueChanged = ^(BOOL on) {
            weakSelf.config.statusBarHidden = on;
        };
        _statusBarHiddenView = view;
    }
    return _statusBarHiddenView;
}

- (QDConfigSegmentView *)statusBarStyleView {
    if (!_statusBarStyleView) {
        NSArray *items = nil;
        if (@available(iOS 13.0, *)) {
            items = @[@"Default", @"Light", @"Dark"];
        } else {
            items = @[@"Default", @"Light"];
        }
        QDConfigSegmentView *view = [[QDConfigSegmentView alloc] initWithItems: items];
        view.title = @"statusBarStyle";
        view.selectedIndex = 0;
        __weak __typeof(self)weakSelf = self;
        view.valueChanged = ^(NSInteger selectedIndex) {
            UIStatusBarStyle style = UIStatusBarStyleDefault;
            switch (selectedIndex) {
                case 0:
                    style = UIStatusBarStyleDefault;
                    break;
                case 1:
                    style = UIStatusBarStyleLightContent;
                    break;
                case 2:
                    if (@available(iOS 13.0, *)) {
                        style = UIStatusBarStyleDarkContent;
                    }
                    break;
                default:
                    break;
            }
            weakSelf.config.statusBarStyle = style;
        };
        _statusBarStyleView = view;
    }
    return _statusBarStyleView;
}

@end
