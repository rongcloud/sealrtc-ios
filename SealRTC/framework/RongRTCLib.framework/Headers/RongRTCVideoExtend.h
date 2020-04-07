//
//  RongRTCVideoExtend.h
//  RongRTCLib
//
//  Created by RongCloud on 2020/2/13.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RongRTCVideoRenderMode) {
    /*!
     自适应裁剪
     */
    RongRTCVideoRenderModeCrop = 1,
    /*!
     填充
     */
    RongRTCVideoRenderModeWhole = 2
};


@interface RongRTCVideoExtend : NSObject

/*!
 裁剪模式, 1: 裁剪  2: 整个充满
 */
@property (nonatomic, assign) RongRTCVideoRenderMode renderMode;

@end

NS_ASSUME_NONNULL_END
