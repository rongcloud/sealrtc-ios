//
//  SealRTCAppDelegate.m
//  RongCloud
//
//  Created by RongCloud on 2016/11/11.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "SealRTCAppDelegate.h"
#import <Bugly/Bugly.h>
#import <RongRTCLib/RongRTCEngine.h>

@implementation SealRTCAppDelegate {
    UIWindow *_window;
}

#pragma mark - UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    BuglyConfig *config = [[BuglyConfig alloc] init];
#ifdef DEBUG
    config.channel = @"Debug";
#else
    config.channel = @"Release";
#endif
    
    [Bugly startWithAppId:@"ac3f6a6401" config:config];
    [Bugly setUserIdentifier:[UIDevice currentDevice].name];
#ifndef DEBUG
    [self redirectNSlogToDocumentFolder];
#endif
    return YES;
}
- (void)redirectNSlogToDocumentFolder {
    NSLog(@"Log重定向到本地，如果您需要控制台Log，注释掉重定向逻辑即可。");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"MMddHHmmss"];
    NSString *formattedDate = [dateformatter stringFromDate:currentDate];
    
    NSString *fileName = [NSString stringWithFormat:@"rc%@.log", formattedDate];
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    __block UIBackgroundTaskIdentifier task = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:task];
        task = UIBackgroundTaskInvalid;
    }];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

@end
