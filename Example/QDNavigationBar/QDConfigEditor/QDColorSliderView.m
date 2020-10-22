//
//  QDColorSliderView.m
//  QDCustomNavigation_Example
//
//  Created by Sinno on 2020/8/5.
//  Copyright © 2020 sinno93. All rights reserved.
//

#import "QDColorSliderView.h"
#import <Masonry/Masonry.h>

@interface QDColorGradientView : UIView
@property (nonatomic, strong) NSArray <UIColor *> *colors;
@end

@interface QDColorSliderView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISlider *sliderView;
@property (nonatomic, strong) QDColorGradientView *gradientView;
@property (nonatomic, strong) UIImageView *bgImageView;
@end

@implementation QDColorSliderView

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
- (void)onValueChange:(UISlider *)slider {
    if (self.valueChanged) {
        self.valueChanged(self.value);
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

- (void)setValue:(CGFloat)value {
    value = MAX(value, 0);
    value = MIN(value, 1);
    self.sliderView.value = value;
}

- (CGFloat)value {
    return self.sliderView.value;
}

- (void)setColors:(NSArray<UIColor *> *)colors {
    self.gradientView.colors = colors;
}

- (NSArray <UIColor *> *)colors {
    return self.gradientView.colors;
}
#pragma mark - Private Methods
// 私有的方法
- (void)configSubviews {
    [self addSubview:self.titleLabel];
    [self addSubview:self.bgImageView];
    [self addSubview:self.gradientView];
    [self addSubview:self.sliderView];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(20);
        make.centerY.equalTo(self);
        make.width.equalTo(@60);
    }];
    
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.titleLabel.mas_trailing).offset(1);
        make.trailing.equalTo(self).offset(-20);
        make.centerY.equalTo(self);
    }];
    [self.gradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.sliderView);
        make.centerY.equalTo(self);
        make.height.equalTo(@10);
    }];
    
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.gradientView);
    }];
    self.gradientView.layer.cornerRadius = 5;
    self.bgImageView.layer.cornerRadius = 5;
    self.bgImageView.layer.masksToBounds = YES;
    self.gradientView.layer.borderColor = UIColor.lightGrayColor.CGColor;
    self.gradientView.layer.borderWidth = 1.0/UIScreen.mainScreen.scale;
}
#pragma mark - Getter && Setter
// Getter和Setter方法
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.blackColor;
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UISlider *)sliderView {
    if (!_sliderView) {
        UISlider *view = [[UISlider alloc] init];
        view.minimumTrackTintColor = UIColor.clearColor;
        view.maximumTrackTintColor = UIColor.clearColor;
        [view addTarget:self action:@selector(onValueChange:) forControlEvents:UIControlEventValueChanged];
        _sliderView = view;
    }
    return _sliderView;
}

- (QDColorGradientView *)gradientView {
    if (!_gradientView) {
        _gradientView = [[QDColorGradientView alloc] init];
        UIColor *color1 = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        UIColor *color2 = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
        
        _gradientView.colors = @[color1, color2];
    }
    return _gradientView;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.image = [UIImage imageNamed:@"opacityImage"];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView = imgView;
    }
    return _bgImageView;
}

@end


@implementation QDColorGradientView

+ (Class)layerClass {
    return CAGradientLayer.class;
}

- (void)setColors:(NSArray<UIColor *> *)colors {
    CAGradientLayer *layer = (CAGradientLayer *)self.layer;
    NSMutableArray *arrayM = [NSMutableArray array];
    for (UIColor *color in colors) {
        [arrayM addObject:(id)color.CGColor];
    }
    layer.startPoint = CGPointMake(0.0f, 0.5f);
    layer.endPoint = CGPointMake(1.0f, 0.5f);
    layer.colors = arrayM.copy;
}

@end
