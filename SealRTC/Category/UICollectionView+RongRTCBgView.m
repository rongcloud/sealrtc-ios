//
//  UICollectionView+RongRTCBgView.m
//  RongCloud
//
//  Created by Vicky on 2018/1/24.
//  Copyright © 2018年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "UICollectionView+RongRTCBgView.h"
#import <objc/runtime.h>

static NSString *strKey = @"touchDelegate";

@implementation UICollectionView (RongRTC)

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];//让下一个响应者可以有机会继续处理

//    if ([self.touchDelegate respondsToSelector:@selector(didTouchedBegan:withEvent:withBlock:)]) {
//        [self.touchDelegate didTouchedBegan:touches withEvent:event withBlock:^{
//            [super touchesBegan:touches withEvent:event];//让下一个响应者可以有机会继续处理
//        }];
//    }
   
//}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint point1 = [self convertPoint:point toView:self.chatVC.whiteBoardWebView];
    __weak ChatViewController *weakChatVC = self.chatVC;
    
    if (weakChatVC.isOpenWhiteBoard) {
        return [super hitTest:point withEvent:event];
    }
    
    if (!weakChatVC && self.tag != 202) {
        return [super hitTest:point withEvent:event];
    }

    
//    if (weakChatVC.userIDArray.count * 90 < ScreenWidth && point1.x > weakChatVC.userIDArray.count * 90 && point.y < CGRectGetMaxY(self.frame) && point.y>self.frame.origin.y) {
    if (CGRectContainsPoint(self.frame, point) && (weakChatVC.userIDArray.count * 90 < ScreenWidth && point1.x > weakChatVC.userIDArray.count * 90) ){
        return self.superview;
    }else {
//        if (CGRectContainsPoint(self.chatVC.whiteBoardWebView.frame, point1)){
//            [self.chatVC showButtonsWithWhiteBoardExist:NO];
//        }
        return [super hitTest:point withEvent:event];
    }
    
}

//- (void)setTouchDelegate:(id<CollectionViewTouchesDelegate>)touchDelegate
//{
//    objc_setAssociatedObject(self, (__bridge const void *)(strKey), touchDelegate, OBJC_ASSOCIATION_ASSIGN);
//}
//
//- (id<CollectionViewTouchesDelegate>)touchDelegate
//{
//    return objc_getAssociatedObject(self, (__bridge const void *)(strKey));
//}

- (void)setChatVC:(ChatViewController *)chatVC
{
    objc_setAssociatedObject(self, (__bridge const void *)(strKey), chatVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ChatViewController *)chatVC
{
    return objc_getAssociatedObject(self, (__bridge const void *)(strKey));
}

@end
