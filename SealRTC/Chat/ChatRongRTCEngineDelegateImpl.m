
//
//  ChatrongRTCEngineDelegateImpl.m
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/15.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "ChatRongRTCEngineDelegateImpl.h"
#import "ChatViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ChatCellVideoViewModel.h"
#import "LoginViewController.h"
#import "RongRTCTalkAppDelegate.h"
#import "UIColor+ColorChange.h"
#import "ChatDataInfoModel.h"
#import "ChatLocalDataInfoModel.h"
#import "CommonUtility.h"

@interface ChatRongRTCEngineDelegateImpl ()
{
    dispatch_semaphore_t sem;
}
@property (nonatomic, strong) ChatViewController *chatViewController;

@end

@implementation ChatRongRTCEngineDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.chatViewController = (ChatViewController *) vc;
        sem = dispatch_semaphore_create(1);
        _bitrateArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - rongRTCEngineDelegate
- (void)rongRTCEngine:(RongRTCEngine *)engine onAudioAuthority:(BOOL)enableAudio onVideoAuthority:(BOOL)enableVideo
{
    
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onConnectionStateChanged:(RongRTCConnectionState)state
{
    [LoginViewController setConnectionState:state];
    
    if (state == RongRTC_ConnectionState_Disconnected)
        [self.chatViewController joinChannel];
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onJoinComplete:(BOOL)success
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    if (success)
    {
        if (weakChatVC.type == ChatTypeAudio) {
            //    [self.rongRTCEngine disableVideo];
        }
        NSInteger avType = [weakChatVC.paraDic[kCloseCamera] integerValue];
        if (avType == RongRTC_User_Only_Audio && weakChatVC.isFinishLeave && !(weakChatVC.observerIndex == RongRTC_User_Observer))
        {
            [weakChatVC modifyAudioVideoType:weakChatVC.chatViewBuilder.openCameraButton];
            weakChatVC.isFinishLeave = NO;
        }

        [UIApplication sharedApplication].idleTimerDisabled = YES;
        [engine requestWhiteBoardExist];
    }
    else
        [self rongRTCEngine:engine onLeaveComplete:YES];
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onLeaveComplete:(BOOL)success
{
    DLog(@"LLH......rongRTCEngine:onLeaveComplete: %zd", success);

    __weak ChatViewController *weakChatVC = self.chatViewController;
    weakChatVC.isFinishLeave = YES;
    [weakChatVC.durationTimer invalidate];
    weakChatVC.talkTimeLabel.text = @"";
    weakChatVC.localView.hidden = NO;
    [weakChatVC.localView removeFromSuperview];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    RongRTCTalkAppDelegate *appDelegate = (RongRTCTalkAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.isForceLandscape = NO;
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];

    [weakChatVC.localVideoViewModel.cellVideoView removeFromSuperview];
    weakChatVC.localVideoViewModel = nil;
    
    [weakChatVC.remoteViewArray removeAllObjects];
    [weakChatVC.navigationController popViewControllerAnimated:YES];
    [weakChatVC resetAudioSpeakerButton];
}

- (void)rongRTCEngine:(RongRTCEngine *)engine OnNotifyUserVideoCreated:(NSString *)userId;
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    
    if ([weakChatVC.localVideoViewModel.userID isEqualToString:userId]) {
        weakChatVC.localVideoViewModel.cellVideoView = [weakChatVC.rongRTCEngine createRemoteVideoViewFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) forUser:userId withDisplayType:RongRTC_VideoViewDisplay_CompleteView];
        [weakChatVC.videoMainView addSubview:weakChatVC.localVideoViewModel.cellVideoView];
        weakChatVC.localVideoViewModel.isShowVideo = YES;
        [weakChatVC.localVideoViewModel.avatarView.indicatorView stopAnimating];
        
        if (weakChatVC.localVideoViewModel.avType == RongRTC_User_Audio_Video_None ||
            weakChatVC.localVideoViewModel.avType == RongRTC_User_Only_Audio) {
            [weakChatVC.localVideoViewModel.cellVideoView addSubview:weakChatVC.localVideoViewModel.avatarView];
            weakChatVC.localVideoViewModel.avatarView.frame = BigVideoFrame;
            weakChatVC.localVideoViewModel.avatarView.center = weakChatVC.localVideoViewModel.cellVideoView.center;
            weakChatVC.localVideoViewModel.isShowVideo = NO;
        }else
            [weakChatVC.localVideoViewModel.avatarView removeFromSuperview];
    }
    
    if (weakChatVC.isSwitchCamera) {
        NSString *bigStreamUseID = weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID;
        NSMutableArray *tinyStreamUseIDs = [NSMutableArray arrayWithArray: weakChatVC.userIDArray];

        if(![bigStreamUseID isEqualToString:kDeviceUUID]) {
            [tinyStreamUseIDs removeObject:bigStreamUseID];
        } else {
            bigStreamUseID = nil;
        }
        [weakChatVC.rongRTCEngine subscribeStreamForTiny:tinyStreamUseIDs forOrigin:bigStreamUseID];

    }else{
        NSString *bigStreamUseID = weakChatVC.localVideoViewModel.userID;

        NSMutableArray *tinyStreamUseIDs = [NSMutableArray arrayWithArray: weakChatVC.userIDArray];
        if(![bigStreamUseID isEqualToString:kDeviceUUID]) {
            [tinyStreamUseIDs removeObject:bigStreamUseID];
        } else {
            bigStreamUseID = nil;
        }

        [weakChatVC.rongRTCEngine subscribeStreamForTiny:tinyStreamUseIDs forOrigin:bigStreamUseID];
    }
    
    [weakChatVC.remoteViewArray enumerateObjectsUsingBlock:^(ChatCellVideoViewModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model.userID isEqualToString:userId]) {
            model.cellVideoView = [weakChatVC.rongRTCEngine createRemoteVideoViewFrame:CGRectMake(0, 0, 90, 120.0) forUser:userId withDisplayType:RongRTC_VideoViewDisplay_FullScreen];
            if (weakChatVC.isSwitchCamera && [weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID isEqualToString:userId]) {
                model.cellVideoView = [weakChatVC.rongRTCEngine changeRemoteVideoViewFrame:weakChatVC.videoMainView.frame withUserID:userId withDisplayType:RongRTC_VideoViewDisplay_CompleteView];
                model.avatarView.frame = BigVideoFrame;
            }else
                model.avatarView.frame = SmallVideoFrame;

            model.isShowVideo = YES;
            [model.avatarView.indicatorView stopAnimating];
            
            if (model.avType == RongRTC_User_Audio_Video_None || model.avType == RongRTC_User_Only_Audio) {
                [model.cellVideoView addSubview:model.avatarView];
                model.avatarView.center = model.cellVideoView.center;
                model.isShowVideo = NO;
            }else
                [model.avatarView removeFromSuperview];
            [weakChatVC.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
        }
    }];
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onUserJoined:(NSString *)userId userName:(NSString *)userName userType:(RongRTCUserType)type audioVideoType:(RongRTCAudioVideoType)avType screenSharingStatus:(RongRTCScreenSharingState)screenSharingStatus
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    if (type == RongRTC_User_Observer)
    {
        UIView *videoView = [[UIView alloc] initWithFrame:SmallVideoFrame];
        ChatCellVideoViewModel *chatCellVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:videoView];
        chatCellVideoViewModel.userID = userId;
        chatCellVideoViewModel.userName = userName;
        chatCellVideoViewModel.avType = avType;
        chatCellVideoViewModel.screenSharingStatus = screenSharingStatus ;
        chatCellVideoViewModel.everOnLocalView = 0;
        
        [weakChatVC.observerArray addObject:chatCellVideoViewModel];
        
         return;
    }
    
    self.chatViewController.isNotLeaveMeAlone = YES;
    [weakChatVC hideAlertLabel:YES];
 
    // Update talk time
    if (weakChatVC.duration == 0 && !weakChatVC.durationTimer)
    {
        weakChatVC.talkTimeLabel.text = @"00:00";
        weakChatVC.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:weakChatVC selector:@selector(updateTalkTimeLabel) userInfo:nil repeats:YES];
    }
    
    if (weakChatVC.observerIndex == RongRTC_User_Observer && (!weakChatVC.localVideoViewModel || [weakChatVC.localVideoViewModel.userID isEqualToString:@""]))
    {
        UIView *videoView = [[UIView alloc] initWithFrame:weakChatVC.videoMainView.bounds];
        weakChatVC.localVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:videoView];
        [weakChatVC.videoMainView addSubview:weakChatVC.localVideoViewModel.cellVideoView];

        weakChatVC.localVideoViewModel.userID = userId;
        weakChatVC.localVideoViewModel.avType = avType;
        weakChatVC.localVideoViewModel.userName = userName;
        weakChatVC.localVideoViewModel.screenSharingStatus = screenSharingStatus ;
        weakChatVC.localVideoViewModel.everOnLocalView = 0;

        weakChatVC.localVideoViewModel.avatarView.frame = BigVideoFrame;
        weakChatVC.localVideoViewModel.avatarView.center = weakChatVC.localVideoViewModel.cellVideoView.center;
        weakChatVC.localVideoViewModel.avatarView.model = [[ChatAvatarModel alloc] initWithShowVoice:NO showIndicator:YES userName:userName userID:userId];
        [weakChatVC.localVideoViewModel.cellVideoView addSubview:weakChatVC.localVideoViewModel.avatarView];

        if (avType == RongRTC_User_Only_Audio || avType == RongRTC_User_Audio_Video_None) {
            [weakChatVC.localVideoViewModel.avatarView.indicatorView stopAnimating];
        }
        
        if (weakChatVC.localVideoViewModel.screenSharingStatus == 1 && weakChatVC.localVideoViewModel.everOnLocalView == 0){
            [weakChatVC.messageStatusBar showMessageBarAndHideAuto: NSLocalizedString(@"chat_Suggested_horizontal_screen_viewing", nil)];
            weakChatVC.localVideoViewModel.everOnLocalView = 1;
        }
    }
    else
    {
        [weakChatVC.userIDArray enumerateObjectsUsingBlock:^(NSString *userID, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([userID isEqualToString:userId]) {
                [weakChatVC.userIDArray removeObject:userID];
            }
        }];
        
        [weakChatVC.userIDArray addObject:userId];
        
//        UIView *videoView = [self.chatViewController.rongRTCEngine createRemoteVideoViewFrame:CGRectMake(0, 0, 90, 120) forUser:userId withDisplayType:RongRTC_VideoViewDisplay_FullScreen];
        UIView *videoView = [[UIView alloc] initWithFrame:SmallVideoFrame];
        ChatCellVideoViewModel *chatCellVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:videoView];
        chatCellVideoViewModel.userID = userId;
        chatCellVideoViewModel.userName = userName;
        chatCellVideoViewModel.avType = avType;
        chatCellVideoViewModel.screenSharingStatus = screenSharingStatus ;
        chatCellVideoViewModel.everOnLocalView = 0;
        chatCellVideoViewModel.isShowVideo = NO;
        DLog(@"User named %@ joined channel", userName);
        [chatCellVideoViewModel.cellVideoView addSubview:chatCellVideoViewModel.avatarView];
        chatCellVideoViewModel.avatarView.frame = SmallVideoFrame;
        chatCellVideoViewModel.avatarView.model = [[ChatAvatarModel alloc] initWithShowVoice:NO showIndicator:YES userName:userName userID:userId];
        if (avType == RongRTC_User_Only_Audio || avType == RongRTC_User_Audio_Video_None) {
            [chatCellVideoViewModel.avatarView.indicatorView stopAnimating];
        }
        [weakChatVC.remoteViewArray addObject:chatCellVideoViewModel];
        [weakChatVC.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakChatVC.userIDArray.count-1 inSection:0]]];
    }
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onUser:(NSString *)userId audioVideoType:(RongRTCAudioVideoType)avType
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    if (weakChatVC.observerIndex == RongRTC_User_Observer && [weakChatVC.localVideoViewModel.userID isEqualToString:userId])
    {
        weakChatVC.localVideoViewModel.avType = avType;
        RongRTCVideoViewDisplayType type;
        if (weakChatVC.localVideoViewModel.cellVideoView.frame.size.width == ScreenWidth && weakChatVC.localVideoViewModel.cellVideoView.frame.size.height == ScreenHeight)
            type = RongRTC_VideoViewDisplay_CompleteView;
        else
            type = RongRTC_VideoViewDisplay_FullScreen;
        
        UIView *videoView = [weakChatVC.rongRTCEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, weakChatVC.localVideoViewModel.cellVideoView.frame.size.width, weakChatVC.localVideoViewModel.cellVideoView.frame.size.height) withUserID:userId withDisplayType:type];
        weakChatVC.localVideoViewModel.cellVideoView = videoView;
        
        if (avType == RongRTC_User_Only_Audio || avType == RongRTC_User_Audio_Video_None)
        {
            if (videoView.frame.size.width == ScreenWidth && videoView.frame.size.height == ScreenHeight)
                weakChatVC.localVideoViewModel.avatarView.frame = BigVideoFrame;
            else
                weakChatVC.localVideoViewModel.avatarView.frame = BigVideoFrame;
 
            [videoView addSubview:weakChatVC.localVideoViewModel.avatarView];
            weakChatVC.localVideoViewModel.avatarView.center = weakChatVC.localVideoViewModel.cellVideoView.center;
            [weakChatVC.localVideoViewModel.avatarView.indicatorView stopAnimating];
        }
        else
        {
            if (weakChatVC.localVideoViewModel.avatarView)
                [weakChatVC.localVideoViewModel.avatarView removeFromSuperview];
        }
        return;
    }
    
    for (NSInteger i = 0; i < [weakChatVC.remoteViewArray count]; i++)
    {
        ChatCellVideoViewModel *tempModel = (ChatCellVideoViewModel *)weakChatVC.remoteViewArray[i];
        if ([tempModel.userID isEqualToString:userId])
        {
            RongRTCVideoViewDisplayType type;
            if (weakChatVC.isSwitchCamera && [weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID isEqualToString:userId]) {
                    type = RongRTC_VideoViewDisplay_CompleteView;
            }else{
                if (tempModel.cellVideoView.frame.size.width == ScreenWidth && tempModel.cellVideoView.frame.size.height == ScreenHeight)
                    type = RongRTC_VideoViewDisplay_CompleteView;
                else
                    type = RongRTC_VideoViewDisplay_FullScreen;
            }

            tempModel.cellVideoView = [weakChatVC.rongRTCEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, tempModel.cellVideoView.frame.size.width, tempModel.cellVideoView.frame.size.height) withUserID:userId withDisplayType:type];
            
            if (avType == RongRTC_User_Only_Audio || avType == RongRTC_User_Audio_Video_None)
            {
                    if (weakChatVC.isSwitchCamera) {
                        if ([weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID isEqualToString:userId]) {
                            tempModel.avatarView.frame = BigVideoFrame;
                        }else
                            tempModel.avatarView.frame = SmallVideoFrame;
                    }else{
                        if (tempModel.cellVideoView.frame.size.width == ScreenWidth && tempModel.cellVideoView.frame.size.height == ScreenHeight)
                            tempModel.avatarView.frame = SmallVideoFrame;
                        else
                            tempModel.avatarView.frame = SmallVideoFrame;
                    }
 
                tempModel.avatarView.model = [[ChatAvatarModel alloc] initWithShowVoice:YES showIndicator:NO userName:tempModel.userName userID:tempModel.userID];
                [tempModel.cellVideoView.superview addSubview:tempModel.avatarView];
                tempModel.avatarView.center = tempModel.cellVideoView.center;
                [tempModel.avatarView.indicatorView stopAnimating];
            }
            else
            {
                if (tempModel.avatarView)
                    [tempModel.avatarView removeFromSuperview];
            }
            
            tempModel.avType = avType;
        }
    }
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onUserLeft:(NSString *)userId
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    dispatch_async(dispatch_get_main_queue(), ^{
        DLog(@"userLeft begin:%@",userId);
    if ([weakChatVC.userIDArray indexOfObject:userId] != NSNotFound)
    {
        NSInteger index = [weakChatVC.userIDArray indexOfObject:userId];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
//        [weakChatVC resumeLocalView:indexPath];
        if (weakChatVC.isSwitchCamera && [weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID isEqualToString:userId]) {
            [weakChatVC.chatCollectionViewDataSourceDelegateImpl collectionView:weakChatVC.collectionView didSelectItemAtIndexPath:indexPath];
        }
        
        [weakChatVC.userIDArray removeObjectAtIndex:index];
        
        if (weakChatVC.remoteViewArray.count > indexPath.row) {
            [weakChatVC.remoteViewArray removeObjectAtIndex:indexPath.row];
        }
        
        [weakChatVC.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        DLog(@"userLeft end:%@",userId);
        
        if (weakChatVC.orignalRow > 0)
            weakChatVC.orignalRow--;
        
        if ([weakChatVC.userIDArray count] == 0)
        {
            if (weakChatVC.durationTimer)
            {
                [weakChatVC.durationTimer invalidate];
                weakChatVC.duration = 0;
                weakChatVC.durationTimer = nil;
            }
 
            weakChatVC.dataTrafficLabel.hidden = YES;
            weakChatVC.talkTimeLabel.text = @"00:00";
            if (![weakChatVC.localVideoViewModel.userID isEqual:userId] && ![weakChatVC.localVideoViewModel.userID isEqualToString:kDeviceUUID]) {
                [weakChatVC hideAlertLabel:YES];
            }else{
                [weakChatVC hideAlertLabel:NO];
            }
        }
    }
    
    if (weakChatVC.observerIndex == RongRTC_User_Observer)
    {
        if ([weakChatVC.localVideoViewModel.userID isEqualToString:userId])
        {
            if ([weakChatVC.remoteViewArray count] > 0)
            {
                if (weakChatVC.isSwitchCamera ) {
                    NSInteger index = [weakChatVC.userIDArray indexOfObject:weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    [weakChatVC.chatCollectionViewDataSourceDelegateImpl collectionView:weakChatVC.collectionView didSelectItemAtIndexPath:indexPath];
                }
                ChatCellVideoViewModel *model = (ChatCellVideoViewModel *)weakChatVC.remoteViewArray[0];
                
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRateRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameWidthRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameHeightRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRate"];
                [weakChatVC.localVideoViewModel.cellVideoView removeFromSuperview];
                [weakChatVC.localVideoViewModel.avatarView removeFromSuperview];
                 weakChatVC.localVideoViewModel = model;
                
                [weakChatVC.remoteViewArray removeObjectAtIndex:0];
                if (weakChatVC.userIDArray.count > 0) {
                    [weakChatVC.userIDArray removeObjectAtIndex:0];
                }
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [weakChatVC.collectionView deleteItemsAtIndexPaths:@[indexPath]];

                weakChatVC.localVideoViewModel.cellVideoView = [weakChatVC.rongRTCEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) withUserID:weakChatVC.localVideoViewModel.userID withDisplayType:RongRTC_VideoViewDisplay_CompleteView];
                
                [weakChatVC.videoMainView addSubview:weakChatVC.localVideoViewModel.cellVideoView];
                
                if (weakChatVC.localVideoViewModel.avType == RongRTC_User_Only_Audio || weakChatVC.localVideoViewModel.avType == RongRTC_User_Audio_Video_None) {
                    weakChatVC.localVideoViewModel.avatarView.frame = BigVideoFrame;
                    [weakChatVC.localVideoViewModel.cellVideoView.superview addSubview:weakChatVC.localVideoViewModel.avatarView];
                    weakChatVC.localVideoViewModel.avatarView.center = CGPointMake(self.chatViewController.videoMainView.frame.size.width / 2, self.chatViewController.videoMainView.frame.size.height / 2);
                }
            }
            else
            {
                [weakChatVC.localVideoViewModel.cellVideoView removeFromSuperview];
                weakChatVC.localVideoViewModel.cellVideoView = nil;
                [weakChatVC.localVideoViewModel.avatarView removeFromSuperview];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRateRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameWidthRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameHeightRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRate"];

                [weakChatVC.localView removeFromSuperview];
                [weakChatVC.localVideoViewModel.cellVideoView removeFromSuperview];
                weakChatVC.localVideoViewModel = nil;
                
                if (weakChatVC.durationTimer)
                {
                    [weakChatVC.durationTimer invalidate];
                    weakChatVC.duration = 0;
                    weakChatVC.durationTimer = nil;
                }
                [weakChatVC hideAlertLabel:NO];
                weakChatVC.talkTimeLabel.text = @"00:00";
            }
        }
    }
        });
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onWhiteBoardURL:(NSString *)url
{
    if ([url isEqualToString:@""] || url == NULL) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.chatViewController.isOpenWhiteBoard) {
            [self.chatViewController showWhiteBoardWithURL:url];
        }
    });
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onWhiteBoardExist:(BOOL)isExist
{
    dispatch_async(dispatch_get_main_queue(), ^{
    self.chatViewController.isWhiteBoardExist = isExist;
    });
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onNotifyWhiteBoardCreateBy:(NSString *)userId
{
    //其他人创建白板的回调
    dispatch_async(dispatch_get_main_queue(), ^{
    self.chatViewController.isWhiteBoardExist = YES;
    });
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onControlAudioVideoDevice:(NSInteger)code
{
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onNotifyControlAudioVideoDevice:(RongRTC_Device_Type)type withUserID:(NSString *)userId open:(BOOL)isOpen
{
    //刷新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUser:userId deviceType:type open:isOpen];
    });
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onRemoteVideoView:(UIView *)videoView vidoeSize:(CGSize)size remoteUserID:(NSString*)userID
{
    dispatch_async(dispatch_get_main_queue(), ^{

        for (NSInteger i = 0; i < [self.chatViewController.remoteViewArray count]; i++)
        {
            ChatCellVideoViewModel *tempView = (ChatCellVideoViewModel *)self.chatViewController.remoteViewArray[i];
            if ([tempView.userID isEqualToString:userID])
                tempView.originalSize = size;
        }
        
        if ([self.chatViewController.localVideoViewModel.userID isEqualToString:userID])
            self.chatViewController.localVideoViewModel.originalSize = size;
    });
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onOutputAudioPortSpeaker:(BOOL)enable
{
    [self.chatViewController selectSpeakerButtons:enable];
    [self.chatViewController.rongRTCEngine switchSpeaker:enable];
    [self.chatViewController enableSpeakerButton:enable];
}

- (void)rongRTCEngineOnAudioDeviceReady:(RongRTCEngine *)engine
{
    [self.chatViewController.speakerControlButton setEnabled:YES];
    NSString *deviceModel = [UIDevice currentDevice].model;
    if ([deviceModel isEqualToString:@"iPod touch"] || [deviceModel containsString:@"iPad"])
    {
        [self.chatViewController.speakerControlButton setEnabled:NO];
        [self.chatViewController selectSpeakerButtons:NO];
        [self.chatViewController.rongRTCEngine switchSpeaker:NO];
    }
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onNetworkSentLost:(NSInteger)lost
{
    DLog(@"LLH...... onNetworkSentLost: %zd", lost);
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onNotifyScreenSharing:(NSString *)userId open:(BOOL)isOpen
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    for (ChatCellVideoViewModel *model in weakChatVC.remoteViewArray) {
        if ([model.userID isEqualToString:userId]) {
            model.screenSharingStatus = isOpen ? 1:0;
            if (weakChatVC.isSwitchCamera && [weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID isEqualToString:userId]) {
                if (isOpen) {
                    [weakChatVC.messageStatusBar showMessageBarAndHideAuto: NSLocalizedString(@"chat_Suggested_horizontal_screen_viewing", nil)];
                    model.everOnLocalView = 1;
                }else{
                    model.everOnLocalView = 0;
                }
            }else{
                model.everOnLocalView = 0;
            }
        }
    }
}

#pragma mark - Meeting
- (void)rongRTCEngine:(RongRTCEngine *)engine onNotifyDegradeNormalUserToObserver:(NSString *)userId
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    DLog(@"userId:%@,localUID:%@",userId,self.chatViewController.localVideoViewModel.userID);
    dispatch_async(dispatch_get_main_queue(), ^{
    if ([kDeviceUUID isEqualToString: userId] && weakChatVC.observerIndex != RongRTC_User_Observer) {

        if (weakChatVC.alertController) {
            [weakChatVC.alertController dismissViewControllerAnimated:YES completion:nil];
        }
        
        if (weakChatVC.isCloseCamera) {
            [weakChatVC didClickVideoMuteButton:weakChatVC.chatViewBuilder.openCameraButton];
        }
        if (weakChatVC.isNotMute) {
            [weakChatVC didClickAudioMuteButton:weakChatVC.chatViewBuilder.microphoneOnOffButton];
        }
        
        [weakChatVC.rongRTCEngine answerDegradeNormalUserToObserver:userId status:YES];
        
        //observerArray 添加标记
        
        [weakChatVC.remoteViewArray enumerateObjectsUsingBlock:^(ChatCellVideoViewModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.userID isEqualToString:userId]) {
                UIView *videoView = [[UIView alloc] initWithFrame:SmallVideoFrame];
                ChatCellVideoViewModel *chatCellVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:videoView];
                chatCellVideoViewModel.userID = userId;
                chatCellVideoViewModel.userName = obj.userName;
                chatCellVideoViewModel.avType = RongRTC_User_Audio_Video;
                chatCellVideoViewModel.screenSharingStatus = 0 ;
                chatCellVideoViewModel.everOnLocalView = 0;
                
                
                [weakChatVC.observerArray addObject:chatCellVideoViewModel];
            }
        }];
        
        if (weakChatVC.isSwitchCamera) {
            ChatCellVideoViewModel *sourceMode = weakChatVC.remoteViewArray[weakChatVC.orignalRow];
            ChatCell *cell = (ChatCell *)[weakChatVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:weakChatVC.orignalRow inSection:0]];
            ChatCellVideoViewModel *tempMode = weakChatVC.localVideoViewModel;
            
            tempMode.cellVideoView = [weakChatVC.rongRTCEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, 90, 120) withUserID:weakChatVC.localVideoViewModel.userID withDisplayType:RongRTC_VideoViewDisplay_FullScreen];
            weakChatVC.remoteViewArray[weakChatVC.orignalRow] = tempMode;
         
            
            weakChatVC.localVideoViewModel = sourceMode;
            weakChatVC.observerIndex = RongRTC_User_Observer;
            [self.chatViewController turnMenuButtonToObserver];
            [weakChatVC.remoteViewArray enumerateObjectsUsingBlock:^(ChatCellVideoViewModel *model, NSUInteger i, BOOL * _Nonnull stop) {
                if ([model.userID isEqualToString:userId]) {
                    [model removeObserver:model forKeyPath:@"frameRateRecv"];
                    [model removeObserver:model forKeyPath:@"frameWidthRecv"];
                    [model removeObserver:model forKeyPath:@"frameHeightRecv"];
                    [model removeObserver:model forKeyPath:@"frameRate"];

                    [model.avatarView removeFromSuperview];
                    [weakChatVC.remoteViewArray removeObjectAtIndex:i];
                    [weakChatVC.userIDArray removeObjectAtIndex:i];
                    [weakChatVC.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
                }
            }];
        }
        else
        {
            if ([weakChatVC.remoteViewArray count] > 0)
            {
                ChatCellVideoViewModel *model = (ChatCellVideoViewModel *)weakChatVC.remoteViewArray[0];

                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRateRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameWidthRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameHeightRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRate"];
                [weakChatVC.localVideoViewModel.cellVideoView removeFromSuperview];
                [weakChatVC.localVideoViewModel.avatarView removeFromSuperview];
                self.degradeCellVideoViewModel = model;
                weakChatVC.localVideoViewModel = model;
                
                [weakChatVC.userIDArray removeObjectAtIndex:0];
                [weakChatVC.remoteViewArray removeObjectAtIndex:0];
                [weakChatVC.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
                
                UIView *videoView = [weakChatVC.rongRTCEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) withUserID:weakChatVC.localVideoViewModel.userID withDisplayType:RongRTC_VideoViewDisplay_CompleteView];
                weakChatVC.localVideoViewModel.cellVideoView = videoView;
                [weakChatVC.videoMainView addSubview:weakChatVC.localVideoViewModel.cellVideoView];

                NSString *bigStreamUseID = weakChatVC.localVideoViewModel.userID;
                NSMutableArray *tinyStreamUseIDs = [NSMutableArray arrayWithArray: weakChatVC.userIDArray];
                if(![bigStreamUseID isEqualToString:kDeviceUUID]) {
                    [tinyStreamUseIDs removeObject:bigStreamUseID];
                } else {
                    bigStreamUseID = nil;
                }
                [weakChatVC.rongRTCEngine subscribeStreamForTiny:tinyStreamUseIDs forOrigin:bigStreamUseID];
                
                if (weakChatVC.localVideoViewModel.avType == RongRTC_User_Only_Audio || weakChatVC.localVideoViewModel.avType == RongRTC_User_Audio_Video_None) {
                    
                    weakChatVC.localVideoViewModel.avatarView.frame = BigVideoFrame;
                    [weakChatVC.localVideoViewModel.cellVideoView addSubview:weakChatVC.localVideoViewModel.avatarView];
                    weakChatVC.localVideoViewModel.avatarView.center = CGPointMake(self.chatViewController.videoMainView.frame.size.width / 2, self.chatViewController.videoMainView.frame.size.height / 2);
                }
                
                if (weakChatVC.isOpenWhiteBoard) {
                    [weakChatVC.videoMainView bringSubviewToFront:weakChatVC.whiteBoardWebView];
                }
                [weakChatVC.videoMainView bringSubviewToFront:weakChatVC.localVideoViewModel.cellVideoView];
 
            }
            weakChatVC.observerIndex = RongRTC_User_Observer;
            [self.chatViewController turnMenuButtonToObserver];
        }
    }
    else
    {
        if ([weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID isEqualToString:userId] && weakChatVC.isCloseCamera) {
            NSInteger index = [weakChatVC.userIDArray indexOfObject:weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID];
            if (index != NSNotFound){
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                if (weakChatVC.isSwitchCamera)
                    [weakChatVC.chatCollectionViewDataSourceDelegateImpl collectionView:weakChatVC.collectionView didSelectItemAtIndexPath:indexPath];
            }
            
            weakChatVC.localView = [weakChatVC.rongRTCEngine createLocalVideoViewFrame:weakChatVC.videoMainView.frame withDisplayType:RongRTC_VideoViewDisplay_FullScreen];
            [weakChatVC.videoMainView addSubview:weakChatVC.localView];
        }
        
        [weakChatVC.remoteViewArray enumerateObjectsUsingBlock:^(ChatCellVideoViewModel *model, NSUInteger i, BOOL * _Nonnull stop) {
            if ([model.userID isEqualToString:userId]) {
                [model removeObserver:model forKeyPath:@"frameRateRecv"];
                [model removeObserver:model forKeyPath:@"frameWidthRecv"];
                [model removeObserver:model forKeyPath:@"frameHeightRecv"];
                [model removeObserver:model forKeyPath:@"frameRate"];

                [weakChatVC.remoteViewArray removeObjectAtIndex:i];
                [weakChatVC.userIDArray removeObjectAtIndex:i];
                [weakChatVC.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
            }
        }];
        
        if ([weakChatVC.localVideoViewModel.userID isEqualToString:userId]) {
            if ([weakChatVC.remoteViewArray count] > 0)
            {
                ChatCellVideoViewModel *model = (ChatCellVideoViewModel *)weakChatVC.remoteViewArray[0];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRateRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameWidthRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameHeightRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRate"];

                //                    weakChatVC.localVideoViewModel = nil;
                //                    ChatCellVideoViewModel *tempModel = weakChatVC.localVideoViewModel;
                [weakChatVC.localVideoViewModel.avatarView removeFromSuperview];
                self.degradeCellVideoViewModel = model;
                weakChatVC.localVideoViewModel = model;
                
                [weakChatVC.userIDArray removeObjectAtIndex:0];
                [weakChatVC.remoteViewArray removeObjectAtIndex:0];
                [weakChatVC.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
                
                weakChatVC.localView = [weakChatVC.rongRTCEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) withUserID:weakChatVC.localVideoViewModel.userID withDisplayType:RongRTC_VideoViewDisplay_CompleteView];
                
                [weakChatVC.videoMainView addSubview:weakChatVC.localView];
                
                
                if (weakChatVC.localVideoViewModel.avType == RongRTC_User_Only_Audio || weakChatVC.localVideoViewModel.avType == RongRTC_User_Audio_Video_None) {
                
                    weakChatVC.localVideoViewModel.avatarView.frame = BigVideoFrame;
                    if (!weakChatVC.isOpenWhiteBoard) {
                        [weakChatVC.localView.superview addSubview:weakChatVC.localVideoViewModel.avatarView];
                    }
                    weakChatVC.localVideoViewModel.avatarView.center = CGPointMake(self.chatViewController.videoMainView.frame.size.width / 2, self.chatViewController.videoMainView.frame.size.height / 2);
                }
                
                if (weakChatVC.isOpenWhiteBoard) {
                    [weakChatVC.videoMainView bringSubviewToFront:weakChatVC.whiteBoardWebView];
                }else{
                    [weakChatVC.videoMainView bringSubviewToFront:weakChatVC.localView];
                }
            }
        }
    }
    });
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onNotifyUpgradeObserverToNormalUser:(NSString *)userId
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    dispatch_async(dispatch_get_main_queue(), ^{

    if ([userId isEqualToString:kDeviceUUID]) {
        if (weakChatVC.observerIndex != RongRTC_User_Observer) {
            return ;
        }
        
        __weak ChatViewController *weakChatVC = self.chatViewController;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([weakChatVC.alertTypeArray containsObject:[NSNumber numberWithInteger:4]]) {
                return ;
            }
            [weakChatVC.alertTypeArray addObject:[NSNumber numberWithInteger:4]];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                weakChatVC.alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"chat_invite_upgrade", nil) preferredStyle:UIAlertControllerStyleAlert];
                [weakChatVC.alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    [weakChatVC.alertTypeArray removeObject:[NSNumber numberWithInteger:4]];
                    dispatch_semaphore_signal(sem);
                    [weakChatVC.localView removeFromSuperview];
                    weakChatVC.localView = nil;
                    if (weakChatVC.deviceOrientaionBefore == UIDeviceOrientationPortrait) {
                        weakChatVC.localView = [weakChatVC.rongRTCEngine createLocalVideoViewFrame:CGRectMake(0, 0, 90, 120) withDisplayType:RongRTC_VideoViewDisplay_FullScreen];
                    }else{
                        weakChatVC.localView = [weakChatVC.rongRTCEngine createLocalVideoViewFrame:CGRectMake(0, 0, 120, 120) withDisplayType:RongRTC_VideoViewDisplay_FullScreen];
                        if (weakChatVC.observerIndex == RongRTC_User_Observer) {
                            weakChatVC.localView.transform = CGAffineTransformIdentity;
                            if (weakChatVC.deviceOrientaionBefore == UIDeviceOrientationLandscapeLeft) {
                                weakChatVC.localView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                            }else{
                                weakChatVC.localView.transform = CGAffineTransformMakeRotation(M_PI_2);
                            }
                        }
                    }
                    
                    weakChatVC.observerIndex = RongRTC_User_Normal;

                    
                    if (weakChatVC.isSwitchCamera && weakChatVC.remoteViewArray.count > weakChatVC.orignalRow) {
                        ChatCellVideoViewModel *sourceMode = weakChatVC.remoteViewArray[weakChatVC.orignalRow];
                         ChatCell *cell = (ChatCell *)[weakChatVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:weakChatVC.orignalRow inSection:0]];
                        [weakChatVC.localVideoViewModel.cellVideoView removeFromSuperview];
                        ChatCellVideoViewModel *tempMode = weakChatVC.localVideoViewModel;
                        
                        tempMode.cellVideoView = [weakChatVC.rongRTCEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, 90, 120) withUserID:weakChatVC.localVideoViewModel.userID withDisplayType:RongRTC_VideoViewDisplay_FullScreen];
                        weakChatVC.remoteViewArray[weakChatVC.orignalRow] = tempMode;
                        if ([weakChatVC.userIDArray containsObject:tempMode.userID]) {
                            [weakChatVC.userIDArray removeObject:tempMode.userID ];
                        }
                        [weakChatVC.userIDArray addObject:tempMode.userID];
                        [cell.videoView addSubview:tempMode.cellVideoView];
                        if (tempMode.avType == RongRTC_User_Only_Audio || tempMode.avType == RongRTC_User_Audio_Video_None)
                        {
                            tempMode.avatarView.frame = SmallVideoFrame;
                            [cell.videoView addSubview:tempMode.avatarView];
                            tempMode.avatarView.center = tempMode.cellVideoView.center;
                        }
                        weakChatVC.localVideoViewModel = sourceMode;
                    }
 

                    if (self.chatViewController.localVideoViewModel && ![self.chatViewController.localVideoViewModel.userID isEqualToString:@""]) {

                        UIView *videoView = [weakChatVC.rongRTCEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) withUserID:weakChatVC.localVideoViewModel.userID withDisplayType:RongRTC_VideoViewDisplay_CompleteView];
                        
                        ChatCellVideoViewModel *chatCellVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:videoView];
                        chatCellVideoViewModel.avatarView = weakChatVC.localVideoViewModel.avatarView;
                        if ([weakChatVC.userIDArray containsObject:self.chatViewController.localVideoViewModel.userID]) {
                            [weakChatVC.userIDArray removeObject:self.chatViewController.localVideoViewModel.userID ];
                        }
                        [weakChatVC.userIDArray addObject:self.chatViewController.localVideoViewModel.userID];
                        if (self.degradeCellVideoViewModel) {
                            chatCellVideoViewModel.avType = self.degradeCellVideoViewModel.avType;
                            chatCellVideoViewModel.originalSize = self.degradeCellVideoViewModel.originalSize;
                        }else{
                            chatCellVideoViewModel.avType = self.chatViewController.localVideoViewModel.avType;
                        }
                        
                        if (chatCellVideoViewModel.avType == RongRTC_User_Audio_Video_None || chatCellVideoViewModel.avType == RongRTC_User_Only_Audio) {
                            
                            chatCellVideoViewModel.avatarView.frame = BigVideoFrame;
 
                            [weakChatVC.localVideoViewModel.cellVideoView addSubview:chatCellVideoViewModel.avatarView];
                            chatCellVideoViewModel.avatarView.center = CGPointMake(self.chatViewController.videoMainView.frame.size.width / 2, self.chatViewController.videoMainView.frame.size.height / 2);
                        }
//                        [chatCellVideoViewModel.cellVideoView addSubview:weakChatVC.localView];
                        chatCellVideoViewModel.userID = weakChatVC.localVideoViewModel.userID;
//                        chatCellVideoViewModel.cellVideoView = weakChatVC.localVideoViewModel.cellVideoView;
//                        [weakChatVC.videoMainView addSubview:chatCellVideoViewModel.cellVideoView];
                        [weakChatVC.remoteViewArray addObject:chatCellVideoViewModel];
                        if (weakChatVC.remoteViewArray.count == weakChatVC.userIDArray.count) {
                            [weakChatVC.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakChatVC.userIDArray.count-1 inSection:0]]];
                        }
                    }
                    [weakChatVC.localVideoViewModel.avatarView removeFromSuperview];
                    //weakChatVC.localview 旋转后
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRateRecv"];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameWidthRecv"];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameHeightRecv"];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRate"];

                    weakChatVC.localVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:weakChatVC.localView];
                    weakChatVC.localVideoViewModel.userID = kDeviceUUID;
                    weakChatVC.localVideoViewModel.avType = RongRTC_User_Audio_Video;
                    weakChatVC.localVideoViewModel.userName = weakChatVC.userName;
                    weakChatVC.localVideoViewModel.screenSharingStatus = 0;
                    weakChatVC.localVideoViewModel.everOnLocalView = 0;
                    weakChatVC.localVideoViewModel.avatarView.model = [[ChatAvatarModel alloc] initWithShowVoice:NO showIndicator:YES userName:weakChatVC.userName userID:kDeviceUUID];

                    
                    if (weakChatVC.userIDArray.count >= 1) {
                        ChatCell *cell = (ChatCell *)[weakChatVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:weakChatVC.userIDArray.count-1 inSection:0]];
                        ChatCellVideoViewModel *tmpModel = weakChatVC.remoteViewArray[weakChatVC.userIDArray.count-1];
                        [weakChatVC.videoMainView addSubview:tmpModel.cellVideoView];
                        
                        weakChatVC.isSwitchCamera = YES;
                        weakChatVC.orignalRow = weakChatVC.userIDArray.count-1;
                        weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel = tmpModel;
                        weakChatVC.selectedChatCell = cell;
                        weakChatVC.localVideoViewModel.avType = RongRTC_User_Audio_Video;
 
 
                        NSString *bigStreamUseID = tmpModel.userID;

                        NSMutableArray *tinyStreamUseIDs = [NSMutableArray arrayWithArray: weakChatVC.userIDArray];
                        if(![bigStreamUseID isEqualToString:kDeviceUUID]) {
                            [tinyStreamUseIDs removeObject:bigStreamUseID];
                        } else {
                            bigStreamUseID = nil;
                        }
                        [weakChatVC.rongRTCEngine subscribeStreamForTiny:tinyStreamUseIDs forOrigin:bigStreamUseID];
                            
                        if (weakChatVC.isOpenWhiteBoard) {
                            [weakChatVC.localView removeFromSuperview];
                            weakChatVC.localVideoViewModel.cellVideoView = [weakChatVC.rongRTCEngine createLocalVideoViewFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) withDisplayType:RongRTC_VideoViewDisplay_CompleteView ];
                            tmpModel.cellVideoView = [weakChatVC.rongRTCEngine changeRemoteVideoViewFrame: CGRectMake(0, 0, 90, 120) withUserID:tmpModel.userID withDisplayType:RongRTC_VideoViewDisplay_FullScreen];
                            [cell.videoView addSubview:tmpModel.cellVideoView];
                            [cell.videoView bringSubviewToFront:tmpModel.cellVideoView];
                            
                            if (tmpModel.avType == RongRTC_User_Only_Audio || tmpModel.avType == RongRTC_User_Audio_Video_None)
                            {
                                tmpModel.avatarView.frame = SmallVideoFrame;
 
                                [tmpModel.cellVideoView addSubview:tmpModel.avatarView];
                                tmpModel.avatarView.center = tmpModel.cellVideoView.center;
                            }
                            
                            weakChatVC.isSwitchCamera = NO;
                            [weakChatVC.videoMainView bringSubviewToFront:weakChatVC.whiteBoardWebView];
                        }else{
                            dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 2 *NSEC_PER_SEC);
                            dispatch_after(time
                                           , dispatch_get_main_queue(), ^{
                                               [cell.videoView addSubview:weakChatVC.localVideoViewModel.cellVideoView];
                                               if (tmpModel.avType == RongRTC_User_Only_Audio || tmpModel.avType == RongRTC_User_Audio_Video_None)
                                               {
                                                   tmpModel.avatarView.frame = BigVideoFrame;
                                                   
                                                   [tmpModel.cellVideoView addSubview:tmpModel.avatarView];
                                                   tmpModel.avatarView.center = tmpModel.cellVideoView.center;
                                               }
                                               
                                           });
                        }
                   }
                    
                    if (weakChatVC.isNotMute) {
                        [weakChatVC didClickAudioMuteButton:weakChatVC.chatViewBuilder.microphoneOnOffButton];
                    }

                    if (weakChatVC.isCloseCamera) {
                        [weakChatVC didClickVideoMuteButton:weakChatVC.chatViewBuilder.openCameraButton];
                    }
                    
                    if (weakChatVC.isBackCamera) {
                        [weakChatVC shouldChangeSwitchCameraButtonBG:weakChatVC.chatViewBuilder.switchCameraButton];
                    }
                    
                    [weakChatVC turnMenuButtonToNormal];
                    weakChatVC.observerIndex = RongRTC_User_Normal;

                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [weakChatVC.rongRTCEngine answerUpgradeObserverToNormalUser:userId status:YES];
                    });
                }]];
                [weakChatVC.alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_no", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    [weakChatVC.rongRTCEngine answerUpgradeObserverToNormalUser:userId status:NO];
                    [weakChatVC.alertTypeArray removeObject:[NSNumber numberWithInteger:4]];
                    dispatch_semaphore_signal(sem);
                }]];
                [weakChatVC presentViewController:weakChatVC.alertController animated:YES completion:^{}];
            });
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        });
    }else{
        [weakChatVC.observerArray enumerateObjectsUsingBlock:^(ChatCellVideoViewModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.userID isEqualToString:userId]) {
                [obj removeObserver:obj forKeyPath:@"frameRateRecv"];
                [obj removeObserver:obj forKeyPath:@"frameWidthRecv"];
                [obj removeObserver:obj forKeyPath:@"frameHeightRecv"];
                [obj removeObserver:obj forKeyPath:@"frameRate"];
                
                [weakChatVC.observerArray removeObject:obj];
                [self rongRTCEngine:engine onUserJoined:userId userName:obj.userName userType:RongRTC_User_Normal audioVideoType:RongRTC_User_Audio_Video screenSharingStatus:RongRTC_ScreenSharing_Off];
            }
        }];
    }
    });
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onNotifyNormalUserRequestHostAuthority:(NSString *)userId
{
    dispatch_async(dispatch_get_main_queue(), ^{
    if ([userId isEqualToString: kDeviceUUID]) {
        self.chatViewController.alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"chat_already_host", nil) preferredStyle:(UIAlertControllerStyleAlert)];
        
        [self.chatViewController.alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_confirm", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self.chatViewController presentViewController:self.chatViewController.alertController animated:YES completion:nil];
    }
    });
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onNotifyRemoveUser:(NSString *)userId
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([userId  isEqual: kDeviceUUID]) {
            
            if (self.chatViewController.alertController) {
                [self.chatViewController.alertController dismissViewControllerAnimated:YES completion:nil];
            }
            
            self.chatViewController.alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"chat_removed_by_host", nil) preferredStyle:UIAlertControllerStyleAlert];
            [self.chatViewController.alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.chatViewController didClickHungUpButton];
             }]];
            [self.chatViewController presentViewController:self.chatViewController.alertController animated:YES completion:^{}];
        }
    });
}

//所有与会人员收到的
- (void)rongRTCEngine:(RongRTCEngine *)engine onNotifyHostControlUserDevice:(NSString *)userId host:(NSString *)hostId deviceType:(RongRTC_Device_Type)dType open:(BOOL)isOpen
{
    DLog(@"userid:%@",userId);
    dispatch_async(dispatch_get_main_queue(), ^{

    if ([userId isEqualToString: kDeviceUUID]) {
        
        ChatCellVideoViewModel *newModel = [[ChatCellVideoViewModel alloc] init];
        newModel.avType = self.chatViewController.localVideoViewModel.avType;
        [self adaptUserType:dType withDataModel:newModel open:isOpen];
        if (newModel.avType == self.chatViewController.localVideoViewModel.avType) {
            return ;
        }
        
        if (isOpen) {
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_yes", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                [self.chatViewController.alertTypeArray removeObject:[NSNumber numberWithInteger:dType]];
                dispatch_semaphore_signal(sem);

                if (self.chatViewController.observerIndex != RongRTC_User_Observer) {
                    [self updateUser:userId deviceType:dType open:isOpen];
                    [engine answerHostControlUserDevice:userId withDeviceType:dType open:isOpen status:YES];
                }

             }];
            UIAlertAction *cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_no", nil) style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
                [self.chatViewController.alertTypeArray removeObject:[NSNumber numberWithInteger:dType]];
                dispatch_semaphore_signal(sem);

                if (self.chatViewController.observerIndex != RongRTC_User_Observer) {
                    [engine answerHostControlUserDevice:userId withDeviceType:dType open:isOpen status:NO];
                }
            }];
 
            __weak ChatViewController *weakChatVC = self.chatViewController;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if ([weakChatVC.alertTypeArray containsObject:[NSNumber numberWithInteger:dType]]) {
                    return ;
                }
                [weakChatVC.alertTypeArray addObject:[NSNumber numberWithInteger:dType]];
                dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    switch (dType) {
                        case RongRTC_Device_CameraMicphone:
                            [self alertWith:@"" withMessage:NSLocalizedString(@"chat_open_cameramic_by_host", nil) withOKAction:ok withCancleAction:cancle];
                            break;
                        case RongRTC_Device_Micphone:
                            [self alertWith:@"" withMessage:NSLocalizedString(@"chat_open_mic_by_host", nil) withOKAction:ok withCancleAction:cancle];
                            break;
                        case RongRTC_Device_Camera:
                            [self alertWith:@"" withMessage:NSLocalizedString(@"chat_open_camera_by_host", nil) withOKAction:ok withCancleAction:cancle];
                            break;
                        default:
                            break;
                    }
                });
                
             });
        }else{
            if (self.chatViewController.observerIndex != RongRTC_User_Observer) {
                [self updateUser:userId deviceType:dType open:isOpen];
                [engine answerHostControlUserDevice:userId withDeviceType:dType open:isOpen status:YES];
            }
        }
    }else{
        [self updateUser:userId deviceType:dType open:isOpen];
    }
        
    });
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onNotifyAnswerHostControlUserDevice:(NSString *)userId withAnswerType:(RongRTC_Answer_Type)type withDeviceType:(RongRTC_Device_Type)dType status:(BOOL)isAccept
{
    if (isAccept) {
        BOOL isOpen = NO;
        if (type == RongRTC_Answer_InviteOpen) {
            isOpen = YES;
        }else if (type == RongRTC_Answer_InviteClose)
            isOpen = NO;
        [self updateUser:userId deviceType:dType open:isOpen];
    }
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onNotifyAnswerUpgradeObserverToNormalUser:(NSString *)userId status:(BOOL)isAccept
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    [weakChatVC.observerArray enumerateObjectsUsingBlock:^(ChatCellVideoViewModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userID isEqualToString:userId]) {
            [obj removeObserver:obj forKeyPath:@"frameRateRecv"];
            [obj removeObserver:obj forKeyPath:@"frameWidthRecv"];
            [obj removeObserver:obj forKeyPath:@"frameHeightRecv"];
            [obj removeObserver:obj forKeyPath:@"frameRate"];

            [weakChatVC.observerArray removeObject:obj];
            [self rongRTCEngine:engine onUserJoined:userId userName:obj.userName userType:RongRTC_User_Normal audioVideoType:RongRTC_User_Audio_Video screenSharingStatus:RongRTC_ScreenSharing_Off];
        }
    }];
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onNotifyAnswerDegradeNormalUserToObserver:(NSString *)userId status:(BOOL)isAccept
{
    DLog(@"LLH...... onNotifyAnswerDegradeNormalUserToObserver implement: %@", userId);

    __weak ChatViewController *weakChatVC = self.chatViewController;
    if (isAccept) {
        if (weakChatVC.isSwitchCamera && [weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID isEqualToString:userId]  ){
                NSInteger index = [weakChatVC.userIDArray indexOfObject:weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.userID];
                if (index != NSNotFound){
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    if (weakChatVC.isSwitchCamera)
                        [weakChatVC.chatCollectionViewDataSourceDelegateImpl collectionView:weakChatVC.collectionView didSelectItemAtIndexPath:indexPath];
                }
         }
        __block NSInteger row;
        [weakChatVC.remoteViewArray enumerateObjectsUsingBlock:^(ChatCellVideoViewModel *model, NSUInteger i, BOOL * _Nonnull stop) {
            if ([model.userID isEqualToString:userId]) {
                UIView *videoView = [[UIView alloc] initWithFrame:SmallVideoFrame];
                ChatCellVideoViewModel *chatCellVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:videoView];
                chatCellVideoViewModel.userID = userId;
                chatCellVideoViewModel.userName = model.userName;
                chatCellVideoViewModel.avType = RongRTC_User_Audio_Video;
                chatCellVideoViewModel.screenSharingStatus = 0 ;
                chatCellVideoViewModel.everOnLocalView = 0;
                
                [weakChatVC.observerArray addObject:chatCellVideoViewModel];
                
                [model removeObserver:model forKeyPath:@"frameRateRecv"];
                [model removeObserver:model forKeyPath:@"frameWidthRecv"];
                [model removeObserver:model forKeyPath:@"frameHeightRecv"];
                [model removeObserver:model forKeyPath:@"frameRate"];

                row = i;
                [weakChatVC.remoteViewArray removeObjectAtIndex:i];
                [weakChatVC.userIDArray removeObjectAtIndex:i];
                [weakChatVC.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
            }
        }];
        if (row <= weakChatVC.orignalRow) {
            weakChatVC.orignalRow -= 1;
        }
        
        if ([weakChatVC.localVideoViewModel.userID isEqualToString:userId]) {
            if ([weakChatVC.remoteViewArray count] > 0)
            {
                {
                    ChatCellVideoViewModel *model = (ChatCellVideoViewModel *)weakChatVC.remoteViewArray[0];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRateRecv"];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameWidthRecv"];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameHeightRecv"];
                    [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRate"];
                    
                    //                    weakChatVC.localVideoViewModel = nil;
                    //                    ChatCellVideoViewModel *tempModel = weakChatVC.localVideoViewModel;
                    [weakChatVC.localVideoViewModel.cellVideoView removeFromSuperview];
                    [weakChatVC.localVideoViewModel.avatarView removeFromSuperview];
                    self.degradeCellVideoViewModel = model;
                    weakChatVC.localVideoViewModel = model;
                    
                    [weakChatVC.userIDArray removeObjectAtIndex:0];
                    [weakChatVC.remoteViewArray removeObjectAtIndex:0];
                    [weakChatVC.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
                    
                    UIView *videoView = [weakChatVC.rongRTCEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) withUserID:weakChatVC.localVideoViewModel.userID withDisplayType:RongRTC_VideoViewDisplay_CompleteView];
                    weakChatVC.localVideoViewModel.cellVideoView = videoView;
                    
                    [weakChatVC.videoMainView addSubview:weakChatVC.localVideoViewModel.cellVideoView];
                    
                    
                    if (weakChatVC.localVideoViewModel.avType == RongRTC_User_Only_Audio || weakChatVC.localVideoViewModel.avType == RongRTC_User_Audio_Video_None) {
                        
                        weakChatVC.localVideoViewModel.avatarView.frame = BigVideoFrame;
                        //                    if (!weakChatVC.isOpenWhiteBoard) {
                        [weakChatVC.localVideoViewModel.cellVideoView addSubview:weakChatVC.localVideoViewModel.avatarView];
                        //                    }
                        
                        weakChatVC.localVideoViewModel.avatarView.center = CGPointMake(self.chatViewController.videoMainView.frame.size.width / 2, self.chatViewController.videoMainView.frame.size.height / 2);
                    }
                    
                    //                    weakChatVC.localVideoViewModel.avType = tempModel.avType;
                    if (weakChatVC.isOpenWhiteBoard) {
                        [weakChatVC.videoMainView bringSubviewToFront:weakChatVC.whiteBoardWebView];
                    }
                    [weakChatVC.videoMainView bringSubviewToFront:weakChatVC.localVideoViewModel.cellVideoView];
                    
                }
            }
    }
    }
    
}

//观察者收到的主持人回应回调
- (void)rongRTCEngine:(RongRTCEngine *)engine onNotifyAnswerObserverRequestBecomeNormalUser:(NSString *)userId status:(RongRTC_Accept_Type)acceptType;
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    dispatch_async(dispatch_get_main_queue(), ^{
    
        if (acceptType == RongRTC_Accept_YES) {
            if ([userId isEqualToString:kDeviceUUID] && weakChatVC.observerIndex == RongRTC_User_Observer) {
                [weakChatVC.localView removeFromSuperview];
                weakChatVC.localView = nil;
                if (weakChatVC.deviceOrientaionBefore == UIDeviceOrientationPortrait) {
                    weakChatVC.localView = [weakChatVC.rongRTCEngine createLocalVideoViewFrame:CGRectMake(0, 0, 90, 120) withDisplayType:RongRTC_VideoViewDisplay_FullScreen];
                }else{
                    weakChatVC.localView = [weakChatVC.rongRTCEngine createLocalVideoViewFrame:CGRectMake(0, 0, 120, 120) withDisplayType:RongRTC_VideoViewDisplay_FullScreen];
                    if (weakChatVC.observerIndex == RongRTC_User_Observer) {
                        weakChatVC.localView.transform = CGAffineTransformIdentity;
                        if (weakChatVC.deviceOrientaionBefore == UIDeviceOrientationLandscapeLeft) {
                            weakChatVC.localView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                        }else{
                            weakChatVC.localView.transform = CGAffineTransformMakeRotation(M_PI_2);
                        }
                    }
                }
                
                if (weakChatVC.isSwitchCamera && weakChatVC.remoteViewArray.count > weakChatVC.orignalRow ) {
                    ChatCellVideoViewModel *sourceMode = weakChatVC.remoteViewArray[weakChatVC.orignalRow];
                    ChatCell *cell = (ChatCell *)[weakChatVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:weakChatVC.orignalRow inSection:0]];
                    [weakChatVC.localVideoViewModel.cellVideoView removeFromSuperview];
                    ChatCellVideoViewModel *tempMode = weakChatVC.localVideoViewModel;
                    
                    tempMode.cellVideoView = [weakChatVC.rongRTCEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, 90, 120) withUserID:tempMode.userID withDisplayType:RongRTC_VideoViewDisplay_FullScreen];
                    weakChatVC.remoteViewArray[weakChatVC.orignalRow] = tempMode;
                    if ([weakChatVC.userIDArray containsObject:tempMode.userID]) {
                        [weakChatVC.userIDArray removeObject:tempMode.userID ];
                    }
                    [weakChatVC.userIDArray addObject:tempMode.userID];
                    [cell.videoView addSubview:tempMode.cellVideoView];
                    if (tempMode.avType == RongRTC_User_Only_Audio || tempMode.avType == RongRTC_User_Audio_Video_None)
                    {
                        tempMode.avatarView.frame = SmallVideoFrame;
                        [cell.videoView addSubview:tempMode.avatarView];
                        tempMode.avatarView.center = tempMode.cellVideoView.center;
                    }
                    weakChatVC.localVideoViewModel = sourceMode;
                }
                
                
                
                if (weakChatVC.localVideoViewModel && ![weakChatVC.localVideoViewModel.userID isEqualToString:@""]) {
                    
                    UIView *videoView = [weakChatVC.rongRTCEngine changeRemoteVideoViewFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) withUserID:weakChatVC.localVideoViewModel.userID withDisplayType:RongRTC_VideoViewDisplay_CompleteView];
                    
                    ChatCellVideoViewModel *chatCellVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:videoView];
                    chatCellVideoViewModel.avatarView = weakChatVC.localVideoViewModel.avatarView;
                    if ([weakChatVC.userIDArray containsObject:weakChatVC.localVideoViewModel.userID]) {
                        [weakChatVC.userIDArray removeObject:weakChatVC.localVideoViewModel.userID ];
                    }
                    [weakChatVC.userIDArray addObject:weakChatVC.localVideoViewModel.userID];
                    if (self.degradeCellVideoViewModel) {
                        chatCellVideoViewModel.avType = self.degradeCellVideoViewModel.avType;
                        chatCellVideoViewModel.originalSize = self.degradeCellVideoViewModel.originalSize;
                    }else{
                        chatCellVideoViewModel.avType = self.chatViewController.localVideoViewModel.avType;
                    }
                    
                    if (chatCellVideoViewModel.avType == RongRTC_User_Audio_Video_None || chatCellVideoViewModel.avType == RongRTC_User_Only_Audio) {
                        
                        chatCellVideoViewModel.avatarView.frame = BigVideoFrame;
                        
                        [weakChatVC.localVideoViewModel.cellVideoView addSubview:chatCellVideoViewModel.avatarView];
                        chatCellVideoViewModel.avatarView.center = CGPointMake(weakChatVC.videoMainView.frame.size.width / 2, weakChatVC.videoMainView.frame.size.height / 2);
                    }
                    //                        [chatCellVideoViewModel.cellVideoView addSubview:weakChatVC.localView];
                    chatCellVideoViewModel.userID = weakChatVC.localVideoViewModel.userID;
                    //                        chatCellVideoViewModel.cellVideoView = weakChatVC.localVideoViewModel.cellVideoView;
                    //                        [weakChatVC.videoMainView addSubview:chatCellVideoViewModel.cellVideoView];
                    [weakChatVC.remoteViewArray addObject:chatCellVideoViewModel];
                    [weakChatVC.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakChatVC.userIDArray.count-1 inSection:0]]];
                }
                [weakChatVC.localVideoViewModel.avatarView removeFromSuperview];
                //weakChatVC.localview 旋转后
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRateRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameWidthRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameHeightRecv"];
                [weakChatVC.localVideoViewModel removeObserver:weakChatVC.localVideoViewModel forKeyPath:@"frameRate"];
                
                weakChatVC.localVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:weakChatVC.localView];
                weakChatVC.localVideoViewModel.userID = kDeviceUUID;
                weakChatVC.localVideoViewModel.avType = RongRTC_User_Audio_Video;
                weakChatVC.localVideoViewModel.userName = weakChatVC.userName;
                weakChatVC.localVideoViewModel.screenSharingStatus = 0;
                weakChatVC.localVideoViewModel.everOnLocalView = 0;
                weakChatVC.localVideoViewModel.avatarView.model = [[ChatAvatarModel alloc] initWithShowVoice:NO showIndicator:YES userName:weakChatVC.userName userID:kDeviceUUID];
                
                
                if (weakChatVC.userIDArray.count >= 1) {
                    ChatCell *cell = (ChatCell *)[weakChatVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:weakChatVC.userIDArray.count-1 inSection:0]];
                    ChatCellVideoViewModel *tmpModel = weakChatVC.remoteViewArray[weakChatVC.userIDArray.count-1];
                    [weakChatVC.videoMainView addSubview:tmpModel.cellVideoView];
                    
                    weakChatVC.isSwitchCamera = YES;
                    weakChatVC.orignalRow = weakChatVC.userIDArray.count-1;
                    weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel = tmpModel;
                    weakChatVC.selectedChatCell = cell;
                    weakChatVC.localVideoViewModel.avType = RongRTC_User_Audio_Video;
                    
 
                    NSString *bigStreamUseID = tmpModel.userID;

                    NSMutableArray *tinyStreamUseIDs = [NSMutableArray arrayWithArray: weakChatVC.userIDArray];
                    if(![bigStreamUseID isEqualToString:kDeviceUUID]) {
                        [tinyStreamUseIDs removeObject:bigStreamUseID];
                    } else {
                        bigStreamUseID = nil;
                    }
                    [weakChatVC.rongRTCEngine subscribeStreamForTiny:tinyStreamUseIDs forOrigin:bigStreamUseID];
                  
                    if (weakChatVC.isOpenWhiteBoard) {
                        [weakChatVC.localView removeFromSuperview];
                        weakChatVC.localVideoViewModel.cellVideoView = [weakChatVC.rongRTCEngine createLocalVideoViewFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) withDisplayType:RongRTC_VideoViewDisplay_CompleteView ];
                        tmpModel.cellVideoView = [weakChatVC.rongRTCEngine changeRemoteVideoViewFrame: CGRectMake(0, 0, 90, 120) withUserID:tmpModel.userID withDisplayType:RongRTC_VideoViewDisplay_FullScreen];
                        [cell.videoView addSubview:tmpModel.cellVideoView];
                        [cell.videoView bringSubviewToFront:tmpModel.cellVideoView];
                        
                        
                        if (tmpModel.avType == RongRTC_User_Only_Audio || tmpModel.avType == RongRTC_User_Audio_Video_None)
                        {
                            tmpModel.avatarView.frame = SmallVideoFrame;
                            
                            [tmpModel.cellVideoView addSubview:tmpModel.avatarView];
                            tmpModel.avatarView.center = tmpModel.cellVideoView.center;
                        }
                        
                        weakChatVC.isSwitchCamera = NO;
                        [weakChatVC.videoMainView bringSubviewToFront:weakChatVC.whiteBoardWebView];
                    }else{
                        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 2 *NSEC_PER_SEC);
                        dispatch_after(time
                                       , dispatch_get_main_queue(), ^{
                                           [cell.videoView addSubview:weakChatVC.localVideoViewModel.cellVideoView];
                                           if (tmpModel.avType == RongRTC_User_Only_Audio || tmpModel.avType == RongRTC_User_Audio_Video_None)
                                           {
                                               tmpModel.avatarView.frame = BigVideoFrame;
                                               [tmpModel.cellVideoView addSubview:tmpModel.avatarView];
                                               tmpModel.avatarView.center = tmpModel.cellVideoView.center;
                                           }
                                       });
                    }
                }
                
                if (weakChatVC.isCloseCamera) {
                    [weakChatVC didClickVideoMuteButton:weakChatVC.chatViewBuilder.openCameraButton];
                }
                if (weakChatVC.isNotMute) {
                    [weakChatVC didClickAudioMuteButton:weakChatVC.chatViewBuilder.microphoneOnOffButton];
                }
                
                if (weakChatVC.isBackCamera) {
                    [weakChatVC shouldChangeSwitchCameraButtonBG:weakChatVC.chatViewBuilder.switchCameraButton];
                }
                
                weakChatVC.observerIndex = RongRTC_User_Normal;
                [weakChatVC turnMenuButtonToNormal];
                
            }else{
                [weakChatVC.observerArray enumerateObjectsUsingBlock:^(ChatCellVideoViewModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.userID isEqualToString:userId]) {
                        [obj removeObserver:obj forKeyPath:@"frameRateRecv"];
                        [obj removeObserver:obj forKeyPath:@"frameWidthRecv"];
                        [obj removeObserver:obj forKeyPath:@"frameHeightRecv"];
                        [obj removeObserver:obj forKeyPath:@"frameRate"];

                        [weakChatVC.observerArray removeObject:obj];
                        [self rongRTCEngine:engine onUserJoined:userId userName:obj.userName userType:RongRTC_User_Normal audioVideoType:RongRTC_User_Audio_Video screenSharingStatus:RongRTC_ScreenSharing_Off];
                    }
                }];
            }
        }else if (acceptType == RongRTC_Accept_NO){
            [weakChatVC turnMenuButtonToObserver];
        }else{
            //Busy
            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_confirm", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [self alertWith:@"" withMessage:NSLocalizedString(@"chat_alert_raisehand_busy", nil) withOKAction:ok withCancleAction:nil];
        }
            
    });
}

//观察者请求成为正常用户后,主持人收到的回调
- (void)rongRTCEngine:(RongRTCEngine *)engine onNotifyObserverRequestBecomeNormalUser:(NSString *)userId authorityType:(RongRTC_Authority_Type)type
{
}

//正常用户请求成为主持人信令是否发送成功的回调
- (void)rongRTCEngine:(RongRTCEngine *)engine onNormalUserRequestHostAuthority:(NSInteger)code
{
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onRemoveUser:(NSInteger)code
{
}

- (void)rongRTCEngine:(RongRTCEngine *)engine onGetInviteURL:(NSString *)url responseCode:(NSInteger)code
{
}

//主持人降低用户级别信令发送状态回调
- (void)rongRTCEngine:(RongRTCEngine *)engine onDegradeNormalUserToObserver:(NSInteger)code
{
}

//主持人提升用户级别信令发送状态回调
- (void)rongRTCEngine:(RongRTCEngine *)engine onUpgradeObserverToNormalUser:(NSInteger)code
{
}

//观察者请求成为正常用户信令是否发送成功的回调
- (void)rongRTCEngine:(RongRTCEngine *)engine onObserverRequestBecomeNormalUser:(NSInteger)code
{
}

//主持人操作某正常用户设备开启关闭,信令发送是否成功的回调
- (void)rongRTCEngine:(RongRTCEngine *)engine onHostControlUserDevice:(NSString *)userId withDeviceType:(RongRTC_Device_Type)dType responseCode:(NSInteger)code
{
}

#pragma mark - audioLevel
- (void)rongRTCEngine:(RongRTCEngine *)engine onNotifyUserAudioLevel:(NSArray *)levelArray
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    for (NSDictionary *dict in levelArray) {
        NSInteger  audioleval = [dict[@"audioleval"] integerValue];
        NSString *userid = dict[@"userid"];
        if ([userid isEqualToString:kDeviceUUID]) {
            if ([weakChatVC.localVideoViewModel.userID isEqualToString:userid]) {
                if ((weakChatVC.localVideoViewModel.avType != RongRTC_User_Audio_Video_None && weakChatVC.localVideoViewModel.avType != RongRTC_User_Only_Video)) {
                    
                    weakChatVC.localVideoViewModel.audioLevel = audioleval;
                    if (weakChatVC.localVideoViewModel.audioLevel <= 0) {
                        [weakChatVC.localVideoViewModel.audioLevelView removeFromSuperview];
                    }else{
                        [weakChatVC.localVideoViewModel.cellVideoView.superview addSubview:weakChatVC.localVideoViewModel.audioLevelView];
                        [weakChatVC.localVideoViewModel.cellVideoView.superview bringSubviewToFront:weakChatVC.localVideoViewModel.audioLevelView];
                        weakChatVC.localVideoViewModel.audioLevelView.center = CGPointMake(weakChatVC.localVideoViewModel.cellVideoView.frame.size.width-20, weakChatVC.localVideoViewModel.cellVideoView.frame.size.height-20);
                    }
                }else
                    [weakChatVC.localVideoViewModel.audioLevelView removeFromSuperview];
            }
            
            continue;
        }
        [weakChatVC.remoteViewArray enumerateObjectsUsingBlock:^(ChatCellVideoViewModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([model.userID isEqualToString:userid]) {
                model.audioLevel = audioleval;
                if (model.audioLevel <= 0) {
                    [model.audioLevelView removeFromSuperview];
                }else{
                    [model.cellVideoView.superview addSubview:model.audioLevelView];
                    [model.cellVideoView.superview bringSubviewToFront:model.audioLevelView];
                    model.audioLevelView.center = CGPointMake(model.cellVideoView.frame.size.width-20, model.cellVideoView.frame.size.height-20);
                }
            }
        }];
    }
}

- (NSString *)trafficString:(NSString *)recvBitrate sendBitrate:(NSString *)sendBitrate {
    return [NSString stringWithFormat:@"%@: %@   %@: %@", NSLocalizedString(@"chat_receive", nil), recvBitrate, NSLocalizedString(@"chat_send", nil), sendBitrate];
}

#pragma mark - private
- (void)updateUser:(NSString *)userId deviceType:(RongRTC_Device_Type)dType open:(BOOL)isOpen
{
    __weak ChatViewController *weakChatVC = self.chatViewController;
    if (weakChatVC.observerIndex == RongRTC_User_Observer){
        if ([self.chatViewController.localVideoViewModel.userID isEqualToString:userId]) {
            [self adaptUserType:dType withDataModel:self.chatViewController.localVideoViewModel open:isOpen];
            [self rongRTCEngine:weakChatVC.rongRTCEngine onUser:userId audioVideoType:self.chatViewController.localVideoViewModel.avType];
        }else{
            for (ChatCellVideoViewModel *model in weakChatVC.remoteViewArray) {
                if ([model.userID isEqualToString:userId]) {
                    [self adaptUserType:dType withDataModel:model open:isOpen];
                    [self rongRTCEngine:weakChatVC.rongRTCEngine onUser:userId audioVideoType:model.avType];
                }
            }
        }
    }if ([userId isEqualToString:kDeviceUUID]) {
        [self adaptUserType:dType withDataModel:weakChatVC.localVideoViewModel open:isOpen];
        DLog(@"avType: %ld", (long)weakChatVC.localVideoViewModel.avType);
        [weakChatVC updateAudioVideoType:weakChatVC.localVideoViewModel.avType];
    }else{
        for (ChatCellVideoViewModel *model in weakChatVC.remoteViewArray) {
            if ([model.userID isEqualToString:userId]) {
                [self adaptUserType:dType withDataModel:model open:isOpen];
                [self rongRTCEngine:weakChatVC.rongRTCEngine onUser:userId audioVideoType:model.avType];
            }
        }
    }
}

#pragma mark - AlertController
- (void)alertWith:(NSString *)title withMessage:(NSString *)msg withOKAction:(UIAlertAction *)ok withCancleAction:(UIAlertAction *)cancel
{
    self.chatViewController.alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [self.chatViewController.alertController addAction:ok];
    if (cancel)
        [self.chatViewController.alertController addAction:cancel];
    
    [self.chatViewController presentViewController:self.chatViewController.alertController animated:YES completion:^{}];
    
}

- (void)adaptUserType:(RongRTC_Device_Type)dType withDataModel:(ChatCellVideoViewModel *)model open:(BOOL)isOpen
{
    switch (model.avType) {
        case RongRTC_User_Only_Audio:
            switch (dType) {
                case RongRTC_Device_Camera:
                    model.avType = isOpen ? RongRTC_User_Audio_Video : RongRTC_User_Only_Audio;
                    break;
                case RongRTC_Device_Micphone:
                    model.avType = isOpen ? RongRTC_User_Only_Audio : RongRTC_User_Audio_Video_None;
                    break;
                case RongRTC_Device_CameraMicphone:
                    model.avType = isOpen ? RongRTC_User_Audio_Video : RongRTC_User_Audio_Video_None;
                    break;
                default:
                    break;
            }
            break;
        case RongRTC_User_Audio_Video:
            switch (dType) {
                case RongRTC_Device_Camera:
                    model.avType = isOpen ? RongRTC_User_Audio_Video : RongRTC_User_Only_Audio;
                    break;
                case RongRTC_Device_Micphone:
                    model.avType = isOpen ? RongRTC_User_Audio_Video : RongRTC_User_Only_Video;
                    break;
                case RongRTC_Device_CameraMicphone:
                    model.avType = isOpen ? RongRTC_User_Audio_Video : RongRTC_User_Audio_Video_None;
                    break;
                default:
                    break;
            }
            break;
        case RongRTC_User_Only_Video:
            switch (dType) {
                case RongRTC_Device_Camera:
                    model.avType = isOpen ? RongRTC_User_Only_Video : RongRTC_User_Audio_Video_None;
                    break;
                case RongRTC_Device_Micphone:
                    model.avType = isOpen ? RongRTC_User_Audio_Video : RongRTC_User_Only_Video;
                    break;
                case RongRTC_Device_CameraMicphone:
                    model.avType = isOpen ? RongRTC_User_Audio_Video : RongRTC_User_Audio_Video_None;
                    break;
                default:
                    break;
            }
            break;
        case RongRTC_User_Audio_Video_None:
            switch (dType) {
                case RongRTC_Device_Camera:
                    model.avType = isOpen ? RongRTC_User_Only_Video : RongRTC_User_Audio_Video_None;
                    break;
                case RongRTC_Device_Micphone:
                    model.avType = isOpen ? RongRTC_User_Only_Audio : RongRTC_User_Audio_Video_None;
                    break;
                case RongRTC_Device_CameraMicphone:
                    model.avType = isOpen ? RongRTC_User_Audio_Video : RongRTC_User_Audio_Video_None;
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}
@end
