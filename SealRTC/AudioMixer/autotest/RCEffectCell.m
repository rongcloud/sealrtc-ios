//
//  RCEffectCell.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/8/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCEffectCell.h"
#import "Masonry.h"
@interface RCEffectCell()

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
 preload
 */
@property (nonatomic , strong) UISwitch *publish;

@end
@implementation RCEffectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}
- (void)setup{
    
    [self.contentView addSubview:self.play];
    [self.contentView addSubview:self.pause];
    [self.contentView addSubview:self.resume];
    [self.contentView addSubview:self.stop];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.volume];
    [self.contentView addSubview:self.preload];
    [self.contentView addSubview:self.publish];
}
- (void)setModel:(RCEffectModel *)model {
    _model = model;
    [self didSelectPreload:self.preload];
    self.nameLabel.text = model.name;
}
- (void)layoutSubviews{
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(5);
        make.top.mas_equalTo(self.contentView.mas_top).offset(5);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
        make.width.mas_equalTo(@(50));
    }];
    [self.preload mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(8);
        make.top.mas_equalTo(self.contentView.mas_top).offset(5);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
        make.width.mas_equalTo(@(50));
    }];
    [self.publish mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.preload.mas_right).offset(8);
        make.top.mas_equalTo(self.contentView.mas_top).offset(5);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
        make.width.mas_equalTo(@(50));
    }];
    [self.play mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.publish.mas_right).offset(8);
        make.top.mas_equalTo(self.contentView.mas_top).offset(5);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
        make.width.mas_equalTo(@(30));
    }];
    [self.pause mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.play.mas_right).offset(8);
        make.top.mas_equalTo(self.contentView.mas_top).offset(5);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
        make.width.mas_equalTo(@(30));
    }];
    [self.stop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.pause.mas_right).offset(8);
        make.top.mas_equalTo(self.contentView.mas_top).offset(5);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
        make.width.mas_equalTo(@(30));
    }];
    [self.resume mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.stop.mas_right).offset(8);
        make.top.mas_equalTo(self.contentView.mas_top).offset(5);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
        make.width.mas_equalTo(@(30));
    }];
    [self.volume mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.resume.mas_right).offset(8);
        make.top.mas_equalTo(self.contentView.mas_top).offset(5);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-5);
    }];
}
- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setFont:[UIFont systemFontOfSize:10]];
        _nameLabel.layer.cornerRadius = 4;
        _nameLabel.layer.masksToBounds = YES;
    }
    return _nameLabel;
}
- (UIButton *)play {
    if (!_play) {
        _play = [[UIButton alloc] init];
        [_play setBackgroundColor:[UIColor blueColor]];
        [_play addTarget:self action:@selector(didSelectPlay) forControlEvents:UIControlEventTouchUpInside];
        [_play setTitle:@"播放" forState:UIControlStateNormal];
        [_play setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_play.titleLabel setFont:[UIFont systemFontOfSize:10]];
        _play.layer.cornerRadius = 4;
        _play.layer.masksToBounds = YES;
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
        
    }
    return _volume;
}
- (UISwitch *)preload {
    if (!_preload) {
        _preload = [[UISwitch alloc] init];
        _preload.on = YES;
        _publish.tag = 1;
        [_preload setOnTintColor:[UIColor blueColor]];
        [_preload addTarget:self action:@selector(didSelectPreload:) forControlEvents:UIControlEventValueChanged];
        
    }
    return _preload;
}
- (UISwitch *)publish {
    if (!_publish) {
        _publish = [[UISwitch alloc] init];
        _publish.on = YES;
        _publish.tag = 1;
        [_publish setOnTintColor:[UIColor redColor]];
        [_publish addTarget:self action:@selector(didSelectPreload:) forControlEvents:UIControlEventValueChanged];
        
    }
    return _publish;
}

- (void)didSelectPlay {
    [self.delegate didSelectPlay:self.model publish:self.publish.on];
}
- (void)didSelectPause {
    [self.delegate didSelectPause:self.model];
}
- (void)didSelectStop{
    [self.delegate didSelectStop:self.model];
}
- (void)didSelectResume{
    [self.delegate didSelectResume:self.model];
}
- (void)didSelectVolome:(UISlider *)slider{
    [self.delegate didSelectVolome:self.model volume:slider.value];
}
- (void)didSelectPreload:(UISwitch *)switchBtn{
    if (switchBtn.tag == 0) {
        [self.delegate didSelectPreload:self.model preload:switchBtn.on];
    }
    if (switchBtn.tag == 1) {
        //        [self.delegate didSelectPublish:self.model preload:switchBtn.on];
    }
}

@end
