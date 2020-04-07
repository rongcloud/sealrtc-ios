//
//  RongRTCEngine.h
//  RongRTCLib
//
//  Created by RongCloud on 2019/1/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RongRTCDefine.h"
#import "RongRTCRoomConfig.h"
#import "RongRTCCodeDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class RongRTCRoom;
@class RongRTCVideoPreviewView;
@class RongRTCVideoCaptureParam;
@class RongRTCAVOutputStream;
@class RongRTCLiveAVInputStream;
@protocol RongRTCNetworkMonitorDelegate;
@protocol RongRTCActivityMonitorDelegate;


/*!
 音视频 SDK 对应版本
 
 RongRTCLib version: RongRTCLib_Version=>version
 RongRTCLib commit: RongRTCLib_Commit=>commit
 RongRTCLib time: RongRTCLib_Time=>time
 */


/*!
 音视频引擎入口
 */
@interface RongRTCEngine : NSObject

/*!
 音视频引擎单例
 */
+ (RongRTCEngine *)sharedEngine;

/*!
 sdk 状态监视器代理
 */
@property (nonatomic, weak) id <RongRTCActivityMonitorDelegate> monitorDelegate;

/*!
 当然已加入的房间
 */
@property (nonatomic,strong,readonly) RongRTCRoom *currentRoom;

/*!
 设置媒体服务服务地址
 
 @param url 媒体服务服务地址
 @discussion
 设置媒体服务服务地址, 私有部署用户使用
 
 @remarks 资源管理
 @return 设置是否成功
 */
- (BOOL)setMediaServerUrl:(NSString *)url;

/*!
 是否允许断线重连
 
 @param enable 断线重连开关
 @discussion
 是否允许断线重连, 默认 YES, SDK 在断线或者自己被踢出房间会尝试重连, 如果设置为 NO , 自己被踢出房间将不再做重连, 会抛出 `- (void)didKickedOutOfTheRoom:(RongRTCRoom *)room;` 代理
 
 @remarks 资源管理
 */
- (void)setReconnectEnable:(BOOL)enable;

/*!
 加入房间
 
 @param roomId 房间 Id , 支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式 最长 64 个字符
 @param completion 加入房间回调,其中, room 对象中的 remoteUsers , 存储当前房间中的所有人, 包括发布资源和没有发布资源的人
 @discussion
 加入房间
 
 @remarks 房间管理
 */
- (void)joinRoom:(NSString *)roomId
      completion:(void (^)( RongRTCRoom  * _Nullable room, RongRTCCode code))completion;

/*!
 加入房间, 可配置加入房间场景。
 
 @param roomId 房间 Id , 支持大小写英文字母、数字、部分特殊符号 + = - _ 的组合方式 最长 64 个字符
 @param config 加入房间的配置, 主要用于配置直播场景。
 @param completion 加入房间回调, 其中 room 对象中的 remoteUsers , 存储当前房间中的所有人, 包括发布资源和没有发布资源的人
 @discussion
 加入房间
 
 @remarks 房间管理
 */
- (void)joinRoom:(NSString *)roomId
          config:(RongRTCRoomConfig *)config
      completion:(nullable void (^)( RongRTCRoom  * _Nullable room, RongRTCCode code))completion;

/*!
 离开房间
 
 @param roomId 房间 Id
 @param completion 加入房间回调
 @discussion
 离开房间时不需要调用取消资源发布和关闭摄像头, SDK 内部会做好取消发布和关闭摄像头资源释放逻辑
 
 @remarks 房间管理
 */
- (void)leaveRoom:(NSString*)roomId
       completion:(void (^) (BOOL isSuccess, RongRTCCode code))completion;

/*!
 仅直播模式可用,  作为观众, 直接观看主播的直播, 无需加入房间, 通过传入主播的 url, 仅观众端可用
 
 @param url 主播直播的 url
 @param liveType 当前直播类型
 @param handler  动作的回调, 会依次回调主播的 RongRTCLiveAVInputStream , 根据 streamType 区分是音频流还是视频流, 如主播发布了音视频流, 此回调会回调两次, 分别为音频的 RongRTCLiveAVInputStream ,  和视频的 RongRTCLiveAVInputStream 。
 @discussion
 仅直播模式可用,  作为观众, 直接观看主播的直播, 无需加入房间, 通过传入主播的 url, 仅观众端可用
 
 @remarks 资源管理
 */
- (void)subscribeLiveAVStream:(NSString *)url
                     liveType:(RongRTCLiveType)liveType
                      handler:(nullable RongRTCLiveCallback)handler;

/*!
 仅直播模式可用, 作为观众, 退出观看主播的直播, 仅观众端使用
 @param url 主播直播的 url, 如果为空, 则为最后一次 `subscribeLiveAVStream` 接口传入的 url
 @param completion 动作的回调
 @discussion
 仅直播模式可用, 作为观众, 退出观看主播的直播, 仅观众端使用
 
 @remarks 资源管理
 */
- (void)unsubscribeLiveAVStream:(nullable NSString *)url
                     completion:(void (^)(BOOL isSuccess , RongRTCCode code))completion;

/*!
 获取当前客户端全局唯一的 ID
 
 @discussion
 获取当前客户端全局唯一的 ID
 
 @remarks 资源管理
 @return 当前客户端全局唯一的 ID
 */
- (NSString *)getClientId;

/*!
 获取 RongRTCLib 版本号
 
 @discussion
 获取 RongRTCLib 版本号
 
 @remarks 资源管理
 @return 版本号
 */
- (NSString *)getRTCLibVersion;

@end

NS_ASSUME_NONNULL_END
