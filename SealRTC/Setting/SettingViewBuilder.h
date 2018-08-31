//
//  SettingViewBuilder.h
//  RongCloud
//
//  Created by LiuLinhong on 2016/12/01.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHPickView.h"

@interface SettingViewBuilder : NSObject

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ZHPickView *resolutionRatioPickview, *frameRatePickview, *codeRatePickview, *codingStylePickview, *minCodeRatePickview;

- (instancetype)initWithViewController:(UIViewController *)vc;

@end
