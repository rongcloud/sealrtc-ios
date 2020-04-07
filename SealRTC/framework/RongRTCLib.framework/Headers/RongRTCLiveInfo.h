//
//  RongRTCLiveInfo.h
//  RongRTCLib
//
//  Created by RongCloud on 2019/8/22.
//  Copyright © 2019 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RongRTCMixConfig.h"
#import "RongRTCDefine.h"
NS_ASSUME_NONNULL_BEGIN

@interface RongRTCLiveInfo : NSObject

/**
 当前的直播地址
 */
@property(nonatomic , copy)NSString *liveUrl;

/*!
 设置混流布局配置
 
 @param config 混流布局配置
 @param completion 动作的回调
 @discussion
 设置混流布局配置
 
 @remarks 资源管理
 */
- (void)setMixStreamConfig:(RongRTCMixConfig *)config completion:(void (^) (BOOL isSuccess , RongRTCCode code))completion;

@end

NS_ASSUME_NONNULL_END
