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
//    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _davServer = [[GCDWebServer alloc] init];
    [_davServer addGETHandlerForBasePath:@"/" directoryPath:NSHomeDirectory() indexFilename:nil cacheAge:3600 allowRangeRequests:YES];
    [_davServer startWithPort:8088 bonjourName:nil];
}
-(void)stop{
    [_davServer stop];
}
@end
