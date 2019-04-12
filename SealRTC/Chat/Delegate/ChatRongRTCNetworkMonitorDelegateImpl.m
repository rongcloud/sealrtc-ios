//
//  ChatRongRTCNetworkMonitorDelegateImpl.m
//  SealRTC
//
//  Created by LiuLinhong on 2019/03/12.
//  Copyright © 2019 BridgeMind. All rights reserved.
//

#import "ChatRongRTCNetworkMonitorDelegateImpl.h"
#import "ChatLocalDataInfoModel.h"
#import "ChatDataInfoModel.h"
#import "ChatViewController.h"

@interface ChatRongRTCNetworkMonitorDelegateImpl ()

@property (nonatomic, weak) ChatViewController *chatViewController;
@property (nonatomic, strong) NSMutableArray *bitrateArray;

@end


@implementation ChatRongRTCNetworkMonitorDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.chatViewController = (ChatViewController *)vc;
        _bitrateArray = [NSMutableArray array];
    }
    return self;
}

- (void)onAudioVideoTransfer:(NSArray *)memberArray
                    transfer:(NSArray *)localArray {
    
    [self.bitrateArray removeAllObjects];
    NSMutableArray *localDIArray = [NSMutableArray array];
    [localDIArray addObject:@[NSLocalizedString(@"chat_data_excel_tunnelname", nil),NSLocalizedString(@"chat_data_excel_kbps", nil),NSLocalizedString(@"chat_data_excel_delay", nil)]];
    
    for (NSInteger i = 0; i < [localArray count]; i++)
    {
        NSDictionary *tmpLocalDic = (NSDictionary *)localArray[i];
        ChatLocalDataInfoModel *tmpLocalModel = [[ChatLocalDataInfoModel alloc] init];
        tmpLocalModel.channelName = tmpLocalDic[@"tunnelName"];
        tmpLocalModel.codeRate = tmpLocalDic[@"bitrate"];
        tmpLocalModel.delay = tmpLocalDic[@"delay"];
        [localDIArray addObject:tmpLocalModel];
    }
    
    [self.bitrateArray addObject:localDIArray];
    __weak ChatViewController *weakChatVC = self.chatViewController;
    if (localArray.count >= 2) {
        weakChatVC.dataTrafficLabel.text = [self trafficString:((ChatLocalDataInfoModel *)localDIArray[2]).codeRate sendBitrate:((ChatLocalDataInfoModel *)localDIArray[1]).codeRate];
    }
    
    ////////////////////////////////////////
    NSMutableArray *remoteDIArray = [NSMutableArray array];
    [remoteDIArray addObject:@[NSLocalizedString(@"chat_data_excel_userid", nil),NSLocalizedString(@"chat_data_excel_tunnelname", nil),NSLocalizedString(@"chat_data_excel_Codec", nil),NSLocalizedString(@"chat_data_excel_dpi", nil),NSLocalizedString(@"chat_data_excel_fps", nil),NSLocalizedString(@"chat_data_excel_kbps", nil),NSLocalizedString(@"chat_data_excel_lossrate", nil)]];
    
    for (NSInteger i = 0; i < [memberArray count]; i++) {
        NSDictionary *tmpDic = (NSDictionary *)memberArray[i];
        ChatDataInfoModel *tmpMemberModel = [[ChatDataInfoModel alloc] init];
        NSString *trackID = tmpDic[@"trackId"];
        if ([trackID isEqualToString:[NSString stringWithFormat:@"%@_RongCloudRTC_video", kLoginManager.userID]]
            || [trackID isEqualToString:[NSString stringWithFormat:@"%@_RongCloudRTC_audio", kLoginManager.userID]]) {
            tmpMemberModel.userName = @"本地";
            if (![tmpDic[@"frame"] isEqualToString:@"--"]) {
                kChatManager.localUserDataModel.frameRate = tmpDic[@"frame"];
                kChatManager.localUserDataModel.frameRateRecv = [tmpDic[@"frameRateSent"] integerValue];
            }
        } else if ([trackID isEqualToString:[NSString stringWithFormat:@"%@_RongCloudRTC_tiny_video", kLoginManager.userID]]) {
            tmpMemberModel.userName = @"本地tiny";
        } else {
            tmpMemberModel.userName = trackID;
        }
        
        tmpMemberModel.tunnelName = tmpDic[@"tunnelName"];
        tmpMemberModel.codec = tmpDic[@"codecName"];
        tmpMemberModel.frame = tmpDic[@"frame"];
        tmpMemberModel.frameRate = tmpDic[@"frameRateSent"];
        tmpMemberModel.codeRate = tmpDic[@"bitrate"];
        tmpMemberModel.lossRate = tmpDic[@"sendLoss"];
        
        if (kChatManager.localUserDataModel && ![kChatManager.localUserDataModel.streamID isEqualToString:kLoginManager.userID]) {
            if (![tmpDic[@"frame"] isEqualToString:@"--"]) {
                if ([kChatManager.localUserDataModel.streamID isEqualToString:trackID]) {
                    kChatManager.localUserDataModel.frameRate = tmpDic[@"frame"];
                    kChatManager.localUserDataModel.frameRateRecv = [tmpDic[@"frameRateSent"] integerValue];
                }
            }
        }
        
        NSMutableArray *remoteModelArray = [kChatManager allRemoteUserDataArray];
        for (NSInteger i = 0; i < [remoteModelArray count]; i++) {
            ChatCellVideoViewModel *tempViewModel = (ChatCellVideoViewModel *)remoteModelArray[i];
            if ([tempViewModel.streamID isEqualToString:trackID]) {
                if (![tmpDic[@"frame"] isEqualToString:@"--"]) {
                    tempViewModel.frameRate = tmpDic[@"frame"];
                    tempViewModel.frameRateRecv = [tmpDic[@"frameRateSent"] integerValue];
                }
            }
        }
        
        [remoteDIArray addObject:tmpMemberModel];
    }
    
    [self.bitrateArray addObject:remoteDIArray];
    self.chatViewController.chatViewBuilder.excelView.array = self.bitrateArray;
}

- (void)onUserAudioLevel:(NSArray *)levelArray
{
    for (NSDictionary *dict in levelArray)
    {
        NSInteger audioleval = [dict[@"audioleval"] integerValue];
        NSString *userid = dict[@"userid"];
        
        if ([userid isEqualToString:kChatManager.localUserDataModel.userID]) {
            if (!kLoginManager.isMuteMicrophone) {
                kChatManager.localUserDataModel.audioLevel = audioleval;
            }
            else {
                kChatManager.localUserDataModel.audioLevel = 0;
            }
        }
        else {
            ChatCellVideoViewModel *remoteModel = [kChatManager getRemoteUserDataModelFromUserID:userid];
            remoteModel.audioLevel = audioleval;
        }
    }
}

#pragma mark - Private
- (NSString *)trafficString:(NSString *)recvBitrate sendBitrate:(NSString *)sendBitrate
{
    return [NSString stringWithFormat:@"%@: %@   %@: %@", NSLocalizedString(@"chat_receive", nil), recvBitrate, NSLocalizedString(@"chat_send", nil), sendBitrate];
}

@end
