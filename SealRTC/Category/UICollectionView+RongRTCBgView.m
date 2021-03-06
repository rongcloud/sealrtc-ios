//
//  UICollectionView+RongRTCBgView.m
//  RongCloud
//
//  Created by Rongcloud on 2018/1/24.
//  Copyright © 2018年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "UICollectionView+RongRTCBgView.h"
#import <objc/runtime.h>

static NSString *strKey = @"touchDelegate";

@implementation UICollectionView (RongRTCBgView)

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint point1 = [self convertPoint:point toView:self.chatVC.chatWhiteBoardHandler.whiteBoardView];
    __weak ChatViewController *weakChatVC = self.chatVC;

    if (!weakChatVC && self.tag != 202) {
        return [super hitTest:point withEvent:event];
    }

    NSInteger count = [kChatManager countOfRemoteUserDataArray];
    if ([self pointInside:point withEvent:event] && (count * 90 < ScreenWidth && point1.x > count * 90)) {
        return self.superview;
    } else {
        return [super hitTest:point withEvent:event];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return CGRectContainsPoint(self.bounds, point);
}

- (void)setChatVC:(ChatViewController *)chatVC {
    objc_setAssociatedObject(self, (__bridge const void *)(strKey), chatVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ChatViewController *)chatVC {
    return objc_getAssociatedObject(self, (__bridge const void *)(strKey));
}

@end
