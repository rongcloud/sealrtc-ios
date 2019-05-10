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
    self.gpuSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth -6-60, 6, 60, 28)];
    [self.gpuSwitch addTarget:self.settingViewController action:@selector(gpuSwitchAction) forControlEvents:UIControlEventValueChanged];
    [self.gpuSwitch setOn:kLoginManager.isGPUFilter];
    
    self.tinyStreamSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth -6-60, 6, 60, 28)];
    [self.tinyStreamSwitch addTarget:self.settingViewController action:@selector(tinyStreamSwitchAction) forControlEvents:UIControlEventValueChanged];
    [self.tinyStreamSwitch setOn:kLoginManager.isTinyStream];
    
    self.autoTestSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth -6-60, 6, 60, 28)];
    [self.autoTestSwitch addTarget:self.settingViewController action:@selector(autoTestAction) forControlEvents:UIControlEventValueChanged];
    [self.autoTestSwitch setOn:kLoginManager.isAutoTest];
    
    self.waterMarkSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth -6-60, 6, 60, 28)];
    [self.waterMarkSwitch addTarget:self.settingViewController action:@selector(waterMarkAction) forControlEvents:UIControlEventValueChanged];
    [self.waterMarkSwitch setOn:kLoginManager.isWaterMark];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self.settingViewController.settingTableViewDelegateSourceImpl;
    self.tableView.delegate = self.settingViewController.settingTableViewDelegateSourceImpl;
    [self.settingViewController.view addSubview:self.tableView];
    
    self.resolutionRatioPickview = [[ZHPickView alloc] initPickviewWithPlistName:Key_ResolutionRatio isHaveNavControler:NO];
    self.resolutionRatioPickview.delegate = self.settingViewController.settingPickViewDelegateImpl;
    [self.resolutionRatioPickview setSelectedPickerItem:kLoginManager.resolutionRatioIndex];
}

@end
