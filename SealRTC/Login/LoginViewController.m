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
#import "STCountryTableViewController.h"
#import "RCDCountry.h"

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

@interface LoginViewController ()<UIAlertViewDelegate,UITextFieldDelegate,STCountryTableViewControllerDelegate>
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
        CGFloat originY = 130;
        if (weakSelf.view.frame.size.width == 320) {
            originY = originY - 44;
        }
        weakSelf.loginViewBuilder.inputNumPasswordView.frame = CGRectMake(weakSelf.loginViewBuilder.inputNumPasswordView.frame.origin.x, originY, weakSelf.loginViewBuilder.inputNumPasswordView.frame.size.width, weakSelf.loginViewBuilder.inputNumPasswordView.frame.size.height);
        
    } completion:^(BOOL finished) {
    }];
    
    self.loginViewBuilder.roomNumberTextField.text = kLoginManager.roomNumber;
    self.loginViewBuilder.phoneNumTextField.text = kLoginManager.phoneNumber;
    self.loginViewBuilder.phoneNumLoginTextField.text = kLoginManager.phoneNumber;
    self.loginViewBuilder.usernameTextField.text = kLoginManager.username;
    if (kLoginManager.countryCode.length > 0 && kLoginManager.regionName.length > 0) {
        self.loginViewBuilder.countryCodeLabel.text = [NSString stringWithFormat:@"+%@",kLoginManager.countryCode];
        self.loginViewBuilder.loginCountryCodeLabel.text = [NSString stringWithFormat:@"+%@",kLoginManager.countryCode];
        NSString* select_fmt = NSLocalizedString(@"select_country_fmt", nil);
        self.loginViewBuilder.countryTxtField.text = [NSString stringWithFormat:select_fmt,kLoginManager.regionName];
        self.loginViewBuilder.loginCountryTxtField.text = [NSString stringWithFormat:select_fmt,kLoginManager.regionName];
    }
    

    joinRoomState = JoinRoom_Token;
    
    [self updateSendSMSButtonEnable:[CommonUtility validateContactNumber:kLoginManager.phoneNumber]];
    
    if ([self.loginViewBuilder.roomNumberTextField.text isEqualToString:@""])
        self.isRoomNumberInput = NO;
    if (self.loginViewBuilder.usernameTextField.text.length <= 0) {
        self.isRoomNumberInput = NO;
    }
    [self updateJoinRoomButtonEnable:NO textFieldInput:self.isRoomNumberInput];
    
    [[RCIMClient sharedRCIMClient] initWithAppKey:RCIMAPPKey];
    
    NSString *naviHost = RCIMNavURL;
    if (![naviHost hasPrefix:@"http"]) {
        naviHost = [@"https://" stringByAppendingString:RCIMNavURL];
    }
    
    NSString *fileHost = RCIMFileURL;
    if (![fileHost hasPrefix:@"http"]) {
        fileHost = [@"https://" stringByAppendingString:RCIMFileURL];
    }
    
    [[RCIMClient sharedRCIMClient] setServerInfo:naviHost fileServer:fileHost];
    [[RCIMClient sharedRCIMClient] setRCConnectionStatusChangeDelegate:self];
    if (Key_Force_Close_Log) {
        [[RCIMClient sharedRCIMClient] setLogLevel:4];
    }
    else{
        [[RCIMClient sharedRCIMClient] setLogLevel:RC_Log_Level_Info];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.navigationController.navigationBarHidden = YES;
    
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
    if (self.loginViewBuilder.roomNumberTextField.text.length <= 0 ||
        self.loginViewBuilder.usernameTextField.text.length <= 0 ||
        self.loginViewBuilder.phoneNumLoginTextField.text.length <= 0)
        self.isRoomNumberInput = NO;
    else
        self.isRoomNumberInput = YES;
    
    [self updateJoinRoomButtonEnable:YES textFieldInput:self.isRoomNumberInput];
}

- (void)userNameTextfieldDidChange:(UITextField*)textField {
    if (self.loginViewBuilder.roomNumberTextField.text.length <= 0 ||
        self.loginViewBuilder.usernameTextField.text.length <= 0 ||
        self.loginViewBuilder.phoneNumLoginTextField.text.length <= 0) {
        self.isRoomNumberInput = NO;
    } else {
        self.isRoomNumberInput = YES;
    }
    [self updateJoinRoomButtonEnable:YES textFieldInput:self.isRoomNumberInput];
}

- (void)phoneNumLoginTextFieldDidChange:(UITextField *)textField
{
    if (self.loginViewBuilder.roomNumberTextField.text.length <= 0 ||
        self.loginViewBuilder.usernameTextField.text.length <= 0 ||
        self.loginViewBuilder.phoneNumLoginTextField.text.length <= 0) {
        self.isRoomNumberInput = NO;
    } else  if ([CommonUtility validateContactNumber:self.loginViewBuilder.phoneNumLoginTextField.text]) {
        self.isRoomNumberInput = YES;
    }

    [self updateJoinRoomButtonEnable:YES textFieldInput:self.isRoomNumberInput];
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
                    [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_login_connecting", nil) forState:UIControlStateNormal];
                    [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_login_connecting", nil) forState:UIControlStateHighlighted];
                }
                    break;
                case JoinRoom_Disconnected:
                {
                    [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_login_network_disable", nil) forState:UIControlStateNormal];
                    [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_login_network_disable", nil) forState:UIControlStateHighlighted];
                }
                    break;
                default:
                    break;
            }
        }
        else
        {
            [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_need_room_number", nil) forState:UIControlStateNormal];
            [self.loginViewBuilder.joinRoomButton setTitle:NSLocalizedString(@"login_input_need_room_number", nil) forState:UIControlStateHighlighted];
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
    kLoginManager.username = self.loginViewBuilder.usernameTextField.text;
    
    DLog(@"Cache keyToken: %@", kLoginManager.keyToken);
    if (!kLoginManager.keyToken || kLoginManager.keyToken.length == 0) {
        self.loginViewBuilder.phoneNumTextField.text = kLoginManager.phoneNumber;
        [self.loginViewBuilder showValidateView:YES];
        self.loginViewBuilder.countryTxtField.delegate = self;
        [self updateSendSMSButtonEnable:[CommonUtility validateContactNumber:kLoginManager.phoneNumber]];
        CGFloat  originY = 186;
        if (self.view.frame.size.width == 320) {
            originY = originY - 44;
        }
        self.loginViewBuilder.inputNumPasswordView.frame = CGRectMake(0, originY,self.loginViewBuilder.inputNumPasswordView.frame.size.width, self.loginViewBuilder.inputNumPasswordView.frame.size.height);
    }
    else if (kLoginManager.isIMConnectionSucc) {
        [self navToChatViewController];
    }
    else {
        [[RCIMClient sharedRCIMClient] connectWithToken:kLoginManager.keyToken
                                                success:^(NSString *userId) {
                                                    DLog(@"MClient connectWithToken Success userId: %@", userId);
                                                    kLoginManager.userID = userId;
                                                    [self navToChatViewController];
                                                }
                                                  error:^(RCConnectErrorCode status) {
                                                      DLog(@"MClient connectWithToken Error: %zd", status);
                                                      if (status == RC_CONN_TOKEN_INCORRECT) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [self.loginViewBuilder showValidateView:YES];

                                                          });
                                                      }
                                                  }
                                         tokenIncorrect:^{
                                             DLog(@"MClient connectWithToken tokenIncorrect: ");
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                [self.loginViewBuilder showValidateView:YES];
                                             });
                                         }];
    }
}

#pragma mark - click send SMS button
- (void)sendSMSButtonPressed:(id)sender
{
    [self startSendSMSTimer];
    NSString* code = [self.loginViewBuilder.countryCodeLabel.text substringFromIndex:1];
    [[RTHttpNetworkWorker shareInstance] fetchSMSValidateCode:self.loginViewBuilder.phoneNumTextField.text regionCode:code
                                                      success:^(NSString * _Nonnull code) {
                                                          DLog(@"send SMS respond code: %@", code);
                                                      } error:^(NSError * _Nonnull error) {
                                                          DLog(@"send SMS request Error: %@", error);
                                                      }];
}

#pragma mark - click validate logon button
- (void)validateLogonButtonPressed:(id)sender
{
    NSString* regionCode = [self.loginViewBuilder.countryCodeLabel.text substringFromIndex:1];
    [[RTHttpNetworkWorker shareInstance]
        validateSMSPhoneNum:self.loginViewBuilder.phoneNumTextField.text
                 regionCode:regionCode
                       code:self.loginViewBuilder.validateSMSTextField.text
                   response:^(NSDictionary * _Nonnull respDict) {
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
                                self.loginViewBuilder.alertLabel.text = NSLocalizedString(@"login_input_verify_error", nil);
                            }
                        });
    } error:^(NSError * _Nonnull error) {
        self.loginViewBuilder.alertLabel.text = NSLocalizedString(@"login_input_verify_error", nil);
    }];
}

#pragma mark - click setting button
- (void)loginSettingButtonPressed
{
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

- (void)fetchCountryPhoneCode:(RCDCountry*)info {
    self.loginViewBuilder.countryCodeLabel.text = [NSString stringWithFormat:@"+%@",info.phoneCode];
    self.loginViewBuilder.loginCountryCodeLabel.text = [NSString stringWithFormat:@"+%@",info.phoneCode];
    NSString* select_fmt = NSLocalizedString(@"select_country_fmt", nil);
    self.loginViewBuilder.countryTxtField.text = [NSString stringWithFormat:select_fmt,info.countryName];
    self.loginViewBuilder.loginCountryTxtField.text = [NSString stringWithFormat:select_fmt,info.countryName];
    kLoginManager.countryCode = info.phoneCode;
    kLoginManager.regionName = info.countryName;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.loginViewBuilder.countryTxtField ||
        textField == self.loginViewBuilder.loginCountryTxtField ) {
        STCountryTableViewController* stc = [[STCountryTableViewController alloc] init];
        stc.delegate = self;
////        UIViewController* vc = [[UIViewController alloc] init];
        [self.navigationController pushViewController:stc animated:YES];
        return NO;
    }
    return  YES;
}



- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait ;
}

@end
