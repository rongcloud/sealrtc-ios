//
//  SettingViewController.m
//  RongCloud
//
//  Created by LiuLinhong on 16/11/11.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "SettingViewController.h"
#import "CommonUtility.h"
#import "SXAlertView.h"
#import "LoginViewController.h"
#import "SettingDebugModeViewController.h"

static NSUserDefaults *settingUserDefaults = nil;

@interface SettingViewController ()<UITextFieldDelegate>
{
    UITapGestureRecognizer *tapGestureRecognizer;
}
@end


@implementation SettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"setting_title", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.sectionNumber = 4;

    [self loadPlistData];
    
    self.settingTableViewDelegateSourceImpl = [[SettingTableViewDelegateSourceImpl alloc] initWithViewController:self];
    self.settingPickViewDelegateImpl = [[SettingPickViewDelegateImpl alloc] initWithViewController:self];
    self.settingViewBuilder = [[SettingViewBuilder alloc] initWithViewController:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadPlistData];
    self.sectionNumber = 4;

    [self.settingViewBuilder.tableView reloadData];
    
#ifdef DEBUG
    if (!tapGestureRecognizer)
    {
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerAction)];
        [tapGestureRecognizer setNumberOfTapsRequired:5];
    }
    [self.navigationController.view addGestureRecognizer:tapGestureRecognizer];
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.settingViewBuilder.resolutionRatioPickview remove];
    self.navigationItem.rightBarButtonItem = nil;
    [self.navigationController.view removeGestureRecognizer:tapGestureRecognizer];
}

- (BOOL)navigationShouldPopOnBackButton
{
    return YES;
}

#pragma mark - load default plist data
- (void)loadPlistData
{
    settingUserDefaults = [SettingViewController shareSettingUserDefaults];
    
    self.resolutionRatioArray = [CommonUtility getPlistArrayByplistName:Key_ResolutionRatio];
    self.frameRateArray = [CommonUtility getPlistArrayByplistName:Key_FrameRate];
    self.codeRateArray = [CommonUtility getPlistArrayByplistName:Key_CodeRate];
    self.codingStyleArray = [CommonUtility getPlistArrayByplistName:Key_CodingStyle];
    
    [self.tinyStreamSwitch setOn:kLoginManager.isTinyStream];
}

#pragma mark - connect style witch action
- (void)gpuSwitchAction
{
    [kLoginManager setIsGPUFilter:self.gpuSwitch.on];
}

- (void)tinyStreamSwitchAction
{
    [kLoginManager setIsTinyStream:self.tinyStreamSwitch.on];
}

- (void)autoTestAction
{
    [kLoginManager setIsAutoTest:self.autoTestSwitch.on];
}

#pragma mark - tap gesture action
- (void)tapGestureRecognizerAction
{
    SettingDebugModeViewController *settingDebugModeViewController = [[SettingDebugModeViewController alloc] init];
    if (![self.navigationController.topViewController isKindOfClass:[SettingDebugModeViewController class]])
        [self.navigationController pushViewController:settingDebugModeViewController animated:YES];
}

#pragma mark - share setting UserDefaults
+ (NSUserDefaults *)shareSettingUserDefaults
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settingUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"settingUserDefaults"];
    });
    return settingUserDefaults;
}

@end
