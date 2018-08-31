//
//  ChatCellVideoViewModel.m
//  RongCloud
//
//  Created by LiuLinhong on 2016/12/07.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "ChatCellVideoViewModel.h"
#import "UIColor+ColorChange.h"

@interface ChatCellVideoViewModel ()
 

@end


@implementation ChatCellVideoViewModel

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self)
    {
        self.cellVideoView = view;
        self.originalSize = CGSizeZero;
        self.userID = @"";
        self.frameRateRecv = 0;
        self.frameWidthRecv = 0;
        self.frameHeightRecv = 0;
        self.avType = 1;
    }
    
    return self;
}

- (UIWebView *)audioLevelView
{
    if (!_audioLevelView) {
        _audioLevelView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"sound" ofType:@"gif"];
        NSURL *url = [NSURL URLWithString:path];
        [_audioLevelView loadRequest:[NSURLRequest requestWithURL:url]];
        _audioLevelView.backgroundColor = [UIColor clearColor];
        _audioLevelView.opaque = NO;
        _audioLevelView.scalesPageToFit = YES;
     }
    return _audioLevelView;
}

- (ChatAvatarView *)avatarView
{
    if (!_avatarView) {
        _avatarView = [[ChatAvatarView alloc] init];
        _avatarView.backgroundColor = [UIColor randomColorForAvatarRBG];
    }
    return _avatarView;
}


- (void)setCellVideoView:(UIView *)cellVideoView
{
    _cellVideoView = cellVideoView;
}

@end
