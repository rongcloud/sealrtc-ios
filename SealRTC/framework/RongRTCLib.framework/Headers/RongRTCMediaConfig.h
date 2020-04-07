//
//  RongRTCMediaConfig.h
//  RongRTCLib
//
//  Created by RongCloud on 2020/2/13.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RongRTCVideoConfig.h"
#import "RongRTCAudioConfig.h"
NS_ASSUME_NONNULL_BEGIN

@interface RongRTCMediaConfig : NSObject

/*!
 视频配置
 */
@property (nonatomic , strong) RongRTCVideoConfig *videoConfig;

/*!
 音频配置
 */
@property (nonatomic , strong) RongRTCAudioConfig *audioConfig;


@end

NS_ASSUME_NONNULL_END
