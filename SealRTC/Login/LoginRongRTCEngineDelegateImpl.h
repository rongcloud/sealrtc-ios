//
//  LoginRongRTCEngineDelegateImpl.h
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/30.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCEngine.h>

@interface LoginRongRTCEngineDelegateImpl : NSObject <RongRTCEngineDelegate>

@property (nonatomic, assign) RongRTCConnectionState connectionState;

- (instancetype)initWithViewController:(UIViewController *)vc;

@end
