//
//  LoginRongRTCEngineDelegateImpl.m
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/30.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "LoginRongRTCEngineDelegateImpl.h"
#import "LoginViewController.h"

@interface LoginRongRTCEngineDelegateImpl ()

@property (nonatomic, strong) LoginViewController *loginViewController;

@end

@implementation LoginRongRTCEngineDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.loginViewController = (LoginViewController *) vc;
    }
    return self;
}

#pragma mark - RongRTCEngineDelegate
- (void)rongRTCEngine:(RongRTCEngine *)engine onConnectionStateChanged:(RongRTCConnectionState)state
{
    [LoginViewController setConnectionState:state];
    self.connectionState = state;
    [self.loginViewController updateJoinRoomButtonSocket:self.connectionState];
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onAudioAuthority:(BOOL)enableAudio onVideoAuthority:(BOOL)enableVideo
{
    if (enableAudio && enableVideo)
        return;
    
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"WARNING" message:@"Please open the Authorization of Camera & Micphone" preferredStyle:UIAlertControllerStyleAlert];
    [alertViewController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }]];
    [alertViewController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    [self.loginViewController presentViewController:alertViewController animated:YES completion:^{}];
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onJoinComplete:(BOOL)success
{
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onLeaveComplete:(BOOL)success
{
    DLog(@"LLH......Login rongRTCEngine:onLeaveComplete: %zd", success);
//    if (![self.loginViewController.navigationController.visibleViewController isEqual:self.loginViewController]) {
//        [self.loginViewController.navigationController popToViewController:self.loginViewController animated:YES];
//    }
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onUserJoined:(NSString *)userId userName:(NSString *)userName userType:(RongRTCUserType)type audioVideoType:(RongRTCAudioVideoType)avType screenSharingStatus:(RongRTCScreenSharingState)screenSharingStatus
{
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onUserLeft:(NSString *)userId
{
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onUser:(NSString *)userId audioVideoType:(RongRTCAudioVideoType)avType
{
    
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onWhiteBoardURL:(NSString *)url
{
}

- (void)rongRTCEngineOnAudioDeviceReady:(RongRTCEngine *)engine
{
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onOutputAudioPortSpeaker:(BOOL)enable
{
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onRemoteVideoView:(UIView *)videoView vidoeSize:(CGSize)size remoteUserID:(NSString*)userID
{
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onNetworkSentLost:(NSInteger)lost
{
}

@end
