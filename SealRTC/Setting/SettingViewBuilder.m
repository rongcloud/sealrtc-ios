//
//  SettingViewBuilder.m
//  RongCloud
//
//  Created by LiuLinhong on 2016/12/01.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "SettingViewBuilder.h"
#import "SettingViewController.h"

@interface SettingViewBuilder () <UITextFieldDelegate>

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
    
    self.mediaServerTextField = [[UITextField alloc] initWithFrame:CGRectMake(14, 0, ScreenWidth-14, 44)];
    self.mediaServerTextField.placeholder = @"Media Server URL";
    self.mediaServerTextField.textAlignment = NSTextAlignmentLeft;
    self.mediaServerTextField.clearButtonMode = UITextFieldViewModeUnlessEditing;
    self.mediaServerTextField.keyboardType = UIKeyboardTypeURL;
    self.mediaServerTextField.returnKeyType = UIReturnKeyDone;
    self.mediaServerTextField.delegate = self;
    self.mediaServerTextField.text = kLoginManager.mediaServerURL;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self.settingViewController.settingTableViewDelegateSourceImpl;
    self.tableView.delegate = self.settingViewController.settingTableViewDelegateSourceImpl;
    [self.settingViewController.view addSubview:self.tableView];
    
    self.resolutionRatioPickview = [[ZHPickView alloc] initPickviewWithPlistName:Key_ResolutionRatio isHaveNavControler:NO];
    self.resolutionRatioPickview.delegate = self.settingViewController.settingPickViewDelegateImpl;
    [self.resolutionRatioPickview setSelectedPickerItem:kLoginManager.resolutionRatioIndex];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.tableView.frame = CGRectMake(weakSelf.tableView.frame.origin.x, -120, weakSelf.tableView.frame.size.width, weakSelf.tableView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.tableView.frame = CGRectMake(weakSelf.tableView.frame.origin.x, 0, weakSelf.tableView.frame.size.width, weakSelf.tableView.frame.size.height);
    } completion:^(BOOL finished) {
        [kLoginManager setMediaServerURL:textField.text];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textfield
{
    [textfield resignFirstResponder];
    return YES;
}

@end
