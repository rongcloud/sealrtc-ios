//
//  ChatLocalVideoRender.h
//  SealRTC
//
//  Created by jfdreamyang on 2019/5/23.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatLocalVideoRender : RongRTCVideoPreviewView
/**
 渲染视图
 
 @param sample 视频 sampleBuffer
 */
- (void)renderSampleBuffer:(CMSampleBufferRef)sample;


/**
 刷新渲染视图 View.
 */
- (void)flushVideoView;
@end

NS_ASSUME_NONNULL_END
