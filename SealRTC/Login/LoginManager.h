//
//  LoginManager.h
//  SealViewer
//
//  Created by LiuLinhong on 2018/08/10.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCEngine.h>

#define kLoginManager ([LoginManager sharedInstance])


@interface LoginManager : NSObject

@property (nonatomic, strong) NSURL *tokenURL;
@property (nonatomic, assign) BOOL isGPUFilter, isSRTPEncrypt, isTinyStream, isWaterMark;
@property (nonatomic, assign) NSInteger resolutionRatioIndex, frameRateIndex, maxCodeRateIndex, minCodeRateIndex, codingStyleIndex;
@property (nonatomic, strong) NSString *roomNumber, *keyToken, *appKey, *phoneNumber, *userID,*username,*countryCode,*regionName;
@property (nonatomic, strong) NSString *selectedServer, *mediaServerURL;
@property (nonatomic, strong,readonly) RongRTCEngine *rongRTCEngine;
@property (nonatomic, assign) BOOL isLoginTokenSucc, isIMConnectionSucc, isAutoTest;
@property (nonatomic, assign) BOOL isObserver, isBackCamera, isCloseCamera, isSpeaker, isMuteMicrophone, isSwitchCamera, isWhiteBoardOpen;

+ (LoginManager *)sharedInstance;
- (NSString *)keyTokenFrom:(NSString *)num;

@end
