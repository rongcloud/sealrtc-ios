//
//  RongRTCWebServer.m
//  SealRTC
//
//  Created by jfdreamyang on 2019/5/31.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RongRTCWebServer.h"
#import "GCDWebServer.h"
#import "GCDWebDAVServer.h"

#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>

bool RunOnXcode(void)
// Returns true if the current process is being debugged (either
// running under the debugger or has a debugger attached post facto).
{
    int                 junk;
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;
    
    // Initialize the flags so that, if sysctl fails for some bizarre
    // reason, we get a predictable result.
    
    info.kp_proc.p_flag = 0;
    
    // Initialize mib, which tells sysctl the info we want, in this case
    // we're looking for information about a specific process ID.
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    
    // Call sysctl.
    
    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);
    
    // We're being debugged if the P_TRACED flag is set.
    
    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}


@implementation RongRTCWebServer
{
    GCDWebServer *_davServer;
}
+(RongRTCWebServer *)sharedWebServer{
    static RongRTCWebServer *_webServer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _webServer = [[self alloc]init];
    });
    return _webServer;
}

-(void)start{
    if (!RunOnXcode()) {
        _davServer = [[GCDWebServer alloc] init];
        [_davServer addGETHandlerForBasePath:@"/" directoryPath:NSHomeDirectory() indexFilename:nil cacheAge:3600 allowRangeRequests:YES];
        [_davServer startWithPort:8088 bonjourName:nil];
    }
}
-(void)stop{
    [_davServer stop];
}
@end
