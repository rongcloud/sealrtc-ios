//
//  RongRTCWebServer.h
//  SealRTC
//
//  Created by jfdreamyang on 2019/5/31.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

bool RunOnXcode(void);

@interface RongRTCWebServer : NSObject
+(RongRTCWebServer *)sharedWebServer;
-(void)start;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
