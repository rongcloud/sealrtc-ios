//
//  RongRTCAudioMixer.h
//  RongRTCLib
//
//  Created by jfdreamyang on 2019/4/16.
//  Copyright © 2019 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RongRTCAudioMixer : NSObject
+(RongRTCAudioMixer *)sharedMixer;

-(BOOL)setAudioSource:(NSString *)audioPath;

-(void)play;

-(void)stop;

-(void)pause;

-(void)seek:(NSTimeInterval)time;

@end

NS_ASSUME_NONNULL_END
