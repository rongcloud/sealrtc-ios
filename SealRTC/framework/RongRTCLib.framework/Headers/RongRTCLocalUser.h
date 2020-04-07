//
//  RongRTCLocalUser.h
//  RongRTCLib
//
//  Created by RongCloud on 2019/1/9.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RongRTCUser.h"
#import "RongRTCCodeDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class RongRTCAVOutputStream;
@class RongRTCDataOutputStream;
@class RongRTCAVInputStream;
@class RCMessageContent;

/*!
 音视频本地用户（当前登陆者）
 */
@interface RongRTCLocalUser : RongRTCUser

/*!
 用户发布的音视频流
 */
@property (nonatomic, copy, readonly) NSArray<RongRTCAVOutputStream *> *localAVStreams;

/*!
 设置用户属性
 
 @param attributeValue 属性值
 @param key 属性名称
 @param message 是否在设置属性的时候携带消息内容，传空则不往房间中发送消息（也不会收到有用户属性变换的回调）
 @param completion 设置完成回调
 @discussion
 设置用户属性
 
 @remarks 房间管理
 */
- (void)setAttributeValue:(NSString *)attributeValue
                   forKey:(NSString *)key
                  message:(RCMessageContent *)message
               completion:(RongRTCOperationCallback)completion;

/*!
 删除用户属性
 
 @param attributeKeys 属性名称数组
 @param message 是否在设置属性的时候携带消息内容，传空则不往房间中发送消息
 @param completion 删除完成回调
 @discussion
 删除用户属性
 
 @remarks 房间管理
 */
- (void)deleteAttributes:(NSArray <NSString *> *)attributeKeys message:(RCMessageContent *)message completion:(RongRTCOperationCallback)completion;

/*!
 获取用户属性
 
 @param attributeKeys 属性名称
 @param completion 获取结果回调
 @discussion
 获取用户属性
 
 @remarks 房间管理
 */
- (void)getAttributes:(NSArray <NSString *> *)attributeKeys completion:(RongRTCAttributeOperationCallback)completion;

/*!
 发布默认音视频流
 
 @param completion 发布完成回调
 @discussion
 发布默认音视频流
 
 @remarks 资源管理
 */
- (void)publishDefaultAVStream:(RongRTCOperationCallback)completion;

/*!
 取消发布默认音视频流
 
 @param comletion 取消发布完成回调
 @discussion
 取消发布默认音视频流
 
 @remarks 资源管理
 */
- (void)unpublishDefaultAVStream:(RongRTCOperationCallback)comletion;

/*!
 发布音视频流
 
 @param stream 发布的音视频流
 @param extra  扩展信息
 @param completion 发布的音视频流结果
 @discussion
 发布音视频流
 
 @remarks 资源管理
 */
- (void)publishAVStream:(RongRTCAVOutputStream *)stream  extra:(nonnull NSString *)extra completion:(nonnull RongRTCOperationCallback)completion;

/*!
 取消发布音视频流
 
 @param stream 取消发布的音视频流
 @param extra  扩展信息
 @param completion 发布的音视频流结果
 @discussion
 取消发布音视频流1
 
 @remarks 资源管理
 */
- (void)unpublishAVStream:(RongRTCAVOutputStream *)stream extra:(NSString *)extra completion:(RongRTCOperationCallback)completion;

@end

NS_ASSUME_NONNULL_END
