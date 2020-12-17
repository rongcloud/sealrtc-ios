//
//  RCDemoEffectCell.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/8/17.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDemoEffectCell.h"
#import "Masonry.h"
#import "UIColor+Helper.h"
#import "RCEffectState.h"
#import <RongRTCLib/RongRTCLib.h>
@interface RCDemoEffectCell()

/**
 名字
 */
@property (nonatomic , strong) UILabel *nameLabel;

/**
 播放
 */
@property (nonatomic , strong) UIButton *play;

/**
 暂停
 */
@property (nonatomic , strong) UIButton *pause;

/**
 停止
 */
@property (nonatomic , strong) UIButton *stop;

/**
 恢复
 */
@property (nonatomic , strong) UIButton *resume;

/**
 音量滑块
 */
@property (nonatomic , strong) UISlider *volume;

/**
 preload
 */
@property (nonatomic , strong) UISwitch *preload;

/**
 state
 */
@property (nonatomic , strong) RCEffectState *stateMachine;

/**
 isEnd
 */
@property (nonatomic , assign) BOOL isEnd;

@end
@implementation RCDemoEffectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}
- (void)setup{
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.preload];
    [self.contentView addSubview:self.volume];
    [self.contentView addSubview:self.play];
    [self.contentView addSubview:self.stop];
    
}
- (void)setModel:(RCEffectModel *)model {
    self.stateMachine = [[RCEffectState alloc] init];

    _model = model;
    self.nameLabel.text = model.name;
    
}
- (void)layoutSubviews{
    int namelabelWidth = 50;
    int preloadWidth = 50;
    int volumeWidth = 100;
    int playWidth = 30;
    int stopWidth = 30;
    int fix = ([UIScreen mainScreen].bounds.size.width - (namelabelWidth + preloadWidth + volumeWidth + playWidth + stopWidth + 30)) / 4;
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(15);
        make.top.mas_equalTo(self.contentView.mas_top).offset(5);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
        make.width.mas_equalTo(@(namelabelWidth));
    }];
    [self.preload mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(fix);
        make.top.mas_equalTo(self.contentView.mas_top).offset(8);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
        make.width.mas_equalTo(@(preloadWidth));
    }];
    [self.volume mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.preload.mas_right).offset(fix);
        make.top.mas_equalTo(self.contentView.mas_top).offset(0);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-15);
        make.width.mas_equalTo(@(volumeWidth));
    }];
    [self.play mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.volume.mas_right).offset(fix);
        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-20);
        make.width.mas_equalTo(@(playWidth));
    }];
    [self.stop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.play.mas_right).offset(fix);
        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-20);
        make.width.mas_equalTo(@(stopWidth));
    }];
}
- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setTextColor:[self getTextColor]];
        [_nameLabel setFont:[UIFont systemFontOfSize:18]];
    }
    return _nameLabel;
}
- (UIButton *)play {
    if (!_play) {
        _play = [[UIButton alloc] init];
        [_play addTarget:self action:@selector(didSelectPlay:) forControlEvents:UIControlEventTouchUpInside];
        [_play setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_play.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [_play setBackgroundImage:[UIImage imageNamed:@"audio_mixer_play"] forState:UIControlStateNormal];
        [_play setBackgroundImage:[UIImage imageNamed:@"audio_mixer_pause"] forState:UIControlStateSelected];
    }
    return _play;
}
- (UIButton *)pause {
    if (!_pause) {
        _pause = [[UIButton alloc] init];
        [_pause setBackgroundColor:[UIColor blueColor]];
        [_pause addTarget:self action:@selector(didSelectPause) forControlEvents:UIControlEventTouchUpInside];
        
        [_pause setTitle:@"暂停" forState:UIControlStateNormal];
        [_pause setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_pause.titleLabel setFont:[UIFont systemFontOfSize:18]];
        _pause.layer.cornerRadius = 4;
        _pause.layer.masksToBounds = YES;
    }
    return _pause;
}
- (UIButton *)stop {
    if (!_stop) {
        _stop = [[UIButton alloc] init];
        [_stop addTarget:self action:@selector(didSelectStop) forControlEvents:UIControlEventTouchUpInside];
        [_stop setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_stop.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [_stop setBackgroundImage:[UIImage imageNamed:@"audio_mixer_stop"] forState:UIControlStateNormal];
        _stop.enabled = NO;
    }
    return _stop;
}
- (UIButton *)resume {
    if (!_resume) {
        _resume = [[UIButton alloc] init];
        [_resume addTarget:self action:@selector(didSelectResume) forControlEvents:UIControlEventTouchUpInside];
        [_resume setTitle:@"恢复" forState:UIControlStateNormal];
        [_resume setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_resume.titleLabel setFont:[UIFont systemFontOfSize:18]];
    }
    return _resume;
}
- (UISlider *)volume {
    if (!_volume) {
        _volume = [[UISlider alloc] init];
        _volume.maximumValue = 100.0;
        _volume.value = 100.0;
        //        _volume.maximumTrackTintColor = [self getCommonColor];
        //        _volume.thumbTintColor = [self getCommonColor];
        _volume.tintColor = [self getCommonColor];
        [_volume addTarget:self action:@selector(didSelectVolome:) forControlEvents:UIControlEventValueChanged];
    }
    return _volume;
}
- (UISwitch *)preload {
    if (!_preload) {
        _preload = [[UISwitch alloc] init];
        _preload.on = YES;
        [_preload setOnTintColor:[self getCommonColor]];
        [_preload addTarget:self action:@selector(toPreload:) forControlEvents:(UIControlEventValueChanged)];
    }
    return _preload;
}
- (void)toPreload:(UISwitch *)swi {
    if ([self.delegate respondsToSelector:@selector(preload:model:)]) {
        [self.delegate preload:swi.on model:self.model];
    }
    if (!swi.on) {
        [self didSelectStop];
        [self reset];
        self.play.enabled = NO;
        self.stop.enabled = NO;
    } else {
         self.play.enabled = YES;
    }
}
- (void)didSelectPlay:(UIButton *)btn {
    self.stop.enabled = YES;
    btn.selected = !btn.selected;
    // idle -> playing
    if (self.stateMachine.currentState == RCEffectStateIdle) {
        [self.stateMachine nextState];
        [self.delegate didSelectPlay:self.model publish:YES];
        return;;
    }
    // playing -> pause
    if (self.stateMachine.currentState == RCEffectStatePlaying) {
        [self.stateMachine nextState];
        [self.delegate didSelectPause:self.model];
        return;
    }
    // pause -> playing(resume)
    if (self.stateMachine.currentState == RCEffectStatePause) {
        [self.stateMachine resumeState];
//        if ([[RCRTCEngine sharedInstance].effectManager isEndEffect:self.model.index]) {
        if (self.isEnd) {
            [self.delegate didSelectPlay:self.model publish:YES];
            self.isEnd = NO;
        } else {
            [self.delegate didSelectResume:self.model];

        }
        return;
    }
    
}
- (void)reset {
    self.isEnd = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stateMachineReset];
        [self setStopEnable:NO];
    });

}
- (void)stateMachineReset {
   [self.stateMachine reset];
    
}
- (void)didSelectPause {
    [self.delegate didSelectPause:self.model];
}
- (void)didSelectStop{
    [self stateMachineReset];
    [self setStopEnable:NO];
    [self.delegate didSelectStop:self.model];
}
- (void)setStopEnable:(BOOL)enable{
    self.play.selected = enable;
    self.stop.enabled = enable;
}
- (void)didSelectResume{
    [self.delegate didSelectResume:self.model];
}
- (void)didSelectVolome:(UISlider *)slider{
    [self.delegate didSelectVolome:self.model volume:slider.value];
}
- (void)didSelectGetVolume {
    [self.delegate didSelectGetVolume];
}
- (UIColor *)getTextColor {
//    return [UIColor colorWithRed:134.0/255.0 green:134.0/255.0 blue:134.0/255.0 alpha:1.0];
    return [UIColor whiteColor];
}
- (UIColor *)getCommonColor {
        return [UIColor colorWithRed:0/255.0 green:161.0/255.0 blue:231.0/255.0 alpha:1.0];
//    return [UIColor blueColor];
}
@end
