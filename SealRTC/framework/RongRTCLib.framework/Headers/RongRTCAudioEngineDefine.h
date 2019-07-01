//
//  RongRTCAudioEngineDefine.h
//  RongRTCLib
//
//  Created by 孙承秀 on 2019/5/14.
//  Copyright © 2019 Bailing Cloud. All rights reserved.
//

#ifndef RongRTCAudioEngineDefine_h
#define RongRTCAudioEngineDefine_h
typedef enum : NSUInteger {
    // 只进行音频混合，不播放音频数据
    RongRTCAudioMixTypeOnlyMix,
    // 只进行声音文件的播放，不混合声音数据，不发送声音文件数据（发送 Mic 数据），
    RongRTCAudioMixTypeOnlyPlay,
    // 混合音频的同时播放音频
    RongRTCAudioMixTypeMixAndPlay,
    // 使用提供的音频源进行发送，不采集 mic 数据
    RongRTCAudioMixTypeReplace,
    // 直接使用 Mic 采集的音频数据进行发送（包含录制的人声和从扬声器出来的声音）
    RongRTCAudioMixTypeLoopback
} RongRTCAudioMixType;

#endif /* RongRTCAudioEngineDefine_h */
