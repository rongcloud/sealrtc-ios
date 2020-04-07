//
//  RongRTCVideoCaptureParam.h
//  RongRTCLib
//
//  Created by RongCloud on 2019/1/10.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "RongRTCDefine.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 视频采集器参数
 */
@interface RongRTCVideoCaptureParam : NSObject

/*!
 获取默认音视频采集参数
 
 @discussion
 获取默认音视频采集参数
 
 @remarks 资源管理
 @return 视频采集器参数
 */
+ (RongRTCVideoCaptureParam *)defaultParameters;

/*!
 摄像头输出的视频分辨率, 默认: RongRTCVideoSizePreset640x480
 */
@property(nonatomic,assign) RongRTCVideoSizePreset videoSizePreset;

/*!
 初始化使用前/后摄像头, 默认: 前置摄像头
 */
@property (nonatomic, assign) RongRTCDeviceCamera camera;

/*!
 初始化时是否打开指定的摄像头, 默认: 打开
 */
@property (nonatomic, assign) BOOL turnOnCamera;

/*!
 视频发送帧率. 默认: 15 FPS
 */
@property (nonatomic, assign) RongRTCVideoFPS videoFrameRate;

/*!
 是否启用视频小流，默认: 开启
 */
@property (nonatomic,assign) BOOL tinyStreamEnable;

/*!
 最大码率, 默认 640x480 分辨率时, 默认: 1000 kbps
 */
@property (nonatomic, assign) NSUInteger maxBitrate;

/*!
 最小码率, 默认 640x480 分辨率时, 默认: 350 kbps
 */
@property (nonatomic, assign) NSUInteger minBitrate;

/*!
 摄像头采集方向，默认: AVCaptureVideoOrientationPortrait 角度进行采集
 */
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;

/*!
 视频编解码器，默认: H264
 */
@property (nonatomic, assign) RongRTCCodecType codecType;

/*!
 音频编解码方式, 默认: OPUS
 */
@property (nonatomic, assign) RongRTCAudioCodecType audioCodecType;

/*!
 音频使用模式，默认: 普通通话模式，RongRTC 支持音乐场景下的使用
 */
@property (nonatomic, assign) RongRTCAudioScenario audioScenario;

/*!
 当 RTC 音频为音乐模式时，可以设置音乐演奏模式，默认常规演奏模式
 */
@property (nonatomic, assign) RongRTCAudioScenarioMusicPlayMode musicPlayMode;

@end


/*!
 stream 参数
 */
@interface RongRTCStreamParams : NSObject

/*!
 视频分辨率参数
 */
@property (nonatomic, assign) RongRTCVideoSizePreset videoSizePreset;

/*!
 视频发送帧率. 默认是 15 FPS
 */
@property (nonatomic, assign) RongRTCVideoFPS videoFrameRate;

/*!
 视频编解码
 */
@property (nonatomic, assign) RongRTCCodecType codecType;

/*!
 音频编解码方式
 */
@property (nonatomic, assign) RongRTCAudioCodecType audioCodecType;

/*!
 分辨率
 
 @discussion
 分辨率
 
 @remarks 视频配置
 @return 分辨率
 */
- (CGSize)resolution;

/*!
 帧率
 
 @discussion
 帧率
 
 @remarks 视频配置
 @return 帧率
 */
- (NSInteger)fpsValue;

@end

NS_ASSUME_NONNULL_END
