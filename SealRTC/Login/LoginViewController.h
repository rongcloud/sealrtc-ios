//
//  LoginViewController.h
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/16.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongRTCLib/RongRTCEngine.h>
#import "SettingViewController.h"
#import "LoginViewBuilder.h"
#import "LoginRongRTCEngineDelegateImpl.h"
#import "LoginTextFieldDelegateImpl.h"
#import "MessageStatusBar.h"
#import "Reachability.h"

/**
 *定义网络连接方式
 */
typedef NS_ENUM(NSInteger, RongRTCConnectionMode)
{
    RongRTC_ConnectionMode_TCP = 0,
    RongRTC_ConnectionMode_QUIC = 1
};

@interface LoginViewController : UIViewController

@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) NSArray *configListArray;
@property (nonatomic, strong) RongRTCEngine *rongRTCEngine;
@property (nonatomic, strong) NSString *keyToken;
@property (nonatomic, strong) NSURL *tokenURL;
@property (nonatomic, strong) NSString *userDefinedToken, *userDefinedCMP, *userDefinedAppKey;
@property (nonatomic, strong) SettingViewController *settingViewController;
@property (nonatomic, strong) LoginViewBuilder *loginViewBuilder;
@property (nonatomic, strong) LoginRongRTCEngineDelegateImpl *loginRongRTCEngineDelegateImpl;
@property (nonatomic, strong) LoginTextFieldDelegateImpl *loginTextFieldDelegateImpl;
@property (nonatomic, assign) BOOL isUserDefinedTokenAndCMP, isRoomNumberInput;
//@property (nonatomic, strong) MessageStatusBar *messageStatusBar;
@property (nonatomic, strong) Reachability *networkReachability;
@property (nonatomic, assign) NetworkStatus currentNetworkStatus;

+ (NSDictionary *)selectedConfigData;
+ (NSString *)getKeyToken;
+ (void)setConnectionState:(RongRTCConnectionState)state;
- (void)roomNumberTextFieldDidChange:(UITextField *)textField;
- (void)userNameTextFieldDidChange:(UITextField *)textField;
- (void)joinRoomButtonPressed:(id)sender;
- (void)onRadioButtonValueChanged:(RadioButton *)sender;
- (void)loginSettingButtonPressed;
- (void)updateJoinRoomButtonSocket:(RongRTCConnectionState)state;

@end
