//
//  RCIMClient+WebRTC.h
//  RongIMLib
//
//  Created by Sin on 2019/1/14.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
@class RCRTCUserInfo,RCRTCRoomInfo;

typedef NS_ENUM(NSInteger, RCWebRTCOrderType) {
    RCWebRTCOrderTypeAsc = 1,         // asc
    RCWebRTCOrderTypeDesc = 2,         // desc
};

typedef NS_ENUM(NSInteger, RCWebRTCDataType) {
    RCWebRTCDataTypeRoom = 1,
    RCWebRTCDataTypeUser = 2,
};

@protocol RCRTCRoomDelegate <NSObject>

/*!
 开始加入 RTC room 的回调
 
 @param roomId roomId
 */
- (void)onRTCRoomJoining:(NSString *)roomId;

/*!
 加入 RTC room 成功的回调
 
 @param roomId roomId
 */
- (void)onRTCRoomJoined:(NSString *)roomId;

/*!
 加入 RTC room 失败的回调
 
 @param roomId  roomId
 @param errorCode  失败的错误码
 */
- (void)onRTCRoomJoinFailed:(NSString *)roomId errorCode:(RCErrorCode)errorCode;

/*!
 退出 RTC room 成功的回调
 
 @param roomId roomId
 */
- (void)onRTCRoomQuited:(NSString *)roomId;

@end

@protocol RCRTCRoomPingDelegate <NSObject>

/**
 RTC room ping 失败的回调

 @param code 错误码，0 代表 ping 成功
 */
- (void)onRTCRoomPingResult:(RCErrorCode)code;

@end

@interface RCIMClient (WebRTC)

@property (nonatomic, weak) id<RCRTCRoomDelegate> rtcRoomDelegate;

@property (nonatomic, weak) id<RCRTCRoomPingDelegate> rtcRoomPingDelegate;

/**
 keepAlive
 */

@property (nonatomic, assign) BOOL forceKeepAlive;


/**
 加入 RTC room 并同时获取 room 内成员列表
 
 @param roomId room id
 @param successBlock 成功
 @param errorBlock 失败
 */
- (void)joinRTCRoomWithUserData:(NSString *)roomId
                        success:(void (^)(NSArray <RCRTCUserInfo *> *users,NSString *token))successBlock error:(void (^)(RCErrorCode status))errorBlock;

/**
 退出 RTC room

 @param roomId room id
 @param successBlock 成功
 @param errorBlock 失败
 */
- (void)quitRTCRoom:(NSString *)roomId success:(void (^)(void))successBlock error:(void (^)(RCErrorCode status))errorBlock;

/**
 设置用户数据

 @param roomId room id
 @param key key
 @param value value
 @param successBlock 成功
 @param errorBlock 失败
 */
- (void)putRTCUserData:(NSString *)roomId key:(NSString *)key value:(NSString *)value success:(void (^)(void))successBlock error:(void (^)(RCErrorCode status))errorBlock;

/**
 设置 RTC room 数据

 @param roomId room id
 @param key key
 @param value value
 @param successBlock 成功
 @param errorBlock 失败
 */
- (void)putRTCRoomData:(NSString *)roomId key:(NSString *)key value:(NSString *)value success:(void (^)(void))successBlock error:(void (^)(RCErrorCode status))errorBlock;

/**
 删除用户数据

 @param roomId room id
 @param keys key 列表
 @param successBlock 成功
 @param errorBlock 失败
 */
- (void)deleteRTCUserDatas:(NSString *)roomId forKeys:(NSArray<NSString *> *)keys success:(void (^)(void))successBlock error:(void (^)(RCErrorCode status))errorBlock;

/**
 删除 RTC room 数据

 @param roomId room id
 @param keys key 列表
 @param successBlock 成功
 @param errorBlock 失败
 */
- (void)deleteRTCRoomDatas:(NSString *)roomId forKeys:(NSArray<NSString *> *)keys success:(void (^)(void))successBlock error:(void (^)(RCErrorCode status))errorBlock;

/**
 获取某 RTC room 内的用户列表

 @param roomId room id
 @param type 获取顺序
 @param successBlock 成功（用户列表）
 @param errorBlock 失败
 */
- (void)getRTCUsers:(NSString *)roomId orderType:(RCWebRTCOrderType)type success:(void (^)(NSArray<RCRTCUserInfo *> *users))successBlock error:(void (^)(RCErrorCode status))errorBlock;

/**
 获取用户成员列表

 @param roomId room id
 @param type 获取顺序
 @param successBlock 成功
 @param errorBlock 失败
 */
- (void)getRTCUserDatas:(NSString *)roomId orderType:(RCWebRTCOrderType)type success:(void (^)(NSArray<RCRTCUserInfo *> *users))successBlock error:(void (^)(RCErrorCode status))errorBlock;

/**
 获取 RTC room 信息

 @param roomId room id
 @param successBlock 成功
 @param errorBlock 失败
 */
- (void)getRTCRoomInfo:(NSString *)roomId success:(void (^)(RCRTCRoomInfo *roomInfo))successBlock error:(void (^)(RCErrorCode status))errorBlock;

/**
 是否只用 RTC

 @return yes，将不会拉取其他会话类型的消息，如单群聊
 */
- (BOOL)useRTCOnly;

//NOTE: inner 与 outer 接口的数据完全隔离，所以才会有两对接口
//inner 接口给 SDK 使用，outer 接口可以提供给开发者使用

/**
 设置内部数据
 
 @param roomId roomId
 @param type 数据所属类型，属于用户层面还是 room 层面
 @param key key
 @param value value
 @param msg 消息体
 @param success 成功回调
 @param error 失败回调
 @discussion 供 SDK 调用，针对当前用户或者 roomId 所对应的 RTC room
 */
- (void)putInnerData:(NSString *)roomId type:(RCWebRTCDataType)type key:(NSString *)key value:(NSString *)value messsage:(RCMessageContent *)msg success:(void (^)(void))success error:(void (^)(RCErrorCode status))error;

/**
 批量获取内部数据
 
 @param roomId roomId
 @param type 数据所属类型，属于用户层面还是 room 层面
 @param keys key 列表
 @param success 成功回调
 @param error 失败回调
 @discussion 供 SDK 调用，针对当前用户或者 roomId 所对应的 RTC room
 */
- (void)getInnerDatas:(NSString *)roomId type:(RCWebRTCDataType)type forKeys:(NSArray <NSString *> *)keys success:(void (^)(NSDictionary *data))success error:(void (^)(RCErrorCode status))error;

/**
 批量删除内部数据
 
 @param roomId roomId
 @param type 数据所属类型，属于用户层面还是 room 层面
 @param keys key 列表
 @param msg 消息体
 @param success 成功回调
 @param error 失败回调
 @discussion 供 SDK 调用，针对当前用户或者 roomId 所对应的 RTC room
 */
- (void)deleteInnerDatas:(NSString *)roomId type:(RCWebRTCDataType)type forKeys:(NSArray <NSString *> *)keys  message:(RCMessageContent *)msg success:(void (^)(void))success error:(void (^)(RCErrorCode status))error;

#pragma mark - outer data

/**
 设置外部数据
 
 @param roomId roomId
 @param type 数据所属类型，属于用户层面还是 room 层面
 @param key key
 @param value value
 @param msg 消息体
 @param success 成功回调
 @param error 失败回调
 @discussion 供开发者调用，针对当前用户或者 roomId 所对应的 RTC room
 */
- (void)putOuterData:(NSString *)roomId type:(RCWebRTCDataType)type key:(NSString *)key value:(NSString *)value messsage:(RCMessageContent *)msg success:(void (^)(void))success error:(void (^)(RCErrorCode status))error;

/**
 批量获取外部数据
 
 @param roomId roomId
 @param type 数据所属类型，属于用户层面还是 room 层面
 @param keys key 列表
 @param success 成功回调
 @param error 失败回调
 @discussion 供开发者调用，针对当前用户或者 roomId 所对应的 RTC room
 */
- (void)getOuterDatas:(NSString *)roomId type:(RCWebRTCDataType)type forKeys:(NSArray <NSString *> *)keys success:(void (^)(NSDictionary *data))success error:(void (^)(RCErrorCode status))error;

/**
 批量删除外部数据
 
 @param roomId roomId
 @param type 数据所属类型，属于用户层面还是 room 层面
 @param keys key 列表
 @param msg 消息体
 @param success 成功回调
 @param error 失败回调
 @discussion 供开发者调用，针对当前用户或者 roomId 所对应的 RTC room
 */
- (void)deleteOuterDatas:(NSString *)roomId type:(RCWebRTCDataType)type forKeys:(NSArray <NSString *> *)keys message:(RCMessageContent *)msg success:(void (^)(void))success error:(void (^)(RCErrorCode status))error;


/**
 将所有 RTC room 连接状态重置为失败，方便后续全部重连
 @warning 仅限于 RCIMClient 内部调用，原则上禁止随意调用，否则会打乱内部重连逻辑
 */
- (void)resetCachedRTCRoomFailed;

/**
 后去 RTCToken

 @param roomId roomId
 @param successBlock 获取成功回调
 @param errorBlock 获取失败的回调 [status:失败的错误码]
 */
- (void)getRTCToken:(NSString *)roomId success:(void (^)(NSString *token))successBlock error:(void (^)(RCErrorCode status))errorBlock;;

@end
