//
//  RCRTCDefine.h
//  RongIMLib
//
//  Created by Sin on 2019/1/16.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#ifndef RCRTCDefine_h
#define RCRTCDefine_h

typedef NS_ENUM(NSInteger, RCRTCErrorCode) {
    /*!
     不在 RTC room 中
     */
    RCRTCErrorCodeNotInRoom = 40001,
    
    /*!
     server 内部错误
     */
    RCRTCErrorCodeInternalError = 40002,
    
    /*!
     没有匹配的 RTC room
     */
    RCRTCErrorCodeNoMatchedRoom = 40003,
    
    /*!
     非法的用户 id
     */
    RCRTCErrorCodeInvalidUserId = 40004,
    
    /*!
     重复加入已经存在的 RTC room
     */
    RCRTCErrorCodeJoinRepeatedRoom = 40005,
};

typedef NS_ENUM(NSInteger, RCRTCRoomStatus) {
    /*!
     正在加入 RTC room 中
     */
    RCRTCRoomStatusJoining = 1,
    
    /*!
     加入 RTC room 成功
     */
    RCRTCRoomStatusJoined = 2,
    
    /*!
     加入 RTC room 失败
     */
    RCRTCRoomStatusJoinFailed = 3,
    
    /*!
     退出了 RTC room
     */
    RCRTCRoomStatusQuited = 4,
};

#endif /* RCRTCDefine_h */
