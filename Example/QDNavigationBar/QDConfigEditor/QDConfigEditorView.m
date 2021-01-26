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
#import <Masonry/Masonry.h>
#import <QDNavigationBar_Example-Swift.h>

@interface QDConfigEditorView ()
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) QDConfigColorView *bgColorView;
@property (nonatomic, strong) QDConfigColorView *bottomLineColorView;
@property (nonatomic, strong) QDConfigSwitchView *barHiddenView;
@property (nonatomic, strong) QDConfigSwitchView *translucentView;
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
    NSArray *array = @[self.bgColorView, self.bottomLineColorView, self.barHiddenView, self.translucentView];
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
    self.bottomLineColorView.color = self.config.shadowLineColor;
    self.barHiddenView.on = self.config.barHidden;
    self.translucentView.on = self.config.barBlurEffect != nil;
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
            weakSelf.config.shadowLineColor = color;
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
        view.title = @"needBlur";
        view.on = YES;
        __weak __typeof(self)weakSelf = self;
        view.valueChanged = ^(BOOL on) {
            UIBlurEffect *effect = nil;
            if (on) {
                effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            }
            weakSelf.config.barBlurEffect = effect;
        };
        _translucentView = view;
    }
    return _translucentView;
}



@end
