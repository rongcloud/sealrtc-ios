//
//  RCRTCDemoEffectBottomView.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/8/19.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCRTCDemoEffectBottomView.h"
#import "Masonry.h"
@interface RCRTCDemoEffectBottomView()<UITextFieldDelegate>
/**
 全局音量
 */
@property (nonatomic , strong) UILabel *nameLabel;

/**
 全局音量滑块
 */
@property (nonatomic , strong) UISlider *volume;

/**
 全局音量
 */
@property (nonatomic , strong) UILabel *volumeLabel;


/**
 stop all
 */
@property (nonatomic , strong) UIButton *stop;

/**
 loop count
 */
@property (nonatomic , strong) UITextField *loopCount;
@end
@implementation RCRTCDemoEffectBottomView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}
- (void)setup {
    [self addSubview:self.volumeLabel];
    [self addSubview:self.volume];
    
    [self addSubview:self.nameLabel];
    [self addSubview:self.stop];
    [self addSubview:self.loopCount];
}
- (void)layoutSubviews{
    [self.volumeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.mas_equalTo(self.mas_left).offset(5);
         make.top.mas_equalTo(self.mas_top).offset(5);
         make.width.mas_equalTo(@(100));
         make.height.mas_equalTo(@(50));
     }];
    [self.volume mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.volumeLabel.mas_right).offset(50);
        make.right.mas_equalTo(self.mas_right).offset(-10);
        make.top.mas_equalTo(self.volumeLabel.mas_top).offset(0);
        make.height.mas_equalTo(@(50));
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(5);
        make.top.mas_equalTo(self.volumeLabel.mas_bottom).offset(5);
        make.width.mas_equalTo(@(100));
        make.height.mas_equalTo(@(50));
    }];
   
    [self.loopCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(2);
        make.top.mas_equalTo(self.nameLabel.mas_top).offset(0);
        make.width.mas_equalTo(@(50));
        make.height.mas_equalTo(@(50));
    }];
   
    [self.stop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-10);
        make.top.mas_equalTo(self.nameLabel.mas_top).offset(5);
        make.width.mas_equalTo(@(150));
        make.height.mas_equalTo(@(40));
    }];
 
}
- (UILabel *)volumeLabel {
    if (!_volumeLabel) {
        _volumeLabel = [[UILabel alloc] init];
        _volumeLabel.text = @"全局音量";
        [_volumeLabel setTextColor:[self getTextColor]];
        [_volumeLabel setFont:[UIFont systemFontOfSize:18]];

    }
    return _volumeLabel;
}
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.text = @"循环次数";
        [_nameLabel setTextColor:[self getTextColor]];
        [_nameLabel setFont:[UIFont systemFontOfSize:18]];
    }
    return _nameLabel;
}
- (UIButton *)stop {
    if (!_stop) {
        _stop = [[UIButton alloc] init];
        [_stop setBackgroundColor:[self getCommonColor]];
        [_stop addTarget:self action:@selector(didSelectStop) forControlEvents:UIControlEventTouchUpInside];
        [_stop setTitle:@"停止所有音效" forState:UIControlStateNormal];
        [_stop setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_stop.titleLabel setFont:[UIFont systemFontOfSize:18]];
        _stop.layer.cornerRadius = 4;
        _stop.layer.masksToBounds = YES;
    }
    return _stop;
}
- (UISlider *)volume {
    if (!_volume) {
        _volume = [[UISlider alloc] init];
        _volume.maximumValue = 100.0;
        _volume.value = 100.0;
        [_volume addTarget:self action:@selector(didSelectVolome:) forControlEvents:UIControlEventValueChanged];
        _volume.layer.cornerRadius = 4;
        _volume.layer.masksToBounds = YES;
        _volume.tintColor = [self getCommonColor];

    }
    return _volume;
}
- (UITextField *)loopCount {
    if (!_loopCount) {
        _loopCount = [[UITextField alloc] init];
        _loopCount.layer.cornerRadius = 4;
        _loopCount.layer.masksToBounds = YES;
        _loopCount.text = [self getStoreCount];
        [_loopCount setTextColor:[self getTextColor]];
        _loopCount.delegate = self;
        [_loopCount setTextAlignment:NSTextAlignmentCenter];
        [_loopCount setBackgroundColor:[UIColor colorWithRed:74.0/255.0 green:74.0/255.0 blue:74.0/255.0 alpha:74.0/255.0]];
    }
    return _loopCount;
}
- (NSString *)getStoreCount {
    NSString *count = [[NSUserDefaults standardUserDefaults] stringForKey:@"loopCount"];
    if (count != nil) {
        return count;;
    }
    return @"1";
}
- (NSString *)getLoopCount {
    return _loopCount.text;
}
- (void)didSelectPause {
    [self.delegate didSelectPause];
}
- (void)didSelectStop{
    [self.delegate didSelectStop];
}
- (void)didSelectResume{
    [self.delegate didSelectResume];
}
- (void)didSelectVolome:(UISlider *)slider{
    [self.delegate didSelectVolome:slider.value];
}
- (void)didSelectGetVolume{
    [self.delegate didSelectGetTotalVolume];
}
- (UIColor *)getTextColor {
//    return [UIColor colorWithRed:134.0/255.0 green:134.0/255.0 blue:134.0/255.0 alpha:1.0];
    return [UIColor whiteColor];
}
- (UIColor *)getCommonColor {
        return [UIColor colorWithRed:0/255.0 green:161.0/255.0 blue:231.0/255.0 alpha:1.0];
//    return [UIColor blueColor];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [[NSUserDefaults standardUserDefaults] setValue:textField.text forKey:@"loopCount"];
    return YES;
}
@end
