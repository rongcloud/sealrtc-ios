//
//  ChatViewController.h
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/15.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongRTCLib/RongRTCLib.h>
#import "ChatCell.h"
#import "ChatCollectionViewDataSourceDelegateImpl.h"
#import "ChatRongRTCRoomDelegateImpl.h"
#import "ChatRongRTCNetworkMonitorDelegateImpl.h"
#import "ChatViewBuilder.h"
#import "ChatCellVideoViewModel.h"
#import "ChatManager.h"
#import "ChatGPUImageHandler.h"
#import "ChatWhiteBoardHandler.h"

#define TitleHeight 78
#define redButtonBackgroundColor [UIColor colorWithRed:243.0/255.0 green:57.0/255.0 blue:58.0/255.0 alpha:1.0]


typedef enum : NSUInteger {
    AVChatModeNormal,
    AVChatModeAudio,
    AVChatModeObserver,
} AVChatMode;

@interface ChatViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *speakerControlButton;
@property (nonatomic, weak) IBOutlet UIButton *audioMuteControlButton;
@property (nonatomic, weak) IBOutlet UIView *videoControlView;
@property (nonatomic, weak) IBOutlet UIView *videoMainView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIView *statusView;
@property (nonatomic, weak) IBOutlet UILabel *talkTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *dataTrafficLabel;
@property (nonatomic, weak) IBOutlet UILabel *alertLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *homeImageView;
@property (nonatomic, strong) RongRTCLocalVideoView *localView;
@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) NSMutableArray *alertTypeArray;
@property (nonatomic, strong) NSMutableDictionary *videoMuteForUids;
@property (nonatomic, strong) NSTimer *durationTimer;
@property (nonatomic, assign) NSUInteger duration;
@property (nonatomic, assign) BOOL isHiddenStatusBar;
@property (nonatomic, assign) NSInteger orignalRow;
@property (nonatomic, strong) ChatCell *selectedChatCell;
@property (nonatomic, assign) CGFloat videoHeight, blankHeight;
@property (nonatomic, strong) ChatCollectionViewDataSourceDelegateImpl *chatCollectionViewDataSourceDelegateImpl;
@property (nonatomic, strong) ChatRongRTCRoomDelegateImpl *chatRongRTCRoomDelegateImpl;
@property (nonatomic, strong) ChatRongRTCNetworkMonitorDelegateImpl *chatRongRTCNetworkMonitorDelegateImpl;
@property (nonatomic, strong) ChatViewBuilder *chatViewBuilder;
@property (nonatomic, strong) ChatGPUImageHandler *chatGPUImageHandler;
@property (nonatomic, strong) ChatWhiteBoardHandler *chatWhiteBoardHandler;
@property (nonatomic, assign) BOOL isFinishLeave,isLandscapeLeft, isNotLeaveMeAlone;
@property (nonatomic, assign) UIDeviceOrientation deviceOrientaionBefore;
@property (nonatomic, weak) RongRTCRoom *room;
@property (nonatomic)RongRTCCode joinRoomCode;
@property (nonatomic)AVChatMode chatMode;
@property (nonatomic, weak) ChatCellVideoViewModel* selectionModel;

- (void)hideAlertLabel:(BOOL)isHidden;
- (void)selectSpeakerButtons:(BOOL)selected;
- (void)updateTalkTimeLabel;
- (void)startTalkTimer;
- (void)didClickHungUpButton;
- (void)menuItemButtonPressed:(UIButton *)sender;
- (void)didClickVideoMuteButton:(UIButton *)btn;
- (void)didClickAudioMuteButton:(UIButton *)btn;
- (void)didClickSwitchCameraButton:(UIButton *)btn;
- (void)showButtons:(BOOL)flag;
- (void)joinChannel;
- (void)subscribeRemoteResource:(NSArray<RongRTCAVInputStream *> *)streams;
- (void)unsubscribeRemoteResource:(NSArray<RongRTCAVInputStream *> *)streams;
- (void)didConnectToUser:(NSString *)userId;
- (void)receivePublishMessage;
- (void)didLeaveRoom;
@end
