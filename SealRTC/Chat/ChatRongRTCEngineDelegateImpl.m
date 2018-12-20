
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
