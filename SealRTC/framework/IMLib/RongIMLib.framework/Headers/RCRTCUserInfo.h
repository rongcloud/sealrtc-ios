//
//  RCRTCUserInfo.h
//  RongIMLib
//
//  Created by Sin on 2019/1/14.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCRTCDefine.h"

/**
 RTC 的用户信息
 */
@interface RCRTCUserInfo : NSObject

/**
 用户 id
 */
@property(nonatomic, copy) NSString *userId;

/**
 用户数据
 */
@property(nonatomic, strong) NSDictionary *data;
@end

/**
 RTC 的房间信息
 */
@interface RCRTCRoomInfo : NSObject

/**
 房间 id
 */
@property(nonatomic, copy) NSString *roomId;

/**
 总共的成员个数
 */
@property(nonatomic, assign) int totalMemberCount;

/**
 房间数据
 */
@property(nonatomic, strong) NSDictionary *data;
@end

@interface RCRTCCacheRoomInfo : NSObject

/**
 rtc 房间的连接状态
 */
@property(nonatomic, assign) RCRTCRoomStatus status;
@end
