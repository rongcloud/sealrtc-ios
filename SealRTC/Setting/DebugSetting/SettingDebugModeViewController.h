//
//  SettingDebugModeViewController.h
//  SealViewer
//
//  Created by LiuLinhong on 2018/08/13.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHPickView.h"

@interface SettingDebugModeViewController : UITableViewController <ZHPickViewDelegate>

@property (nonatomic, strong) ZHPickView *frameRatePickview, *maxCodeRatePickview, *minCodeRatePickview, *codingStylePickview;

@property (nonatomic, strong) UISwitch *srtpSwitch;

@end
