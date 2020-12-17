//
//  RCRTCEffectBottomView.h
//  SealRTC
//
//  Created by 孙承秀 on 2020/8/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RCEffectAllProtocol;
NS_ASSUME_NONNULL_BEGIN

@interface RCRTCEffectBottomView : UIView

/**
 delegate
 */
@property (nonatomic , weak) id <RCEffectAllProtocol> delegate;
- (NSString *)getLoopCount;
@end

@protocol RCEffectAllProtocol <NSObject>


- (void)didSelectPause;
- (void)didSelectStop;
- (void)didSelectResume;
- (void)didSelectVolome:(double)volume;
- (void)didSelectGetTotalVolume;

@end
NS_ASSUME_NONNULL_END
