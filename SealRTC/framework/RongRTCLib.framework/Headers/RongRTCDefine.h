//
//  RongRTCDefine.h
//  RongRTCLib
//
//  Created by RongCloud on 2019/1/3.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#ifndef RongRTCDefine_h
#define RongRTCDefine_h

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "RongRTCCodeDefine.h"

#if defined(__cplusplus)
#define RC_EXPORT extern "C"
#else
#define RC_EXPORT extern
#endif

@class RongRTCMember;
@class RongRTCRoom;
@class RongRTCStream;
@class RongRTCLiveInfo;
@class RongRTCLiveAVInputStream;


/*!
 加入房间成功之后的回调
 
 @param isSuccess 加入成功与否
 @param room 房间中的所有用户信息, 包含自己的信息
 @discussion
 加入房间成功之后的回调, 其中包含房间中的所有用户信息, 包含自己的信息
 
 @remarks 房间管理
 */
typedef void(^RTCJoinRoomCallback)(BOOL isSuccess, RongRTCRoom * _Nullable room);

/*!
 创建流的回调
 
 @param stream 流通道属性, 通过该属性可以直接操作对应的音视频流或者数据
 @discussion
 创建流的回调
 
 @remarks 资源管理
 */
typedef void(^RongRTCCreateStreamCallback)(RongRTCStream * _Nullable stream);

/*!
 某些操作的回调
 
 @param isSuccess 操作是否成功
 @param desc 成功或者失败描述的错误码
 @discussion
 某些操作的回调
 
 @remarks 资源管理
 */
typedef void(^RongRTCOperationCallback)(BOOL isSuccess, RongRTCCode desc);

/*!
 直播操作的回调
 
 @param isSuccess 操作是否成功
 @param desc 成功或者失败描述的错误码
 @param liveInfo 当前直播主持人的数据模型
 @discussion
 直播操作的回调
 
 @remarks 资源管理
 */
typedef void(^RongRTCLiveOperationCallback)(BOOL isSuccess, RongRTCCode desc, RongRTCLiveInfo * _Nullable liveInfo);

/*!
 观众观看直播的回调
 
 @param desc 成功或者失败描述的错误码
 @param inputStream 当前直播流
 @discussion
 观众观看直播的回调
 
 @remarks 资源管理
 */
typedef void(^RongRTCLiveCallback)(RongRTCCode desc, RongRTCLiveAVInputStream * _Nullable inputStream);

/*!
 获取用户属性操作回调
 
 @param isSuccess 操作是否成功
 @param desc 成功或者失败的描述 错误码
 @param attr 获取结果
 @discussion
 获取用户属性操作回调
 
 @remarks 资源管理
 */
typedef void(^RongRTCAttributeOperationCallback)(BOOL isSuccess, RongRTCCode desc, NSDictionary * _Nullable attr);

/*!
 当前流状态
 */
typedef NS_ENUM(NSUInteger, RongRTCInputStreamState) {
    /*!
     输入流处于禁用状态, 不应该订阅, 即使订阅该流也不会收到音视频数据
     */
    RongRTCInputStreamStateForbidden = 0,
    /*!
     输入流处于正常状态, 可以正常订阅
     */
    RongRTCInputStreamStateNormal
} ;

/*!
 资源类型
 */
typedef NS_ENUM(NSUInteger, RTCMediaType) {
    /*!
     只有声音
     */
    RTCMediaTypeAudio,
    /*!
     声音视频
     */
    RTCMediaTypeVideo,
    /*!
     数据（暂不支持）
     */
    RTCMediaTypeData,
    /*!
     空数据
     */
    RTCMediaTypeNothing
};

/*!
 视频分辨率类型
 */
typedef NS_ENUM(NSUInteger, RongRTCVideoSizePreset) {
    /*!
     分辨率 176X132
     */
    RongRTCVideoSizePreset176x132,
    /*!
     分辨率 176X144
     */
    RongRTCVideoSizePreset176x144 DEPRECATED_MSG_ATTRIBUTE("不再支持, 请使用 RongRTCVideoSizePreset176x132 替换"),
    /*!
     分辨率 256X144
     */
    RongRTCVideoSizePreset256x144,
    /*!
     分辨率 320X180
     */
    RongRTCVideoSizePreset320x180,
    /*!
     分辨率 240X240
     */
    RongRTCVideoSizePreset240x240,
    /*!
     分辨率 320X240
     */
    RongRTCVideoSizePreset320x240,
    /*!
     分辨率 480X360
     */
    RongRTCVideoSizePreset480x360,
    /*!
     分辨率 640X360
     */
    RongRTCVideoSizePreset640x360,
    /*!
     分辨率 480X480
     */
    RongRTCVideoSizePreset480x480,
    /*!
     分辨率 640X480
     */
    RongRTCVideoSizePreset640x480,
    /*!
     分辨率 720X480
     */
    RongRTCVideoSizePreset720x480,
    /*!
     分辨率 1280X720
     */
    RongRTCVideoSizePreset1280x720,
};

/*!
 视频方向
 */
typedef NS_ENUM(NSUInteger, RongRTCVideoOrientation) {
    /*!
     竖立, home 键在下部
     */
    RongRTCVideoOrientationPortrait            = 1,
    /*!
     竖立, home 键在上部
     */
    RongRTCVideoOrientationPortraitUpsideDown,
    /*!
     横屏, home 键在左侧
     */
    RongRTCVideoOrientationLandscapeRight,
    /*!
     竖立, home 键在右侧
     */
    RongRTCVideoOrientationLandscapeLeft,
};

/*!
 视频填充模式
 */
typedef NS_ENUM(NSInteger, RCVideoFillMode) {
    /*!
     完整显示, 填充黑边
     */
    RCVideoFillModeAspect,
    /*!
     满屏显示
     */
    RCVideoFillModeAspectFill
}DEPRECATED_MSG_ATTRIBUTE("即将废弃, 请使用 RongRTCVideoFillMode 替换");

/*!
 视频填充模式
 */
typedef NS_ENUM(NSInteger, RongRTCVideoFillMode) {
    /*!
     完整显示, 填充黑边
     */
    RongRTCVideoFillModeAspect,
    /*!
     满屏显示
     */
    RongRTCVideoFillModeAspectFill
};

/*!
 帧率
 */
typedef NS_ENUM(NSUInteger, RongRTCVideoFPS) {
    /*!
     每秒 10 帧
     */
    RongRTCVideoFPS10,
    /*!
     每秒 15 帧
     */
    RongRTCVideoFPS15,
    /*!
     每秒 24 帧
     */
    RongRTCVideoFPS24,
    /*!
     每秒 30 帧
     */
    RongRTCVideoFPS30
};

/*!
 视频编解码
 */
typedef NS_ENUM(NSUInteger, RongRTCCodecType) {
    /*!
     H264 编码
     */
    RongRTCCodecH264
};

/*!
 音频编解码
 */
typedef NS_ENUM(NSUInteger, RongRTCAudioCodecType) {
    /*!
     PCMU
     */
    RongRTCAudioCodecPCMU = 0,
    /*!
     OPUS
     */
    RongRTCAudioCodecOPUS = 111
};

/*!
 摄像头
 */
typedef NS_ENUM(NSUInteger, RongRTCDeviceCamera) {
    /*!
     未指明
     */
    RongRTCCaptureDeviceUnspecified = AVCaptureDevicePositionUnspecified,
    /*!
     后置摄像头
     */
    RongRTCCaptureDeviceBack = AVCaptureDevicePositionBack,
    /*!
     前置摄像头
     */
    RongRTCCaptureDeviceFront = AVCaptureDevicePositionFront
};

/*!
 设置加入房间时音视频使用模式
 */
typedef NS_ENUM(NSUInteger, RongRTCRoomType) {
    /*!
     普通音视频类型
     */
    RongRTCRoomTypeNormal = 0,
    /*!
     直播类型
     */
    RongRTCRoomTypeLive = 2
};

/*!
 直播类型
 */
typedef NS_ENUM(NSUInteger , RongRTCLiveType) {
    /*!
     当前直播为音视频直播
     */
    RongRTCLiveTypeAudioVideo = 0,
    
    /*!
     当前直播为仅音频直播
     */
    RongRTCLiveTypeAudio = 1
};

/*!
 设置音频通话模式, 默认为普通通话模式 RongRTCAudioScenarioDefault
 */
typedef NS_ENUM(NSUInteger, RongRTCAudioScenario) {
    /*!
     普通通话模式(普通音质模式), 满足正常音视频场景
     */
    RongRTCAudioScenarioDefault,
    /*!
     音乐模式(高音质模式), 提升声音质量, 适用对音质要求较高的场景
     */
    RongRTCAudioScenarioMusic
};

/*!
 设置音乐演奏模式, 当音频通话模式为音乐模式（高音质模式, RongRTCAudioScenarioMusic）时, 可以设置音乐演奏模式, 默认为常规演奏模式 RongRTCAudioScenarioMusicNomalPlay
 */
typedef NS_ENUM(NSUInteger, RongRTCAudioScenarioMusicPlayMode) {
    /*!
     常规演奏模式, 满足一般演奏和讲话
     */
    RongRTCAudioScenarioMusicNomalPlay,
    /*!
     单音节演奏模式, 适合长音演奏, 会有一定的回声, 为了提升效果, 需要对端关闭麦克风
     */
    RongRTCAudioScenarioMusicSingleNotePlay
};

/*!
 * Error passing block.
 */
typedef void (^RongRTCVideoCapturerErrorBlock)(NSError * _Nullable error);

/*!
 视频帧回调
 
 @param valid 该视频帧是否有效
 @param sampleBuffer 视频帧内容
 @discussion
 视频帧回调
 
 @remarks 视频流处理
 @return 用户自定义视频帧
 */
typedef CMSampleBufferRef _Nullable (^RongRTCVideoCMSampleBufferCallback)(BOOL valid,CMSampleBufferRef _Nullable sampleBuffer);

/*!
 接收到音频输入输出的回调
 
 @param isOutput 1 证明是从本端发到远端的数据, 0 是接收到的音频数据
 @param audioSamples 音频 PCM 数据
 @param length PCM 数据长度
 @param channels 通道数
 @param sampleRate 采样率
 @discussion
 接收到音频输入输出的回调
 
 @remarks 音频流处理
 */
typedef void(^RongRTCAudioPCMBufferCallback)(BOOL isOutput,const short * _Nullable audioSamples,const int length,const int channels,const int sampleRate);

#endif /* RongRTCDefine_h */
