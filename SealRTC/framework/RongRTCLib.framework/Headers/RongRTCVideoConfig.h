//
//  RongRTCVideoConfig.h
//  RongRTCLib
//
//  Created by RongCloud on 2020/2/13.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RongRTCVideoExtend.h"
#import "RongRTCVideoLayout.h"
NS_ASSUME_NONNULL_BEGIN

@interface RongRTCVideoConfig : NSObject

/*!
 大视频流配置
 */
@property (nonatomic , strong) RongRTCVideoLayout *videoLayout;
/*!
 小视频流配置
 */
@property (nonatomic , strong) RongRTCVideoLayout *tinyVideoLayout;
/*!
 视频扩展
 */
@property (nonatomic , strong) RongRTCVideoExtend *videoExtend;

@end

NS_ASSUME_NONNULL_END
