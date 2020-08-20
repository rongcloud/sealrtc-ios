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
#import "RTActiveWheel.h"
#import <RongIMLib/RongIMLib.h>

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
    NSString *cellName = [self.settingViewController.settingTableViewCellArray objectAtIndex:section];
    if (cellName) {
        if ([cellName isEqualToString:@"setting_private_environment"]) {
            PrivateCloudSettingViewController *pvc = [[PrivateCloudSettingViewController alloc]init];
            [self.settingViewController.navigationController pushViewController:pvc animated:YES];
        } else if ([cellName isEqualToString:@"setting_resolution"]) {
            [self.settingViewController.settingViewBuilder.resolutionRatioPickview show];
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *cellName = [self.settingViewController.settingTableViewCellArray objectAtIndex:section];
    if (cellName) {
        if ([cellName isEqualToString:@"setting_crypto"]) {
            return 2;
        }
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.settingViewController.sectionNumber;
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
    NSString *cellName = [self.settingViewController.settingTableViewCellArray objectAtIndex:section];
    if (cellName) {
        if ([cellName isEqualToString:@"setting_private_environment"]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = NSLocalizedString(@"setting_private_environment", nil);
        } else if ([cellName isEqualToString:@"setting_resolution"]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [NSString stringWithFormat:@"%@", self.settingViewController.resolutionRatioArray[kLoginManager.resolutionRatioIndex]];
        } else if ([cellName isEqualToString:@"setting_water_mark"]) {
            [cell.contentView addSubview:self.settingViewController.settingViewBuilder.waterMarkSwitch];
            cell.textLabel.text = NSLocalizedString(@"setting_water_mark", nil);
        } else if ([cellName isEqualToString:@"setting_tiny_stream"]) {
            [cell.contentView addSubview:self.settingViewController.settingViewBuilder.tinyStreamSwitch];
            cell.textLabel.text = NSLocalizedString(@"setting_tiny_stream", nil);
        } else if ([cellName isEqualToString:@"setting_auto_test"]) {
            [cell.contentView addSubview:self.settingViewController.settingViewBuilder.autoTestSwitch];
            cell.textLabel.text = NSLocalizedString(@"setting_auto_test", nil);
        } else if ([cellName isEqualToString:@"setting_userid"]) {
            [cell.contentView addSubview:self.settingViewController.settingViewBuilder.userIDTextField];
        } else if ([cellName isEqualToString:@"setting_audio_scenario"]) {
            [cell.contentView addSubview:self.settingViewController.settingViewBuilder.audioScenarioSwitch];
            cell.textLabel.text = NSLocalizedString(@"setting_audio_scenario", nil);
        } else if ([cellName isEqualToString:@"setting_back_camera_mirror"]) {
            [cell.contentView addSubview:self.settingViewController.settingViewBuilder.videoMirrorSwitch];
            cell.textLabel.text = NSLocalizedString(@"Enable remote vedio mirroring", nil);
        } else if ([cellName isEqualToString:@"setting_crypto"]) {
            switch (row) {
                case 0:
                {
                    [cell.contentView addSubview:self.settingViewController.settingViewBuilder.audioCryptoSwitch];
                    cell.textLabel.text = NSLocalizedString(@"setting_crypto_audio", nil);
                }
                    break;
                case 1:
                {
                    [cell.contentView addSubview:self.settingViewController.settingViewBuilder.videoCryptoSwitch];
                    cell.textLabel.text = NSLocalizedString(@"setting_crypto_video", nil);
                }
                    break;
                default:
                    break;
            }
        }
    }
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *cellName = [self.settingViewController.settingTableViewCellArray objectAtIndex:section];
    if (cellName) {
        if ([cellName isEqualToString:@"setting_private_environment"]) {
            return NSLocalizedString(@"setting_private_environment", nil);
        } else if ([cellName isEqualToString:@"setting_resolution"]) {
            return NSLocalizedString(@"setting_resolution_ratio", nil);
        } else if ([cellName isEqualToString:@"setting_water_mark"]) {
            return NSLocalizedString(@"setting_local_video", nil);
        } else if ([cellName isEqualToString:@"setting_tiny_stream"]) {
            return NSLocalizedString(@"setting_tiny_stream", nil);
        } else if ([cellName isEqualToString:@"setting_auto_test"]) {
            return NSLocalizedString(@"setting_auto_test", nil);
        } else if ([cellName isEqualToString:@"setting_userid"]) {
            return NSLocalizedString(@"setting_userid_title", nil);
        } else if ([cellName isEqualToString:@"setting_audio_scenario"]) {
            return NSLocalizedString(@"setting_audio_scenario", nil);
        } else if ([cellName isEqualToString:@"setting_back_camera_mirror"]) {
            return NSLocalizedString(@"Enable remote vedio mirroring", nil);
        } else if ([cellName isEqualToString:@"setting_crypto"]) {
            return NSLocalizedString(@"setting_crypto", nil);
        }
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

