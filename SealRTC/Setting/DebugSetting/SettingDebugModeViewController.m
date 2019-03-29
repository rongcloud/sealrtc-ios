//
//  SettingDebugModeViewController.m
//  SealViewer
//
//  Created by LiuLinhong on 2018/08/13.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "SettingDebugModeViewController.h"
#import "LoginManager.h"
#import "CommonUtility.h"

@interface SettingDebugModeViewController ()
{
    UITableView *tableView;
    NSArray *frameRateArray, *codeRateArray, *codingStyleArray;
    NSInteger selectedSection;
}

@end

@implementation SettingDebugModeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Debug Setting";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStyleGrouped];
    [self initDebugModeView];
    
    NSString *frameRatePath = [[NSBundle mainBundle] pathForResource:Key_FrameRate ofType:@"plist"];
    frameRateArray = [[NSArray alloc] initWithContentsOfFile:frameRatePath];
    
    
    NSString *codeRatePath = [[NSBundle mainBundle] pathForResource:@"CodeRate" ofType:@"plist"];
    codeRateArray = [[NSArray alloc] initWithContentsOfFile:codeRatePath];
    
    NSString *codingStylePath = [[NSBundle mainBundle] pathForResource:Key_CodingStyle ofType:@"plist"];
    codingStyleArray = [[NSArray alloc] initWithContentsOfFile:codingStylePath];
}

- (void)initDebugModeView
{
    //帧率
    self.frameRatePickview = [[ZHPickView alloc] initPickviewWithPlistName:Key_FrameRate isHaveNavControler:NO];
    self.frameRatePickview.delegate = self;
    [self.frameRatePickview setSelectedPickerItem:kLoginManager.frameRateIndex];
    
    //最大,最小码率
    NSArray *codeRateArray = [CommonUtility getPlistArrayByplistName:@"CodeRate"];
    NSDictionary *codeRateDictionary = codeRateArray[kLoginManager.resolutionRatioIndex];
    //NSInteger min = [codeRateDictionary[Key_Min] integerValue];
    NSInteger max = [codeRateDictionary[@"max"] integerValue];
    NSInteger defaultValue = [codeRateDictionary[@"default"] integerValue];
    NSInteger step = [codeRateDictionary[@"step"] integerValue];
    self.maxCodeRatePickview = [[ZHPickView alloc] initPickerWithMinValue:0 max:max defaultValue:defaultValue step:step isHaveNavControler:NO];
    self.maxCodeRatePickview.delegate = self;
    
    self.minCodeRatePickview = [[ZHPickView alloc] initPickerWithMinValue:0 max:max defaultValue:0 step:step isHaveNavControler:NO];
    self.minCodeRatePickview.delegate = self;

    //编码方式
    self.codingStylePickview = [[ZHPickView alloc] initPickviewWithPlistName:Key_CodingStyle isHaveNavControler:NO];
    self.codingStylePickview.delegate = self;
    [self.codingStylePickview setSelectedPickerItem:kLoginManager.codingStyleIndex];
    
    //SRTP
    self.srtpSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(ScreenWidth -6-60, 6, 60, 28)];
    [self.srtpSwitch addTarget:self action:@selector(srtpEncryptAction) forControlEvents:UIControlEventValueChanged];
    [self.srtpSwitch setOn:kLoginManager.isSRTPEncrypt];
}

- (void)srtpEncryptAction
{
    [kLoginManager setIsSRTPEncrypt:self.srtpSwitch.on];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
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
        case 0: //帧率
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [NSString stringWithFormat:@"%@", frameRateArray[kLoginManager.frameRateIndex]];
        }
            break;
        case 1:
        case 2:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            NSDictionary *codeRateDict = codeRateArray[kLoginManager.resolutionRatioIndex];
            NSInteger max = [codeRateDict[@"max"] integerValue];
            NSInteger step = [codeRateDict[@"step"] integerValue];
            NSMutableArray *muArray = [NSMutableArray array];
            for (NSInteger temp = 0; temp <= max; temp += step)
                [muArray addObject:[NSString stringWithFormat:@"%zd", temp]];

            if (section == 1)
                cell.textLabel.text = [NSString stringWithFormat:@"%zdkbps", [muArray[kLoginManager.maxCodeRateIndex] integerValue]];
            else if (section == 2)
                cell.textLabel.text = [NSString stringWithFormat:@"%zdkbps", [muArray[kLoginManager.minCodeRateIndex] integerValue]];
        }
            break;
        case 3:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [NSString stringWithFormat:@"%@", codingStyleArray[kLoginManager.codingStyleIndex]];
        }
            break;
        case 4:
        {
            [cell.contentView addSubview:self.srtpSwitch];
            cell.textLabel.text = @"SRTP";
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    selectedSection = section;

    [self.frameRatePickview remove];
    [self.maxCodeRatePickview remove];
    [self.minCodeRatePickview remove];
    [self.codingStylePickview remove];
    
    ZHPickView *pickView;
    switch (section)
    {
        case 0:
            pickView = self.frameRatePickview;
            break;
        case 1:
            pickView = self.maxCodeRatePickview;
            break;
        case 2:
            pickView = self.minCodeRatePickview;
            break;
        case 3:
            pickView = self.codingStylePickview;
            break;
        default:
            break;
    }
    
    [pickView show];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"帧率"; //Picker
        case 1:
            return @"最大码率"; //Picker
        case 2:
            return @"最小码率"; //Picker
        case 3:
            return @"编码方式"; //Picker
        case 4:
            return @"媒体数据加密"; //switch
        default:
            break;
    }
    return @"";
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @" ";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

#pragma mark - ZhpickVIewDelegate
- (void)toolbarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString selectedRow:(NSInteger)selectedRow
{
    switch (selectedSection)
    {
        case 0:
            kLoginManager.frameRateIndex = selectedRow;
            break;
        case 1:
            kLoginManager.maxCodeRateIndex = selectedRow;
            break;
        case 2:
            kLoginManager.minCodeRateIndex = selectedRow;
            break;
        case 3:
            kLoginManager.codingStyleIndex = selectedRow;
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}

- (void)toolbarCancelBtnHaveClick:(ZHPickView *)pickView
{
    switch (selectedSection)
    {
        case 0:
            [self.frameRatePickview setSelectedPickerItem:kLoginManager.frameRateIndex];
            break;
        case 1:
            [self.maxCodeRatePickview setSelectedPickerItem:kLoginManager.maxCodeRateIndex];
            break;
        case 2:
            [self.minCodeRatePickview setSelectedPickerItem:kLoginManager.minCodeRateIndex];
            break;
        case 3:
            [self.codingStylePickview setSelectedPickerItem:kLoginManager.codingStyleIndex];
            break;
        default:
            break;
    }
}

@end
