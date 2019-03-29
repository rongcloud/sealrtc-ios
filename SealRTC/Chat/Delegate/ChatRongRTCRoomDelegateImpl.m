//
//  ChatRongRTCRoomDelegateImpl.m
//  SealRTC
//
//  Created by LiuLinhong on 2019/02/14.
//  Copyright © 2019 BridgeMind. All rights reserved.
//

#import "ChatRongRTCRoomDelegateImpl.h"
#import "ChatViewController.h"
#import <RongIMLib/RongIMLib.h>

@interface ChatRongRTCRoomDelegateImpl ()

@property (nonatomic, weak) ChatViewController *chatViewController;

@end

@implementation ChatRongRTCRoomDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.chatViewController = (ChatViewController *) vc;
    }
    return self;
}

/**
 有用户加入的回调
 @param user 加入的用户信息
 */
- (void)didJoinUser:(RongRTCRemoteUser*)user
{
    FwLogI(RC_Type_RTC,@"A-appReceiveUserJoin-T",@"%@appReceiveUserJoin",@"sealRTCApp:");
    NSString *userId = user.userId;
    DLog(@"didJoinUser userID: %@", userId);
    [self.chatViewController hideAlertLabel:YES];
    
    [self.chatViewController startTalkTimer];
}

/**
 有用户离开时的回调
 @param user 离开的用户
 */
- (void)didLeaveUser:(RongRTCRemoteUser*)user
{
    FwLogI(RC_Type_RTC,@"A-appReceiveUserLeave-T",@"%@appReceiveUserLeave",@"sealRTCApp:");
    __weak ChatViewController *weakChatVC = self.chatViewController;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *userId = user.userId;
        DLog(@"didLeaveUser userID: %@", userId);
        
        NSArray *streams = user.remoteAVStreams;
        for (RongRTCAVInputStream *stream in streams) {
            NSString *streamID = stream.streamId;
            if ([kChatManager isContainRemoteUserFromUserID:streamID])
            {
                NSInteger index = [kChatManager indexOfRemoteUserDataArray:streamID];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                
                if (kLoginManager.isSwitchCamera)
                {
                    if ([weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.streamID isEqualToString:streamID]
                        || [weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.streamID isEqualToString:[NSString stringWithFormat:@"%@_screen", streamID]])
                    {
                        [weakChatVC.chatCollectionViewDataSourceDelegateImpl collectionView:weakChatVC.collectionView didSelectItemAtIndexPath:indexPath];
                    }
                }
                
                [kChatManager removeRemoteUserDataModelFromUserID:streamID];
                FwLogI(RC_Type_RTC,@"A-appReceiveUserLeave-T",@"%@appReceiveUserLeave and remove user",@"sealRTCApp:");
                [weakChatVC.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                
                if (weakChatVC.orignalRow > 0)
                    weakChatVC.orignalRow--;
            }
        }
        FwLogI(RC_Type_RTC,@"A-appReceiveUserJoin-T",@"usercount: %@",@([kChatManager countOfRemoteUserDataArray]));
        if ([kChatManager countOfRemoteUserDataArray] == 0)
        {
            if (weakChatVC.durationTimer)
            {
                [weakChatVC.durationTimer invalidate];
                weakChatVC.duration = 0;
                weakChatVC.durationTimer = nil;
            }
            
            weakChatVC.dataTrafficLabel.hidden = YES;
            weakChatVC.talkTimeLabel.text = @"";//NSLocalizedString(@"chat_total_time", nil);
            FwLogI(RC_Type_RTC,@"A-appReceiveUserJoin-T",@"hideAlertLabel NO");
            [weakChatVC hideAlertLabel:NO];
        }
    });
}

/**
 数据流第一个关键帧到达
 @param stream 开始接收数据的 stream
 */
- (void)didReportFirstKeyframe:(RongRTCAVInputStream *)stream
{
}

-(void)didConnectToStream:(RongRTCAVInputStream *)stream{
    FwLogI(RC_Type_RTC,@"A-appConnectToStream-T",@"%@appConnectTostream",@"sealRTCApp:");
    if (stream.streamId) {
        [self.chatViewController didConnectToUser:stream.streamId];
    } else {
        DLog(@"did connect to stream but userId is nil");
    }
}

/**
 当有用户发布资源的时候，通过此方法回调用户发布的流,可通过 `RongRTCLocalUser` 中的 `- (void)subcribeUserResource:(RongRTCAVInputStream *)stream attachTiny:(BOOL)attachTiny compltion:(nullable void (^) ( BOOL isSuccess ,  RongRTCError error))completion;` 接口，来决定订阅 user.remoteAVStreams 中的某一道流
 @param streams 用户发布的资源信息
 */
- (void)didPublishStreams:(NSArray <RongRTCAVInputStream *>*)streams
{
    FwLogI(RC_Type_RTC,@"A-appPublishStreaam-T",@"%@appPublishStream",@"sealRTCApp:");
    [self.chatViewController receivePublishMessage];
    [self.chatViewController subscribeRemoteResource:streams];
}

/**
 当有用户取消发布资源的时候，通过此方法回调。
 @param streams 取消发布资源
 */
- (void)didUnpublishStreams:(NSArray<RongRTCAVInputStream *>*)streams
{
    FwLogI(RC_Type_RTC,@"A-appReceiveUnpublishStream-T",@"%@app receive unpublishstreams",@"sealRTCApp:");
//    [self.chatViewController unsubscribeRemoteResource:streams];
    
    __weak ChatViewController *weakChatVC = self.chatViewController;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for (RongRTCAVInputStream *stream in streams) {
            NSString *streamID = stream.streamId;
            if ([kChatManager isContainRemoteUserFromUserID:streamID])
            {
                NSInteger index = [kChatManager indexOfRemoteUserDataArray:streamID];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                
                if (kLoginManager.isSwitchCamera)
                {
                    if ([weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.streamID isEqualToString:streamID]
                        || [weakChatVC.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.streamID isEqualToString:[NSString stringWithFormat:@"%@_screen", streamID]])
                    {
                        [weakChatVC.chatCollectionViewDataSourceDelegateImpl collectionView:weakChatVC.collectionView didSelectItemAtIndexPath:indexPath];
                    }
                }
                
                [kChatManager removeRemoteUserDataModelFromUserID:streamID];
                FwLogI(RC_Type_RTC,@"A-appReceiveUserLeave-T",@"%@appReceiveUserLeave and remove user",@"sealRTCApp:");
                [weakChatVC.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                
                if (weakChatVC.orignalRow > 0)
                    weakChatVC.orignalRow--;
            }
        }
    });
}

- (void)didKickedOutOfTheRoom:(RongRTCRoom *)room
{
    FwLogI(RC_Type_RTC,@"A-appreceiveLeaveRoom-T",@"%@all reveive leave room",@"sealRTCApp:");
    [self.chatViewController didLeaveRoom];
}

/**
 音频状态改变
 @param stream 流信息
 @param mute 当前流是否可用
 */
- (void)stream:(RongRTCAVInputStream*)stream didAudioMute:(BOOL)mute
{
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//    }];
//    UIAlertController *controler = [UIAlertController alertControllerWithTitle:@"有人开关麦克风了" message:[NSString stringWithFormat:@"%@把%@这道流的麦克风%@了",stream.userId,stream.streamId,!mute?@"关":@"开"] preferredStyle:(UIAlertControllerStyleAlert)];
//    [controler addAction:action];
//    [self presentViewController:controler animated:YES completion:^{
//    }];
}

/**
 视频状态改变
 @param stream 流信息
 @param enable 当前流是否可用
 */
- (void)stream:(RongRTCAVInputStream*)stream didVideoEnable:(BOOL)mute {
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//    }];
//    UIAlertController *controler = [UIAlertController alertControllerWithTitle:@"有人开关摄像头了" message:[NSString stringWithFormat:@"%@把%@这道流的摄像头%@了",stream.userId,stream.streamId,!mute?@"关":@"开"] preferredStyle:(UIAlertControllerStyleAlert)];
//    [controler addAction:action];
//    [self presentViewController:controler animated:YES completion:^{
//    }];
}


@end
