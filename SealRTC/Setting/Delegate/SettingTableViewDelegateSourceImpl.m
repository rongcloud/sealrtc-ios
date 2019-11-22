//
//  SettingTableViewDelegateSourceImpl.m
//  RongCloud
//
//  Created by LiuLinhong on 2016/12/01.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "SettingTableViewDelegateSourceImpl.h"
#import "SettingViewController.h"
#import "PrivateCloudSettingViewController.h"

#ifndef IS_PRIVATE_ENVIRONMENT

@interface SettingTableViewDelegateSourceImpl ()

@property (nonatomic, weak) SettingViewController *settingViewController;

@end


@implementation SettingTableViewDelegateSourceImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.settingViewController = (SettingViewController *) vc;
    }
    return self;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.settingViewController.indexPath = indexPath;
    NSInteger section = [indexPath section];
    [self.settingViewController.settingViewBuilder.resolutionRatioPickview remove];
    switch (section)
    {
        case 0:
            [self.settingViewController.settingViewBuilder.resolutionRatioPickview show];
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 1:
            return 2;
        default:
            return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (ENABLE_MANUAL_MEDIASERVER) {
        return self.settingViewController.sectionNumber;
    }
    else{
        return self.settingViewController.sectionNumber - 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    NSString *identifer = [NSString stringWithFormat:@"Cell%zd%zd", section, row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifer];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    switch (section)
    {
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [NSString stringWithFormat:@"%@", self.settingViewController.resolutionRatioArray[kLoginManager.resolutionRatioIndex]];
        }
            break;
        case 1:
        {
            switch (row) {
                case 0:
                {
                    [cell.contentView addSubview:self.settingViewController.settingViewBuilder.gpuSwitch];
                    cell.textLabel.text = NSLocalizedString(@"setting_gpu_filter", nil);
                }
                    break;
                case 1:
                {
                    [cell.contentView addSubview:self.settingViewController.settingViewBuilder.waterMarkSwitch];
                    cell.textLabel.text = NSLocalizedString(@"setting_water_mark", nil);
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            [cell.contentView addSubview:self.settingViewController.settingViewBuilder.tinyStreamSwitch];
            cell.textLabel.text = NSLocalizedString(@"setting_tiny_stream", nil);
        }
            break;
        case 3:
        {
            [cell.contentView addSubview:self.settingViewController.settingViewBuilder.autoTestSwitch];
            cell.textLabel.text = NSLocalizedString(@"setting_auto_test", nil);
        }
            break;
        case 4:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"Media Server URL";
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return NSLocalizedString(@"setting_resolution_ratio", nil);
        case 1:
            return NSLocalizedString(@"setting_local_video", nil);
        case 2:
            return NSLocalizedString(@"setting_tiny_stream", nil);
        case 3:
            return NSLocalizedString(@"setting_auto_test", nil);
        case 4:
            return NSLocalizedString(@"setting_media_server_url", nil);
        default:
            break;
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? 30.f : 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

@end

#else

@interface SettingTableViewDelegateSourceImpl ()

@property (nonatomic, weak) SettingViewController *settingViewController;

@end


@implementation SettingTableViewDelegateSourceImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.settingViewController = (SettingViewController *) vc;
    }
    return self;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.settingViewController.indexPath = indexPath;
    NSInteger section = [indexPath section];
    [self.settingViewController.settingViewBuilder.resolutionRatioPickview remove];
    switch (section)
    {
        case 0:{
            PrivateCloudSettingViewController *pvc = [[PrivateCloudSettingViewController alloc]init];
            [self.settingViewController.navigationController pushViewController:pvc animated:YES];
        }
            break;
        case 1:
            [self.settingViewController.settingViewBuilder.resolutionRatioPickview show];
            break;
        case 5:
        {
            MediaServerURLViewController *mediaServerURLViewController = [[MediaServerURLViewController alloc] init];
            if (![self.settingViewController.navigationController.topViewController isKindOfClass:[MediaServerURLViewController class]])
                [self.settingViewController.navigationController pushViewController:mediaServerURLViewController animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 2:
            return 2;
        default:
            return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    if (ENABLE_MANUAL_MEDIASERVER) {
        return self.settingViewController.sectionNumber;
    }
    else{
        return self.settingViewController.sectionNumber - 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    NSString *identifer = [NSString stringWithFormat:@"Cell%zd%zd", section, row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifer];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    switch (section)
    {
        case 0:{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = NSLocalizedString(@"setting_private_environment", nil);
        }
            break;
        case 1:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [NSString stringWithFormat:@"%@", self.settingViewController.resolutionRatioArray[kLoginManager.resolutionRatioIndex]];
        }
            break;
        case 2:
        {
            switch (row) {
                case 0:
                {
                    [cell.contentView addSubview:self.settingViewController.settingViewBuilder.gpuSwitch];
                    cell.textLabel.text = NSLocalizedString(@"setting_gpu_filter", nil);
                }
                    break;
                case 1:
                {
                    [cell.contentView addSubview:self.settingViewController.settingViewBuilder.waterMarkSwitch];
                    cell.textLabel.text = NSLocalizedString(@"setting_water_mark", nil);
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 3:
        {
            [cell.contentView addSubview:self.settingViewController.settingViewBuilder.tinyStreamSwitch];
            cell.textLabel.text = NSLocalizedString(@"setting_tiny_stream", nil);
        }
            break;
        case 4:
        {
            [cell.contentView addSubview:self.settingViewController.settingViewBuilder.autoTestSwitch];
            cell.textLabel.text = NSLocalizedString(@"setting_auto_test", nil);
        }
            break;
        case 5:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"Media Server URL";
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return NSLocalizedString(@"setting_private_environment", nil);
        case 1:
            return NSLocalizedString(@"setting_resolution_ratio", nil);
        case 2:
            return NSLocalizedString(@"setting_local_video", nil);
        case 3:
            return NSLocalizedString(@"setting_tiny_stream", nil);
        case 4:
            return NSLocalizedString(@"setting_auto_test", nil);
        case 5:
            return NSLocalizedString(@"setting_media_server_url", nil);
        default:
            break;
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? 30.f : 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

@end


#endif
