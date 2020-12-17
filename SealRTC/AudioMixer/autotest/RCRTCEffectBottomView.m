//
//  RCRTCEffectBottomView.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/8/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCRTCEffectBottomView.h"
#import "Masonry.h"
@interface RCRTCEffectBottomView()

/**
 全局音量
 */
@property (nonatomic , strong) UILabel *volumeLabel;

/**
 全局音量滑块
 */
@property (nonatomic , strong) UISlider *volume;

/**
 暂停全部
 */
@property (nonatomic , strong) UIButton *pause;

/**
 stop all
 */
@property (nonatomic , strong) UIButton *stop;

/**
 恢复所有播放
 */
@property (nonatomic , strong) UIButton *resume;

/**
 获取全局音量值
 */
@property (nonatomic , strong) UIButton *totalVolume;
/**
 getVolume
 */
@property (nonatomic , strong) UIButton *getVolume;

/**
 loop count
 */
@property (nonatomic , strong) UITextField *loopCount;
@end
@implementation RCRTCEffectBottomView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}
- (void)setup {
    [self addSubview:self.volumeLabel];
    [self addSubview: self.volume];
    [self addSubview:self.pause];
    [self addSubview:self.resume];
    [self addSubview:self.stop];
    [self addSubview:self.getVolume];
    [self addSubview:self.loopCount];
}
- (void)layoutSubviews{
    
    [self.volumeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(5);
        make.top.mas_equalTo(self.mas_top).offset(5);
        make.width.mas_equalTo(@(50));
        make.height.mas_equalTo(@(50));
    }];
    [self.volume mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.volumeLabel.mas_right).offset(50);
        make.top.mas_equalTo(self.mas_top).offset(5);
        make.right.mas_equalTo(self.mas_right).offset(-50);
        make.height.mas_equalTo(@(50));
    }];
    [self.loopCount mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.volumeLabel.mas_left).offset(5);
        make.top.mas_equalTo(self.volumeLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(@(50));
        make.height.mas_equalTo(@(50));
    }];
    [self.pause mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.loopCount.mas_right).offset(20);
        make.top.mas_equalTo(self.volumeLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(@(50));
        make.height.mas_equalTo(@(50));
    }];
    [self.stop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.pause.mas_right).offset(20);
        make.top.mas_equalTo(self.volumeLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(@(50));
        make.height.mas_equalTo(@(50));
    }];
    [self.resume mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.stop.mas_right).offset(20);
        make.top.mas_equalTo(self.volumeLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(@(50));
        make.height.mas_equalTo(@(50));
    }];
    [self.getVolume mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.resume.mas_right).offset(20);
        make.top.mas_equalTo(self.volumeLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(@(100));
        make.height.mas_equalTo(@(50));
    }];
}
- (UILabel *)volumeLabel {
    if (!_volumeLabel) {
        _volumeLabel = [[UILabel alloc] init];
        _volumeLabel.text = @"全局音量";
    }
    return _volumeLabel;
}
- (UIButton *)pause {
    if (!_pause) {
        _pause = [[UIButton alloc] init];
        [_pause setBackgroundColor:[UIColor blueColor]];
        [_pause addTarget:self action:@selector(didSelectPause) forControlEvents:UIControlEventTouchUpInside];
        
        [_pause setTitle:@"暂停" forState:UIControlStateNormal];
        [_pause setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_pause.titleLabel setFont:[UIFont systemFontOfSize:10]];
        _pause.layer.cornerRadius = 4;
        _pause.layer.masksToBounds = YES;
    }
    return _pause;
}
- (UIButton *)stop {
    if (!_stop) {
        _stop = [[UIButton alloc] init];
        [_stop setBackgroundColor:[UIColor blueColor]];
        [_stop addTarget:self action:@selector(didSelectStop) forControlEvents:UIControlEventTouchUpInside];
        [_stop setTitle:@"停止" forState:UIControlStateNormal];
        [_stop setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_stop.titleLabel setFont:[UIFont systemFontOfSize:10]];
        _stop.layer.cornerRadius = 4;
        _stop.layer.masksToBounds = YES;
    }
    return _stop;
}
- (UIButton *)resume {
    if (!_resume) {
        _resume = [[UIButton alloc] init];
        [_resume setBackgroundColor:[UIColor blueColor]];
        [_resume addTarget:self action:@selector(didSelectResume) forControlEvents:UIControlEventTouchUpInside];
        [_resume setTitle:@"恢复" forState:UIControlStateNormal];
        [_resume setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_resume.titleLabel setFont:[UIFont systemFontOfSize:10]];
        _resume.layer.cornerRadius = 4;
        _resume.layer.masksToBounds = YES;
    }
    return _resume;
}
- (UISlider *)volume {
    if (!_volume) {
        _volume = [[UISlider alloc] init];
        _volume.maximumValue = 100.0;
        _volume.value = 100.0;
        [_volume addTarget:self action:@selector(didSelectVolome:) forControlEvents:UIControlEventValueChanged];
        _volume.layer.cornerRadius = 4;
        _volume.layer.masksToBounds = YES;
    }
    return _volume;
}
- (UIButton *)getVolume {
    if (!_getVolume) {
        _getVolume = [[UIButton alloc] init];
        [_getVolume setBackgroundColor:[UIColor blueColor]];
        [_getVolume addTarget:self action:@selector(didSelectGetVolume) forControlEvents:UIControlEventTouchUpInside];
        [_getVolume setTitle:@"获取全局音量" forState:UIControlStateNormal];
        [_getVolume setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_getVolume.titleLabel setFont:[UIFont systemFontOfSize:10]];
        _getVolume.layer.cornerRadius = 4;
        _getVolume.layer.masksToBounds = YES;
    }
    return _getVolume;
}
- (UITextField *)loopCount {
    if (!_loopCount) {
        _loopCount = [[UITextField alloc] init];
        _loopCount.layer.borderWidth = 1;
        _loopCount.layer.borderColor = [UIColor blueColor].CGColor;
        _loopCount.layer.cornerRadius = 4;
        _loopCount.layer.masksToBounds = YES;
    }
    return _loopCount;
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
@end
