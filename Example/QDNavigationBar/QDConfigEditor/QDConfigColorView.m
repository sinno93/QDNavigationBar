//
//  QDConfigColorView.m
//  QDCustomNavigation_Example
//
//  Created by Sinno on 2020/8/5.
//  Copyright © 2020 sinno93. All rights reserved.
//

#import "QDConfigColorView.h"
#import <Masonry/Masonry.h>
#import "QDColorPickerController.h"


@interface QDConfigColorView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *colorView;
@end

@implementation QDConfigColorView

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

- (void)colorTap:(UITapGestureRecognizer *)tap {
    QDColorPickerController *vc = [[QDColorPickerController alloc] init];
    vc.color = self.color;
    
    [[self getViewController] presentViewController:vc animated:NO completion:nil];
    __weak __typeof(self)weakSelf = self;
    vc.colorChanged = ^(UIColor * _Nonnull color) {
        weakSelf.color = color;
        if (weakSelf.colorChanged) {
            weakSelf.colorChanged(color);
        }
    };
}

#pragma mark - Delegate


#pragma mark - Public Methods
// 公开的方法
- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (void)setColor:(UIColor *)color {
    self.colorView.backgroundColor = color;
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    UIColor *contrastColor = nil;
    CGFloat grayLevel = (0.299 * red + 0.587 * green + 0.114 * blue);
    if (grayLevel > 0.5 || alpha<0.5) {
        contrastColor = UIColor.blackColor;
    } else {
        contrastColor = UIColor.whiteColor;
    }
    _colorView.tintColor = contrastColor;
}

- (UIColor *)color {
    return self.colorView.backgroundColor;
}
#pragma mark - Private Methods
// 私有的方法
- (void)configSubviews {
    [self addSubview:self.titleLabel];
    [self addSubview:self.colorView];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(15);
    }];
    
    [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.trailing.equalTo(self).offset(-25);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}

- (UIViewController *)getViewController {
    UIResponder *responder = self;
    while (responder.nextResponder) {
        if ([responder.nextResponder isKindOfClass:UIViewController.class]) {
            return (UIViewController *)responder.nextResponder;
        }
        responder = responder.nextResponder;
    }
    return nil;
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

- (UIView *)colorView {
    if (!_colorView) {
        
        _colorView = [[UIView alloc] init];
        _colorView.layer.borderColor = UIColor.grayColor.CGColor;
        _colorView.layer.borderWidth = 1.0;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(colorTap:)];
        [_colorView addGestureRecognizer:tapGesture];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [[UIImage imageNamed:@"expand_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        [_colorView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_colorView);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
    }
    return _colorView;
}
@end
