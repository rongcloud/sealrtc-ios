//
//  ChatViewController.h
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/15.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "ChatViewController.h"

#import <ReplayKit/ReplayKit.h>
#import <AVFoundation/AVFoundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <RongIMLib/RongIMLib.h>
#import <RongRTCLib/RongRTCLib.h>

#import "UIView+Toast.h"
#import "SettingViewController.h"
#import "CommonUtility.h"
#import "LoginViewController.h"
#import "SealRTCAppDelegate.h"
#import "UICollectionView+RongRTCBgView.h"
#import "STParticipantsTableViewController.h"
#import "STPresentationViewController.h"
#import "STParticipantsInfo.h"
#import "STSetRoomInfoMessage.h"
#import "STDeleteRoomInfoMessage.h"
#import "STKickOffInfoMessage.h"
#import "RTActiveWheel.h"
#import "RCRTCFileSource.h"
#import "RTHttpNetworkWorker.h"
#import "RongAudioVolumeControl.h"
#import "STAudioMixingPannelController.h"
#import "STAudioMixerConfiguration.h"
#import "UIScrollView+Responder.h"

#import "RCRTCVideoCaptureParam.h"
#import "ZHPickView.h"
@interface ChatViewController () <UINavigationControllerDelegate, UIAlertViewDelegate, RCRTCFileCapturerDelegate, RCConnectionStatusChangeDelegate, RongAudioVolumeControlDelegate, UIScrollViewDelegate, ZHPickViewDelegate, UIGestureRecognizerDelegate>


{
    CGFloat localVideoWidth, localVideoHeight;
    UIButton *silienceButton;
    BOOL isShowButton, isChatCloseCamera;
    NSTimeInterval showButtonSconds;
    NSTimeInterval defaultButtonShowTime;
    CADisplayLink *displayLink;
    RCRTCFileSource *fileCapturer;
    RCRTCVideoOutputStream *videoOutputStream;
    BOOL isStartPublishAudio;
    BOOL isShowController;
    BOOL isShowVolumeControl;
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
@property (nonatomic, strong) NSMutableArray<STParticipantsInfo *> *dataSource;
@property (nonatomic, strong) RCRTCLocalVideoView *localFileVideoView;
@property (nonatomic, weak) IBOutlet UILabel *connectingLabel;
@property (nonatomic, strong) UIButton *audioControl;
@property (nonatomic, strong) RongAudioVolumeControl *controller;
@property (nonatomic, strong) UIButton *audioBubbleButton;
@property (nonatomic, strong) STParticipantsTableViewController *participantsTableViewController;
@property (nonatomic, strong) UIView *beauView;
@property (nonatomic, assign) BOOL isBeau;
@property (nonatomic, strong) STAudioMixerConfiguration *audioMixerConfig;
@property (nonatomic, strong) UIView *focusView;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

/**
 分辨率 view
 */
@property (nonatomic, strong) ZHPickView *resolutionPickView;

/**
 分辨率映射
 */
/**
 beauBtn
 */
@property (nonatomic, strong) UIButton *beauBtn;
@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.videoMuteForUids = [NSMutableDictionary dictionary];
    self.alertTypeArray = [NSMutableArray array];
    self.videoHeight = ScreenWidth * 640.0 / 480.0;
    self.blankHeight = (ScreenHeight - self.videoHeight) / 2;
    self.isFinishLeave = YES;
    self.isLandscapeLeft = NO;
    self.isNotLeaveMeAlone = NO;
    isChatCloseCamera = kLoginManager.isCloseCamera;
    isShowButton = YES;
    showButtonSconds = 0;
    defaultButtonShowTime = 6;
    self.titleLabel.text = [NSString stringWithFormat:@"%@：%@",
                            NSLocalizedString(@"chat_room", nil), kLoginManager.roomNumber];
    self.dataTrafficLabel.hidden = YES;
    
    //remote video collection view
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.chatCollectionViewDataSourceDelegateImpl =
    [[ChatCollectionViewDataSourceDelegateImpl alloc] initWithViewController:self];
    self.collectionView.dataSource = self.chatCollectionViewDataSourceDelegateImpl;
    self.collectionView.delegate = self.chatCollectionViewDataSourceDelegateImpl;
    self.collectionView.tag = 202;
    self.collectionView.chatVC = self;
    self.collectionViewLayout = self.collectionView.collectionViewLayout;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.frame = (CGRect) { 0, 60, screenSize.width, 120 };
    if (@available(iOS 11.0, *)) {
        if (UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom > 0.0) {
            self.collectionView.frame = (CGRect) { 0, 94, screenSize.width, 120 };
        }
    }
    
    self.chatViewBuilder = [[ChatViewBuilder alloc] initWithViewController:self];
    self.chatRongRTCRoomDelegateImpl = [[ChatRongRTCRoomDelegateImpl alloc] initWithViewController:self];
    self.chatRongRTCNetworkMonitorDelegateImpl = [[ChatRongRTCNetworkMonitorDelegateImpl alloc] initWithViewController:self];
    
    if (kLoginManager.isOpenAudioCrypto) {
        [[RCRTCEngine sharedInstance] setAudioCustomizedEncryptorDelegate:kChatManager.chatRongAudioRTCEncryptorDelegateImpl];
        [[RCRTCEngine sharedInstance] setAudioCustomizedDecryptorDelegate:kChatManager.chatRongAudioRTCDecryptorDelegateImpl];
    } else {
        [[RCRTCEngine sharedInstance] setAudioCustomizedEncryptorDelegate:nil];
        [[RCRTCEngine sharedInstance] setAudioCustomizedDecryptorDelegate:nil];
    }
    
    if (kLoginManager.isOpenVideoCrypto) {
        [[RCRTCEngine sharedInstance] setVideoCustomizedEncryptorDelegate:kChatManager.chatRongVideoRTCEncryptorDelegateImpl];
        [[RCRTCEngine sharedInstance] setVideoCustomizedDecryptorDelegate:kChatManager.chatRongVideoRTCDecryptorDelegateImpl];
    } else {
        [[RCRTCEngine sharedInstance] setVideoCustomizedEncryptorDelegate:nil];
        [[RCRTCEngine sharedInstance] setVideoCustomizedDecryptorDelegate:nil];
    }
    
    
#ifdef IS_PRIVATE_ENVIRONMENT
    if (kLoginManager.isPrivateEnvironment) {
        if (kLoginManager.privateMediaServer && kLoginManager.privateMediaServer.length > 0) {
            NSLog(@"private mediaserver : %@", kLoginManager.privateMediaServer);
            [[RCRTCEngine sharedInstance] setMediaServerUrl:kLoginManager.privateMediaServer];
        } else {
            [[RCRTCEngine sharedInstance] setMediaServerUrl:@""];
        }
    }
#endif
    
    [self.speakerControlButton setEnabled:NO];
    [self selectSpeakerButtons:NO];
    [self addObserver];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [scrollView setContentSize:CGSizeMake(ScreenWidth, ScreenHeight)];
    scrollView.maximumZoomScale = 4.0;
    scrollView.minimumZoomScale = 1.0;
    scrollView.delegate = self;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.alwaysBounceVertical = NO;
    scrollView.contentInset = UIEdgeInsetsZero;
    //    scrollView.bounces = NO;
    self.scrollView = scrollView;
    
    self.localView = [[RCRTCLocalVideoView alloc] initWithFrame:self.scrollView.bounds];
    self.localView.frameAnimated = NO;
    self.localView.fillMode = RCRTCVideoFillModeAspect;
    if (kLoginManager.isVideoMirror) {
        self.localView.isPreviewMirror = NO;
    } else {
        self.localView.isPreviewMirror = YES;
    }
    
    self.localView.userInteractionEnabled = YES;
    self.zoomView = self.localView;
    [scrollView addSubview:self.localView];
    [self.videoMainView addSubview:scrollView];
    
    [kChatManager configAudioParameter];
    [kChatManager configVideoParameter];
    
    [[RCRTCEngine sharedInstance].defaultAudioStream setMicrophoneDisable:kLoginManager.isMuteMicrophone];
    
    if (kLoginManager.isObserver) {
        self.chatMode = AVChatModeObserver;
    } else if (kLoginManager.isCloseCamera) {
        self.chatMode = AVChatModeAudio;
    } else {
        self.chatMode = AVChatModeNormal;
    }
    
    if (self.chatMode == AVChatModeNormal) {
        [[RCRTCEngine sharedInstance].defaultVideoStream setVideoView:self.localView];
        
        [self setCaptureParam];
#ifdef IS_LIVE
        if (kLoginManager.isHost) {
            [[RCRTCEngine sharedInstance].defaultVideoStream startCapture];
        }
#else
        [[RCRTCEngine sharedInstance].defaultVideoStream startCapture];
        
#endif
        
        self.chatGPUImageHandler = [[ChatGPUImageHandler alloc] init];
        __weak typeof(self) weakSelf = self;
        [RCRTCEngine sharedInstance].defaultVideoStream.videoSendBufferCallback =
            ^CMSampleBufferRef _Nullable(BOOL valid, CMSampleBufferRef  _Nullable sampleBuffer) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return sampleBuffer;
            }
            CMSampleBufferRef processedSampleBuffer = [strongSelf.chatGPUImageHandler onGPUFilterSource:sampleBuffer];
            if (!processedSampleBuffer) {
                return sampleBuffer;
            }
            return processedSampleBuffer;
        };
    }
    
    kChatManager.localUserDataModel = nil;
    kChatManager.localUserDataModel = [[ChatCellVideoViewModel alloc] initWithView:self.localView];
    kChatManager.localUserDataModel.streamID = kLoginManager.userID;
    kChatManager.localUserDataModel.userID = kLoginManager.userID;
    kChatManager.localUserDataModel.isShowVideo = !isChatCloseCamera;
    kChatManager.localUserDataModel.userName = NSLocalizedString(@"me", nil);
    kChatManager.localUserDataModel.originalSize = CGSizeMake(localVideoWidth, localVideoHeight);
    //    [kChatManager.localUserDataModel.cellVideoView addSubview:kChatManager.localUserDataModel.infoLabel];
    
    [self.videoMainView addSubview:kChatManager.localUserDataModel.infoLabel];
    
    self.localFileVideoView = [[RCRTCLocalVideoView alloc] initWithFrame:CGRectMake(0, 0, 90, 120)];
    self.localFileVideoView.fillMode = RCRTCVideoFillModeAspect;
    self.localFileVideoView.frameAnimated = NO;
    kChatManager.localFileVideoModel = nil;
    kChatManager.localFileVideoModel =
    [[ChatCellVideoViewModel alloc] initWithView:self.localFileVideoView];
    
    NSString *fileStreamId = [kChatManager.userID stringByAppendingString:@"RongRTCFileVideo"];
    if (!fileStreamId) {
        fileStreamId = @"RongRTCFileVideo";
    }
    kChatManager.localFileVideoModel.streamID = fileStreamId;
    kChatManager.localFileVideoModel.userID = kLoginManager.userID;
    kChatManager.localFileVideoModel.userName = @"我的视频文件";
    [kChatManager.localFileVideoModel.cellVideoView addSubview:kChatManager.localFileVideoModel.infoLabel];
    kChatManager.localFileVideoModel.isShowVideo = YES;
    
    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:self];
    
    RongAudioVolumeControl *control = [[RongAudioVolumeControl alloc]initWithFrame:CGRectMake(0, 0, 170, 90)];
    control.delegate = self;
    control.center = CGPointMake(self.view.frame.size.width / 2, 250);
    control.layer.masksToBounds = YES;
    control.layer.cornerRadius = 5.f;
    control.hidden = YES;
    [self.view addSubview:control];
    
    self.controller = control;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.f, 0.f, 36.f, 36.f);
    [button addTarget:self
               action:@selector(audioControlButtonClick:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"chat_av_audio_adjust_gray"]
            forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"chat_av_audio_adjust"] forState:UIControlStateSelected];
    self.audioControl = button;
    self.audioControl.hidden = YES;
    [self.view addSubview:self.audioControl];
    
#ifdef IS_LIVE
    [self joinLiveChannel];
#else
    [self joinChannelImpl];
#endif
    [self.view addSubview:self.focusView];
    [self.tapGesture class];
}

- (void)audioControlButtonClick:(UIButton *)button {
    button.selected = !button.selected;
    self.controller.hidden = !button.selected;
    isShowController = !self.controller.hidden;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    _deviceOrientaionBefore = UIDeviceOrientationPortrait;
    
    self.isHiddenStatusBar = NO;
    [self dismissButtons:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self isHeadsetPluggedIn])
        [self reloadSpeakerRoute:NO];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}
    
- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleAudioRouteChange:) 
                                                 name:AVAudioSessionRouteChangeNotification 
                                               object:nil];
}

- (void)handleAudioRouteChange:(NSNotification*)notification
{
    NSInteger reason = [[[notification userInfo] objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    AVAudioSessionRouteDescription *route = [AVAudioSession sharedInstance].currentRoute;
    AVAudioSessionPortDescription *port = route.outputs.firstObject;
    switch (reason)
    {
        case AVAudioSessionRouteChangeReasonUnknown:
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange : //3
            break;
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable : //1
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable : //2
        case AVAudioSessionRouteChangeReasonOverride : //4
        {
            if ([port.portType isEqualToString: AVAudioSessionPortBuiltInSpeaker]) {
                [self reloadSpeakerRoute:YES];
            } else {
                [self reloadSpeakerRoute:NO];
            }
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
    self.participantsTableViewController = nil;
    _chatWhiteBoardHandler = nil;
    [self.localView removeFromSuperview];
    self.localView = nil;
    [self.localFileVideoView removeFromSuperview];
    self.localFileVideoView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadSpeakerRoute:(BOOL)enable
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        kLoginManager.isSpeaker = enable;
        [strongSelf switchButtonBackgroundColor:kLoginManager.isSpeaker 
                                         button:strongSelf.chatViewBuilder.speakerOnOffButton];
        
        if (enable)
            [CommonUtility setButtonImage:strongSelf.chatViewBuilder.speakerOnOffButton 
                                imageName:@"chat_speaker_on"];
        else
            [CommonUtility setButtonImage:strongSelf.chatViewBuilder.speakerOnOffButton 
                                imageName:@"chat_speaker_off"];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [displayLink invalidate];
    displayLink = nil;
    self.collectionView.chatVC = nil;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES 
                                            withAnimation:UIStatusBarAnimationSlide];
    
    _chatCollectionViewDataSourceDelegateImpl = nil;
    _chatViewBuilder = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillTransitionToSize:(CGSize)size 
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.scrollView setZoomScale:1.0];
    self.videoMainView.subviews.firstObject.frame = (CGRect) { 0, 0, size.width, size.height };
    self.scrollView.frame = (CGRect) { 0, 0, size.width, size.height };
    for (UIView *view in self.scrollView.subviews) {
        if ([view isKindOfClass:[RCRTCLocalVideoView class]]) {
            RCRTCLocalVideoView *localView = (RCRTCLocalVideoView *)view;
            localView.frame = (CGRect) { 0, 0, size.width, size.height };
        }
        if ([view isKindOfClass:[RCRTCRemoteVideoView class]]) {
            RCRTCRemoteVideoView *remoteView = (RCRTCRemoteVideoView *)view;
            remoteView.frame = (CGRect) { 0, 0, size.width, size.height };
        }
    }
    
    self.scrollView.contentSize = CGSizeMake(size.width, size.height);
    CGFloat menuWidth = self.chatViewBuilder.upMenuView.frame.size.width;
    CGFloat menuHeight = self.chatViewBuilder.upMenuView.frame.size.height;
    self.chatViewBuilder.upMenuView.frame =
        (CGRect) { size.width - menuWidth - 16, (size.height - menuHeight) / 2, menuWidth, menuHeight };
    self.chatViewBuilder.hungUpButton.center = CGPointMake(size.width / 2, size.height - 44);
    self.chatViewBuilder.openCameraButton.center =
        CGPointMake(size.width / 2 - ButtonDistance - 44 / 2, size.height - 44);
    self.chatViewBuilder.microphoneOnOffButton.center =
        CGPointMake(size.width / 2 + ButtonDistance + 44 / 2, size.height - 44);
    CGFloat height = self.collectionView.frame.size.height;
    self.collectionView.frame = (CGRect) { 0, 0, height, size.height };
    
    if (self.chatViewBuilder.excelView.hidden) {
        self.chatViewBuilder.excelView.frame = (CGRect) { -size.width, 0, size.width, size.height };
    } else {
        self.chatViewBuilder.excelView.frame = (CGRect) { 0, 0, size.width, size.height };
    }
    self.chatViewBuilder.excelView.excelView.frame = (CGRect) { 16, 0, size.width - 32, size.height };
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        UIInterfaceOrientation orientation =
            [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationPortrait == orientation) {
            [RCRTCEngine sharedInstance].defaultVideoStream.videoOrientation =
                AVCaptureVideoOrientationPortrait;
            self.videoMainView.frame = (CGRect) { 0, 0, size.width, size.height };
        } else if (UIInterfaceOrientationLandscapeLeft == orientation) {
            CGFloat x = self.chatViewBuilder.upMenuView.frame.origin.x - 44;
            CGFloat y = self.chatViewBuilder.upMenuView.frame.origin.y;
            self.chatViewBuilder.upMenuView.frame = (CGRect) { x, y, menuWidth, menuHeight };
            [RCRTCEngine sharedInstance].defaultVideoStream.videoOrientation =
                AVCaptureVideoOrientationLandscapeLeft;
            self.videoMainView.frame = (CGRect) { 0, 0, size.height, size.width };
        } else if (UIInterfaceOrientationLandscapeRight == orientation) {
            [RCRTCEngine sharedInstance].defaultVideoStream.videoOrientation =
                AVCaptureVideoOrientationLandscapeRight;
            self.videoMainView.frame = (CGRect) { 0, 0, size.height, size.width };
        } else if (UIInterfaceOrientationPortraitUpsideDown == orientation) {
            [RCRTCEngine sharedInstance].defaultVideoStream.videoOrientation =
                AVCaptureVideoOrientationPortraitUpsideDown;
            self.videoMainView.frame = (CGRect) { 0, 0, size.width, size.height };
        }
        
        CGFloat offset = 16;
        CGFloat leftOffset = 0;
        CGFloat topOffset = 0;
        if (@available(iOS 11.0, *)) {
            if (UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom > 0.0) {
                topOffset = 34;
                offset += UIInterfaceOrientationIsLandscape(orientation) ? 34 : 78;
                if (orientation == UIInterfaceOrientationLandscapeRight) {
                    leftOffset = 44;
                } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
                    leftOffset = 34;
                }
            }
        }
        
        if (self.selectionModel) {
            self.selectionModel.infoLabel.frame = (CGRect) { 13, size.height - offset, size.width - 16, 16 };
            self.selectionModel.infoLabelGradLayer.frame =
                (CGRect) { 0, size.height - offset, size.width, 16 };
            self.selectionModel.avatarView.frame = (CGRect) { 0, 0, size.width, size.height };
        } else {
            kChatManager.localUserDataModel.infoLabel.frame =
                (CGRect) { 13, size.height - offset, size.width - 16, 16 };
            kChatManager.localUserDataModel.infoLabelGradLayer.frame =
                (CGRect) { 0, size.height - offset, size.width, 16 };
            kChatManager.localUserDataModel.avatarView.frame =
                (CGRect) { 0, 0, size.width, size.height };
        }
        
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            self.collectionView.frame = (CGRect) { leftOffset, 0, 90, size.height };
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;
            self.collectionView.alwaysBounceVertical = YES;
            self.collectionView.alwaysBounceHorizontal = NO;
        } else {
            self.collectionView.frame = (CGRect) { 0, 60 + topOffset, size.width, 120 };
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            self.collectionView.alwaysBounceHorizontal = YES;
            self.collectionView.alwaysBounceVertical = NO;
        }
        
        if (self->_chatWhiteBoardHandler) {
            [self->_chatWhiteBoardHandler rotateWhiteBoardView];
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (kLoginManager.isWaterMark) {
            BOOL isTrans = size.width > size.height;
            [self.chatGPUImageHandler transformWaterMark:isTrans];
        }
    }];
    
    CGPoint point = [self.audioBubbleButton convertPoint:self.audioBubbleButton.frame.origin
                                      toView:self.view];
    self.audioControl.frame = 
        CGRectMake(point.x - 45, point.y, 
                   self.audioControl.frame.size.width, self.audioControl.frame.size.height);
    self.controller.center = CGPointMake(size.width/2, point.y + 60);
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
        } else if (![self isiPhoneX]) {
            _mainVieTopMargin.constant = 0.0;
            [self setNeedsStatusBarAppearanceUpdate];
        }
    } else {
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
    } else {
        if (_deviceOrientaionBefore == UIDeviceOrientationPortrait) {
            _collectionViewTopMargin.constant = 0;
        }
    }
    self.isHiddenStatusBar = flag;
    if (flag) {
        self.audioControl.hidden = YES;
        self.controller.hidden = YES;
    } else {
        if (isShowController) {
            self.controller.hidden = NO;
        }
        if (isShowVolumeControl) {
            self.audioControl.hidden = NO;
        }
    }
}

#pragma mark - CollectionViewTouchesDelegate
- (void)didTouchedBegan:(NSSet<UITouch *> *)touches 
              withEvent:(UIEvent *)event 
              withBlock:(void (^)(void))block
{
    UITouch *touch = [touches anyObject];
    if (CGRectContainsPoint(self.collectionView.frame, [touch locationInView:self.collectionView])) {
        CGPoint point = [touch locationInView:self.collectionView];
        NSInteger count = [kChatManager countOfRemoteUserDataArray];
        if (count * 60 < ScreenWidth && point.x > count * 60) {
            showButtonSconds = 0;
            [self showButtons:isShowButton];
            if (isShowButton)
                displayLink.paused = NO;
            
            return;
        }
    }
    
    block();
}

#pragma mark - join channel
- (void)joinLiveChannel {
    [[RCIMClient sharedRCIMClient] registerMessageType:STSetRoomInfoMessage.class];
    [[RCIMClient sharedRCIMClient] registerMessageType:STDeleteRoomInfoMessage.class];
    [[RCIMClient sharedRCIMClient] registerMessageType:RongWhiteBoardMessage.class];
    
    if (!kLoginManager.isHost) {
        [[RCRTCEngine sharedInstance] enableSpeaker:YES];
        [[RCRTCEngine sharedInstance] subscribeLiveStream:kLoginManager.liveUrl
                                               streamType:RCRTCAVStreamTypeAudioVideo
                                               completion:^(RCRTCCode desc, RCRTCInputStream *_Nullable inputStream) {
            if (inputStream.mediaType == RTCMediaTypeVideo) {
                RCRTCRemoteVideoView *view =
                [[RCRTCRemoteVideoView alloc] initWithFrame:self.localView.bounds];
                [self.localView addSubview:view];
                view.fillMode = RCRTCVideoFillModeAspect;
                [(RCRTCVideoInputStream *)inputStream setVideoView:view];
            }
        }];
        return;
    }
    
    //    [[RCRTCEngine sharedInstance] setMediaServerUrl:kLoginManager.mediaServerURL];
    RCRTCRoomConfig *config = [[RCRTCRoomConfig alloc] init];
    config.roomType = RCRTCRoomTypeLive;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"audio"]) {
        config.liveType = RCRTCLiveTypeAudio;
    }
    [[RCIMClient sharedRCIMClient] registerMessageType:STKickOffInfoMessage.class];
    if (ENABLE_MANUAL_MEDIASERVER) {
        [[RCRTCEngine sharedInstance] setMediaServerUrl:kLoginManager.mediaServerURL];
    }
    
    [[RCRTCEngine sharedInstance] joinRoom:kLoginManager.roomNumber
                                    config:config
                                completion:^(RCRTCRoom *_Nullable room, RCRTCCode code) {
        [self showAlertLabelWithString:NSLocalizedString(@"chat_wait_attendees", nil)];
        self.room = room;
        [RCRTCEngine sharedInstance].statusReportDelegate = self.chatRongRTCNetworkMonitorDelegateImpl;
        self.joinRoomCode = code;
        if (kLoginManager.isObserver) {
            [self joinChannelImpl];
        } else if (room.remoteUsers.count >= MAX_NORMAL_PERSONS &&
                   room.remoteUsers.count < MAX_AUDIO_PERSONS) {
            NSString *msg = [NSString stringWithFormat:@"会议室中视频通话人数已超过 %d 人，你将以音频模式加入会议室。", MAX_NORMAL_PERSONS];
            UIAlertView *al = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            al.tag = 1110;
            [al show];
        } else if (room.remoteUsers.count >= MAX_AUDIO_PERSONS) {
            NSString *msg = [NSString stringWithFormat:@"会议室中人数已超过 %d 人，你将以旁听者模式加入会议室。", MAX_AUDIO_PERSONS];
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:nil
                                                         message:msg
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                               otherButtonTitles:@"确定", nil];
            al.tag = 1111;
            [al show];
        } else if (room) {
            [self joinChannelImpl];
        } else {
            [self showAlertLabelWithString:NSLocalizedString(@"chat_wait_attendees", nil)];
        }
    }];
}

- (void)joinChannel {
    [[RCIMClient sharedRCIMClient] registerMessageType:STSetRoomInfoMessage.class];
    [[RCIMClient sharedRCIMClient] registerMessageType:STDeleteRoomInfoMessage.class];
    [[RCIMClient sharedRCIMClient] registerMessageType:RongWhiteBoardMessage.class];
    [[RCIMClient sharedRCIMClient] registerMessageType:STKickOffInfoMessage.class];
    
    if (ENABLE_MANUAL_MEDIASERVER) {
        [[RCRTCEngine sharedInstance] setMediaServerUrl:kLoginManager.mediaServerURL];
    }
    
    [[RCRTCEngine sharedInstance] joinRoom:kLoginManager.roomNumber 
                               completion :^(RCRTCRoom *_Nullable room, RCRTCCode code) {
        if (code != RCRTCCodeSuccess) {
            NSString *alertTitle = [NSString stringWithFormat:@"加入房间失败: %zd", code];
            if (code == 40021) {
                alertTitle = NSLocalizedString(@"chat_join_kicked_by_server", nil);
            }
            UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:alertTitle
                                                message:nil
                                         preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *action =
            [UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_confirm", nil) style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *_Nonnull action) {
                [self didClickHungUpButton];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:^{}];
            return;
        }
        
        [self showAlertLabelWithString:NSLocalizedString(@"chat_wait_attendees", nil)];
        self.room = room;
        [RCRTCEngine sharedInstance].statusReportDelegate = self.chatRongRTCNetworkMonitorDelegateImpl;
        self.joinRoomCode = code;
        if (kLoginManager.isObserver) {
            [self joinChannelImpl];
        } else if (room.remoteUsers.count >= MAX_NORMAL_PERSONS &&
                   room.remoteUsers.count < MAX_AUDIO_PERSONS) {
            NSString *msg =
            [NSString stringWithFormat:@"会议室中视频通话人数已超过 %d 人，你将以音频模式加入会议室。",
             MAX_NORMAL_PERSONS];
            UIAlertView *al =
            [[UIAlertView alloc] initWithTitle:nil
                                       message:msg
                                      delegate:self
                             cancelButtonTitle:@"取消"
                             otherButtonTitles:@"确定", nil];
            al.tag = 1110;
            [al show];
        } else if (room.remoteUsers.count >= MAX_AUDIO_PERSONS) {
            NSString *msg =
            [NSString stringWithFormat:@"会议室中人数已超过 %d 人，你将以旁听者模式加入会议室。",
             MAX_AUDIO_PERSONS];
            UIAlertView *al =
            [[UIAlertView alloc] initWithTitle:nil
                                       message:msg
                                      delegate:self
                             cancelButtonTitle:@"取消"
                             otherButtonTitles:@"确定", nil];
            al.tag = 1111;
            [al show];
        } else if (room) {
            [self joinChannelImpl];
        } else {
            [self showAlertLabelWithString:NSLocalizedString(@"chat_wait_attendees", nil)];
        }
    }];
}

- (void)joinChannelImpl
{
    [[RCIMClient sharedRCIMClient] registerMessageType:STSetRoomInfoMessage.class];
    [[RCIMClient sharedRCIMClient] registerMessageType:STDeleteRoomInfoMessage.class];
    [[RCIMClient sharedRCIMClient] registerMessageType:RongWhiteBoardMessage.class];
    [[RCIMClient sharedRCIMClient] registerMessageType:STKickOffInfoMessage.class];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.chatRongRTCRoomDelegateImpl.infos = self.dataSource;
    self.room.delegate = self.chatRongRTCRoomDelegateImpl;
    [RCRTCEngine sharedInstance].statusReportDelegate  = self.chatRongRTCNetworkMonitorDelegateImpl;
    
    kLoginManager.isMaster = [self.room.remoteUsers count] ? NO : YES;
    NSInteger master = kLoginManager.isMaster ? 1 : 0;
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    STParticipantsInfo* info = 
        [[STParticipantsInfo alloc] initWithDictionary:@{
                @"userId":[RCIMClient sharedRCIMClient].currentUserInfo.userId,
                @"userName":kLoginManager.username,
                @"joinMode":@(self.chatMode),
                @"joinTime":@(timestamp),
                @"master":@(master)
    }];
    STSetRoomInfoMessage* message = 
        [[STSetRoomInfoMessage alloc] initWithInfo:info 
                                            forKey:[RCIMClient sharedRCIMClient].currentUserInfo.userId];
    
    [self.room setRoomAttributeValue:[info toJsonString] 
                              forKey:[RCIMClient sharedRCIMClient].currentUserInfo.userId 
                             message:message 
                          completion:^(BOOL isSuccess, RCRTCCode desc) {
        if (isSuccess) {
            FwLogD(RC_Type_APP,@"A-joinChannelImpl-T",@"setRoomAttributeValue Success");
        } else {
            FwLogD(RC_Type_APP,@"A-joinChannelImpl-T",
                   @"setRoomAttributeValue Failed code: %@", @(desc));
        }
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
        [self.room getRoomAttributes:nil
                          completion:^(BOOL isSuccess, RCRTCCode desc, NSDictionary * _Nullable attr) {
            [attr enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([key isEqualToString:kWhiteBoardMessageKey]) {
                    NSString *whiteboardJson = attr[kWhiteBoardMessageKey];
                    if (whiteboardJson) {
                        NSDictionary* dicInfo =
                        [NSJSONSerialization JSONObjectWithData:[whiteboardJson dataUsingEncoding:NSUTF8StringEncoding]
                                                        options:0
                                                          error:nil];
                        NSArray *keys = [dicInfo allKeys];
                        if ([keys containsObject:kWhiteBoardUUID]) {
                            self.chatWhiteBoardHandler.roomUuid = dicInfo[kWhiteBoardUUID];
                        }
                        if ([keys containsObject:kWhiteBoardRoomToken]) {
                            self.chatWhiteBoardHandler.roomToken = dicInfo[kWhiteBoardRoomToken];
                        }
                    }
                } else {
                    NSDictionary* dicInfo =
                    [NSJSONSerialization JSONObjectWithData:[obj dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0
                                                      error:nil];
                    STParticipantsInfo* info =
                    [[STParticipantsInfo alloc] initWithDictionary:dicInfo];
                    [self.dataSource addObject:info];
                    [kChatManager setRemoteModelUsername:info.userName userId:info.userId];
                }
            }];
        }];
#pragma clang diagnostic pop
    }];
    
    [[RCRTCEngine sharedInstance] enableSpeaker:YES];
    //    [[RCRTCEngine sharedInstance].defaultAudioStream setAudioConfig:kChatManager.audioCaptureParam];
    
    FwLogD(RC_Type_APP,@"A-joinChannelImpl-T",@"joinChannelImpl chatMode %@",@(self.chatMode));
    if (self.chatMode == AVChatModeObserver || self.chatMode == AVChatModeAudio) {
        kChatManager.videoCaptureParam.turnOnCamera = NO;
        if (self.chatMode == AVChatModeAudio) {
            [[RCRTCEngine sharedInstance].defaultVideoStream stopCapture];
        }
        
        self.chatViewBuilder.openCameraButton.enabled = NO;
        self.chatViewBuilder.switchCameraButton.enabled = NO;
        if (self.chatMode == AVChatModeObserver) {
            self.chatViewBuilder.microphoneOnOffButton.enabled = NO;
            self.chatViewBuilder.customVideoButton.enabled = NO;
            self.chatViewBuilder.customAudioButton.enabled = NO;
            self.localView.hidden = YES;
        }
        else if (self.chatMode == AVChatModeAudio) {
            isChatCloseCamera = YES;
        }
        [[RCRTCEngine sharedInstance] enableSpeaker:YES];
    } else {
//        [self setCaptureParam];
//        [[RCRTCEngine sharedInstance].defaultVideoStream startCapture];
    }
    
    if (isChatCloseCamera)
    {
        [self switchButtonBackgroundColor:isChatCloseCamera 
                                   button:self.chatViewBuilder.openCameraButton];
        [CommonUtility setButtonImage:self.chatViewBuilder.openCameraButton 
                            imageName:@"chat_close_camera"];
        self.chatViewBuilder.switchCameraButton.enabled = NO;
        
        kChatManager.localUserDataModel.avatarView.frame = self.localView.frame;
        [kChatManager.localUserDataModel.cellVideoView addSubview:kChatManager.localUserDataModel.avatarView];
    }
    
    RCRTCCode code = self.joinRoomCode;
    FwLogD(RC_Type_APP,@"A-appReceiveUserJoin-T",@"joinRoom  %@",@(code));
    if (code == RCRTCCodeSuccess) {
        DLog(@"joinRoom code Success");
        if (self.chatMode == AVChatModeAudio || self.chatMode == AVChatModeNormal) {
#ifdef IS_LIVE
            [self publishLiveLocalResource];
#else
            [self publishLocalResource];
#endif
        }
        
        if (self.room.remoteUsers.count > 0) {
            NSMutableArray *arr = [NSMutableArray array];
            for (RCRTCRemoteUser *user in self.room.remoteUsers) {
                for (RCRTCInputStream *stream in user.remoteStreams) {
                    [arr addObject:stream];
                }
            }
            
            [self subscribeRemoteResource:arr];
        } else {
            [self showAlertLabelWithString:NSLocalizedString(@"chat_wait_attendees", nil)];
            DLog(@"joinRoom room.remoteUsers.count < 0");
        }
    } else {
        DLog(@"joinRoom code Failed, code: %zd", code);
    }
}

- (void)setCaptureParam{
    RCRTCVideoCaptureParam *param = kChatManager.videoCaptureParam;
    if (kLoginManager.isVideoMirror) {
        param.videoMirrored = YES;
    } else {
        param.videoMirrored = NO;
    }
    RCRTCVideoStreamConfig* config = [RCRTCVideoStreamConfig new];
    config.maxBitrate = param.maxBitrate;
    config.minBitrate = param.minBitrate;
    config.videoSizePreset = param.videoSizePreset;
    config.videoFps = param.videoFrameRate;
    kChatManager.videoCaptureParam = param;
    [RCRTCEngine sharedInstance].defaultVideoStream.cameraPosition = param.cameraPosition;
    [RCRTCEngine sharedInstance].defaultVideoStream.isPreviewMirror = param.videoMirrored;
    [RCRTCEngine sharedInstance].defaultVideoStream.enableTinyStream = param.tinyStreamEnable;
    [RCRTCEngine sharedInstance].defaultVideoStream.videoConfig = config;
}

- (void)didLeaveRoom {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = 
            [UIAlertController alertControllerWithTitle:NSLocalizedString(@"chat_kicked_by_server", nil) 
                                                message:nil 
                                         preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = 
            [UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_confirm", nil) 
                                     style:UIAlertActionStyleDefault 
                                   handler:^(UIAlertAction * _Nonnull action) {
            [self didClickHungUpButton];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:^{}];
    });
}

- (void)publishLocalResource {
    DLog(@"start publishLocalResource");
    if (self.chatMode == AVChatModeAudio) {
        [self.room.localUser publishStream:[RCRTCEngine sharedInstance].defaultAudioStream 
                                completion:^(BOOL isSuccess, RCRTCCode desc) {
            if (isSuccess) {
                DLog(@"publish Audio Resource Success");
            }
            else {
                DLog(@"publish Audio Resource Failed,  Desc: %@", @(desc));
            }
        }];
    } else if (self.chatMode == AVChatModeNormal) {
        [self.room.localUser publishDefaultStreams:^(BOOL isSuccess,RCRTCCode desc) {
        }];
    }
}

- (void)publishLiveLocalResource {
    DLog(@"start publishLocalResource");
    [self.room.localUser publishDefaultLiveStreams:^(BOOL isSuccess, RCRTCCode desc, RCRTCLiveInfo * _Nullable liveInfo) {
            //        RCRTCRoom *room = self.room;
            if (isSuccess) {
                DLog(@"publishLocalResource Success");
            } else {
                DLog(@"publishLocalResource Failed,  Desc: %@", @(desc));
            }
            
            if (isSuccess) {
                [[RTHttpNetworkWorker shareInstance] publish:self.room.roomId roomName:self.room.roomId liveUrl:liveInfo.liveUrl completion:^(BOOL success) {
                    DLog(@"主播发布资源%@",success?@"成功了":@"失败了");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"主播" message:[NSString stringWithFormat:@"当前主播发布资源%@",success?@"成功":@"失败"] preferredStyle:(UIAlertControllerStyleAlert)];
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"浪去吧" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];
                        [controller addAction:action];
                        [self presentViewController:controller animated:YES completion:^{}];
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"主播" message:[NSString stringWithFormat:@"主播发布音视频资源失败"] preferredStyle:(UIAlertControllerStyleAlert)];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"下播吧" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];
                    [controller addAction:action];
                    [self presentViewController:controller animated:YES completion:^{}];
                });
            }
        }];
}

// 自动化使用
- (void)receivePublishMessage {
}

- (void)subscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams {
    NSMutableArray *incomingStreams = [streams mutableCopy];
    if ([incomingStreams count]) {
        FwLogD(RC_Type_APP,@"A-appSubscribeStream-T",
               @"%@app to  subscribe streams count : %@",
               @"sealRTCApp:",@(incomingStreams.count));
        [self.room.localUser subscribeStream:nil 
                                 tinyStreams:incomingStreams 
                                  completion:^(BOOL isSuccess, RCRTCCode desc) {
            if (isSuccess) {
                FwLogD(RC_Type_APP,@"A-appSubscribeStream-R",
                       @"%@all subscribe streams success",@"sealRTCApp:");
                [self hideAlertLabel:YES];
                [self startTalkTimer];
                
                for (RCRTCInputStream *stream in incomingStreams) {
                    for (STParticipantsInfo* info in self.dataSource) {
                        if ([stream.tag containsString:@"RongRTCFileVideo"] && 
                            [info.userId isEqualToString:stream.userId]) {
                            kChatManager.videoOwner = info.userName;
                            break;
                        }
                    }
                    DLog(@"Subscribe streamID: %@   mediaType: %zd", stream.streamId, stream.mediaType);
                    NSString *streamID = stream.streamId;
                    ChatCellVideoViewModel *model = 
                        [kChatManager getRemoteUserDataModelFromStreamID:streamID];
                    if (model) {
                        if (stream.mediaType == RTCMediaTypeVideo) {
                            model.inputVideoStream = stream;
                            [((RCRTCVideoInputStream *)stream) setVideoView:(RCRTCRemoteVideoView*)model.cellVideoView];
                            model.isShowVideo = stream.resourceState == ResourceStateNormal;
                            if (!model.isShowVideo) {
                                model.avatarView.frame = model.cellVideoView.frame;
                                [model.cellVideoView addSubview:model.avatarView];
                            } else {
                                [model.avatarView removeFromSuperview];
                            }
                        } else {
                            model.inputAudioStream = stream;
                        }
                    } else {
                        RCRTCRemoteVideoView *view =
                            [[RCRTCRemoteVideoView alloc] initWithFrame:CGRectMake(0, 0, 90, 120)];
                        view.fillMode = RCRTCVideoFillModeAspect;
                        view.frameAnimated = NO;
                        
                        ChatCellVideoViewModel *chatCellVideoViewModel =
                            [[ChatCellVideoViewModel alloc] initWithView:view];
                        chatCellVideoViewModel.streamID = stream.streamId;
                        chatCellVideoViewModel.userID = stream.userId;
                        chatCellVideoViewModel.everOnLocalView = 0;
                        
                        if (stream.mediaType == RTCMediaTypeVideo) {
                            chatCellVideoViewModel.inputVideoStream = stream;
                            [((RCRTCVideoInputStream *)stream) setVideoView:view];
                            chatCellVideoViewModel.isShowVideo =
                            stream.resourceState == ResourceStateNormal;
                        } else {
                            if ([stream.tag isEqualToString:@"RongCloudRTC"] == NO) {
                                continue;
                            }
                            chatCellVideoViewModel.inputAudioStream = stream;
                        }
                        
                        if (!chatCellVideoViewModel.isShowVideo) {
                            chatCellVideoViewModel.avatarView.frame = view.frame;
                            [chatCellVideoViewModel.cellVideoView addSubview:chatCellVideoViewModel.avatarView];
                        }
                        [view addSubview:chatCellVideoViewModel.infoLabel];
                        [kChatManager addRemoteUserDataModel:chatCellVideoViewModel];
                        
                        [self.room getRoomAttributes:@[chatCellVideoViewModel.userID]
                                          completion:^(BOOL isSuccess, RCRTCCode desc, NSDictionary * _Nullable attr) {
                            [attr enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                                NSDictionary* dicInfo =
                                    [NSJSONSerialization JSONObjectWithData:[obj dataUsingEncoding:NSUTF8StringEncoding]
                                                                    options:0
                                                                      error:nil];
                                STParticipantsInfo* info =
                                    [[STParticipantsInfo alloc] initWithDictionary:dicInfo];
                                [kChatManager setRemoteModelUsername:info.userName
                                                              userId:info.userId];
                                ChatCellVideoViewModel* model =
                                    [kChatManager getRemoteUserDataModelSimilarUserID:info.userId];
                                model.userName = info.userName;
                            }];
                        }];
                        
                        NSInteger row = [kChatManager countOfRemoteUserDataArray]-1;
                        NSIndexPath *tempPath = [NSIndexPath indexPathForRow:row inSection:0];
                        [self.collectionView insertItemsAtIndexPaths:@[tempPath]];
                    }
                    for (STParticipantsInfo *info in self.dataSource) {
                        ChatCellVideoViewModel *model = 
                            [kChatManager getRemoteUserDataModelFromUserID:info.userId];
                        if (info.userName) {
                            model.userName = info.userName;
                        }
                    }
                }
            } else {
                FwLogD(RC_Type_APP,@"A-appSubscribeStream-E",
                       @"%@all subscribe streams error",@"sealRTCApp:");
                DLog(@"subscribeStream Failed, Desc: %@", @(desc));
            }
        }];
    }
}

- (void)didConnectToUser:(NSString *)userId {
    FwLogD(RC_Type_APP,@"A-appConnectToStream-T",
           @"%@appConnectTostream collectionview to render",@"sealRTCApp:");
}

- (void)unsubscribeRemoteResource:(NSArray<RCRTCInputStream *> *)streams
{
    for (RCRTCInputStream *stream in streams) {
        DLog(@"Unsubscribe streamID: %@   mediaType: %zd", stream.streamId, stream.mediaType);
    }
    
    [self.room.localUser unsubscribeStreams:streams completion:^(BOOL isSuccess,RCRTCCode desc) {
    }];
}

//#pragma mark - alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 9999) {
        if (buttonIndex > 0) {
            self.chatViewBuilder.customVideoButton.enabled = NO;
            [self startPublishVideoFile:buttonIndex];
        }
        else {
            self.chatViewBuilder.customVideoButton.enabled = YES;
            self.chatViewBuilder.customVideoButton.selected = NO;
        }
    }
    else{
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
            [[RCRTCEngine sharedInstance] leaveRoom:^(BOOL isSuccess, RCRTCCode code) {}];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - show alert label
- (void)showAlertLabelWithString:(NSString *)text
{
    self.alertLabel.hidden = NO;
    self.alertLabel.text = text;
}

- (void)showAlertLabelWithAnimate:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.chatViewBuilder.masterLabel.hidden = NO;
        self.chatViewBuilder.masterLabel.alpha = 1;
        self.chatViewBuilder.masterLabel.text = text;
        
        [UIView animateWithDuration:3.0 animations:^{
            self.chatViewBuilder.masterLabel.alpha = 0;
        } completion:^(BOOL finished){
        }];
    });
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
        self.talkTimeLabel.text = 
            [NSString stringWithFormat:@"%01ld:%02ld:%02ld", 
                      (unsigned long)hour, (unsigned long)minutes, (unsigned long)seconds];
    else
        self.talkTimeLabel.text = 
            [NSString stringWithFormat:@"%02ld:%02ld",
                      (unsigned long)minutes, (unsigned long)seconds];
}

- (void)startTalkTimer
{
    if (self.duration == 0 && !self.durationTimer)
    {
        self.talkTimeLabel.text = @"00:00";
        self.durationTimer = 
            [NSTimer scheduledTimerWithTimeInterval:1 
                                             target:self 
                                           selector:@selector(updateTalkTimeLabel) 
                                           userInfo:nil 
                                            repeats:YES];
    }
}

- (void)beauButtonPressed:(UIButton *)btn{
}

- (void)didSelectHD:(UIButton *)btn{
    self.resolutionPickView = 
        [[ZHPickView alloc] initPickviewWithPlistName:Dynamic_resolution isHaveNavControler:NO];
    self.resolutionPickView.delegate = self;
    [self.resolutionPickView setSelectedPickerItem:0];
    [self.view addSubview:self.resolutionPickView];
}

- (void)clickCameraFocus {
    self.enableCameraFocus = !self.enableCameraFocus;
    if (self.enableCameraFocus) {
        self.chatViewBuilder.cameraFocusButton.tintColor = [UIColor blackColor];
        [CommonUtility setButtonImage:self.chatViewBuilder.cameraFocusButton 
                            imageName:@"chat_disable_camera_focus"];
        [self.view makeToast:@"启动相机对焦" 
                    duration:1.5 
                    position:CSToastPositionCenter];
    } else {
        self.chatViewBuilder.cameraFocusButton.tintColor = nil;
        [CommonUtility setButtonImage:self.chatViewBuilder.cameraFocusButton 
                            imageName:@"chat_enable_camera_focus"];
        [self.view makeToast:@"关闭相机对焦" 
                    duration:1.5 
                    position:CSToastPositionCenter];
    }
}

- (void)hideHDView {
    if (self.resolutionPickView) {
        [self.resolutionPickView removeFromSuperview];
        self.resolutionPickView = nil;
    }
}

#pragma mark - click memu item button
- (void)menuItemButtonPressed:(UIButton *)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger tag = button.tag;
    self.beauBtn.selected = NO;
    [self hideSelectFUView];
    [self hideHDView];
    switch (tag)
    {
        case -2:{
            
            [self beauButtonPressed:sender];
        }break;
        case -1:{
            
            if (self.chatViewBuilder.customVideoButton.selected) {
                [RTActiveWheel showPromptHUDAddedTo:self.view text:@"请先关闭视频文件"];
                return;
            }
            
            [self didClickMixerBtn];
            
        }
            break;
        case 0:
        {
            isShowController = NO;
            isShowVolumeControl = NO;
            self.chatViewBuilder.customAudioButton.selected = NO;
            [[RCRTCAudioMixer sharedInstance] stop];
            sender.selected = !sender.selected;
            if (sender.selected) {
                for (RCRTCRemoteUser *remoteUser in self.room.remoteUsers) {
                    for (RCRTCInputStream *stream in remoteUser.remoteStreams) {
                        if (stream.mediaType == RTCMediaTypeVideo) {
                            if ([stream.tag hasPrefix:@"RongRTCFileVideo"]) {
                                [RTActiveWheel showPromptHUDAddedTo:self.view text:@"房间中已有人发布视频文件"];
                                sender.selected = NO;
                                return;
                            }
                        }
                    }
                }
                sender.enabled = NO;
                UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"选择视频文件" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"视频文件 1",@"视频文件 2", nil];
                al.tag = 9999;
                [al show];
                self.audioControl.selected = NO;
                self.audioControl.hidden = YES;
                self.controller.hidden = YES;
            }
            else{
                if (fileCapturer) {
                    [fileCapturer stop];
                    fileCapturer.delegate = nil;
                    fileCapturer = nil;
                }
                sender.enabled = NO;
                NSString *streamID = kChatManager.localFileVideoModel.streamID;
                if ([kChatManager isContainRemoteUserFromStreamID:streamID])
                {
                    RCRTCLocalVideoView *localVideoRender = 
                        (RCRTCLocalVideoView *)kChatManager.localFileVideoModel.cellVideoView;
                    if (localVideoRender) {
                        [localVideoRender flushVideoView];
                    }
                    NSInteger index = [kChatManager indexOfRemoteUserDataArray:streamID];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    if (kLoginManager.isSwitchCamera
                        && [self.chatCollectionViewDataSourceDelegateImpl.originalSelectedViewModel.streamID isEqualToString:streamID])
                    {
                        [self.chatCollectionViewDataSourceDelegateImpl collectionView:self.collectionView 
                                                             didSelectItemAtIndexPath:indexPath];
                    }
                    [kChatManager removeRemoteUserDataModelFromStreamID:streamID];
                    FwLogD(RC_Type_APP,@"A-appReceiveUserLeave-T",
                           @"%@appReceiveUserLeave and remove user",@"sealRTCApp:");
                    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                    if (self.orignalRow > 0) self.orignalRow--;
                }
                
                [self.room.localUser unpublishStream:videoOutputStream 
                                          completion:^(BOOL isSuccess, RCRTCCode desc) {
                        sender.enabled = YES;
                }];
                videoOutputStream = nil;
                isStartPublishAudio = NO;
            }
        }
            break;
        case 1: //switch camera
            [self didClickSwitchCameraButton:button];
            break;
        case 2: //mute speaker
            [self didClickSpeakerButton:button];
            break;
        case 3:
            [self didClickMemeberBtn];
            break;
        case 4: //white board
            [self didClickWhiteboardButton];
            break;
        case 5:
            sender.selected = !sender.selected;
            [self didClickMusicMode:sender.selected];
            break;
        case 6:
            [self didSelectHD:button];
            break;
        case 7:
            [self clickCameraFocus];
            break;
        default:
            break;
    }
}

- (void)startPublishVideoFile:(NSInteger)buttonIndex {
    NSString *tag = @"RongRTCFileVideo";
    videoOutputStream = [[RCRTCVideoOutputStream alloc] initVideoOutputStreamWithTag:tag];
    RCRTCVideoStreamConfig* videoConfig = videoOutputStream.videoConfig;
    videoConfig.videoSizePreset = RCRTCVideoSizePreset640x360;
    [videoOutputStream setVideoConfig:videoConfig];
    [videoOutputStream setVideoView:self.localFileVideoView];
    NSString *path = 
        [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"video_demo%@_low",@(buttonIndex)] 
                                        ofType:@"mp4"];
    self->fileCapturer = [[RCRTCFileSource alloc] initWithFilePath:path];
    self->fileCapturer.delegate = self;
    videoOutputStream.videoSource = self->fileCapturer;
    [self->fileCapturer setObserver:videoOutputStream];
    
#ifdef IS_LIVE
    [self.room.localUser publishLiveStream:videoOutputStream 
                                completion:^(BOOL isSuccess, RCRTCCode desc, RCRTCLiveInfo * _Nullable liveInfo) {
            self.chatViewBuilder.customVideoButton.enabled = YES;
            if (desc == RCRTCCodeSuccess) {
                [RTActiveWheel showPromptHUDAddedTo:self.view text:@"发布成功"];
            } else {
                [RTActiveWheel showPromptHUDAddedTo:self.view text:@"发布失败"];
            }
    }];
#else

    [self.room.localUser publishStream:videoOutputStream completion:^(BOOL isSuccess, RCRTCCode desc) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.chatViewBuilder.customVideoButton.enabled = YES;
            if (desc == RCRTCCodeSuccess) {
                [RTActiveWheel showPromptHUDAddedTo:self.view text:@"发布成功"];
            }
            else{
                [RTActiveWheel showPromptHUDAddedTo:self.view text:@"发布失败"];
            }
        });
    }];
#endif
    
    isStartPublishAudio = YES;
    
    [kChatManager addRemoteUserDataModel:kChatManager.localFileVideoModel];
    NSInteger row = [kChatManager countOfRemoteUserDataArray]-1;
    NSIndexPath *tempPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.collectionView insertItemsAtIndexPaths:@[tempPath]];
}

- (void)didWillStartRead {
    RCRTCLocalVideoView *localView =
        (RCRTCLocalVideoView *)kChatManager.localFileVideoModel.cellVideoView;
    [localView flushVideoView];
}

- (void)didReadCompleted {
    RCRTCLocalVideoView *localView = 
        (RCRTCLocalVideoView *)kChatManager.localFileVideoModel.cellVideoView;
    [localView flushVideoView];
}

-(void)showSelectFUView{
}

- (void)hideSelectFUView {
}

#pragma mark - focus camera
- (void)focusCameraAction:(UITapGestureRecognizer *)gesture {
    [self showOrHideViews];
    if (!self.enableCameraFocus) {
        return;
    }

    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:[gesture.view convertPoint:point toView:self.localView]];

    /*
     * 下面是手触碰屏幕后对焦的效果
     */
    _focusView.center = point;
    _focusView.hidden = NO;

    [UIView animateWithDuration:0.3 animations:^{
            self.focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                    self.focusView.transform = CGAffineTransformIdentity;
                } completion:^(BOOL finished) {
                    self.focusView.hidden = YES;
                }];
        }];
}

- (void)focusAtPoint:(CGPoint)point{
    point.x += _scrollView.contentOffset.x;
    point.y += _scrollView.contentOffset.y;
    point.x /= _scrollView.zoomScale;
    point.y /= _scrollView.zoomScale;
    [[RCRTCEngine sharedInstance].defaultVideoStream setCameraFocusPositionInPreview:point];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer != self.tapGesture) return YES;

    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    

    if (self.collectionView && CGRectContainsPoint(self.collectionView.frame, point)) {
        for (UICollectionViewCell* cell in self.collectionView.visibleCells) {
            CGPoint cellPoint = 
                [cell.contentView convertPoint:point fromView:gestureRecognizer.view];
            if (CGRectContainsPoint(cell.contentView.frame, cellPoint))
                return NO;
        }
    }

    return YES;
}


#pragma mark - click mute micphone
- (void)didClickAudioMuteButton:(UIButton *)btn
{
    kLoginManager.isMuteMicrophone = !kLoginManager.isMuteMicrophone;
    [[RCRTCEngine sharedInstance].defaultAudioStream setMicrophoneDisable:kLoginManager.isMuteMicrophone];
    [self switchButtonBackgroundColor:!kLoginManager.isMuteMicrophone button:btn];
    
    if (kLoginManager.isMuteMicrophone) {
        [CommonUtility setButtonImage:btn imageName:@"chat_microphone_off"];
    } else {
        [CommonUtility setButtonImage:btn imageName:@"chat_microphone_on"];
    }
    kChatManager.localUserDataModel.audioLevelView.hidden = kLoginManager.isMuteMicrophone;
}

#pragma mark - click mute speaker
- (void)didClickSpeakerButton:(UIButton *)btn
{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        kLoginManager.isSpeaker = !kLoginManager.isSpeaker;
        if(![[RCRTCEngine sharedInstance] enableSpeaker:kLoginManager.isSpeaker]) {
            kLoginManager.isSpeaker = !kLoginManager.isSpeaker;
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self switchButtonBackgroundColor:kLoginManager.isSpeaker button:btn];
            
            NSString* message;
            if (kLoginManager.isSpeaker) {
                [CommonUtility setButtonImage:btn imageName:@"chat_speaker_on"];
                message = NSLocalizedString(@"chat_switch_to_speaker", nil);
                 
            } else {
                [CommonUtility setButtonImage:btn imageName:@"chat_speaker_off"];
                message = NSLocalizedString(@"chat_switch_to_receiver", nil);
            }
            [RTActiveWheel showPromptHUDAddedTo:self.view text:message];
        });
    });
}
-(void)touchBeauView{
    [self.chatViewBuilder enableSwipeGesture:YES];
    [self.beauView removeFromSuperview];
    self.beauView = nil;
}
#pragma mark - click member
- (void)didClickMixerBtn {
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController* nav = 
        [sb instantiateViewControllerWithIdentifier:@"nav_st_audio_mixing_pannel"];
    STAudioMixingPannelController* ampc = 
        (STAudioMixingPannelController*)nav.viewControllers[0];
    ampc.config = self.audioMixerConfig;
    STPresentationViewController* pvc = 
        [[STPresentationViewController alloc] initWithPresentedViewController:nav 
                                                     presentingViewController:self];
    nav.transitioningDelegate = pvc;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didClickMemeberBtn {
    self.participantsTableViewController = 
        [[STParticipantsTableViewController alloc] initWithRoom:self.room 
                                              participantsInfos:self.dataSource];
    self.participantsTableViewController.tableView.allowsSelection = NO;
    STPresentationViewController* pvc = 
        [[STPresentationViewController alloc] initWithPresentedViewController:self.participantsTableViewController 
                                                     presentingViewController:self];
    self.participantsTableViewController.transitioningDelegate = pvc;
    [self presentViewController:self.participantsTableViewController animated:YES completion:nil];
}

#pragma mark - click white board
- (void)didClickWhiteboardButton
{
    if (self.chatMode == AVChatModeObserver) {
        if (!self.chatWhiteBoardHandler.roomUuid || 
            self.chatWhiteBoardHandler.roomUuid.length == 0 || 
            !self.chatWhiteBoardHandler.roomToken || 
            self.chatWhiteBoardHandler.roomToken.length == 0) {
            UIAlertController *alert = 
                [UIAlertController alertControllerWithTitle:NSLocalizedString(@"chat_white_open_failed", nil) 
                                                    message:@"" 
                                             preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = 
                [UIAlertAction actionWithTitle:@"OK" 
                                         style:(UIAlertActionStyleDefault) 
                                       handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:^{
            }];
            return;
        } else {
            [self.chatWhiteBoardHandler setOperationEnable:NO];
        }
    }
    
    kLoginManager.isWhiteBoardOpen = !kLoginManager.isWhiteBoardOpen;
    
    if (kLoginManager.isWhiteBoardOpen) {
        [self.chatWhiteBoardHandler openWhiteBoardRoom];
    } else {
        [self.chatWhiteBoardHandler closeWhiteBoardRoom];
    }
}

#pragma mark - click local video
- (void)didClickVideoMuteButton:(UIButton *)btn
{
    isChatCloseCamera = !isChatCloseCamera;
    if (isChatCloseCamera)
        [[RCRTCEngine sharedInstance].defaultVideoStream stopCapture];
    else
        [[RCRTCEngine sharedInstance].defaultVideoStream startCapture];
    //[RCRTCEngine sharedInstance].defaultVideoStream.isMute = isChatCloseCamera;
    [self switchButtonBackgroundColor:!isChatCloseCamera button:btn];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationPortrait == orientation) {
        [RCRTCEngine sharedInstance].defaultVideoStream.videoOrientation = 
            AVCaptureVideoOrientationPortrait;
    } else if (UIInterfaceOrientationLandscapeLeft == orientation) {
        [RCRTCEngine sharedInstance].defaultVideoStream.videoOrientation = 
            AVCaptureVideoOrientationLandscapeLeft;
    } else if(UIInterfaceOrientationLandscapeRight == orientation) {
        [RCRTCEngine sharedInstance].defaultVideoStream.videoOrientation = 
            AVCaptureVideoOrientationLandscapeRight;
    } else if (UIInterfaceOrientationPortraitUpsideDown == orientation) {
        [RCRTCEngine sharedInstance].defaultVideoStream.videoOrientation = 
            AVCaptureVideoOrientationPortraitUpsideDown;
    }
    kChatManager.localUserDataModel.isShowVideo = !isChatCloseCamera;
    kChatManager.localUserDataModel.avatarView.frame = self.localView.frame;
    if (isChatCloseCamera) {
        [CommonUtility setButtonImage:btn imageName:@"chat_close_camera"];
        self.chatViewBuilder.switchCameraButton.enabled = NO;
        [kChatManager.localUserDataModel.cellVideoView addSubview:kChatManager.localUserDataModel.avatarView];
    } else {
        [CommonUtility setButtonImage:btn imageName:@"chat_open_camera"];
        self.chatViewBuilder.switchCameraButton.enabled = YES;
        [kChatManager.localUserDataModel.avatarView removeFromSuperview];
    }
}

#pragma mark - click switch camera
- (void)didClickSwitchCameraButton:(UIButton *)btn
{
    kLoginManager.isBackCamera = !kLoginManager.isBackCamera;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[RCRTCEngine sharedInstance].defaultVideoStream switchCamera];
        if (kLoginManager.isBackCamera) {
            [RCRTCEngine sharedInstance].defaultVideoStream.isPreviewMirror = NO;
            self.localView.isPreviewMirror = NO;
        } else {
            if (kLoginManager.isVideoMirror) {
                [RCRTCEngine sharedInstance].defaultVideoStream.isPreviewMirror = YES;
                self.localView.isPreviewMirror = NO;
            } else {
                [RCRTCEngine sharedInstance].defaultVideoStream.isPreviewMirror = NO;
                self.localView.isPreviewMirror = YES;
            }
        }
        if (kLoginManager.isWaterMark) {
            [self.chatGPUImageHandler rotateWaterMark:kLoginManager.isBackCamera];
        }
    });
}

#pragma mark - click hungup button
- (void)didClickHungUpButton
{
    if (kLoginManager.isMaster && [self.dataSource count] > 1) {
        STParticipantsInfo *firstInfo = (STParticipantsInfo *)self.dataSource[1];
        if ([firstInfo.userId isEqualToString:kLoginManager.userID]) {
            firstInfo = (STParticipantsInfo *)self.dataSource[0];
        }
        NSString *userId = firstInfo.userId;
        if (userId) {
            STParticipantsInfo *info = 
                [[STParticipantsInfo alloc] initWithDictionary:@{@"userId":firstInfo.userId,
                            @"userName":firstInfo.userName,
                            @"joinMode":@(firstInfo.joinMode),
                            @"joinTime":@(firstInfo.joinTime),
                            @"master":@(1)
            }];
            STSetRoomInfoMessage *message = 
                [[STSetRoomInfoMessage alloc] initWithInfo:info forKey:firstInfo.userId];
            [self.room setRoomAttributeValue:[info toJsonString] 
                                      forKey:firstInfo.userId 
                                     message:message 
                                  completion:^(BOOL isSuccess, RCRTCCode desc) {}];
        }
    }
    
    [[RCRTCAudioMixer sharedInstance] stop];
    if (fileCapturer) {
        [fileCapturer stop];
        fileCapturer.delegate = nil;
        fileCapturer = nil;
    }
    
    STDeleteRoomInfoMessage* deleteMessage = 
        [[STDeleteRoomInfoMessage alloc] initWithInfoKey:kLoginManager.userID];
    if (kLoginManager.userID) {
        [self.room deleteRoomAttributes:@[kLoginManager.userID] 
                                message:deleteMessage 
                             completion:^(BOOL isSuccess, RCRTCCode desc) {
        }];
    }
    
    
    if (_chatWhiteBoardHandler) {
        [_chatWhiteBoardHandler leaveRoom];
        if (![kChatManager countOfRemoteUserDataArray]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
            [self.room deleteRoomAttributes:@[kWhiteBoardMessageKey] 
                                    message:nil 
                                 completion:^(BOOL isSuccess, RCRTCCode desc) {
            }];
#pragma clang diagnostic pop
            [_chatWhiteBoardHandler deleteRoom];
        }
        _chatWhiteBoardHandler = nil;
    }
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:nil];
        [strongSelf.controller removeFromSuperview];
        strongSelf.controller = nil;
        [strongSelf.participantsTableViewController dismissViewControllerAnimated:YES 
                                                                       completion:nil];
        
        if (kLoginManager.isHost) {
            [[RTHttpNetworkWorker shareInstance] unpublish:strongSelf.room.roomId 
                                                completion:^(BOOL success) {
                DLog(@"leave live ,unpublish: %@", @(success));
            }];
            [[RCRTCEngine sharedInstance] leaveRoom:^(BOOL isSuccess, NSInteger code) {
                __strong typeof(weakSelf) strongSelf2 = weakSelf;
                if (!strongSelf2) return;

                strongSelf2.room = nil;
                if (isSuccess) {
                    DLog(@"leaveRoom Success");
                }else {
                    DLog(@"leaveRoom Failed, code: %zd", code);
                }
            }];
        } else {
#ifdef IS_LIVE
            [[RCRTCEngine sharedInstance] unsubscribeLiveStream:kLoginManager.liveUrl
                                                     completion:^(BOOL isSuccess, RCRTCCode code) {
                __strong typeof(weakSelf) strongSelf2 = weakSelf;
                if (!strongSelf2) return;

                strongSelf2.room = nil;
                if (isSuccess) {
                    DLog(@"leaveRoom Success");
                }else {
                    DLog(@"leaveRoom Failed, code: %zd", code);
                }
            }];
            
#else
            [[RCRTCEngine sharedInstance] leaveRoom:^(BOOL isSuccess, NSInteger code) {
                __strong typeof(weakSelf) strongSelf2 = weakSelf;
                if (!strongSelf2) return;

                strongSelf2.room = nil;
                if (isSuccess) {
                    DLog(@"leaveRoom Success");
                } else {
                    DLog(@"leaveRoom Failed, code: %zd", code);
                }
            }];
#endif
        }
        [[RCRTCEngine sharedInstance].defaultVideoStream stopCapture];
        strongSelf.isFinishLeave = YES;
        [strongSelf.durationTimer invalidate];
        strongSelf.talkTimeLabel.text = @"";
        strongSelf.localView.hidden = NO;
        [strongSelf.localView removeFromSuperview];
        strongSelf.localView = nil;
        
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        
        [kChatManager.localUserDataModel removeKeyPathObservers];
        [kChatManager.localUserDataModel.cellVideoView removeFromSuperview];
        kChatManager.localUserDataModel = nil;
        [kChatManager.localFileVideoModel removeKeyPathObservers];
        [kChatManager.localFileVideoModel.cellVideoView removeFromSuperview];
        kChatManager.localFileVideoModel = nil;
        kLoginManager.isMuteMicrophone = NO;
        kLoginManager.isSwitchCamera = NO;
        kLoginManager.isBackCamera = NO;
        kLoginManager.isWhiteBoardOpen = NO;
        [kChatManager clearAllDataArray];
        [strongSelf.collectionView reloadData];
        [strongSelf.collectionView removeFromSuperview];
        strongSelf.collectionView.chatVC = nil;
        strongSelf.collectionView = nil;
        [strongSelf.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark - switch menu button color
- (void)switchButtonBackgroundColor:(BOOL)is button:(UIButton *)btn
{
    dispatch_async(dispatch_get_main_queue(), ^{
        btn.backgroundColor = 
            !is ? [UIColor whiteColor] : [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.4f];
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
        if ([outputer isEqualToString:AVAudioSessionPortHeadphones] || 
            [outputer isEqualToString:AVAudioSessionPortBluetoothLE] || 
            [outputer isEqualToString:AVAudioSessionPortBluetoothHFP] || 
            [outputer isEqualToString:AVAudioSessionPortBluetoothA2DP])
            return YES;
    }
    return NO;
}

#pragma mark - AlertController
- (void)alertWith:(NSString *)title 
      withMessage:(NSString *)msg 
     withOKAction:(nullable  UIAlertAction *)ok 
 withCancleAction:(nullable UIAlertAction *)cancel
{
    self.alertController = 
        [UIAlertController alertControllerWithTitle:title 
                                            message:msg 
                                     preferredStyle:UIAlertControllerStyleAlert];
    if (cancel)
        [self.alertController addAction:cancel];
    if (!ok){
        UIAlertAction *ok = 
            [UIAlertAction actionWithTitle:NSLocalizedString(@"chat_alert_btn_confirm", nil) 
                                     style:(UIAlertActionStyleDefault) 
                                   handler:^(UIAlertAction * _Nonnull action) {
            [self.alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [self.alertController addAction:ok];
    }else{
        [self.alertController addAction:ok];
    }
    [self presentViewController:self.alertController animated:YES completion:^{}];
}

#pragma mark - Getters
- (NSMutableArray<STParticipantsInfo*>*)dataSource {
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] initWithCapacity:100];
    }
    return _dataSource;
}

- (STAudioMixerConfiguration*)audioMixerConfig {
    if (!_audioMixerConfig) {
        _audioMixerConfig = [[STAudioMixerConfiguration alloc] init];
        NSString* path = [[NSBundle mainBundle] pathForResource:@"my_homeland" ofType:@"aac"];
        NSURL* fileURL = [NSURL fileURLWithPath:path];
        _audioMixerConfig.audioFileURL = fileURL;
        _audioMixerConfig.localVolume = 100;
        _audioMixerConfig.remoteVolume = 100;
        _audioMixerConfig.micVolume = 100;
        _audioMixerConfig.mixerModeIndex =  0;
        _audioMixerConfig.mixingOption = STAudioMixingOptionPlaying | STAudioMixingOptionMixing;
    }
    return _audioMixerConfig;
}

- (ChatWhiteBoardHandler *)chatWhiteBoardHandler
{
    if (!_chatWhiteBoardHandler) {
        _chatWhiteBoardHandler = [[ChatWhiteBoardHandler alloc] initWithViewController:self];
    }
    
    return _chatWhiteBoardHandler;
}

- (UIView *)focusView {
    if (!_focusView) {
        _focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        _focusView.layer.borderWidth = 1.0;
        _focusView.layer.borderColor =[UIColor greenColor].CGColor;
        _focusView.backgroundColor = [UIColor clearColor];
        _focusView.hidden = YES;
    }

    return _focusView;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = 
            [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                    action:@selector(focusCameraAction:)];
        _tapGesture.delegate = self;
        [self.view addGestureRecognizer:_tapGesture];
    }
    
    return _tapGesture;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)didClickMusicMode:(BOOL) selected
{
    if (selected) {
        [[RCRTCEngine sharedInstance].defaultAudioStream changeMusicPlayMode:RCRTCAudioScenarioMusicSingleNotePlay];
    } else {
        [[RCRTCEngine sharedInstance].defaultAudioStream changeMusicPlayMode:RCRTCAudioScenarioMusicNormalPlay];
    }
}


#pragma mark - RCConnectionStatusChangeDelegate
- (void)onConnectionStatusChanged:(RCConnectionStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == ConnectionStatus_Connected) {
            self.connectingLabel.text = nil;
            self.connectingLabel.hidden = YES;
        } else if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
            [self didClickHungUpButton];
            kLoginManager.isIMConnectionSucc = NO;
            UIAlertView *alertV = 
                [[UIAlertView alloc]initWithTitle:nil 
                                          message:@"此用户已在其他设备登录，可修改用户名后再尝试登录" 
                                         delegate:nil 
                                cancelButtonTitle:nil 
                                otherButtonTitles:@"确定", nil];
            [alertV show];
        } else {
            self.connectingLabel.hidden = NO;
            self.connectingLabel.text = NSLocalizedString(@"connecting_im", nil);
        }
    });
}
#pragma mark - scrollView delegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.zoomView;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView 
                      withView:(UIView *)view 
                       atScale:(CGFloat)scale{
    if (scrollView.zoomScale > 2) {
        [scrollView setZoomScale:2];
    }
}

- (void)volumeValueChanged:(NSInteger)value {
}

#pragma mark - pick view delegate
-(void)toolbarCancelBtnHaveClick:(ZHPickView *)pickView{
    
}
-(void)toolbarDonBtnHaveClick:(ZHPickView *)pickView 
                 resultString:(NSString *)resultString 
                  selectedRow:(NSInteger)selectedRow{
    NSLog(@"%@",resultString);
    RCRTCVideoSizePreset preset = RCRTCVideoSizePreset480x360;
    if ([resultString isEqualToString: @"高清"]) {
        preset = RCRTCVideoSizePreset640x480;
    } else if ([resultString isEqualToString:@"超高清"]){
        preset = RCRTCVideoSizePreset1280x720;
    }
    RCRTCVideoStreamConfig *config = [[RCRTCVideoStreamConfig alloc] init];
    config.videoSizePreset = preset;
    [[RCRTCEngine sharedInstance].defaultVideoStream setVideoConfig:config];
    
}

#pragma mark - Private
- (void)showOrHideViews {
    showButtonSconds = 0;
    self.beauBtn.selected = NO;
    [self showButtons:isShowButton];
    if (isShowButton) {
        displayLink.paused = NO;
    }
    [self hideSelectFUView];
}

@end
