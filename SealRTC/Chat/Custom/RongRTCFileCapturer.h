//
//  RongRTCFileCapturer.h
//  RongRTCLib
//
//  Created by jfdreamyang on 2019/1/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <RongRTCLib/RongRTCLib.h>

@protocol RongRTCFileCapturerDelegate <NSObject>

/**
 音视频样本输出是会调用该方法
 
 @param sampleBuffer 音频或者视频样本
 */
- (void)didOutputSampleBuffer:(CMSampleBufferRef _Nullable)sampleBuffer;

- (void)didReadCompleted;

@end

NS_ASSUME_NONNULL_BEGIN

@interface RongRTCFileCapturer : NSObject

@property (nonatomic,weak)id <RongRTCFileCapturerDelegate> delegate;

@property (nonatomic,copy,readonly)NSString *currentPath;

/**
 采集本地视频文件

 @param filePath 视频文件路径，注意不能是网络视频流
 @param errorBlock 结果
 */
- (void)startCapturingFromFilePath:(NSString *)filePath
                           onError:(__nullable RongRTCVideoCapturerErrorBlock)errorBlock;

/**
 * Immediately stops capture.
 */
- (void)stopCapture;
@end

NS_ASSUME_NONNULL_END
