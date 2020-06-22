//
//  RCRTCStream.h
//  RongRTCLib
//
//  Created by RongCloud on 2019/1/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>
#import "RCRTCLibDefine.h"


NS_ASSUME_NONNULL_BEGIN

/*!
 列席会议的成员信息
 */
@interface RCRTCUser : NSObject

/*!
 请勿调用初始化方法
 */
- (instancetype)init NS_UNAVAILABLE;

/*!
 请勿调用初始化方法
 */
- (instancetype)new NS_UNAVAILABLE;

/*!
 列席会议的用户ID
 */
@property (nonatomic,copy,readonly) NSString * userId;

/*!
 用户扩展信息
 */
@property (nonatomic,copy,readonly)NSString * extra;

/*!
 根据流 Id 获取流
 
 @param streamId 流 Id
 @discussion
 根据流 Id 获取流
 
 @remarks 资源管理
 @return 流对象
 */
- (nullable RCRTCStream *)getStream:(nonnull NSString *)streamId;

@end


NS_ASSUME_NONNULL_END
