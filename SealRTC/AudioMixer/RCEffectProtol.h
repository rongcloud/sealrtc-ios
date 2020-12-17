//
//  RCEffectProtol.h
//  SealRTC
//
//  Created by 孙承秀 on 2020/8/17.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCEffectProtol <NSObject>
- (void)didSelectPlay:(RCEffectModel *)model publish:(BOOL)publish;
- (void)didSelectPause:(RCEffectModel *)model;
- (void)didSelectStop:(RCEffectModel *)model;
- (void)didSelectResume:(RCEffectModel *)model;
- (void)didSelectVolome:(RCEffectModel *)model volume:(NSUInteger)volume;
- (void)didSelectPreload:(RCEffectModel *)model preload:(BOOL)preload;
- (void)didSelectGetVolume;
- (void)didSelectPublish:(RCEffectModel *)model preload:(BOOL)preload;
- (void)preload:(BOOL)preload model:(RCEffectModel *)model;
@end

NS_ASSUME_NONNULL_END
