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

@property (nonatomic, strong) SettingViewController *settingViewController;

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
    self.settingViewController.connectStyleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth -6-60, 6, 60, 28)];
    [self.settingViewController.connectStyleSwitch addTarget:self.settingViewController action:@selector(connectStyleSwitchAction) forControlEvents:UIControlEventValueChanged];
    if (self.settingViewController.connectionStyleIndex)
        [self.settingViewController.connectStyleSwitch setOn:YES];
    else
        [self.settingViewController.connectStyleSwitch setOn:NO];
    
    self.settingViewController.observerSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth -6-60, 6, 60, 28)];
    [self.settingViewController.observerSwitch addTarget:self.settingViewController action:@selector(observerSwitchAction) forControlEvents:UIControlEventValueChanged];
    if (self.settingViewController.observerIndex == 1)
        [self.settingViewController.observerSwitch setOn:NO];
    else if (self.settingViewController.observerIndex == 2)
        [self.settingViewController.observerSwitch setOn:YES];
    
    self.settingViewController.gpuSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth -6-60, 6, 60, 28)];
    [self.settingViewController.gpuSwitch addTarget:self.settingViewController action:@selector(gpuSwitchAction) forControlEvents:UIControlEventValueChanged];
    [self.settingViewController.gpuSwitch setOn:self.settingViewController.isGPUFilter];
    
    self.settingViewController.srtpSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth -6-60, 6, 60, 28)];
    [self.settingViewController.srtpSwitch addTarget:self.settingViewController action:@selector(srtpEncryptAction) forControlEvents:UIControlEventValueChanged];
    [self.settingViewController.srtpSwitch setOn:self.settingViewController.isGPUFilter];
    
  
    self.settingViewController.tinyStreamSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth -6-60, 6, 60, 28)];
    [self.settingViewController.tinyStreamSwitch addTarget:self.settingViewController action:@selector(tinyStreamSwitchAction) forControlEvents:UIControlEventValueChanged];
    [self.settingViewController.tinyStreamSwitch setOn:self.settingViewController.isTinyStreamMode];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self.settingViewController.settingTableViewDelegateSourceImpl;
    self.tableView.delegate = self.settingViewController.settingTableViewDelegateSourceImpl;
    [self.settingViewController.view addSubview:self.tableView];
    
    self.resolutionRatioPickview = [[ZHPickView alloc] initPickviewWithPlistName:Key_ResolutionRatio isHaveNavControler:NO];
    self.resolutionRatioPickview.delegate = self.settingViewController.settingPickViewDelegateImpl;
    [self.resolutionRatioPickview setSelectedPickerItem:self.settingViewController.resolutionRatioIndex];
    
    self.frameRatePickview = [[ZHPickView alloc] initPickviewWithPlistName:Key_FrameRate isHaveNavControler:NO];
    self.frameRatePickview.delegate = self.settingViewController.settingPickViewDelegateImpl;
    [self.frameRatePickview setSelectedPickerItem:self.settingViewController.frameRateIndex];
    
    self.codingStylePickview = [[ZHPickView alloc] initPickviewWithPlistName:Key_CodingStyle isHaveNavControler:NO];
    self.codingStylePickview.delegate = self.settingViewController.settingPickViewDelegateImpl;
    [self.codingStylePickview setSelectedPickerItem:self.settingViewController.codingStyleIndex];
    
    NSDictionary *codeRateDictionary = self.settingViewController.codeRateArray[self.settingViewController.resolutionRatioIndex];
    //NSInteger min = [codeRateDictionary[Key_Min] integerValue];
    NSInteger max = [codeRateDictionary[Key_Max] integerValue];
    NSInteger defaultValue = [codeRateDictionary[Key_Default] integerValue];
    NSInteger step = [codeRateDictionary[Key_Step] integerValue];
    
    self.codeRatePickview = [[ZHPickView alloc] initPickerWithMinValue:0 max:max defaultValue:defaultValue step:step isHaveNavControler:NO];
    self.codeRatePickview.delegate = self.settingViewController.settingPickViewDelegateImpl;
    
    self.minCodeRatePickview = [[ZHPickView alloc] initPickerWithMinValue:0 max:max defaultValue:0 step:step isHaveNavControler:NO];
    self.minCodeRatePickview.delegate = self.settingViewController.settingPickViewDelegateImpl;
}

@end
