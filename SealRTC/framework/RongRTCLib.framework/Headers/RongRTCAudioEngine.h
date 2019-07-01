//
//  RongRTCAudioEngine.h
//  RongRTCLib
//
//  Created by 孙承秀 on 2019/5/14.
//  Copyright © 2019 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RongRTCAudioEngineDefine.h"
NS_ASSUME_NONNULL_BEGIN

@interface RongRTCAudioEngine : NSObject
/**
 单例
 */
@property(class , readonly)RongRTCAudioEngine *instance;
/**
 混音功能（目前只支持混合本地音频数据），开始新混音之前需要先调用 stop，结束混音
 
 @param filePath 要混合的音频数据
 @param mixType 混音音频的类型
 @param loop 视频循环混合音频数据，YES 时 音频数据播放结束时会循环播放
 @return 成功与否
 */
-(void)mixAudioWithFilePath:(NSString *)filePath mixType:(RongRTCAudioMixType)mixType loop:(BOOL)loop;
- (void)start;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
