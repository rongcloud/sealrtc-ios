//
//  MessageStatusBar.m
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/11.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "MessageStatusBar.h"
#import "CommonUtility.h"

#define Background_Color [UIColor yellowColor]

static MessageStatusBar *sharedMessageStatusBar = nil;
@implementation MessageStatusBar


+ (MessageStatusBar *)sharedInstance
{
    static dispatch_once_t once_dispatch;
    dispatch_once(&once_dispatch, ^{
        sharedMessageStatusBar = [[MessageStatusBar alloc] init];
    });
    return sharedMessageStatusBar;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;

        NSInteger version = [[[UIDevice currentDevice] systemVersion] integerValue];
        if (version == 11 && [self isiPhoneX]) {
            self.frame = CGRectMake(0,[UIApplication sharedApplication].statusBarFrame.size.height, ScreenWidth, 20.0);
        }else{
            self.frame = [UIApplication sharedApplication].statusBarFrame;
        }

        self.backgroundColor = Background_Color;
        self.animateWithDuration = 0.5f;
        self.messageDelaySeconds = 2.f;
        
        _messageLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textColor = [UIColor blackColor];
        _messageLabel.font = [UIFont systemFontOfSize:14.0f];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 2;
        [self addSubview:_messageLabel];
    }
    return self;
}

- (BOOL)isiPhoneX
{
    if ([[CommonUtility getdeviceName] isEqualToString:@"iPhone X"]) {
        return YES;
    }
    return NO;
}

- (void)showMessageStatusBar:(NSString *)message
{
    self.hidden = NO;
    self.alpha = 0.0f;
    _messageLabel.text = @"";
    CGSize totalSize = self.frame.size;
    self.frame = (CGRect){ self.frame.origin, totalSize };
    
    [UIView animateWithDuration:self.animateWithDuration animations:^{
        self.alpha = 1.0f;
        self->_messageLabel.text = message;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:self.animateWithDuration animations:^{
            self.alpha = 1.0f;
        } completion:^(BOOL finished){
            self->_messageLabel.text = message;
            self.hidden = NO;
        }];
    }];
}

- (void)showMessageStatusBar:(NSString *)message withBackgroundColor:(UIColor *)bgColor
{
    self.backgroundColor = bgColor;
    [self showMessageBarAndHideAuto:message];
}

- (void)hideManual
{
    self.alpha = 1.0f;
    
    [UIView animateWithDuration:0.0f animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished){
        self->_messageLabel.text = @"";
        self.hidden = YES;
    }];
}

- (void)showMessageBarAndHideAuto:(NSString *)message
{
    [self showMessageBarAndHideAuto:message finish:nil];
}

- (void)showMessageBarAndHideAuto:(NSString *)message finish:(void (^)(void))finishBlock
{
    self.hidden = NO;
    self.alpha = 0.0f;
    _messageLabel.text = @"";
    CGSize totalSize = self.frame.size;
    self.frame = (CGRect){ self.frame.origin, totalSize };
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:self.animateWithDuration animations:^{
        weakSelf.alpha = 1.0f;
        self->_messageLabel.text = message;
    } completion:^(BOOL finished){
        [UIView animateWithDuration:self.animateWithDuration delay:self.messageDelaySeconds options:UIViewAnimationOptionCurveLinear animations:^{
            weakSelf.alpha = 0.0f;
        } completion:^(BOOL finished){
            self->_messageLabel.text = @"";
            weakSelf.hidden = YES;
            weakSelf.backgroundColor = Background_Color;
            if (finishBlock)
                finishBlock();
        }];
    }];
}

@end
