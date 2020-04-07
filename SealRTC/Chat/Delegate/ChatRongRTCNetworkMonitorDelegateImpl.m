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
#import "ChatManager.h"

@interface ChatRongRTCNetworkMonitorDelegateImpl ()

@property (nonatomic, weak) ChatViewController *chatViewController;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSNumber*>*  timesOfExceedingBaseLine;
@end


@implementation ChatRongRTCNetworkMonitorDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.chatViewController = (ChatViewController *)vc;
    }
    return self;
}

- (NSMutableDictionary<NSString*, NSNumber*>*)timesOfExceedingBaseLine {
    if (!_timesOfExceedingBaseLine) {
        _timesOfExceedingBaseLine = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    return _timesOfExceedingBaseLine;
}

#pragma mark - RongRTCActivityMonitorDelegate
- (void)didReportStatForm:(RongRTCStatisticalForm*)form {
    NSMutableArray *bitrateArray = [NSMutableArray new];
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
    
    [bitrateArray addObject:localDIArray];
    
    NSMutableArray *remoteDIArray = [NSMutableArray array];
    [remoteDIArray addObject:@[NSLocalizedString(@"chat_data_excel_userid", nil),NSLocalizedString(@"chat_data_excel_tunnelname", nil),NSLocalizedString(@"chat_data_excel_Codec", nil),NSLocalizedString(@"chat_data_excel_dpi", nil),NSLocalizedString(@"chat_data_excel_fps", nil),NSLocalizedString(@"chat_data_excel_kbps", nil),NSLocalizedString(@"chat_data_excel_lossrate", nil)]];

    for (RongRTCStreamStat* stat in form.sendStats) {
        ChatDataInfoModel *tmpMemberModel = [[ChatDataInfoModel alloc] init];
        tmpMemberModel.userName = @"本地";
        if ([stat.mediaType isEqualToString:RongRTCMediaTypeVideo]) {
            tmpMemberModel.tunnelName = @"视频发送";
            tmpMemberModel.frame = [NSString stringWithFormat:@"%@*%@",@(stat.frameWidth),@(stat.frameHeight)];
            tmpMemberModel.frameRate = [NSString stringWithFormat:@"%@",@(stat.frameRate)];
            if (kChatManager.localUserDataModel.isShowVideo) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    kChatManager.localUserDataModel.bitRate = [NSString stringWithFormat:@"%f",stat.bitRate].integerValue;
                });
            }
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
        NSString *userId = [RongRTCStatisticalForm fetchUserIdFromTrackId:stat.trackId];
        ChatCellVideoViewModel *remoteModel = [kChatManager getRemoteUserDataModelFromUserID:userId];
        tmpMemberModel.userName = remoteModel.userName;
        if ([stat.mediaType isEqualToString:RongRTCMediaTypeVideo]) {
            tmpMemberModel.tunnelName = @"视频接收";
            tmpMemberModel.frame = [NSString stringWithFormat:@"%@*%@",@(stat.frameWidth),@(stat.frameHeight)];
            tmpMemberModel.frameRate = [NSString stringWithFormat:@"%@",@(stat.frameRate)];
            if (remoteModel.isShowVideo) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    remoteModel.bitRate = [NSString stringWithFormat:@"%f",stat.bitRate].integerValue;
                });
            }
        } else {
            tmpMemberModel.tunnelName = @"音频接收";
            tmpMemberModel.frame = @"--";
            tmpMemberModel.frameRate = @"--";
            dispatch_async(dispatch_get_main_queue(), ^{
                remoteModel.audioLevel = stat.audioLevel;
            });
        }
        
        tmpMemberModel.codec = stat.codecName.length > 0 ? stat.codecName : @"--";
        tmpMemberModel.codeRate = [NSString stringWithFormat:@"%.02f",stat.bitRate];
        tmpMemberModel.lossRate = [NSString stringWithFormat:@"%.02f",stat.packetLoss*100];
        [remoteDIArray addObject:tmpMemberModel];
    }
    
    [bitrateArray addObject:remoteDIArray];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.chatViewController.chatViewBuilder.excelView.array = [bitrateArray copy];
    });
    
    
    ///  弱网提示逻辑参照   https://pha.rongcloud.net/T4688
    const CGFloat audioLossBaseline = 0.15; /// 音频丢包基准新
    const CGFloat videoLossBaseLine = 0.3;  /// 视频丢包基准线
    const NSInteger cycleLength = 10;       /// 统计周期长度
    const NSInteger timesThreshold = 5;     //// 次数阈值
    static NSInteger triggerTimes = 0;
    triggerTimes += 1;
    BOOL (^checkStatExceedBaselineOrNot)(RongRTCStreamStat*)  = ^BOOL (RongRTCStreamStat* each) {
        return ([each.mediaType isEqualToString:RongRTCMediaTypeAudio] && each.packetLoss > audioLossBaseline) ||
               ([each.mediaType isEqualToString:RongRTCMediaTypeVideo] && each.packetLoss > videoLossBaseLine);
    };
    for (RongRTCStreamStat* each in form.sendStats) {
        if (checkStatExceedBaselineOrNot(each)) {
            NSInteger lastValue = [self.timesOfExceedingBaseLine[each.trackId] integerValue];
            self.timesOfExceedingBaseLine[each.trackId] = @(lastValue + 1);
        }
    }
    
    for (RongRTCStreamStat* each in form.recvStats) {
        if (checkStatExceedBaselineOrNot(each)) {
            NSInteger lastValue = [self.timesOfExceedingBaseLine[each.trackId] integerValue];
            self.timesOfExceedingBaseLine[each.trackId] = @(lastValue + 1);
        }
    }
    
    //NSLog(@"���� %@",self.timesOfExceedingBaseLine);
    if (triggerTimes < cycleLength) {
        return;
    }
    
    triggerTimes = 0;
    NSMutableSet* uIds = [[NSMutableSet alloc] initWithCapacity:10];
    [self.timesOfExceedingBaseLine enumerateKeysAndObjectsUsingBlock:^(NSString* trackId, NSNumber* times, BOOL * _Nonnull stop) {
        NSInteger count = [times integerValue];
        if (count >= timesThreshold) {
            NSString* userId = [RongRTCStatisticalForm fetchUserIdFromTrackId:trackId];
            if (userId.length > 0) {
                [uIds addObject:userId];
            } else if ([trackId containsString:kLoginManager.userID]){
                [uIds addObject:kLoginManager.userID];
            }
        }
    }];
    [self.timesOfExceedingBaseLine removeAllObjects];
    if (uIds.count <= 0) {
        return;
    }
    
    NSMutableString* userNames = [[NSMutableString alloc] initWithCapacity:30];
    NSArray* userIds = [uIds allObjects];
    for (NSInteger i = 0; i < userIds.count;  i++) {
        NSString* uid = userIds[i];
        if ([uid isEqualToString:kLoginManager.userID]) {
            [userNames appendFormat:@"%@",kLoginManager.username];
        } else {
            ChatCellVideoViewModel *model = [kChatManager getRemoteUserDataModelFromUserID:userIds[i]];
            [userNames appendFormat:@"%@",model.userName];
        }
        if (i != userIds.count - 1) {
            [userNames appendString:@","];
        }
    }
        
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* format =  NSLocalizedString(@"voip_network_bad_fmt",nil);
        NSString* aText = [NSString stringWithFormat:format,userNames];
        [RTActiveWheel showPromptHUDAddedTo:self.chatViewController.view.window text:aText];
    });

}

#pragma mark - Private
- (NSString *)trafficString:(NSString *)recvBitrate sendBitrate:(NSString *)sendBitrate
{
    return [NSString stringWithFormat:@"%@: %@   %@: %@", NSLocalizedString(@"chat_receive", nil), recvBitrate, NSLocalizedString(@"chat_send", nil), sendBitrate];
}

@end
