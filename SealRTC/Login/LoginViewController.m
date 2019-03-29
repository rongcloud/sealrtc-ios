//
//  LoginViewController.m
//  SealRTC
//
//  Created by LiuLinhong on 2016/11/16.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "SealRTCAppDelegate.h"
#import "ChatViewController.h"
#import "CommonUtility.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+length.h"
#import "RTHttpNetworkWorker.h"


typedef NS_ENUM(NSInteger, TextFieldInputError)
{
    TextFieldInputErrorNil,
    TextFieldInputErrorLength,
    TextFieldInputErrorIllegal,
    TextFieldInputErrorNone
};

typedef NS_ENUM(NSInteger, JoinRoomState)
{
    JoinRoom_Token,
    JoinRoom_Connecting,
    JoinRoom_Disconnected,
};

static NSString * const SegueIdentifierChat = @"Chat";
static NSDictionary *selectedServer;

@interface LoginViewController ()<UIAlertViewDelegate>
{
    NSUserDefaults *settingUserDefaults;
    TextFieldInputError inputError;
    JoinRoomState joinRoomState;
    NSTimer *countdownTimer;
    NSUInteger countdown;
}
@end


@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isRoomNumberInput = YES;
    __weak typeof(self) weakSelf = self;
    
    self.networkReachability = [Reachability reachabilityForInternetConnection];
    [self.networkReachability startNotifier];
    self.currentNetworkStatus = [self.networkReachability currentReachabilityStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginReachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    kLoginManager;
    
    self.loginTextFieldDelegateImpl = [[LoginTextFieldDelegateImpl alloc] initWithViewController:self];
    self.settingViewController = [[SettingViewController alloc] init];
    self.settingViewController.loginVC = self;
    self.loginViewBuilder = [[LoginViewBuilder alloc] initWithViewController:self];
    
    [UIView animateWithDuration:0.4 animations:^{
        weakSelf.view.backgroundColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
        weakSelf.loginViewBuilder.loginIconImageView.frame = CGRectMake(weakSelf.loginViewBuilder.loginIconImageView.frame.origin.x, 50, weakSelf.loginViewBuilder.loginIconImageView.frame.size.width, weakSelf.loginViewBuilder.loginIconImageView.frame.size.height);
        weakSelf.loginViewBuilder.inputNumPasswordView.frame = CGRectMake(weakSelf.loginViewBuilder.inputNumPasswordView.frame.origin.x, 186, weakSelf.loginViewBuilder.inputNumPasswordView.frame.size.width, weakSelf.loginViewBuilder.inputNumPasswordView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
    
    self.loginViewBuilder.roomNumberTextField.text = kLoginManager.roomNumber;
    self.loginViewBuilder.phoneNumTextField.text = kLoginManager.phoneNumber;
    self.loginViewBuilder.phoneNumLoginTextField.text = kLoginManager.phoneNumber;
    joinRoomState = JoinRoom_Token;
    
    [self updateSendSMSButtonEnable:[CommonUtility validateContactNumber:kLoginManager.phoneNumber]];
    
    if ([self.loginViewBuilder.roomNumberTextField.text isEqualToString:@""])
        self.isRoomNumberInput = NO;
    [self updateJoinRoomButtonEnable:NO textFieldInput:self.isRoomNumberInput];
    
    [[RCIMClient sharedRCIMClient] initWithAppKey:RCIMAPPKey];
    [[RCIMClient sharedRCIMClient] setServerInfo:RCIMNavURL fileServer:RCIMFileURL];
    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:self];
    [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Info];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.navigationController.navigationBarHidden = YES;
    
    SealRTCAppDelegate *appDelegate = (SealRTCAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.isForcePortrait = YES;
    [appDelegate application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
    
    DLog(@"Cache keyToken: %@", kLoginManager.keyToken);
    [self updateJoinRoomButtonEnable:YES textFieldInput:self.isRoomNumberInput];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self.alertController dismissViewControllerAnimated:YES completion:nil];
    self.alertController = nil;
}

- (void)loginReachabilityChanged:(NSNotification *)noti
{
    Reachability *reachability = [noti object];
    self.currentNetworkStatus = [reachability currentReachabilityStatus];
    BOOL success = (self.currentNetworkStatus == NotReachable) ? NO : YES;
    if ((self.currentNetworkStatus == NotReachable))
        joinRoomState = JoinRoom_Disconnected;
    else
        joinRoomState = JoinRoom_Connecting;
    
    [self updateJoinRoomButtonEnable:success textFieldInput:self.isRoomNumberInput];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - setter
+ (NSDictionary *)selectedConfigData
{
    return selectedServer;
}

#pragma mark - room number text change
- (void)roomNumberTextFieldDidChange:(UITextField *)textField
{
    if ([self.loginViewBuilder.roomNumberTextField.text isEqualToString:@""])
        self.isRoomNumberInput = NO;
    else
        self.isRoomNumberInput = YES;
    
    [self updateJoinRoomButtonEnable:YES textFieldInput:self.isRoomNumberInput];
}

- (void)phoneNumTextFieldDidChange:(UITextField *)textField
{
    if (countdown == 0) {
        [self updateSendSMSButtonEnable:[CommonUtility validateContactNumber:textField.text]];
    }
    else
    {
        if (![self.loginViewBuilder.validateSMSTextField.text isEqualToString:@""]
            && [CommonUtility validateContactNumber:self.loginViewBuilder.phoneNumTextField.text])
        {
            [self updateValidateLogonButtonEnable:YES];
        } else {
            [self updateValidateLogonButtonEnable:NO];
        }
    }
}

- (void)validateSMSTextFieldDidChange:(UITextField *)textField
{
    if (![self.loginViewBuilder.validateSMSTextField.text isEqualToString:@""]
        && [CommonUtility validateContactNumber:self.loginViewBuilder.phoneNumTextField.text])
    {
        [self updateValidateLogonButtonEnable:YES];
    } else {
        [self updateValidateLogonButtonEnable:NO];
    }
}

#pragma mark - change join button enable/unenable
- (void)updateJoinRoomButtonEnable:(BOOL)success textFieldInput:(BOOL)input
{
    dispatch_async(dispatch_get_main_queue(), ^{
    if (success && input)
    {
        self.loginViewBuilder.joinRoomButton.enabled = YES;
        self.loginViewBuilder.joinRoomButton.backgroundColor = JoinButtonEnableBackgroundColor;
        [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_enter_meeting_room", nil) forState:UIControlStateNormal];
        [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_enter_meeting_room", nil) forState:UIControlStateHighlighted];
    }
    else
    {
        self.loginViewBuilder.joinRoomButton.enabled = NO;
        self.loginViewBuilder.joinRoomButton.backgroundColor = JoinButtonUnableBackgroundColor;
        
        if (input)
        {
            switch (self->joinRoomState)
            {
//                case JoinRoom_Token:
//                {
//                    [self.loginViewBuilder.joinRoomButton setTitle:@"查询Token中" forState:UIControlStateNormal];
//                    [self.loginViewBuilder.joinRoomButton setTitle:@"查询Token中" forState:UIControlStateHighlighted];
//                }
//                    break;
                case JoinRoom_Connecting:
                {
                    [self.loginViewBuilder.joinRoomButton setTitle:@"连接中" forState:UIControlStateNormal];
                    [self.loginViewBuilder.joinRoomButton setTitle:@"连接中" forState:UIControlStateHighlighted];
                }
                    break;
                case JoinRoom_Disconnected:
                {
                    [self.loginViewBuilder.joinRoomButton setTitle:@"当前网络不可用，请检查网络设置" forState:UIControlStateNormal];
                    [self.loginViewBuilder.joinRoomButton setTitle:@"当前网络不可用，请检查网络设置" forState:UIControlStateHighlighted];
                }
                    break;
                default:
                    break;
            }
        }
        else
        {
            [self.loginViewBuilder.joinRoomButton setTitle:@"请输入房间号" forState:UIControlStateNormal];
            [self.loginViewBuilder.joinRoomButton setTitle:@"请输入房间号" forState:UIControlStateHighlighted];
        }
    }
    });
}

#pragma mark - prepareForSegue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (![segue.identifier isEqualToString:SegueIdentifierChat])
        return;
}

- (void)navToChatViewController
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loginViewBuilder.roomNumberTextField resignFirstResponder];
        if (![self.navigationController.topViewController isKindOfClass:[ChatViewController class]]){
            [self performSegueWithIdentifier:SegueIdentifierChat sender:self.loginViewBuilder.joinRoomButton];
        }
    });
}

#pragma mark - click join Button
- (void)joinRoomButtonPressed:(id)sender
{
    kLoginManager.roomNumber = self.loginViewBuilder.roomNumberTextField.text;
    kLoginManager.phoneNumber = self.loginViewBuilder.phoneNumLoginTextField.text;
    DLog(@"Cache keyToken: %@", kLoginManager.keyToken);
    if (!kLoginManager.keyToken || kLoginManager.keyToken.length == 0) {
        self.loginViewBuilder.phoneNumTextField.text = kLoginManager.phoneNumber;
        [self.loginViewBuilder showValidateView:YES];
        [self updateSendSMSButtonEnable:[CommonUtility validateContactNumber:kLoginManager.phoneNumber]];
    }
    else if (kLoginManager.isIMConnectionSucc) {
        [self navToChatViewController];
    }
    else {
        [[RCIMClient sharedRCIMClient] connectWithToken:kLoginManager.keyToken
                                                success:^(NSString *userId) {
                                                    DLog(@"MClient connectWithToken Success userId: %@", userId);
                                                    [self navToChatViewController];
                                                }
                                                  error:^(RCConnectErrorCode status) {
                                                      DLog(@"MClient connectWithToken Error: %zd", status);
                                                      if (status == RC_CONN_TOKEN_INCORRECT) {
                                                          [self.loginViewBuilder showValidateView:YES];
                                                      }
                                                  }
                                         tokenIncorrect:^{
                                             DLog(@"MClient connectWithToken tokenIncorrect: ");
                                             [self.loginViewBuilder showValidateView:YES];
                                         }];
    }
}

#pragma mark - click send SMS button
- (void)sendSMSButtonPressed:(id)sender
{
    [self startSendSMSTimer];
    [[RTHttpNetworkWorker shareInstance] fetchSMSValidateCode:self.loginViewBuilder.phoneNumTextField.text success:^(NSString * _Nonnull code) {
        DLog(@"send SMS respond code: %@", code);
    } error:^(NSError * _Nonnull error) {
        DLog(@"send SMS request Error: %@", error);
    }];
}

#pragma mark - click validate logon button
- (void)validateLogonButtonPressed:(id)sender
{
    [[RTHttpNetworkWorker shareInstance] validateSMSPhoneNum:self.loginViewBuilder.phoneNumTextField.text code:self.loginViewBuilder.validateSMSTextField.text response:^(NSDictionary * _Nonnull respDict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger code = [respDict[@"code"] integerValue];
            if (code == 200) {
                [self.loginViewBuilder showValidateView:NO];
                kLoginManager.phoneNumber = self.loginViewBuilder.phoneNumTextField.text;
                self.loginViewBuilder.phoneNumLoginTextField.text = kLoginManager.phoneNumber;
                
                kLoginManager.keyToken = respDict[@"result"][@"token"];
                kLoginManager.isLoginTokenSucc = YES;
                self->joinRoomState = JoinRoom_Connecting;
                [self updateJoinRoomButtonEnable:YES textFieldInput:self.isRoomNumberInput];
            }
            else {
                self.loginViewBuilder.alertLabel.text = @"验证码错误, 请重新获取";
            }
        });
    } error:^(NSError * _Nonnull error) {
        self.loginViewBuilder.alertLabel.text = @"验证码错误, 请重新获取";
    }];
}

#pragma mark - click setting button
- (void)loginSettingButtonPressed
{
    kLoginManager.isCloseCamera = NO;
    if (![self.navigationController.topViewController isKindOfClass:[SettingViewController class]])
        [self.navigationController pushViewController:self.settingViewController animated:YES];
}

#pragma mark - click redio button
- (void)onRadioButtonValueChanged:(RadioButton *)radioButton
{
    if (radioButton.tag == 0)
    {
        if (radioButton.selected)
        {
            kLoginManager.isCloseCamera = YES;
            kLoginManager.isObserver = NO;
        }
        else
            kLoginManager.isCloseCamera = NO;
    }
    else if (radioButton.tag == 1)
    {
        if (radioButton.selected)
        {
            kLoginManager.isCloseCamera = NO;
            kLoginManager.isObserver = YES;
        }
        else
            kLoginManager.isObserver = NO;
    }
    
    [self.loginViewBuilder.roomNumberTextField resignFirstResponder];
    [self.loginViewBuilder.phoneNumLoginTextField resignFirstResponder];
}

#pragma mark - gesture selector method
- (IBAction)didTapHideKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark - Private
- (void)startSendSMSTimer
{
    if (countdown == 0 && !countdownTimer)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateSendSMSButtonEnable:NO];
            NSString *cTime = [NSString stringWithFormat:@"60%@", NSLocalizedString(@"login_input_count_down_sec", nil)];
            [self.loginViewBuilder.sendSMSButton setTitle:cTime forState:UIControlStateNormal];
            [self.loginViewBuilder.sendSMSButton setTitle:cTime forState:UIControlStateHighlighted];
            
            self->countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCountDownLabel) userInfo:nil repeats:YES];
        });
    }
}

- (void)updateCountDownLabel
{
    countdown++;
    if (countdown < 60) {
        NSInteger cdSec = 60 - countdown;
        NSString *cTime = [NSString stringWithFormat:@"%zd%@", cdSec, NSLocalizedString(@"login_input_count_down_sec", nil)];
        [self.loginViewBuilder.sendSMSButton setTitle:cTime forState:UIControlStateNormal];
        [self.loginViewBuilder.sendSMSButton setTitle:cTime forState:UIControlStateHighlighted];
    }
    else {
        countdown = 0;
        [countdownTimer invalidate];
        countdownTimer = nil;
        [self updateSendSMSButtonEnable:[CommonUtility validateContactNumber:self.loginViewBuilder.phoneNumTextField.text]];
        [self.loginViewBuilder.sendSMSButton setTitle:NSLocalizedString(@"login_input_phone_send_sms", nil) forState:UIControlStateNormal];
        [self.loginViewBuilder.sendSMSButton setTitle:NSLocalizedString(@"login_input_phone_send_sms", nil) forState:UIControlStateHighlighted];
    }
}

- (void)updateSendSMSButtonEnable:(BOOL)isEnable
{
    self.loginViewBuilder.sendSMSButton.enabled = isEnable;
    self.loginViewBuilder.sendSMSButton.backgroundColor = isEnable ? JoinButtonEnableBackgroundColor : JoinButtonUnableBackgroundColor;
}

- (void)updateValidateLogonButtonEnable:(BOOL)isEnable
{
    self.loginViewBuilder.validateLogonButton.enabled = isEnable;
    self.loginViewBuilder.validateLogonButton.backgroundColor = isEnable ? JoinButtonEnableBackgroundColor : JoinButtonUnableBackgroundColor;
}

#pragma mark - RCConnectionStatusChangeDelegate
- (void)onConnectionStatusChanged:(RCConnectionStatus)status
{
    switch (status) {
        case ConnectionStatus_Connected:
        {
            kLoginManager.isIMConnectionSucc = YES;
            [self updateJoinRoomButtonEnable:kLoginManager.isIMConnectionSucc textFieldInput:self.isRoomNumberInput];
        }
            break;
        case ConnectionStatus_Unconnected:
        {
            kLoginManager.isIMConnectionSucc = NO;
        }
            break;
        default:
            break;
    }
}

@end
