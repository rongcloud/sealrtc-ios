//
//  SettingPickViewDelegateImpl.m
//  Rongcloud
//
//  Created by LiuLinhong on 2016/12/01.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "SettingPickViewDelegateImpl.h"
#import "SettingViewController.h"

static NSUserDefaults *settingPickViewUserDefaults = nil;

@interface SettingPickViewDelegateImpl ()

@property (nonatomic, strong) SettingViewController *settingViewController;

@end


@implementation SettingPickViewDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.settingViewController = (SettingViewController *) vc;
        settingPickViewUserDefaults = [SettingViewController shareSettingUserDefaults];
    }
    return self;
}

#pragma mark - ZhpickVIewDelegate
- (void)toolbarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString selectedRow:(NSInteger)selectedRow
{
    NSInteger section = self.settingViewController.indexPath.section;
    switch (section)
    {
        case 0:
        {
            [settingPickViewUserDefaults setObject:@(selectedRow) forKey:Key_ResolutionRatio];
            
            if (self.settingViewController.resolutionRatioIndex != selectedRow)
            {
                self.settingViewController.resolutionRatioIndex = selectedRow;
                
                //max code rate
                NSDictionary *codeRateDictionary = self.settingViewController.codeRateArray[self.settingViewController.resolutionRatioIndex];
                //NSInteger min = [codeRateDictionary[Key_Min] integerValue];
                NSInteger max = [codeRateDictionary[Key_Max] integerValue];
                NSInteger defaultValue = [codeRateDictionary[Key_Default] integerValue];
                NSInteger step = [codeRateDictionary[Key_Step] integerValue];
                
                [self.settingViewController.settingViewBuilder.codeRatePickview setMin:0 max:max defaultValue:defaultValue step:step];
                
                NSMutableArray *muArray = [NSMutableArray array];
                for (NSInteger temp = 0; temp <= max; temp += step)
                    [muArray addObject:[NSString stringWithFormat:@"%zd", temp]];
                
                NSInteger defaultIndex = [muArray indexOfObject:[NSString stringWithFormat:@"%zd", defaultValue]];
                self.settingViewController.codeRateIndex = defaultIndex;
                [settingPickViewUserDefaults setObject:@(self.settingViewController.codeRateIndex) forKey:Key_CodeRate];
                
                //min code rate
                NSMutableArray *minArray = [NSMutableArray array];
                for (NSInteger tmp = 0; tmp <= max; tmp += step)
                    [minArray addObject:[NSString stringWithFormat:@"%zd", tmp]];
                
                NSInteger minCodeRateDefaultValue;
//                switch (self.settingViewController.resolutionRatioIndex)
//                {
//                    case 0:
//                        minCodeRateDefaultValue = 150;
//                        break;
//                    case 1:
//                        minCodeRateDefaultValue = 350;
//                        break;
//                    case 2:
//                        minCodeRateDefaultValue = 750;
//                        break;
//                    case 3:
//                        minCodeRateDefaultValue = 1500;
//                        break;
//                    default:
//                        minCodeRateDefaultValue = 350;
//                        break;
//                }

                minCodeRateDefaultValue = [codeRateDictionary[Key_Min] integerValue];
                
                [self.settingViewController.settingViewBuilder.minCodeRatePickview setMin:0 max:max defaultValue:minCodeRateDefaultValue step:step];
                self.settingViewController.minCodeRateIndex = [minArray indexOfObject:[NSString stringWithFormat:@"%zd", minCodeRateDefaultValue]];
                [settingPickViewUserDefaults setObject:@(self.settingViewController.minCodeRateIndex) forKey:Key_CodeRateMin];
                
                //frame rate
                self.settingViewController.frameRateIndex = 0;
                [self.settingViewController.settingViewBuilder.frameRatePickview setSelectedPickerItem:self.settingViewController.frameRateIndex];
                [settingPickViewUserDefaults setObject:@(self.settingViewController.frameRateIndex) forKey:Key_FrameRate];
            }
        }
            break;
        case 5:
        {
            [settingPickViewUserDefaults setObject:@(selectedRow) forKey:Key_FrameRate];
            self.settingViewController.frameRateIndex = selectedRow;
        }
            break;
        case 6:
        {
            [settingPickViewUserDefaults setObject:@(selectedRow) forKey:Key_CodeRate];
            self.settingViewController.codeRateIndex = selectedRow;
        }
            break;
        case 8:
        {
            [settingPickViewUserDefaults setObject:@(selectedRow) forKey:Key_CodingStyle];
            self.settingViewController.codingStyleIndex = selectedRow;
        }
            break;
        case 9:
        {
            [settingPickViewUserDefaults setObject:@(selectedRow) forKey:Key_CodeRateMin];
            self.settingViewController.minCodeRateIndex = selectedRow;
        }
            break;
        default:
            break;
    }
    [settingPickViewUserDefaults synchronize];
    
    //    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPath];
    //    cell.textLabel.text = resultString;
    [self.settingViewController.settingViewBuilder.tableView reloadData];
}

- (void)toolbarCancelBtnHaveClick:(ZHPickView *)pickView
{
    NSInteger section = self.settingViewController.indexPath.section;
    switch (section)
    {
        case 0:
            [self.settingViewController.settingViewBuilder.resolutionRatioPickview setSelectedPickerItem:self.settingViewController.resolutionRatioIndex];
            break;
        case 2:
            [self.settingViewController.settingViewBuilder.frameRatePickview setSelectedPickerItem:self.settingViewController.frameRateIndex];
            break;
        case 3:
            [self.settingViewController.settingViewBuilder.codeRatePickview setSelectedPickerItem:self.settingViewController.codeRateIndex];
            break;
        case 5:
            [self.settingViewController.settingViewBuilder.codingStylePickview setSelectedPickerItem:self.settingViewController.codingStyleIndex];
            break;
        case 6:
            [self.settingViewController.settingViewBuilder.minCodeRatePickview setSelectedPickerItem:self.settingViewController.minCodeRateIndex];
            break;
        default:
            break;
    }
}

@end
