//
//  ChatAvatarView.m
//  RongCloud
//
//  Created by Vicky on 2018/3/1.
//  Copyright © 2018年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "ChatAvatarView.h"
#import "UIColor+ColorChange.h"
#import "CommonUtility.h"

@implementation ChatAvatarModel

- (instancetype)initWithShowVoice:(BOOL)isShowVoice showIndicator:(BOOL)isShowIndicator userName:(NSString *)userName userID:(NSString *)userId;
{
    self = [super init];
    if (self) {
        _isShowVoice = isShowVoice;
        _isShowIndicator = isShowIndicator;
        _userID = userId;
        _userName = userName;
    }
    return self;
}

@end


@implementation ChatAvatarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self configUI];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    [self configUI];
}

- (UIImageView *)closeCameraImageView
{
    if (!_closeCameraImageView) {
        _closeCameraImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 83)];
        _closeCameraImageView.contentMode = UIViewContentModeScaleToFill;
        _closeCameraImageView.image = [UIImage imageNamed:@"chat_audio_only"];
    }
    return _closeCameraImageView;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.frame.size.width-90)/2,  (self.frame.size.height-90)/2, 90.0, 90.0)];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        CGAffineTransform transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        _indicatorView.transform = transform;
    }
    return _indicatorView;
}

- (void)configUI
{
    self.closeCameraImageView.center = self.center;
    [self addSubview:self.closeCameraImageView];
    
//    self.indicatorView.frame = CGRectMake((self.frame.size.width-90)/2,  (self.frame.size.height-90)/2, 90, 90);
//    [self addSubview:_indicatorView];
//    _indicatorView.hidesWhenStopped = YES;
//    [_indicatorView stopAnimating];
}

- (void)setModel:(ChatAvatarModel *)model
{
    _model = model;
    _closeCameraImageView.hidden = !model.isShowVoice;
    _indicatorView.hidden = !model.isShowIndicator;

    if (model.isShowIndicator)
        [_indicatorView startAnimating];
    else
        [_indicatorView stopAnimating];
}

- (void)hideCloseCameraImage
{
    [self.closeCameraImageView removeFromSuperview];
}

@end
