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
#import "STSetRoomInfoMessage.h"
#import "STDeleteRoomInfoMessage.h"
#import "STParticipantsInfo.h"

@interface ChatRongRTCRoomDelegateImpl ()

@property (nonatomic, weak) ChatViewController *chatViewController;

@end

NSNotificationName const STParticipantsInfoDidRemove = @"STParticipantsInfoDidRemove";
NSNotificationName const STParticipantsInfoDidAdd = @"STParticipantsInfoDidAdd";

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
            if ([kChatManager isContainRemoteUserFromStreamID:streamID])
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
                
                [kChatManager removeRemoteUserDataModelFromStreamID:streamID];
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
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:STDidLeaveUserNotificatioin object:user];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger index = NSNotFound;
        for (int i = 0; i < self.infos.count; i++) {
            STParticipantsInfo* info = self.infos[i];
            if ([info.userId isEqualToString:user.userId]) {
                index = i;
                break;
            }
        }
        
        if (index != NSNotFound) {
            [self.infos removeObjectAtIndex:index];
            [[NSNotificationCenter defaultCenter]
                postNotificationName:STParticipantsInfoDidRemove
                              object:[NSIndexPath indexPathForRow:index inSection:0]];
//            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        }
        //[self updateParticipantsCount];
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
            if ([kChatManager isContainRemoteUserFromStreamID:streamID])
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
                
                [kChatManager removeRemoteUserDataModelFromStreamID:streamID];
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
    ChatCellVideoViewModel *remoteModel = [kChatManager getRemoteUserDataModelFromStreamID:stream.streamId];
    remoteModel.isShowVideo = mute;
    if (!mute) {
        remoteModel.avatarView.frame = remoteModel.cellVideoView.frame;
        [remoteModel.cellVideoView addSubview:remoteModel.avatarView];
    }
    else {
        [remoteModel.avatarView removeFromSuperview];
    }
}

- (void)didReceiveMessage:(RCMessage *)message {
    if ([message.content isKindOfClass:STSetRoomInfoMessage.class]) {
        STSetRoomInfoMessage* infoMessage = (STSetRoomInfoMessage*)message.content;
        if (infoMessage.key <= 0) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL isFound = NO;
            for (STParticipantsInfo* info in self.infos) {
                if ([info.userId isEqualToString:infoMessage.key]) {
                    isFound = YES;
                    break;
                }
            }
            if (!isFound) {
                [self.infos insertObject:infoMessage.info atIndex:0];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:STParticipantsInfoDidAdd
                               object:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
        });
        ChatCellVideoViewModel* model = [kChatManager getRemoteUserDataModelSimilarUserID:infoMessage.key];
        model.userName = infoMessage.info.userName;
        //[[NSNotificationCenter defaultCenter] postNotificationName:STDidRecvSetRoomInfoMessageNotification object:message.content];
    } else if ([message.content isKindOfClass:STDeleteRoomInfoMessage.class]) {
        STDeleteRoomInfoMessage* infoMessage = (STDeleteRoomInfoMessage*)message.content;
        if (infoMessage.key <= 0) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger index = NSNotFound;
            for (int i = 0; i < self.infos.count; i++) {
                STParticipantsInfo* info = self.infos[i];
                if ([info.userId isEqualToString:infoMessage.key]) {
                    index = i;
                    break;
                }
            }
            
            if (index != NSNotFound) {
                [self.infos removeObjectAtIndex:index];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:STParticipantsInfoDidRemove
                 object:[NSIndexPath indexPathForRow:index inSection:0]];
            }
        });
        //[[NSNotificationCenter defaultCenter] postNotificationName:STDidRecvDeleteRoomInfoMessageNotification object:message.content];
    }
}

//
//- (void)didRecvSetRoomInfoNotification:(NSNotification*)notification {
//    STSetRoomInfoMessage* infoMessage = (STSetRoomInfoMessage*)notification.object;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        BOOL isFound = NO;
//        for (STParticipantsInfo* info in self.infos) {
//            if ([info.userId isEqualToString:infoMessage.key]) {
//                isFound = YES;
//                break;
//            }
//        }
//        if (!isFound) {
//            [self.dataSource addObject:infoMessage.info];
//            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
//        }
//        [self updateParticipantsCount];
//    });
//}

//- (void)didRecvDeleteRoomInfoNotification:(NSNotification*)notification {
//    STDeleteRoomInfoMessage* infoMessage = (STDeleteRoomInfoMessage*)notification.object;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSInteger index = NSNotFound;
//        for (int i = 0; i < self.dataSource.count; i++) {
//            STParticipantsInfo* info = self.dataSource[i];
//            if ([info.userId isEqualToString:infoMessage.key]) {
//                index = i;
//                break;
//            }
//        }
//
//        if (index != NSNotFound) {
//            [self.dataSource removeObjectAtIndex:index];
//            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
//        }
//        [self updateParticipantsCount];
//    });
//}

//- (void)didLeaveUserNotification:(NSNotification*)notification {
//    RongRTCRemoteUser* user = (RongRTCRemoteUser*)notification.object;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSInteger index = NSNotFound;
//        for (int i = 0; i < self.dataSource.count; i++) {
//            STParticipantsInfo* info = self.dataSource[i];
//            if ([info.userId isEqualToString:user.userId]) {
//                index = i;
//                break;
//            }
//        }
//
//        if (index != NSNotFound) {
//            [self.dataSource removeObjectAtIndex:index];
//            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
//        }
//        [self updateParticipantsCount];
//    });}


@end
