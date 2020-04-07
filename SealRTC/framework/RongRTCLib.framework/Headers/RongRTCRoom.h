//
//  RongRTCRoom.h
//  RongRTCLib
//
//  Created by RongCloud on 2019/1/7.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RongRTCRoomDelegate.h"
#import "RongRTCLocalUser.h"
#import "RongRTCRemoteUser.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 音视频通话的房间
 */
@interface RongRTCRoom : NSObject

/*!
 房间 Delegate
 */
@property (nonatomic, weak) id <RongRTCRoomDelegate> delegate;

/*!
 房间ID
 */
@property (nonatomic, copy, readonly) NSString *roomId;

/*!
 当前用户
 */
@property (nonatomic, strong, readonly) RongRTCLocalUser *localUser;

/*!
 参与用户
 */
@property (nonatomic, strong, readonly) NSArray<RongRTCRemoteUser *> *remoteUsers;

/*!
 会话 id, 用于 server API
 */
@property (nonatomic, copy, readonly) NSString *sessionId;

/*!
 发布默认音视频流，非直播模式使用

 @param completion 发布完成回调
 @discussion
 发布默认音视频流, 非直播模式使用
 
 @remarks 资源管理
 */
- (void)publishDefaultAVStream:(RongRTCOperationCallback)completion;

/*!
 发布主播默认音视频流, 此接口仅直播模式的主播可用, 即 RongRTCRoomType 为 RongRTCRoomTypeLive 可用

 @param completion 发布完成回调
 @discussion
 发布主播默认音视频流, 此接口仅直播模式的主播可用, 即 RongRTCRoomType 为 RongRTCRoomTypeLive 可用
 
 @remarks 资源管理
 */
- (void)publishDefaultLiveAVStream:(RongRTCLiveOperationCallback)completion;

/*!
 取消发布默认音视频流

 @param comletion 取消发布完成回调
 @discussion
 取消发布默认音视频流
 
 @remarks 资源管理
 */
- (void)unpublishDefaultAVStream:(RongRTCOperationCallback)comletion;

/*!
 发送消息
 
 @param content             消息的内容
 @param successBlock        消息发送成功的回调 [messageId:消息的ID]
 @param errorBlock          消息发送失败的回调 [nErrorCode:发送失败的错误码,messageId:消息的ID]
 @discussion
 该接口只能发送 persistentFlag 为 MessagePersistent_STATUS 的状态消息, 远端用户如果不在线则消息丢失, 自定义消息时下面标识一定要给出, 否则会导致消息发送失败
 + (RCMessagePersistent)persistentFlag {
    return MessagePersistent_STATUS;
 }
 
 @remarks 房间管理
 @return 发送的消息实体
 */
- (RCMessage *)sendRTCMessage:(RCMessageContent *)content
                      success:(void (^)(long messageId))successBlock
                        error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock;

/*!
 设置房间属性
 
 @param attributeValue 属性值
 @param key 属性名称
 @param message 是否在设置属性的时候携带消息内容, 传空则不往房间中发送消息
 @param completion 设置完成回调
 @discussion
 设置房间属性
 
 @remarks 房间管理
 */
- (void)setRoomAttributeValue:(NSString *)attributeValue
                       forKey:(NSString *)key
                      message:(RCMessageContent *)message
                   completion:(RongRTCOperationCallback)completion;

/*!
 删除房间属性
 
 @param attributeKeys 属性名称数组
 @param message 是否在设置属性的时候携带消息内容, 传空则不往房间中发送消息
 @param completion 删除完成回调
 @discussion
 删除房间属性
 
 @remarks 房间管理
 */
- (void)deleteRoomAttributes:(NSArray <NSString *> *)attributeKeys message:(RCMessageContent *)message completion:(RongRTCOperationCallback)completion;

/*!
 获取房间属性
 
 @param attributeKeys 属性名称
 @param completion 获取结果回调
 @discussion
 获取房间属性
 
 @remarks 房间管理
 */
- (void)getRoomAttributes:(NSArray <NSString *> *)attributeKeys completion:(RongRTCAttributeOperationCallback)completion;

/*!
 发布音视频流

 @param stream 发布的音视频流
 @param extra  扩展信息
 @param completion 发布的音视频流结果
 @discussion
 发布音视频流
 
 @remarks 资源管理
 */
- (void)publishAVStream:(RongRTCAVOutputStream *)stream extra:(NSString *)extra completion:(RongRTCOperationCallback)completion;

/*!
 发布直播音视频流
 
 @param stream 发布的音视频流
 @param extra  扩展信息
 @param completion 发布的音视频流结果, 包括此主播的推流 url
 @discussion
 发布直播音视频流, 此接口仅直播模式的主播可用, 即 RongRTCRoomType 为 RongRTCRoomTypeLive 可用
 
 @remarks 资源管理
 */
- (void)publishLiveAVStream:(RongRTCAVOutputStream *)stream  extra:(nonnull NSString *)extra completion:(nonnull RongRTCLiveOperationCallback)completion;

/*!
 发布数据流
 
 @param stream 发布的数据流
 @param completion 发布的音视频流结果
 @discussion
 发布数据流
 
 @remarks 资源管理
 */
- (void)publishDataStream:(RongRTCDataOutputStream *)stream completion:(RongRTCOperationCallback)completion;

/*!
 取消发布音视频流
 
 @param stream 取消发布的音视频流
 @param extra  扩展信息
 @param completion 发布的音视频流结果
 @discussion
 取消发布音视频流
 
 @remarks 资源管理
 */
- (void)unpublishAVStream:(RongRTCAVOutputStream *)stream extra:(NSString *)extra completion:(RongRTCOperationCallback)completion;

/*!
 取消发布数据流
 
 @param stream 取消发布的数据流
 @param completion 发布的音视频流结果
 @discussion
 取消发布数据流
 
 @remarks 资源管理
 */
- (void)unpublishDataStream:(RongRTCDataOutputStream *)stream completion:(RongRTCOperationCallback)completion;

/*!
 订阅流
 
 @param avStreams 普通流
 @param tinyStreams 需要携带小流的流数组
 @param completion 完成的回调
 @discussion
 avStreams 表示正常大流, tinyStreams 需要订阅的小流, 两个数组至少有一个不为空, 如果全为空, SDK 将断言, 如果小流数组中包含大流z数组中的流, 则 SDK 认为为订阅小流
 
 @remarks 资源管理
 */
- (void)subscribeAVStream:(nullable NSArray<RongRTCAVInputStream *> *)avStreams
              tinyStreams:(nullable NSArray<RongRTCAVInputStream *> *)tinyStreams
               completion:(nullable RongRTCOperationCallback)completion;

/*!
 接收数据流
 
 @param streams 要接收的数据流
 @param completion 结果
 @discussion
 接收数据流
 
 @remarks 资源管理
 */
- (void)subscribeDataStream:(NSArray<RongRTCAVInputStream *> *)streams
                 completion:(RongRTCOperationCallback)completion;

/*!
 取消订阅音视频流
 
 @param streams 发布的音视频流
 @param completion 取消订阅的音视频流的回调
 @discussion
 取消订阅音视频流, streams 不能为空, 否则 SDK 将断言
 
 @remarks 资源管理
 */
- (void)unsubscribeAVStream:(NSArray <RongRTCAVInputStream *> *)streams completion:(nonnull RongRTCOperationCallback)completion;

/*!
 取消接收数据流
 
 @param streams 要接收的数据流
 @param completion 结果
 @discussion
 取消接收数据流
 
 @remarks 资源管理
 */
- (void)unsubscribeDataStream:(NSArray<RongRTCAVInputStream *> *)streams
                   completion:(RongRTCOperationCallback)completion;

@end

NS_ASSUME_NONNULL_END
