//
//  QDColorfulView.m
//  QDCustomNavigation_Example
//
//  Created by sinno on 2020/8/6.
//  Copyright © 2020 sinno93. All rights reserved.
//

#import "QDColorfulView.h"
#import <Masonry/Masonry.h>

@interface QDColorfulView ()
@property (nonatomic, strong) UIStackView *stackView;
@end

@implementation QDColorfulView

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
#pragma mark - Public Methods

#pragma mark - Private Methods
// 私有的方法
- (void)configSubviews {
    [self addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(8, 13, 8, 13));
    }];
    
    NSArray *colorArray = @[UIColor.redColor, UIColor.greenColor, UIColor.blueColor, UIColor.cyanColor, UIColor.magentaColor];
    for (UIColor *color in colorArray) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = color;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(30, 30));
//            make.width.equalTo(view.mas_height);
//            make.height.equalTo(@30);
        }];
        [self.stackView addArrangedSubview:view];
    }
    self.layer.borderColor = UIColor.lightGrayColor.CGColor;
    self.layer.borderWidth = 1.0/UIScreen.mainScreen.scale;
    self.layer.cornerRadius = 15;
}
#pragma mark - Getter && Setter
// Getter和Setter方法
- (UIStackView *)stackView {
    if (!_stackView) {
        UIStackView *view = [UIStackView new];
        view.axis = UILayoutConstraintAxisHorizontal;
        view.alignment = UIStackViewAlignmentCenter;
        view.distribution = UIStackViewDistributionEqualCentering;
        view.spacing = 10.0f;
        
        view.backgroundColor = UIColor.grayColor;
        _stackView = view;
    }
    return _stackView;
}

@end
