//
//  SealRTCAppDelegate.m
//  RongCloud
//
//  Created by RongCloud on 2016/11/11.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "SealRTCAppDelegate.h"
#import "RCRTCWebServer.h"
#import <RongRTCLib/RCRTCEngine.h>
#import <ReplayKit/ReplayKit.h>
@implementation SealRTCAppDelegate {
    UIWindow *_window;
}

#pragma mark - UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 自动化测试取消重定向
    if (Key_Force_Close_Log) {
        [self redirectNSlogToDocumentFolder];
    }
    [[RCRTCWebServer sharedWebServer] start];
    
    return YES;
}
- (void)redirectNSlogToDocumentFolder {
    // Xcode 调试时直接输出到 Xcode 上，非 Xcode 调试时输出到文件中
    if (!RunOnXcode()) {
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
    [[RCRTCWebServer sharedWebServer] stop];
}

@end
