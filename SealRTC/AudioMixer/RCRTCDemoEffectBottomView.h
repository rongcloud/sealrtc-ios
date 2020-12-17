//
//  RCRTCDemoEffectBottomView.h
//  SealRTC
//
//  Created by 孙承秀 on 2020/8/19.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol RCDemoEffectAllProtocol;
@interface RCRTCDemoEffectBottomView : UIView

/**
 delegate
 */
@property (nonatomic , weak) id <RCDemoEffectAllProtocol> delegate;
- (NSString *)getLoopCount;
@end
@protocol RCDemoEffectAllProtocol <NSObject>


- (void)didSelectPause;
- (void)didSelectStop;
- (void)didSelectResume;
- (void)didSelectVolome:(double)volume;
- (void)didSelectGetTotalVolume;

@end
NS_ASSUME_NONNULL_END
