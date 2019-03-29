//
//  ChatRongRTCRoomDelegateImpl.h
//  SealRTC
//
//  Created by LiuLinhong on 2019/02/14.
//  Copyright © 2019 BridgeMind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatRongRTCRoomDelegateImpl : NSObject <RongRTCRoomDelegate>

- (instancetype)initWithViewController:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
