//
//  ChatViewController.h
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/15.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "ChatViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SettingViewController.h"
#import "CommonUtility.h"
#import "WhiteBoardWebView.h"
#import "LoginViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "SealRTCAppDelegate.h"
#import "UICollectionView+RongRTCBgView.h"
#import <RongIMLib/RongIMLib.h>


@interface ChatViewController () <UINavigationControllerDelegate,UIAlertViewDelegate>
{
    CGFloat localVideoWidth, localVideoHeight;
    UIButton *silienceButton;
    BOOL isShowButton;
    NSTimeInterval showButtonSconds;
    NSTimeInterval defaultButtonShowTime;
    CADisplayLink *displayLink;
}

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *mainVieTopMargin;
@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *collectionViewTopMargin;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *collectionViewLeadingMargin;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *collectionViewTrailingMargin;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;
@property (nonatomic, weak) IBOutlet UIView *statuView;
@property (nonatomic, strong) IBOutlet UICollectionViewLayout *collectionViewLayout;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Info];
    self.videoMuteForUids = [NSMutableDictionary dictionary];
    self.alertTypeArray = [NSMutableArray array];
    self.videoHeight = ScreenWidth * 640.0 / 480.0;
    self.blankHeight = (ScreenHeight - self.videoHeight)/2;
    self.messageStatusBar = [[MessageStatusBar alloc] init];
    self.isFinishLeave = YES;
    self.isLandscapeLeft = NO;
    self.isNotLeaveMeAlone = NO;
    isShowButton = YES;
    showButtonSconds = 0;
    defaultButtonShowTime = 6;
    self.titleLabel.text = [NSString stringWithFormat:@"%@：%@",NSLocalizedString(@"chat_room", nil), kLoginManager.roomNumber];
    self.dataTrafficLabel.hidden = YES;
    
    //remote video collection view
    self.chatCollectionViewDataSourceDelegateImpl = [[ChatCollectionViewDataSourceDelegateImpl alloc] initWithViewController:self];
    self.collectionView.dataSource = self.chatCollectionViewDataSourceDelegateImpl;
    self.collectionView.delegate = self.chatCollectionViewDataSourceDelegateImpl;
    self.collectionView.tag = 202;
    self.collectionView.chatVC = self;
    self.collectionViewLayout = self.collectionView.collectionViewLayout;
    
    self.chatViewBuilder = [[ChatViewBuilder alloc] initWithViewController:self];
    self.chatRongRTCRoomDelegateImpl = [[ChatRongRTCRoomDelegateImpl alloc] initWithViewController:self];
    self.chatRongRTCNetworkMonitorDelegateImpl = [[ChatRongRTCNetworkMonitorDelegateImpl alloc] initWithViewController:self];
    [RongRTCEngine sharedEngine].netMonitor = self.chatRongRTCNetworkMonitorDelegateImpl;
    self.chatGPUImageHandler = [[ChatGPUImageHandler alloc] init];
    
    [self.speakerControlButton setEnabled:NO];
    [self selectSpeakerButtons:NO];
    if (kLoginManager.isCloseCamera) {
        [self switchButtonBackgroundColor:kLoginManager.isCloseCamera button:self.chatViewBuilder.openCameraButton];
        [CommonUtility setButtonImage:self.chatViewBuilder.openCameraButton imageName:@"chat_close_camera"];
        self.chatViewBuilder.switchCameraButton.enabled = NO;
    }

    [self addObserver];
    
    self.localView = [[RongRTCLocalVideoView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.localView.fillMode = RCVideoFillModeAspect;
    [self.videoMainView addSubview:self.localView];
    [[RongRTCAVCapturer sharedInstance] setVideoRender:self.localView];
    [kChatManager configParameter];
    if (kLoginManager.isGPUFilter) {
//        [RongRTCAVCapturer sharedInstance].videoDisplayBufferCallback = ^CMSampleBufferRef _Nullable(BOOL valid, CMSampleBufferRef  _Nullable sampleBuffer) {
//            CMSampleBufferRef processedSampleBuffer = [self.chatGPUImageHandler onGPUFilterSource:sampleBuffer];
//            return processedSampleBuffer;
//        };
        
        [RongRTCAVCapturer sharedInstance].videoSendBufferCallback = ^CMSampleBufferRef _Nullable(BOOL valid, CMSampleBufferRef  _Nullable sampleBuffer) {
            CMSampleBufferRef processedSampleBuffer = [self.chatGPUImageHandler onGPUFilterSource:sampleBuffer];
            return processedSampleBuffer;
        };
    }
    else {
        [RongRTCAVCapturer sharedInstance].videoDisplayBufferCallback = nil;
        [RongRTCAVCapturer sharedInstance].videoSendBufferCallback = nil;
    }

    kChatManager.localUserDataModel = nil;
    kChatManager.localUserDataModel = [[ChatCellVideoViewModel alloc] initWithView:self.localView];
    kChatManager.localUserDataModel.streamID = kLoginManager.userID;
    kChatManager.localUserDataModel.originalSize = CGSizeMake(localVideoWidth, localVideoHeight);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.chatViewBuilder.chatViewController = self;
    
    SealRTCAppDelegate *appDelegate = (SealRTCAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.isForceLandscape = YES;
    self.isLandscapeLeft = YES;
    [appDelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
    _deviceOrientaionBefore = UIDeviceOrientationPortrait;
    
    self.isHiddenStatusBar = NO;
    [self dismissButtons:YES];
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    switch (deviceOrientation)
    {
        case UIDeviceOrientationLandscapeLeft:
            if ([[UIDevice currentDevice]respondsToSelector:@selector(setOrientation:)])
            {
                NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIDeviceOrientationLandscapeLeft];
                [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
            }
            break;
        case UIDeviceOrientationLandscapeRight:
            if ([[UIDevice currentDevice]respondsToSelector:@selector(setOrientation:)])
            {
                NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIDeviceOrientationLandscapeRight];
                [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
            }
            break;
        default:
            break;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self joinChannel];
    
    if ([self isHeadsetPluggedIn])
        [self reloadSpeakerRoute:NO];
}

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAudioRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)handleAudioRouteChange:(NSNotification*)notification
{
    NSInteger reason = [[[notification userInfo] objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (reason)
    {
        case AVAudioSessionRouteChangeReasonUnknown:
            break;
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable : //1
            [self reloadSpeakerRoute:NO];
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable : //2
            [self reloadSpeakerRoute:YES];
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange : //3
            break;
        case AVAudioSessionRouteChangeReasonOverride : //4
        {
            if ([self isHeadsetPluggedIn])
                [self reloadSpeakerRoute:NO];
        }
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep : //6
            break;
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory : //7
            break;
        case AVAudioSessionRouteChangeReasonRouteConfigurationChange : //8
            break;
        default:
            break;
    }
}

- (void)dealloc
{
    self.collectionView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)reloadSpeakerRoute:(BOOL)enable
{
    kLoginManager.isSpeaker = !enable;
    [self switchButtonBackgroundColor:kLoginManager.isSpeaker button:self.chatViewBuilder.speakerOnOffButton];
    
    if (enable)
        [CommonUtility setButtonImage:self.chatViewBuilder.speakerOnOffButton imageName:@"chat_speaker_on"];
    else
        [CommonUtility setButtonImage:self.chatViewBuilder.speakerOnOffButton imageName:@"chat_speaker_off"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.messageStatusBar hideManual];
    [displayLink invalidate];
    displayLink = nil;
    self.collectionView.chatVC = nil;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];

    SealRTCAppDelegate *appDelegate = (SealRTCAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.isForceLandscape = NO;
    appDelegate.isForcePortrait = YES;
    
    _chatCollectionViewDataSourceDelegateImpl = nil;
    _chatViewBuilder = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - status bar
- (BOOL)prefersStatusBarHidden
{
    return _isHiddenStatusBar;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)setIsHiddenStatusBar:(BOOL)isHiddenStatusBar
{
    _isHiddenStatusBar = isHiddenStatusBar;
    NSInteger version = [[[UIDevice currentDevice] systemVersion] integerValue];
    if (version == 11) {
        if (isHiddenStatusBar && ![self isiPhoneX]) {
            _mainVieTopMargin.constant = 20.0;
            [self setNeedsStatusBarAppearanceUpdate];
        }else if (![self isiPhoneX]) {
            _mainVieTopMargin.constant = 0.0;
            [self setNeedsStatusBarAppearanceUpdate];
        }
    }else{
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (BOOL)isiPhoneX
{
    if ([[CommonUtility getdeviceName] isEqualToString:@"iPhone X"]) {
        return YES;
    }
    return NO;
}

#pragma mark - config UI
- (void)dismissButtons:(BOOL)flag
{
    if (isShowButton) {
        displayLink.paused = NO;
    }
}

- (void)showButtons:(BOOL)flag
{
    isShowButton = !flag;
    
    self.chatViewBuilder.upMenuView.hidden = flag;
    self.chatViewBuilder.hungUpButton.hidden = flag;
    self.dataTrafficLabel.hidden = YES;
    self.talkTimeLabel.hidden = flag;
    self.titleLabel.hidden = flag;
    self.chatViewBuilder.openCameraButton.hidden = flag;
    self.chatViewBuilder.microphoneOnOffButton.hidden = flag;
    
    if (!isShowButton) {
        if (_deviceOrientaionBefore == UIDeviceOrientationPortrait) {
            _collectionViewTopMargin.constant = -40;
        }
    }else{
        if (_deviceOrientaionBefore == UIDeviceOrientationPortrait) {
            _collectionViewTopMargin.constant = 0;
        }
    }

    self.isHiddenStatusBar = flag;
}

#pragma mark - touch event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    showButtonSconds = 0;
    [self showButtons:isShowButton];
    if (isShowButton) {
        displayLink.paused = NO;
    }
}

#pragma mark - CollectionViewTouchesDelegate
- (void)didTouchedBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event withBlock:(void (^)(void))block
{
    UITouch *touch = [touches anyObject];
    if (CGRectContainsPoint(self.collectionView.frame, [touch locationInView:self.collectionView]))
    {
        CGPoint point = [touch locationInView:self.collectionView];
        NSInteger count = [kChatManager countOfRemoteUserDataArray];
        if (count * 60 < ScreenWidth && point.x > count * 60)
        {
            showButtonSconds = 0;
            [self showButtons:isShowButton];
            if (isShowButton)
                displayLink.paused = NO;
            
            return;
        }
    }
    
    block();
}


-(void)joinChannel{
    [[RongRTCEngine sharedEngine] joinRoom:kLoginManager.roomNumber completion:^(RongRTCRoom * _Nullable room, RongRTCCode code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlertLabelWithString:NSLocalizedString(@"chat_wait_attendees", nil)];
            self.room = room;
            self.joinRoomCode = code;
            if (kLoginManager.isObserver) {
                self.chatMode = AVChatModeObserver;
                [self joinChannelImpl];
            }
            else if (room.remoteUsers.count >= MAX_NORMAL_PERSONS && room.remoteUsers.count < MAX_AUDIO_PERSONS) {
                NSString * msg = [NSString stringWithFormat:@"会议室中视频通话人数已超过 %d 人，你将以音频模式加入会议室。",MAX_NORMAL_PERSONS];
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                al.tag = 1110;
                [al show];
            }
            else if (room.remoteUsers.count >= MAX_AUDIO_PERSONS){
                NSString * msg = [NSString stringWithFormat:@"会议室中人数已超过 %d 人，你将以旁听者模式加入会议室。",MAX_AUDIO_PERSONS];
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                al.tag = 1111;
                [al show];
            }
            else{
                self.chatMode = AVChatModeNormal;
                [self joinChannelImpl];
            }
        });
    }];
}

#pragma mark - alertView delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        // 用户点击确定
        AVChatMode mode = AVChatModeAudio;
        if (alertView.tag == 1111) {
            mode = AVChatModeObserver;
        }
        self.chatMode = mode;
        [self joinChannelImpl];
    }
    else{
        [[RongRTCEngine sharedEngine] leaveRoom:kLoginManager.roomNumber completion:^(BOOL isSuccess, RongRTCCode code) {}];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - join channel
- (void)joinChannelImpl
{
    [[RongRTCAVCapturer sharedInstance] setCaptureParam:kChatManager.captureParam];
    FwLogI(RC_Type_RTC,@"A-joinChannelImpl-T",@"joinChannelImpl chatMode %@",@(self.chatMode));
    if (self.chatMode == AVChatModeObserver || self.chatMode == AVChatModeAudio) {
        kChatManager.captureParam.turnOnCamera = NO;
        if (self.chatMode == AVChatModeAudio) {
            [[RongRTCAVCapturer sharedInstance] setCameraDisable:YES];
        }
        self.chatViewBuilder.openCameraButton.enabled = NO;
        self.chatViewBuilder.switchCameraButton.enabled = NO;
        self.localView.hidden = YES;
        if (self.chatMode == AVChatModeObserver) {
            self.chatViewBuilder.microphoneOnOffButton.enabled = NO;
        }
        [[RongRTCAVCapturer sharedInstance] useSpeaker:YES];
    }
    else{
        [[RongRTCAVCapturer sharedInstance] startCapture];
    }
    
    self.room.delegate = self.chatRongRTCRoomDelegateImpl;
    RongRTCCode code = self.joinRoomCode;
    FwLogI(RC_Type_RTC,@"A-appReceiveUserJoin-T",@"joinRoom  %@",@(code));
    if (code == RongRTCCodeSuccess ) {
        DLog(@"joinRoom code Success");
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        if (self.chatMode == AVChatModeAudio || self.chatMode == AVChatModeNormal) {
            [self publishLocalResource];
        }
        if (self.room.remoteUsers.count > 0) {
            NSMutableArray *arr = [NSMutableArray array];
            for (RongRTCRemoteUser *user in self.room.remoteUsers) {
                for (RongRTCAVInputStream *stream in user.remoteAVStreams) {
                    [arr addObject:stream];
                }
            }
            FwLogI(RC_Type_RTC,@"A-appReceiveUserJoin-T",@"joinRoom success hideAlertLabel YES");
            [self hideAlertLabel:YES];
            [self startTalkTimer];
            
            if (kLoginManager.isAutoTest) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 自动化使用
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 100) / 2, [UIScreen mainScreen].bounds.size.height - 100, 100, 40)];
                    label.center = CGPointMake(self.localView.center.x, self.localView.center.y+220);
                    [label setFont:[UIFont systemFontOfSize:13]];
                    [label setTextAlignment:NSTextAlignmentCenter];
                    [label setTextColor:[UIColor greenColor]];
                    [label setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.15]];
                    [label setText:@"房间中有流了"];
                    [self.view addSubview:label];
                });
            }
            
            [self subscribeRemoteResource:arr];
        }
        else {
            DLog(@"joinRoom room.remoteUsers.count < 0");
        }
    }
    else {
        DLog(@"joinRoom code Failed, code: %zd", code);
        if (kLoginManager.isAutoTest) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"加入房间失败:%ld",code] preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    [self didClickHungUpButton];
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:^{
                    
                }];
            });
        }
    }
}

- (void)didLeaveRoom {
    if (kLoginManager.isAutoTest) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"已经不在房间中了"] preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                [self didClickHungUpButton];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:^{
                
            }];
        });
    }
}

- (void)publishLocalResource {
    DLog(@"start publishLocalResource");
    [self.room publishDefaultAVStream:^(BOOL isSuccess,RongRTCCode desc) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                DLog(@"publishLocalResource Success");
                if (kLoginManager.isAutoTest) {
                    // 自动化使用
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
                    label.center = CGPointMake(self.localView.center.x, self.localView.center.y+180);
                    [label setText:@"发布成功"];
                    [label setFont:[UIFont systemFontOfSize:13]];
                    [label setTextAlignment:NSTextAlignmentCenter];
                    [label setTextColor:[UIColor greenColor]];
                    [label setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.15]];
                    [self.videoMainView addSubview:label];
                }
            }
            else {
                DLog(@"publishLocalResource Failed,  Desc: %@", @(desc));
                if (kLoginManager.isAutoTest) {
                    // 自动化使用
                    UILabel *failedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220, 40)];
                    failedLabel.center = CGPointMake(self.localView.center.x, self.localView.center.y + 180);
                    [failedLabel setText:[NSString stringWithFormat:@"发布失败:%@",@(desc)]];
                    [failedLabel setFont:[UIFont systemFontOfSize:13]];
                    [failedLabel setTextAlignment:NSTextAlignmentCenter];
                    [failedLabel setTextColor:[UIColor redColor]];
                    [failedLabel setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.15]];
                    [self.videoMainView addSubview:failedLabel];
                }
            }
        });
    }];
}

// 自动化使用
- (void)receivePublishMessage {
    if (kLoginManager.isAutoTest) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 自动化使用
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 100) / 2, [UIScreen mainScreen].bounds.size.height - 100, 100, 40)];
            label.center = CGPointMake(self.localView.center.x, self.localView.center.y+260);
            [label setText:@"有人发流了"];
            [label setFont:[UIFont systemFontOfSize:13]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setTextColor:[UIColor greenColor]];
            [label setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.15]];
            [self.view addSubview:label];
        });
    }
}

- (void)subscribeRemoteResource:(NSArray<RongRTCAVInputStream *> *)streams
{
    NSMutableArray *subscribes = [NSMutableArray new];
    for (RongRTCAVInputStream *stream in streams) {
        NSString *streamID = stream.streamId;
        [subscribes addObject:stream];
        DLog(@"Subscribe streamID: %@   mediaType: %zd", stream.streamId, stream.streamType);

        ChatCellVideoViewModel *model = [kChatManager getRemoteUserDataModelFromUserID:streamID];
        if (stream.streamType == RTCMediaTypeVideo) {
            if (![kChatManager isContainRemoteUserFromUserID:streamID] || model.cellVideoView == nil) {
                RongRTCRemoteVideoView *view = [[RongRTCRemoteVideoView alloc] initWithFrame:CGRectMake(0, 0, 90, 120)];
                view.fillMode = RCVideoFillModeAspectFill;
                [stream setVideoRender:view];
                
                ChatCellVideoViewModel *chatCellVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:view];
                chatCellVideoViewModel.streamID = streamID;
                chatCellVideoViewModel.everOnLocalView = 0;
                chatCellVideoViewModel.isShowVideo = NO;
                chatCellVideoViewModel.inputStream = stream;
                [kChatManager addRemoteUserDataModel:chatCellVideoViewModel];
                DLog(@"Subscribe remote user count: %zd", [kChatManager countOfRemoteUserDataArray]);
                
                NSInteger row = [kChatManager countOfRemoteUserDataArray]-1;
                NSIndexPath *tempPath = [NSIndexPath indexPathForRow:row inSection:0];
                [self.collectionView insertItemsAtIndexPaths:@[tempPath]];
                FwLogI(RC_Type_RTC,@"A-appSetRender-T",@"%@appSetRender dont contanin user",@"sealRTCApp:");
            }
            else {
                FwLogI(RC_Type_RTC,@"A-appSetRender-T",@"%@appSetRender and contain render",@"sealRTCApp:");
                ChatCellVideoViewModel *model = [kChatManager getRemoteUserDataModelFromUserID:streamID];
                [stream setVideoRender:(RongRTCRemoteVideoView *)model.cellVideoView];
            }
        }
    }
    
    for (RongRTCAVInputStream *stream in streams) {
        if (![kChatManager isContainRemoteUserFromUserID:stream.streamId] &&
            stream.streamType == RTCMediaTypeAudio) {
            ChatCellVideoViewModel *chatCellVideoViewModel = [[ChatCellVideoViewModel alloc] initWithView:nil];
            chatCellVideoViewModel.streamID = stream.streamId;
            chatCellVideoViewModel.everOnLocalView = 0;
            chatCellVideoViewModel.isShowVideo = NO;
            chatCellVideoViewModel.inputStream = stream;
            [kChatManager addRemoteUserDataModel:chatCellVideoViewModel];
            
            NSInteger row = [kChatManager countOfRemoteUserDataArray]-1;
            NSIndexPath *tempPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.collectionView insertItemsAtIndexPaths:@[tempPath]];
        }

    }

    
    DLog(@"start subscribeRemoteResource");
    FwLogI(RC_Type_RTC,@"A-appSubscribeStream-T",@"%@app to  subscribe streams count : %ld",@"sealRTCApp:",subscribes.count);
    if (subscribes.count > 0) {
        FwLogI(RC_Type_RTC,@"A-appSubscribeStream-T",@"%@all subscribe streams",@"sealRTCApp:");
        [self.room subscribeAVStream:nil tinyStreams:subscribes completion:^(BOOL isSuccess, RongRTCCode desc) {
            for (RongRTCAVInputStream *inStream in subscribes) {
                if (inStream.streamType != RTCMediaTypeVideo) {
                    continue;
                }
                
                NSString *sid = inStream.streamId;
                if (isSuccess) {
                    FwLogI(RC_Type_RTC,@"A-appSubscribeStream-T",@"%@all subscribe streams success",@"sealRTCApp:");
                    DLog(@"subscribeAVStream Success");
                    if (kLoginManager.isAutoTest) {
                        // 自动化使用
                        dispatch_async(dispatch_get_main_queue(), ^{
                            ChatCellVideoViewModel *chatCellVideoViewModel = [kChatManager getRemoteUserDataModelFromUserID:sid];
                            chatCellVideoViewModel.isSubscribeSuccess = YES;
                            chatCellVideoViewModel.subscribeLog = @"订阅成功了";
                            NSInteger index = [kChatManager indexOfRemoteUserDataArray:sid];
                            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                            DLog(@"LLH.....subscribeAVStream success");
                            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                        });
                    }
                }
                else {
                    FwLogI(RC_Type_RTC,@"A-appSubscribeStream-T",@"%@all subscribe streams error",@"sealRTCApp:");
                    DLog(@"subscribeAVStream Failed, Desc: %@", @(desc));
                    if (kLoginManager.isAutoTest) {
                        // 自动化使用
                        dispatch_async(dispatch_get_main_queue(), ^{
                            ChatCellVideoViewModel *chatCellVideoViewModel = [kChatManager getRemoteUserDataModelFromUserID:sid];
                            chatCellVideoViewModel.isSubscribeSuccess = NO;
                            chatCellVideoViewModel.subscribeLog = [@"" stringByAppendingFormat:@"%ld",desc];
                            NSInteger index =[kChatManager indexOfRemoteUserDataArray:sid];
                            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                            DLog(@"LLH.....subscribeAVStream fail: %zd", index);
                            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                        });
                    }
                }
            }
        }];
    }
}

- (void)didConnectToUser:(NSString *)userId {
    FwLogI(RC_Type_RTC,@"A-appConnectToStream-T",@"%@appConnectTostream collectionview to render",@"sealRTCApp:");
    if (kLoginManager.isAutoTest) {
        // 自动化使用
        dispatch_async(dispatch_get_main_queue(), ^{
            ChatCellVideoViewModel *chatCellVideoViewModel = [kChatManager getRemoteUserDataModelFromUserID:userId];
            chatCellVideoViewModel.isConnectSuccess = YES;
            chatCellVideoViewModel.connectLog = @"流通了";
            NSInteger index =[kChatManager indexOfRemoteUserDataArray:userId];
            DLog(@"LLH...... didConnectToUser index: %zd", index);
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        });
    }
}

- (void)unsubscribeRemoteResource:(NSArray<RongRTCAVInputStream *> *)streams
{
    for (RongRTCAVInputStream *stream in streams) {
        DLog(@"Unsubscribe streamID: %@   mediaType: %zd", stream.streamId, stream.streamType);
    }
    
    [self.room unsubscribeAVStream:streams completion:^(BOOL isSuccess,RongRTCCode desc) {
    }];
}

#pragma mark - show alert label
- (void)showAlertLabelWithString:(NSString *)text;
{
    self.alertLabel.hidden = NO;
    self.alertLabel.text = text;
}

#pragma mark - hide alert label
- (void)hideAlertLabel:(BOOL)isHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.alertLabel.hidden = isHidden;
    });
}

#pragma mark - update Time/Traffic by timer
- (void)updateTalkTimeLabel
{
    self.duration++;
    NSUInteger hour = self.duration / 3600;
    NSUInteger minutes = (self.duration - 3600 * hour) / 60;
    NSUInteger seconds = (self.duration - 3600 * hour - 60 * minutes) % 60;
    
    if (hour > 0)
        self.talkTimeLabel.text = [NSString stringWithFormat:@"%01ld:%02ld:%02ld", (unsigned long)hour, (unsigned long)minutes, (unsigned long)seconds];
    else
        self.talkTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (unsigned long)minutes, (unsigned long)seconds];
}

- (void)startTalkTimer
{
    if (self.duration == 0 && !self.durationTimer)
    {
        self.talkTimeLabel.text = @"00:00";
        self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTalkTimeLabel) userInfo:nil repeats:YES];

        if (kLoginManager.isAutoTest) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 自动化使用
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 100) / 2, [UIScreen mainScreen].bounds.size.height - 250, 100, 40)];
                label.center = CGPointMake(self.localView.center.x+100, self.localView.center.y+220);
                [label setText:@"有人来了"];
                [label setFont:[UIFont systemFontOfSize:13]];
                [label setTextAlignment:NSTextAlignmentCenter];
                [label setTextColor:[UIColor greenColor]];
                [label setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.15]];
                [self.view addSubview:label];
            });
        }
    }
}

#pragma mark - click memu item button
- (void)menuItemButtonPressed:(UIButton *)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger tag = button.tag;
    
    switch (tag)
    {
        case 0: //switch camera
            [self didClickSwitchCameraButton:button];
            break;
        case 1: //mute speaker
            [self didClickSpeakerButton:button];
            break;
        default:
            break;
    }
}

#pragma mark - click mute micphone
- (void)didClickAudioMuteButton:(UIButton *)btn
{
    kLoginManager.isMuteMicrophone = !kLoginManager.isMuteMicrophone;
    [[RongRTCAVCapturer sharedInstance] setMicrophoneDisable:kLoginManager.isMuteMicrophone];
    [self switchButtonBackgroundColor:kLoginManager.isMuteMicrophone button:btn];

    if (kLoginManager.isMuteMicrophone) {
        [CommonUtility setButtonImage:btn imageName:@"chat_microphone_off"];
    } else {
        [CommonUtility setButtonImage:btn imageName:@"chat_microphone_on"];
    }
}

#pragma mark - click mute speaker
- (void)didClickSpeakerButton:(UIButton *)btn
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        kLoginManager.isSpeaker = !kLoginManager.isSpeaker;
        [[RongRTCAVCapturer sharedInstance] useSpeaker:kLoginManager.isSpeaker];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self switchButtonBackgroundColor:!kLoginManager.isSpeaker button:btn];
            
            if (kLoginManager.isSpeaker) {
                [CommonUtility setButtonImage:btn imageName:@"chat_speaker_on"];
            } else {
                [CommonUtility setButtonImage:btn imageName:@"chat_speaker_off"];
            }
        });
    });
}

#pragma mark - click local video
- (void)didClickVideoMuteButton:(UIButton *)btn
{
    kLoginManager.isCloseCamera = !kLoginManager.isCloseCamera;
    [[RongRTCAVCapturer sharedInstance] setCameraDisable:kLoginManager.isCloseCamera];
    [self switchButtonBackgroundColor:kLoginManager.isCloseCamera button:btn];
    
    if (kLoginManager.isCloseCamera) {
        [CommonUtility setButtonImage:btn imageName:@"chat_close_camera"];
        self.chatViewBuilder.switchCameraButton.enabled = NO;
    } else {
        [CommonUtility setButtonImage:btn imageName:@"chat_open_camera"];
        self.chatViewBuilder.switchCameraButton.enabled = YES;
    }
}

#pragma mark - click switch camera
- (void)didClickSwitchCameraButton:(UIButton *)btn
{
    kLoginManager.isBackCamera = !kLoginManager.isBackCamera;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[RongRTCAVCapturer sharedInstance] switchCamera];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self switchButtonBackgroundColor:kLoginManager.isBackCamera button:btn];
        });
    });
}

#pragma mark - click hungup button
- (void)didClickHungUpButton
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[RongRTCAVCapturer sharedInstance] stopCapture];
        [[RongRTCEngine sharedEngine] leaveRoom:kLoginManager.roomNumber completion:^(BOOL isSuccess, NSInteger code) {
            self.room = nil;
            if (isSuccess) {
                DLog(@"leaveRoom Success");
            }else {
                DLog(@"leaveRoom Failed, code: %zd", code);
            }
        }];
        
        self.isFinishLeave = YES;
        [self.durationTimer invalidate];
        self.talkTimeLabel.text = @"";
        self.localView.hidden = NO;
        [self.localView removeFromSuperview];
        
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        SealRTCAppDelegate *appDelegate = (SealRTCAppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.isForceLandscape = NO;
        
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        
        [kChatManager.localUserDataModel removeKeyPathObservers];
        
        [kChatManager.localUserDataModel.cellVideoView removeFromSuperview];
        kChatManager.localUserDataModel = nil;
        kLoginManager.isCloseCamera = NO;
        kLoginManager.isMuteMicrophone = NO;
        kLoginManager.isSwitchCamera = NO;
        kLoginManager.isBackCamera = NO;
        [kChatManager clearAllDataArray];
        [self.collectionView reloadData];
        [self.collectionView removeFromSuperview];
        self.collectionView = nil;
        [self.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark - switch menu button color
- (void)switchButtonBackgroundColor:(BOOL)is button:(UIButton *)btn
{
    dispatch_async(dispatch_get_main_queue(), ^{
        btn.backgroundColor = is ? [UIColor whiteColor] : [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.4f];
    });
}

#pragma mark - Speaker/Audio/Video button selected
- (void)selectSpeakerButtons:(BOOL)selected
{
    _speakerControlButton.selected = selected;
}

- (void)selectAudioMuteButtons:(BOOL)selected
{
    _audioMuteControlButton.selected = selected;
}

- (BOOL)isHeadsetPluggedIn
{
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs])
    {
        NSString *outputer = desc.portType;
        if ([outputer isEqualToString:AVAudioSessionPortHeadphones] || [outputer isEqualToString:AVAudioSessionPortBluetoothLE] || [outputer isEqualToString:AVAudioSessionPortBluetoothHFP] || [outputer isEqualToString:AVAudioSessionPortBluetoothA2DP])
            return YES;
    }
    return NO;
}

#pragma mark - AlertController
- (void)alertWith:(NSString *)title withMessage:(NSString *)msg withOKAction:(nullable  UIAlertAction *)ok withCancleAction:(nullable UIAlertAction *)cancel
{
    self.alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    if (cancel)
        [self.alertController addAction:cancel];
    if (!ok){
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_confirm", nil) style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [self.alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [self.alertController addAction:ok];
    }else{
        [self.alertController addAction:ok];
    }
    [self presentViewController:self.alertController animated:YES completion:^{}];
}

@end
