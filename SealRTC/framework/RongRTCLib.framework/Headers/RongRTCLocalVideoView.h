//
//  RCLocalPreviewView.h
//  RongRTCLib
//
//  Created by RongCloud on 2018/12/17.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "RongRTCVideoPreviewView.h"
#import <AVFoundation/AVFoundation.h>


NS_ASSUME_NONNULL_BEGIN

/*!
 视频渲染的 view
 
 @discussion
 请不要直接在 localView 上添加视图, 内部会有翻转的逻辑, 仅供手机摄像头视频显示使用
 */
@interface RongRTCLocalVideoView : RongRTCVideoPreviewView

/*!
 刷新渲染视图 View
 
 @discussion
 刷新渲染视图 View
 
 @remarks 视频配置
 */
- (void)flushVideoView;

@end

NS_ASSUME_NONNULL_END
