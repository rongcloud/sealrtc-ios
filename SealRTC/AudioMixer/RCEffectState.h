//
//  RCEffectState.h
//  SealRTC
//
//  Created by 孙承秀 on 2020/8/20.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger,RCEffectStateMachine) {
    RCEffectStateIdle,
    RCEffectStatePlaying,
    RCEffectStatePause,
    RCEffectStateStop,
};
@interface RCEffectState : NSObject

/**
 state
 */
@property (nonatomic , assign , readonly) RCEffectStateMachine currentState;


- (void)nextState;
- (void)resumeState;
- (void)reset;
@end

NS_ASSUME_NONNULL_END
