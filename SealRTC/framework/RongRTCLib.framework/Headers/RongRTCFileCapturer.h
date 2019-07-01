//
//  RongRTCFileCapturer.h
//  RongRTCLib
//
//  Created by jfdreamyang on 2019/1/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "RongRTCDefine.h"

@protocol RongRTCFileCapturerDelegate <NSObject>

/**
 音视频样本输出是会调用该方法
 
 @param sampleBuffer 音频或者视频样本
 */
- (void)didOutputSampleBuffer:(CMSampleBufferRef _Nullable)sampleBuffer;

@end

NS_ASSUME_NONNULL_BEGIN

@interface RongRTCFileCapturer : NSObject

@property (nonatomic,weak)id <RongRTCFileCapturerDelegate> delegate;

- (void)startCapturingFromFilePath:(NSString *)filePath
                           onError:(__nullable RongRTCVideoCapturerErrorBlock)errorBlock;

/**
 * Immediately stops capture.
 */
- (void)stopCapture;
@end

NS_ASSUME_NONNULL_END
