//
//  MeetingManager.m
//  SealViewer
//
//  Created by LiuLinhong on 2018/08/22.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "ChatManager.h"


@interface ChatManager ()

@end


static ChatManager *sharedMeetingManager = nil;

@implementation ChatManager

+ (ChatManager *)sharedInstance
{
    static dispatch_once_t once_dispatch;
    dispatch_once(&once_dispatch, ^{
        sharedMeetingManager = [[ChatManager alloc] init];
    });
    return sharedMeetingManager;
}

- (RongRTCEngine *)rongRTCEngine
{
    return kLoginManager.rongRTCEngine;
}

- (void)clearAllDataArray
{
    _localUserDataModel = nil;
    [_allRemoteUserDataArray removeAllObjects];
    [_recentDataArray removeAllObjects];
}

#pragma mark - 全部远端用户
- (NSMutableArray *)allRemoteUserDataArray
{
    if (!_allRemoteUserDataArray)
        _allRemoteUserDataArray = [NSMutableArray array];
    
    return _allRemoteUserDataArray;
}

- (ChatCellVideoViewModel *)getRemoteUserDataModelFromIndex:(NSInteger)index
{
    ChatCellVideoViewModel *model = self.allRemoteUserDataArray[index];
    return model;
}

- (ChatCellVideoViewModel *)getRemoteUserDataModelFromStreamID:(NSString *)streamID
{
    for (ChatCellVideoViewModel *model in self.allRemoteUserDataArray)
    {
        if ([model.streamID isEqualToString:streamID])
            return model;
    }
    
    return nil;
}

- (ChatCellVideoViewModel *)getRemoteUserDataModelFromUserID:(NSString *)userID
{
    for (ChatCellVideoViewModel *model in self.allRemoteUserDataArray)
    {
        if ([model.userID isEqualToString:userID])
            return model;
    }
    return nil;
}

- (void)setRemoteModelUsername:(NSString *)userName userId:(NSString *)userId{
    if (userId.length <= 0) {
        return;
    }
    for (ChatCellVideoViewModel *model in self.allRemoteUserDataArray)
    {
        NSRange range =  [model.streamID rangeOfString:@"_" options:NSLiteralSearch];
        if (range.location != NSNotFound) {
            NSString* uid = [model.streamID substringToIndex:range.location];
            if ([uid isEqualToString:userId]) {
                model.userName = userName;
            }
        }
    }
}

- (ChatCellVideoViewModel *)getRemoteUserDataModelSimilarUserID:(NSString *)userID
{
    if (userID.length <= 0) {
        return nil;
    }
    for (ChatCellVideoViewModel *model in self.allRemoteUserDataArray)
    {
        NSRange range =  [model.streamID rangeOfString:@"_" options:NSLiteralSearch];
        if (range.location != NSNotFound) {
            NSString* uid = [model.streamID substringToIndex:range.location];
            if ([uid isEqualToString:userID]) {
                return model;
            }
        }
    }
    return nil;
}

- (NSString *)getUserIDOfRemoteUserDataModelFromIndex:(NSInteger)index
{
    ChatCellVideoViewModel *model = self.allRemoteUserDataArray[index];
    return model.streamID;
}

- (NSArray *)getAllRemoteUserIDArray
{
    NSMutableArray *userIDArray = [NSMutableArray array];
    for (ChatCellVideoViewModel *model in self.allRemoteUserDataArray)
    {
        [userIDArray addObject:model.userID];
    }
    return userIDArray;
}

- (void)addRemoteUserDataModel:(ChatCellVideoViewModel *)model
{
    [self.allRemoteUserDataArray addObject:model];
}

- (void)setRemoteUserDataModel:(ChatCellVideoViewModel *)model atIndex:(NSInteger)index
{
    [_allRemoteUserDataArray insertObject:model atIndex:index];
}

- (void)removeRemoteUserDataModelFromStreamID:(NSString *)streamID
{
    for (ChatCellVideoViewModel *model in _allRemoteUserDataArray)
    {
        if ([model.streamID isEqualToString:streamID])
        {
            [self.allRemoteUserDataArray removeObject:model];
            break;
        }
    }
}

- (void)removeRemoteUserDataModelFromIndex:(NSInteger)index
{
    [_allRemoteUserDataArray removeObjectAtIndex:index];
}

- (NSInteger)indexOfRemoteUserDataArray:(NSString *)streamID
{
    for (NSInteger i = 0; i < [self.allRemoteUserDataArray count]; i++)
    {
        ChatCellVideoViewModel *model = self.allRemoteUserDataArray[i];
        if ([model.streamID isEqualToString:streamID])
            return i;
    }
    return -1;
}

- (NSInteger)countOfRemoteUserDataArray
{
    return [self.allRemoteUserDataArray count];
}

- (BOOL)isContainRemoteUserFromStreamID:(NSString *)streamID
{
    for (ChatCellVideoViewModel *model in self.allRemoteUserDataArray)
    {
        if ([model.streamID isEqualToString:streamID])
            return YES;
    }
    return NO;
}

- (BOOL)isContainRemoteUserFromUserID:(NSString *)userId
{
    for (ChatCellVideoViewModel *model in self.allRemoteUserDataArray)
    {
        if ([model.userID isEqualToString:userId])
            return YES;
    }
    return NO;
}


#pragma mark - 最近浏览
- (NSMutableArray *)recentDataArray
{
    if (!_recentDataArray)
        _recentDataArray = [NSMutableArray array];
    
    return [_recentDataArray mutableCopy];
}

- (ChatCellVideoViewModel *)getRecentUserDataModelFromIndex:(NSInteger)index
{
    ChatCellVideoViewModel *model = _recentDataArray[index];
    return model;
}

- (ChatCellVideoViewModel *)getRecentUserDataModelFromUserID:(NSString *)userID
{
    for (ChatCellVideoViewModel *model in _recentDataArray)
    {
        if ([model.streamID isEqualToString:userID])
            return model;
    }
    
    return nil;
}

- (void)addRecentUserDataModel:(ChatCellVideoViewModel *)model
{
    [_recentDataArray addObject:model];
}

- (void)addRecentUserDic:(NSDictionary *)dic
{
    [_recentDataArray addObject:dic];
}

- (void)removeRecentUserDicFromWebId:(NSString *)webId
{
    for (NSDictionary *dic in _recentDataArray)
    {
        if ([dic objectForKey:@"data"]) {
            NSDictionary *dataDic = [dic objectForKey:@"data"];
            if ([[dataDic objectForKey:@"wbId"] isEqualToString:webId])
            {
                [_recentDataArray removeObject:dic];
                break;
            }
        }
    }
}

- (void)removeAllRecentUserDic
{
    [_recentDataArray removeAllObjects];
}

- (void)removeRecentUserDataModelFromUserID:(NSString *)userID
{
    for (ChatCellVideoViewModel *model in _recentDataArray)
    {
        if ([model.streamID isEqualToString:userID])
        {
            [_recentDataArray removeObject:model];
            break;
        }
    }
}

- (NSInteger)indexOfRecentUserDataArray:(NSString *)userID
{
    for (NSInteger i = 0; i < [_recentDataArray count]; i++)
    {
        ChatCellVideoViewModel *model = _recentDataArray[i];
        if ([model.streamID isEqualToString:userID])
            return i;
    }
    
    return -1;
}

#pragma mark - getter
- (RongRTCVideoCaptureParam *)captureParam
{
    if (!_captureParam) {
        _captureParam = [[RongRTCVideoCaptureParam alloc] init];
    }
    return _captureParam;
}

- (NSMutableArray *)observerArray
{
    if (!_observerArray) {
        _observerArray = [NSMutableArray array];
    }
    return _observerArray;
}

#pragma mark - 音视频参数
- (void)configParameter
{
    self.captureParam.tinyStreamEnable = kLoginManager.isTinyStream;
    
    switch (kLoginManager.resolutionRatioIndex) {
        case 0: //320*240
            self.captureParam.videoSizePreset = RongRTCVideoSizePreset320x240;
            break;
        case 1: //640*480
            self.captureParam.videoSizePreset = RongRTCVideoSizePreset640x480;
            break;
        case 2: //1280*720
            self.captureParam.videoSizePreset = RongRTCVideoSizePreset1280x720;
            break;
        default:
            self.captureParam.videoSizePreset = RongRTCVideoSizePreset640x480;
            break;
    }
    
    //最大码率
    NSString *codeRatePath = [[NSBundle mainBundle] pathForResource:@"CodeRate" ofType:@"plist"];
    NSArray *codeRateArray = [[NSArray alloc] initWithContentsOfFile:codeRatePath];
    NSDictionary *codeRateDictionary = codeRateArray[kLoginManager.resolutionRatioIndex];
    NSInteger max = [codeRateDictionary[@"max"] integerValue];
    NSInteger step = [codeRateDictionary[@"step"] integerValue];
    
    NSMutableArray *muArray = [NSMutableArray array];
    for (NSInteger temp = 0; temp <= max; temp += step)
        [muArray addObject:[NSString stringWithFormat:@"%zd", temp]];
    
    if ([muArray count] > kLoginManager.maxCodeRateIndex)
        self.captureParam.maxBitrate = [muArray[kLoginManager.maxCodeRateIndex] integerValue];
    
    //帧率
    switch (kLoginManager.frameRateIndex) {
        case 0:
            self.captureParam.videoFrameRate = RongRTCVideoFPS15;
            break;
        case 1:
            self.captureParam.videoFrameRate = RongRTCVideoFPS24;
            break;
        case 2:
            self.captureParam.videoFrameRate = RongRTCVideoFPS30;
            break;
        default:
            self.captureParam.videoFrameRate = RongRTCVideoFPS15;
            break;
    }
    
    //关闭摄像头
    self.captureParam.turnOnCamera = !kLoginManager.isCloseCamera;
    
    //编码方式
    switch (kLoginManager.codingStyleIndex) {
        case 0:
            self.captureParam.codecType = RongRTCCodecH264;
            break;
        case 1:
            self.captureParam.codecType = RongRTCCodecVP8;
            break;
        case 2:
            self.captureParam.codecType = RongRTCCodecVP9;
            break;
        default:
            break;
    }
}

@end
