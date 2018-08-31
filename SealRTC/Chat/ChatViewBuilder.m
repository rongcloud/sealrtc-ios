//
//  ChatViewBuilder.m
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/18.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "ChatViewBuilder.h"
#import "ChatViewController.h"
#import "CommonUtility.h"

@interface ChatViewBuilder ()
{
    UIView *infoView;
    ChatBubbleMenuViewDelegateImpl *chatBubbleMenuViewDelegateImpl;
    BOOL isLeftDisplay, isRightDisplay;
}

@end

@implementation ChatViewBuilder
@synthesize upMenuView = upMenuView;


- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.chatViewController = (ChatViewController *) vc;
        [self initView];
        [self initTapGesture];
    }
    return self;
}

- (void)initView
{
    self.hungUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.hungUpButton.frame = CGRectMake(0, 0, 44, 44);
    
    NSString *deviceModel = [UIDevice currentDevice].model;
    if ([deviceModel containsString:@"iPad"])
        self.hungUpButton.center = CGPointMake(ScreenWidth/2, ScreenHeight - 44);
    else
        self.hungUpButton.center = CGPointMake(ScreenWidth/2, (ScreenHeight - (TitleHeight + self.chatViewController.videoHeight))/2 + (TitleHeight + self.chatViewController.videoHeight));
    
    [CommonUtility setButtonImage:self.hungUpButton imageName:@"chat_hung_up"];
    [self.hungUpButton addTarget:self.chatViewController action:@selector(didClickHungUpButton) forControlEvents:UIControlEventTouchUpInside];
    self.hungUpButton.backgroundColor = redButtonBackgroundColor;
    self.hungUpButton.layer.masksToBounds = YES;
    self.hungUpButton.layer.cornerRadius = 22.f;
//    [self.hungUpButton setEnabled:NO];
    [self.chatViewController.view addSubview:self.hungUpButton];
    
    
    self.rotateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rotateButton.frame = CGRectMake(0, 0, 36, 36);
    if ([deviceModel containsString:@"iPad"])
        self.rotateButton.center = CGPointMake(16.f+18.f, ScreenHeight - 44);
    else
        self.rotateButton.center = CGPointMake(16.f+18.f, (ScreenHeight - (TitleHeight + self.chatViewController.videoHeight))/2 + (TitleHeight + self.chatViewController.videoHeight));
    
    self.rotateButton.hidden = YES;
    [self.rotateButton addTarget:self.chatViewController action:@selector(didcClickRotateButton:) forControlEvents:UIControlEventTouchUpInside];
    self.rotateButton.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.4f];
    self.rotateButton.tintColor = [UIColor blackColor];
    
    [CommonUtility setButtonImage:self.rotateButton imageName:@"chat_rotate_off"];
    self.rotateButton.layer.masksToBounds = YES;
    self.rotateButton.layer.cornerRadius = 18.f;
    [self.chatViewController.view addSubview:self.rotateButton];
    
    self.openCameraButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.openCameraButton.frame = CGRectMake(ScreenWidth/2 - 120.f - 44.f, self.hungUpButton.frame.origin.y, 44.f, 44.f);
    self.openCameraButton.layer.cornerRadius = 44.f / 2.f;
    self.openCameraButton.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.4f];
    self.openCameraButton.clipsToBounds = YES;
    [self.openCameraButton addTarget:self.chatViewController action:@selector(didClickVideoMuteButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.openCameraButton setTintColor:[UIColor blackColor]];
    [self.chatViewController.view addSubview:self.openCameraButton];
    [CommonUtility setButtonImage:self.openCameraButton imageName:@"chat_open_camera"];
    
    self.microphoneOnOffButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.microphoneOnOffButton.frame = CGRectMake(ScreenWidth/2 + 120.f, self.hungUpButton.frame.origin.y, 44.f, 44.f);
    self.microphoneOnOffButton.layer.cornerRadius = 44.f / 2.f;
    self.microphoneOnOffButton.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.4f];
    self.microphoneOnOffButton.clipsToBounds = YES;
    [self.microphoneOnOffButton addTarget:self.chatViewController action:@selector(didClickAudioMuteButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.microphoneOnOffButton setTintColor:[UIColor blackColor]];
    [self.chatViewController.view addSubview:self.microphoneOnOffButton];
    [CommonUtility setButtonImage:self.microphoneOnOffButton imageName:@"chat_microphone_on"];

    [self initMenuButton];
    
    self.playbackModeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.playbackModeButton.frame = CGRectMake(self.chatViewController.view.frame.size.width - self.chatViewController.homeImageView.frame.size.width - 16.f, self.upMenuView.frame.origin.y - 56.0, 36.f, 36.f);
    
    self.playbackModeButton.layer.cornerRadius = 36.f / 2.f;
    self.playbackModeButton.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.4f];
    self.playbackModeButton.clipsToBounds = YES;
    [self.playbackModeButton addTarget:self.chatViewController action:@selector(didClickPlaybackModeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.playbackModeButton setTintColor:[UIColor blackColor]];
    [self.chatViewController.view addSubview:self.playbackModeButton];
    [CommonUtility setButtonImage:self.playbackModeButton imageName:@"chat_hd"];
    [self.chatViewController.view addSubview:self.playbackModeButton];
    self.playbackModeButton.center = CGPointMake(self.upMenuView.center.x, self.upMenuView.frame.origin.y - 30.0);
    
    self.hungUpButton.center = CGPointMake(ScreenWidth/2, ScreenHeight-ButtonWidth);
    self.openCameraButton.center = CGPointMake(ScreenWidth/2 - ButtonDistance - ButtonWidth/2, ScreenHeight-ButtonWidth);
    self.microphoneOnOffButton.center = CGPointMake(ScreenWidth/2 + ButtonDistance+ButtonWidth/2, ScreenHeight-ButtonWidth);
}

- (void)reloadChatView
{
    self.hungUpButton.center = CGPointMake(ScreenHeight/2, ScreenWidth - 44);
    upMenuView.frame = CGRectMake(self.chatViewController.view.frame.size.height - self.chatViewController.homeImageView.frame.size.height - 16.f, ScreenWidth - 60, self.chatViewController.homeImageView.frame.size.height, self.chatViewController.homeImageView.frame.size.width);
 }

#pragma mark - init menu button
- (void)initMenuButton
{
    chatBubbleMenuViewDelegateImpl = [[ChatBubbleMenuViewDelegateImpl alloc] initWithViewController:self.chatViewController];
    
    self.chatViewController.homeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 36.f, 36.f)];
    self.chatViewController.homeImageView.userInteractionEnabled = YES;
    self.chatViewController.homeImageView.image = [UIImage imageNamed:@"chat_menu"];
    self.chatViewController.homeImageView.backgroundColor = [UIColor whiteColor];
    self.chatViewController.homeImageView.layer.masksToBounds = YES;
    self.chatViewController.homeImageView.layer.cornerRadius = self.chatViewController.homeImageView.frame.size.width / 2.f;
    
    CGRect BubbleMenuButtonRect;
    NSString *deviceModel = [UIDevice currentDevice].model;
    if ([deviceModel containsString:@"iPad"])
    {
        BubbleMenuButtonRect = CGRectMake(self.chatViewController.view.frame.size.width - self.chatViewController.homeImageView.frame.size.width - 16.f, ScreenHeight - 60, self.chatViewController.homeImageView.frame.size.width, self.chatViewController.homeImageView.frame.size.height);
    }
    else
    {
        BubbleMenuButtonRect = CGRectMake(self.chatViewController.view.frame.size.width - self.chatViewController.homeImageView.frame.size.width - 16.f, (ScreenHeight - (TitleHeight + self.chatViewController.videoHeight) - 36)/2 + (TitleHeight + self.chatViewController.videoHeight), self.chatViewController.homeImageView.frame.size.width, self.chatViewController.homeImageView.frame.size.height);
    }
    upMenuView = [[DWBubbleMenuButton alloc] initWithFrame:BubbleMenuButtonRect expansionDirection:DirectionUp];
//    upMenuView.center = CGPointMake(self.chatViewController.view.frame.size.width - self.chatViewController.homeImageView.frame.size.width/2 - 16.f, ScreenHeight/2+(6*36+5*10)/2);
    CGFloat centerY = MAX(ScreenHeight/2+(8*36+7*10)/2, self.chatViewController.dataTrafficLabel.frame.origin.y+self.chatViewController.dataTrafficLabel.frame.size.height + 130.0 + (8*36+7*10));
    centerY = MAX(ScreenHeight/2+(6*36+5*10)/2,self.chatViewController.dataTrafficLabel.frame.origin.y+self.chatViewController.dataTrafficLabel.frame.size.height + 130.0 + (6*36+5*10));

    upMenuView.center = CGPointMake(self.chatViewController.view.frame.size.width - self.chatViewController.homeImageView.frame.size.width/2 - 16.f, centerY);
    _originCenter = CGPointMake(self.chatViewController.view.frame.size.width - self.chatViewController.homeImageView.frame.size.width/2 - 16.f, centerY);
    
    upMenuView.homeButtonView = self.chatViewController.homeImageView;
    upMenuView.delegate = chatBubbleMenuViewDelegateImpl;
    [upMenuView addButtons:[self createDemoButtonArray]];
    [self.chatViewController.view addSubview:upMenuView];
    [upMenuView showButtons];
    upMenuView.homeButtonView.hidden = YES;
}

- (NSArray *)createDemoButtonArray
{
    NSMutableArray *buttonsMutable = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < 4; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(0.f, 0.f, 36.f, 36.f);
        button.layer.cornerRadius = button.frame.size.height / 2.f;
        button.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.4f];
        button.clipsToBounds = YES;
        button.tag = i;
        [button addTarget:self.chatViewController action:@selector(menuItemButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [buttonsMutable addObject:button];
        [button setTintColor:[UIColor blackColor]];
        
        switch (button.tag)
        {
            case 0:
            {
                self.raiseHandButton = button;
                [CommonUtility setButtonImage:button imageName:@"chat_handup_off"];
            }
                break;
            case 1:
            {
                self.whiteBoardButton = button;
                [CommonUtility setButtonImage:button imageName:@"chat_white_board_off"];
            }
                break;
            case 2:
                self.switchCameraButton = button;
                [CommonUtility setButtonImage:button imageName:@"chat_switch_camera"];
                break;
            case 3:
            {
                self.speakerOnOffButton = button;
                [CommonUtility setButtonImage:button imageName:@"chat_speaker_on"];
            }
                break;
            case 4:
            {
                self.videoProfileUpButton = button;
                [CommonUtility setButtonImage:button imageName:@"chat_preview_up_enable"];
            }
                break;

            case 5:
            {
                self.videoProfileDownButton = button;
                [CommonUtility setButtonImage:button imageName:@"chat_preview_down_enable"];
            }
                break;
            case 8:
            {
                self.stopRecordingButton = button;
                [CommonUtility setButtonImage:button imageName:@"chat_microphone_on"];
            }
                break;
            case 9:
            {
                self.playRecordButton = button;
                [CommonUtility setButtonImage:button imageName:@"chat_microphone_on"];
            }

                break;
            default:
                break;
        }
    }
    
    return [buttonsMutable copy];
}

- (void)initTapGesture
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerAction)];
    [self.chatViewController.videoMainView addGestureRecognizer:tapGestureRecognizer];
}

- (void)tapGestureRecognizerAction
{
    if (!upMenuView.isCollapsed)
    {
//        [upMenuView dismissButtons];
    }
}

- (void)tapGesturAction:(UITapGestureRecognizer *)recognize
{
//    [self.chatViewController showButtonsWithTap];
}

@end
