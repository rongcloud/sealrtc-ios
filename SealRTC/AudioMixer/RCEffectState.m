//
//  RCEffectState.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/8/20.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCEffectState.h"
@interface RCEffectState()
/**
 state
 */
@property (nonatomic , assign ) RCEffectStateMachine currentState;
@end
@implementation RCEffectState
- (void)nextState {
    if (self.currentState < RCEffectStateStop) {
        self.currentState += 1;
    } else {
        self.currentState = RCEffectStateIdle;
    }
}
- (void)resumeState {
    if (self.currentState > RCEffectStateIdle) {
        self.currentState -= 1;
    }
}
-(void)reset {
    self.currentState = RCEffectStateIdle;
}
@end
