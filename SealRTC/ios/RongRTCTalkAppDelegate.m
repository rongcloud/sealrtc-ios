//
//  RongRTCTalkAppDelegate.m
//  RongCloud
//
//  Created by RongCloud on 2016/11/11.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "RongRTCTalkAppDelegate.h"
#import <RongRTCLib/RongRTCEngine.h>

@implementation RongRTCTalkAppDelegate {
    UIWindow *_window;
}

#pragma mark - UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window
{
    if (self.isForceLandscape) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }else if (self.isForcePortrait){
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskPortrait;
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
