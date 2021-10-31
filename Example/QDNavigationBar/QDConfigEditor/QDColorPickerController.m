//
//  QDColorPickerController.m
//  QDCustomNavigation_Example
//
//  Created by Sinno on 2020/8/5.
//  Copyright © 2020 sinno93. All rights reserved.
//

#import "QDColorPickerController.h"
#import <Masonry/Masonry.h>
#import "QDColorSliderView.h"

@interface QDColorPickerController ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *colorView;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) QDColorSliderView *redSliderView;
@property (nonatomic, strong) QDColorSliderView *greenSliderView;
@property (nonatomic, strong) QDColorSliderView *blueSliderView;
@property (nonatomic, strong) QDColorSliderView *alphaSliderView;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation QDColorPickerController



#pragma mark - Initialization
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return self;
}
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configSubviews];
    [self setData];
    self.containerView.hidden = YES;
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self show];
}

#pragma mark - Actions
- (void)onColorChanged {
    CGFloat red = self.redSliderView.value;
    CGFloat green = self.greenSliderView.value;
    CGFloat blue = self.blueSliderView.value;
    CGFloat alpha = self.alphaSliderView.value;
    
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    _color = color;
    [self setData];
    if (self.colorChanged) {
        self.colorChanged(color);
    }
}

- (void)closeButtonClick:(UIButton *)button {
    [self dismiss];
}

- (void)emptyTap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self.containerView];
    
    if (!CGRectContainsPoint(self.containerView.bounds, point)) {
        [self dismiss];
    }
    
}

#pragma mark - Delegates
#pragma mark - Public methods
- (void)show {
    self.view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0];
    [self.view layoutIfNeeded];
    self.containerView.hidden = NO;
    self.containerView.transform = CGAffineTransformMakeTranslation(0, self.containerView.frame.size.height);
    [UIView animateWithDuration:0.35 animations:^{
        self.containerView.transform = CGAffineTransformIdentity;
        self.view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.4];
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.35 animations:^{
        self.containerView.transform = CGAffineTransformMakeTranslation(0, self.containerView.frame.size.height);
        self.view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self setData];
}
- (void)setData {
    UIColor *color = self.color;
    if (!color) {
        color = UIColor.whiteColor;
    }
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    self.redSliderView.value = red;
    self.greenSliderView.value = green;
    self.blueSliderView.value = blue;
    self.alphaSliderView.value = alpha;
    
//    self.redSliderView.colors =
    self.redSliderView.colors = @[colorWithRGB(0, green, blue), colorWithRGB(1, green, blue)];
    self.greenSliderView.colors = @[colorWithRGB(red, 0, blue), colorWithRGB(red, 1, blue)];
    self.blueSliderView.colors = @[colorWithRGB(red, green, 0), colorWithRGB(red, green, 1)];
    self.alphaSliderView.colors = @[colorWithRGBA(0, 0, 0, 0),colorWithRGBA(0, 0, 0, 1)];
    self.colorView.backgroundColor = color;
    
    // https://blog.walterlv.com/post/get-gray-reversed-color.html
    // 计算反差色
    UIColor *contrastColor = nil;
    CGFloat grayLevel = (0.299 * red + 0.587 * green + 0.114 * blue);
    if (grayLevel > 0.5 || alpha<0.5) {
        contrastColor = UIColor.blackColor;
    } else {
        contrastColor = UIColor.whiteColor;
    }
    self.titleLabel.textColor = contrastColor;
    [self.closeButton setTitleColor:contrastColor forState:UIControlStateNormal];
    NSString *str = [QDColorPickerController hexStringFromColor:color];
    self.titleLabel.text = str;
}
UIColor *colorWithRGB(CGFloat r, CGFloat g, CGFloat b) {
    return colorWithRGBA(r, g, b, 1);
}
UIColor *colorWithRGBA(CGFloat r, CGFloat g, CGFloat b, CGFloat a) {
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}
- (UIColor *)colorWithRGBA:(NSArray *)array {
    CGFloat red = [array[0] doubleValue];
    CGFloat green = [array[1] doubleValue];;
    CGFloat blue = [array[2] doubleValue];;
    CGFloat alpha = [array[3] doubleValue];;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
#pragma mark - Private methods
- (void)configSubviews {
    self.view.backgroundColor = UIColor.clearColor;
    [self.view addSubview:self.containerView];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            make.bottom.equalTo(self.view);
        } else {
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }
        
    }];
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.containerView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.bottom.equalTo(self.containerView);
    }];
    [self.containerView addSubview:self.colorView];
    [self.containerView addSubview:self.closeButton];
    [self.containerView addSubview:self.stackView];
    [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView);
        make.leading.trailing.equalTo(self.view);
        make.height.equalTo(@44);
    }];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.containerView.mas_right).offset(-15);
        
        make.centerY.equalTo(self.colorView);
    }];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.containerView);
        make.top.equalTo(self.colorView.mas_bottom).offset(15);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.containerView.mas_safeAreaLayoutGuideBottom).offset(-15);
        } else {
            make.bottom.equalTo(self.containerView).offset(-15);
        }
        
    }];
    
    NSArray *array = @[self.redSliderView, self.greenSliderView, self.blueSliderView, self.alphaSliderView];
    for (QDColorSliderView *view in array) {
        [self.stackView addArrangedSubview:view];
        __weak __typeof(self)weakSelf = self;
        view.valueChanged = ^(CGFloat value) {
            [weakSelf onColorChanged];
        };
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@40);
        }];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emptyTap:)];
    [self.view addGestureRecognizer:tap];
}
#pragma mark - Setter && Getter

- (UIView *)containerView {
    if (!_containerView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = UIColor.whiteColor;
        _containerView = view;
    }
    return _containerView;
}

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

- (UIView *)colorView {
    if (!_colorView) {
        UIView *view = [[UIView alloc] init];
        view.layer.borderColor = UIColor.grayColor.CGColor;
        view.layer.borderWidth = 1.0/UIScreen.mainScreen.scale;
        [view addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(view);
        }];
        _colorView = view;
    }
    return _colorView;
}

- (QDColorSliderView *)redSliderView {
    if (!_redSliderView) {
        QDColorSliderView *sliderView = [QDColorSliderView new];
        sliderView.title = @"Red";
        _redSliderView = sliderView;
    }
    return _redSliderView;
}

- (QDColorSliderView *)greenSliderView {
    if (!_greenSliderView) {
        QDColorSliderView *sliderView = [QDColorSliderView new];
        sliderView.title = @"Green";
        _greenSliderView = sliderView;
    }
    return _greenSliderView;
}

- (QDColorSliderView *)blueSliderView {
    if (!_blueSliderView) {
        QDColorSliderView *sliderView = [QDColorSliderView new];
        sliderView.title = @"Blue";
        _blueSliderView = sliderView;
    }
    return _blueSliderView;
}

- (QDColorSliderView *)alphaSliderView {
    if (!_alphaSliderView) {
        QDColorSliderView *sliderView = [QDColorSliderView new];
        sliderView.title = @"Alpha";
        _alphaSliderView = sliderView;
    }
    return _alphaSliderView;
}


- (UIButton *)closeButton {
    if (!_closeButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"确定" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.systemBlueColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _closeButton = button;
    }
    return _closeButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.text = @"颜色选择器";
        _titleLabel = label;
    }
    return _titleLabel;
}

+ (NSString *)hexStringFromColor:(UIColor *)color {
    CGColorSpaceModel colorSpace = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
    const CGFloat *components = CGColorGetComponents(color.CGColor);

    CGFloat r, g, b, a;

    if (colorSpace == kCGColorSpaceModelMonochrome) {
        r = components[0];
        g = components[0];
        b = components[0];
        a = components[1];
    } else if (colorSpace == kCGColorSpaceModelRGB) {
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }

    return [NSString stringWithFormat:@"#%02lX%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255),
            lroundf(a * 255)];
}
@end
