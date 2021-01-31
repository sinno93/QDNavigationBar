//
//  QDConfigSegmentView.m
//  QDNavigationBar_Example
//
//  Created by Sinno on 2021/1/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

#import "QDConfigSegmentView.h"
#import <Masonry/Masonry.h>

@interface QDConfigSegmentView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) NSArray *items;
@end

@implementation QDConfigSegmentView

#pragma mark - Initialization
// 初始化方法

- (instancetype)initWithItems:(NSArray *)items {
    if (self = [super initWithFrame:CGRectZero]) {
        self.items = items;
        [self configSubviews];
    }
    return self;
}

#pragma mark - Super methods

#pragma mark - Action Methods
- (void)onValueChanged {
    if (self.valueChanged) {
        self.valueChanged(self.segmentControl.selectedSegmentIndex);
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

- (void)setSelectedIndex:(NSInteger)index {
    self.segmentControl.selectedSegmentIndex = index;
}

- (NSInteger)selectedIndex {
    return self.segmentControl.selectedSegmentIndex;
}

#pragma mark - Private Methods
// 私有的方法
- (void)configSubviews {
    [self addSubview:self.titleLabel];
    [self addSubview:self.segmentControl];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(15);
        make.trailing.lessThanOrEqualTo(self.segmentControl.mas_leading).offset(-15);
    }];
    
    [self.segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-15);
    }];
}
#pragma mark - Getter && Setter
// Getter和Setter方法
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:20.0];
        label.textColor = UIColor.blackColor;
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = 0.8;
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UISegmentedControl *)segmentControl {
    if (!_segmentControl) {
        UISegmentedControl *view = [[UISegmentedControl alloc] initWithItems:self.items];
        view.apportionsSegmentWidthsByContent = YES;
        [view addTarget:self action:@selector(onValueChanged) forControlEvents:UIControlEventValueChanged];
        _segmentControl = view;
    }
    return _segmentControl;
}

@end

