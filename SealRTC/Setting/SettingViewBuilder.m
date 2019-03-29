//
//  SettingViewBuilder.m
//  RongCloud
//
//  Created by LiuLinhong on 2016/12/01.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "SettingViewBuilder.h"
#import "SettingViewController.h"

@interface SettingViewBuilder ()

@property (nonatomic, weak) SettingViewController *settingViewController;

@end

@implementation SettingViewBuilder

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.settingViewController = (SettingViewController *) vc;
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.settingViewController.gpuSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth -6-60, 6, 60, 28)];
    [self.settingViewController.gpuSwitch addTarget:self.settingViewController action:@selector(gpuSwitchAction) forControlEvents:UIControlEventValueChanged];
    [self.settingViewController.gpuSwitch setOn:kLoginManager.isGPUFilter];
    
    self.settingViewController.tinyStreamSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth -6-60, 6, 60, 28)];
    [self.settingViewController.tinyStreamSwitch addTarget:self.settingViewController action:@selector(tinyStreamSwitchAction) forControlEvents:UIControlEventValueChanged];
    [self.settingViewController.tinyStreamSwitch setOn:kLoginManager.isTinyStream];
    
    self.settingViewController.autoTestSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth -6-60, 6, 60, 28)];
    [self.settingViewController.autoTestSwitch addTarget:self.settingViewController action:@selector(autoTestAction) forControlEvents:UIControlEventValueChanged];
    [self.settingViewController.autoTestSwitch setOn:kLoginManager.isAutoTest];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self.settingViewController.settingTableViewDelegateSourceImpl;
    self.tableView.delegate = self.settingViewController.settingTableViewDelegateSourceImpl;
    [self.settingViewController.view addSubview:self.tableView];
    
    self.resolutionRatioPickview = [[ZHPickView alloc] initPickviewWithPlistName:Key_ResolutionRatio isHaveNavControler:NO];
    self.resolutionRatioPickview.delegate = self.settingViewController.settingPickViewDelegateImpl;
    [self.resolutionRatioPickview setSelectedPickerItem:kLoginManager.resolutionRatioIndex];
}

@end
