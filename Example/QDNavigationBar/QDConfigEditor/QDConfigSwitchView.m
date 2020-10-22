//
//  QDConfigSwitchView.m
//  QDCustomNavigation_Example
//
//  Created by Sinno on 2020/8/5.
//  Copyright © 2020 sinno93. All rights reserved.
//

#import "QDConfigSwitchView.h"
#import <Masonry/Masonry.h>

@interface QDConfigSwitchView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *switchView;
@end

@implementation QDConfigSwitchView

#pragma mark - Initialization
// 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configSubviews];
    }
    return self;
}

#pragma mark - Super methods

#pragma mark - Action Methods
- (void)onValueChanged {
    if (self.valueChanged) {
        self.valueChanged(self.switchView.on);
    }
}

#pragma mark - Public Methods
// 公开的方法
- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (void)setOn:(BOOL)on {
    self.switchView.on = on;
}

- (BOOL)on {
    return self.switchView.on;
}

#pragma mark - Private Methods
// 私有的方法
- (void)configSubviews {
    [self addSubview:self.titleLabel];
    [self addSubview:self.switchView];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(15);
    }];
    
    [self.switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-25);
    }];
    
}
#pragma mark - Getter && Setter
// Getter和Setter方法
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:20.0];
        label.textColor = UIColor.blackColor;
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UISwitch *)switchView {
    if (!_switchView) {
        _switchView = [[UISwitch alloc] init];
        [_switchView addTarget:self action:@selector(onValueChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

@end
