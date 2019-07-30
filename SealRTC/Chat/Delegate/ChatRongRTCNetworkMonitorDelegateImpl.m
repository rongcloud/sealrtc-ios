//
//  ChatRongRTCNetworkMonitorDelegateImpl.m
//  SealRTC
//
//  Created by LiuLinhong on 2019/03/12.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "ChatRongRTCNetworkMonitorDelegateImpl.h"
#import "ChatLocalDataInfoModel.h"
#import "ChatDataInfoModel.h"
#import "ChatViewController.h"
#import "RTActiveWheel.h"

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
            tmpMemberModel.userName = @"本地小流";
        } else if ([trackID isEqualToString:[NSString stringWithFormat:@"%@_RongRTCFileVideo_video", kLoginManager.userID]]) {
            tmpMemberModel.userName = @"本地自";
        } else {
            NSArray *arr = [trackID componentsSeparatedByString:@"_"];
            ChatCellVideoViewModel *model = [kChatManager getRemoteUserDataModelFromUserID:arr[0]];
            NSString *userName = model.userName;
            if (userName)
                tmpMemberModel.userName = userName;
            else
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

- (void)didReportStatForm:(RongRTCStatisticalForm*)form {
    static CGFloat lossRate = 0;
    static time_t prePlayTime = 0;
    const CGFloat lossRateBase = 0.30;
    BOOL isPlay = NO;
    for (RongRTCStreamStat* stat in form.sendStats) {
        if (stat.packetLoss > lossRateBase) {
            isPlay = YES;
            break;
        }
    }

    for (RongRTCStreamStat* stat in form.recvStats) {
        if (stat.packetLoss > lossRate) {
            isPlay = YES;
            break;
        }
    }
    
    if (isPlay && time(nil) - prePlayTime > 5) {
        prePlayTime = time(nil)                 ;
        NSString* soundPath =  [[NSBundle mainBundle] pathForResource:@"voip_network_error_sound" ofType:@"wav"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.chatViewController.networkLabel.hidden = NO;
            self.chatViewController.networkLabel.text = NSLocalizedString(@"voip_network_bad",nil);
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.chatViewController.networkLabel.hidden = YES;
            self.chatViewController.networkLabel.text = nil;
        });
    }
    
    [self.bitrateArray removeAllObjects];
     NSMutableArray *localDIArray = [NSMutableArray array];
    [localDIArray addObject:@[NSLocalizedString(@"chat_data_excel_tunnelname", nil),NSLocalizedString(@"chat_data_excel_kbps", nil),NSLocalizedString(@"chat_data_excel_delay", nil)]];
    
    ChatLocalDataInfoModel *sendModel = [[ChatLocalDataInfoModel alloc] init];
    sendModel.channelName = @"发送";
    sendModel.codeRate =  [NSString stringWithFormat:@"%0.2fkbps",form.totalSendBitRate];
    sendModel.delay = [NSString stringWithFormat:@"%@",@(form.rtt)];
    [localDIArray addObject:sendModel];
    
    ChatLocalDataInfoModel *recvModel = [[ChatLocalDataInfoModel alloc] init];
    recvModel.channelName = @"接收";
    recvModel.codeRate =  [NSString stringWithFormat:@"%0.2fkbps",form.totalRecvBitRate];
    recvModel.delay = @"--";
    [localDIArray addObject:recvModel];
    
    [self.bitrateArray addObject:localDIArray];
    
    NSMutableArray *remoteDIArray = [NSMutableArray array];
    [remoteDIArray addObject:@[NSLocalizedString(@"chat_data_excel_userid", nil),NSLocalizedString(@"chat_data_excel_tunnelname", nil),NSLocalizedString(@"chat_data_excel_Codec", nil),NSLocalizedString(@"chat_data_excel_dpi", nil),NSLocalizedString(@"chat_data_excel_fps", nil),NSLocalizedString(@"chat_data_excel_kbps", nil),NSLocalizedString(@"chat_data_excel_lossrate", nil)]];

    for (RongRTCStreamStat* stat in form.sendStats) {
        ChatDataInfoModel *tmpMemberModel = [[ChatDataInfoModel alloc] init];
        tmpMemberModel.userName = @"本地";
        if ([stat.mediaType isEqualToString:RongRTCMediaTypeVideo]) {
            tmpMemberModel.tunnelName = @"视频发送";
            tmpMemberModel.frame = [NSString stringWithFormat:@"%@*%@",@(stat.frameWidth),@(stat.frameHeight)];
            tmpMemberModel.frameRate = [NSString stringWithFormat:@"%@",@(stat.frameRate)];
        } else {
            tmpMemberModel.tunnelName = @"音频发送";
            tmpMemberModel.frame = @"--";
            tmpMemberModel.frameRate = @"--";
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!kLoginManager.isMuteMicrophone) {
                    kChatManager.localUserDataModel.audioLevel = stat.audioLevel;
                } else {
                    kChatManager.localUserDataModel.audioLevel = 0;
                }
            });
        }
        
        
        tmpMemberModel.codec = stat.codecName;
        tmpMemberModel.codeRate = [NSString stringWithFormat:@"%.02f",stat.bitRate];
        tmpMemberModel.lossRate = [NSString stringWithFormat:@"%.02f",stat.packetLoss*100];
         [remoteDIArray addObject:tmpMemberModel];
    }
    
    for (RongRTCStreamStat* stat in form.recvStats) {
        ChatDataInfoModel *tmpMemberModel = [[ChatDataInfoModel alloc] init];
        tmpMemberModel.userName = @"远端";
        if ([stat.mediaType isEqualToString:RongRTCMediaTypeVideo]) {
            tmpMemberModel.tunnelName = @"视频接收";
            tmpMemberModel.frame = [NSString stringWithFormat:@"%@*%@",@(stat.frameWidth),@(stat.frameHeight)];
            tmpMemberModel.frameRate = [NSString stringWithFormat:@"%@",@(stat.frameRate)];
        } else {
            tmpMemberModel.tunnelName = @"音频接收";
            tmpMemberModel.frame = @"--";
            tmpMemberModel.frameRate = @"--";
            dispatch_async(dispatch_get_main_queue(), ^{
                NSRange range =  [stat.trackId rangeOfString:@"_"];
                if (range.location != NSNotFound) {
                    NSString* userId = [stat.trackId substringToIndex:range.location];
                    ChatCellVideoViewModel *remoteModel = [kChatManager getRemoteUserDataModelFromUserID:userId];
                    remoteModel.audioLevel = stat.audioLevel;
                }
            });
        }
        
        
        tmpMemberModel.codec = stat.codecName.length > 0 ? stat.codecName : @"--";
        tmpMemberModel.codeRate = [NSString stringWithFormat:@"%.02f",stat.bitRate];
        tmpMemberModel.lossRate = [NSString stringWithFormat:@"%.02f",stat.packetLoss*100];
        [remoteDIArray addObject:tmpMemberModel];
    }
    
    [self.bitrateArray addObject:remoteDIArray];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.chatViewController.chatViewBuilder.excelView.array = [self.bitrateArray copy];        
    });
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
