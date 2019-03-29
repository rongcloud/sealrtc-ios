//
//  ChatCollectionViewDataSourceDelegateImpl.m
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/15.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "ChatCollectionViewDataSourceDelegateImpl.h"
#import "ChatViewController.h"
#import "CommonUtility.h"

@interface ChatCollectionViewDataSourceDelegateImpl ()
{
    NSString *originalRemoteUserID;
}

@property (nonatomic, weak) ChatViewController *chatViewController;

@end

@implementation ChatCollectionViewDataSourceDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.chatViewController = (ChatViewController *) vc;
    }
    
    return self;
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [kChatManager countOfRemoteUserDataArray];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ChatCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    if ([kChatManager countOfRemoteUserDataArray] <= indexPath.row)
        return cell;
    
    NSString *streamId = [kChatManager getUserIDOfRemoteUserDataModelFromIndex:indexPath.row];
    NSNumber *videoMute = [self.chatViewController.videoMuteForUids objectForKey:streamId];
    ChatCellVideoViewModel *model = [kChatManager getRemoteUserDataModelFromIndex:indexPath.row];
    
    if (videoMute.boolValue)
        cell.type = ChatTypeAudio;
    else
    {
        cell.type = ChatTypeVideo;
        if ([kChatManager countOfRemoteUserDataArray] <= indexPath.row)
            return cell;
        if (kLoginManager.isSwitchCamera && indexPath.row == self.chatViewController.orignalRow)
            [cell.videoView addSubview:kChatManager.localUserDataModel.cellVideoView];
        else
            [cell.videoView addSubview:model.cellVideoView];
    }
    
    cell.nameLabel.text = model.streamID;
    if (kLoginManager.isAutoTest)
        [cell refreshAutoTestLabel:!model.isSubscribeSuccess connectLabel:!model.isConnectSuccess subscribeLog:model.subscribeLog connectLog:model.connectLog];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    @synchronized (self)
    {
        NSInteger selectedRow = indexPath.row;
        ChatCellVideoViewModel *selectedViewModel = [kChatManager getRemoteUserDataModelFromIndex:selectedRow];
        ChatCell *cell = (ChatCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        NSString *bigStreamUseID = selectedViewModel.streamID;
        if (kLoginManager.isSwitchCamera) {
            if (selectedRow == self.chatViewController.orignalRow) {
                bigStreamUseID = kChatManager.localUserDataModel.streamID;
            }
        }
        
        if (kLoginManager.isSwitchCamera)
        {
            if (selectedRow == self.chatViewController.orignalRow)
            {
                //本地: 恢复在大屏上显示
                RongRTCLocalVideoView *localVideoView = (RongRTCLocalVideoView *)kChatManager.localUserDataModel.cellVideoView;
                localVideoView.fillMode = RCVideoFillModeAspect;
                localVideoView.frame = self.chatViewController.videoMainView.frame;
                [self.chatViewController.videoMainView addSubview:kChatManager.localUserDataModel.cellVideoView];
                
                //远端: 恢复显示在collection cell中
                RongRTCRemoteVideoView *remoteVideoView = (RongRTCRemoteVideoView *)selectedViewModel.cellVideoView;
                remoteVideoView.fillMode = RCVideoFillModeAspectFill;
                remoteVideoView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
                [cell.videoView addSubview:selectedViewModel.cellVideoView];
                [cell.videoView addSubview:selectedViewModel.infoLabel];
                
                [self.chatViewController.room subscribeAVStream:nil tinyStreams:@[selectedViewModel.inputStream] completion:^(BOOL isSuccess, RongRTCCode desc) {
                }];
                
                kLoginManager.isSwitchCamera = !kLoginManager.isSwitchCamera;
            }
            else
            {
                //远端: 之前切换到大屏上的远端,先切换回原collection cell上
                RongRTCRemoteVideoView *originalRemoteVideoView = (RongRTCRemoteVideoView *)self.originalSelectedViewModel.cellVideoView;
                originalRemoteVideoView.fillMode = RCVideoFillModeAspectFill;
                originalRemoteVideoView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
                [self.chatViewController.selectedChatCell.videoView addSubview:self.originalSelectedViewModel.cellVideoView];
                
                //远端: 当前点击的远端,切换到大屏
                self.originalSelectedViewModel = selectedViewModel;
                originalRemoteUserID = selectedViewModel.streamID;
                
                RongRTCRemoteVideoView *remoteVideoView = (RongRTCRemoteVideoView *)selectedViewModel.cellVideoView;
                remoteVideoView.fillMode = RCVideoFillModeAspect;
                remoteVideoView.frame = self.chatViewController.videoMainView.frame;
                [self.chatViewController.videoMainView addSubview:selectedViewModel.cellVideoView];
                
                [self.chatViewController.room subscribeAVStream:@[selectedViewModel.inputStream] tinyStreams:@[self.originalSelectedViewModel.inputStream] completion:^(BOOL isSuccess, RongRTCCode desc) {
                }];
                
                //本地: 为在cell上铺满屏,根据所选本地分辨率判断宽高比例,切换到collection cell上
                RongRTCLocalVideoView *localVideoView = (RongRTCLocalVideoView *)kChatManager.localUserDataModel.cellVideoView;
                localVideoView.fillMode = RCVideoFillModeAspectFill;
                localVideoView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
                [cell.videoView addSubview:kChatManager.localUserDataModel.cellVideoView];
            }
        }
        else
        {
            //远端: 根据远端设置的分辨率比例显示在大屏上
            self.originalSelectedViewModel = selectedViewModel;
            originalRemoteUserID = selectedViewModel.streamID;
            
            RongRTCRemoteVideoView *remoteVideoView = (RongRTCRemoteVideoView *)selectedViewModel.cellVideoView;
            remoteVideoView.fillMode = RCVideoFillModeAspect;
            remoteVideoView.frame = self.chatViewController.videoMainView.frame;
            [self.chatViewController.videoMainView addSubview:selectedViewModel.cellVideoView];
            
            [self.chatViewController.room subscribeAVStream:@[selectedViewModel.inputStream] tinyStreams:nil completion:^(BOOL isSuccess,RongRTCCode desc) {
            }];
            
            //本地: 为了在cell上铺满屏,根据所选本地分辨率判断宽高比例,切换到collection cell上
            RongRTCLocalVideoView *localVideoView = (RongRTCLocalVideoView *)kChatManager.localUserDataModel.cellVideoView;
            localVideoView.fillMode = RCVideoFillModeAspectFill;
            localVideoView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
            
            [cell.videoView addSubview:kChatManager.localUserDataModel.cellVideoView];
            
            kLoginManager.isSwitchCamera = !kLoginManager.isSwitchCamera;
        }
        
        self.chatViewController.selectedChatCell = cell;
        self.chatViewController.orignalRow = selectedRow;
    }
}



@end
