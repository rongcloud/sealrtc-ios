//
//  ChatSwitchModeTableViewController.h
//  RongCloud
//
//  Created by Vicky on 2018/7/4.
//  Copyright © 2018年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongRTCLib/RongRTCEngine.h>
 

typedef void(^SwitchModeBlock)(RongRTCVideoMode,NSIndexPath *);


@interface ChatSwitchModeTableViewController : UITableViewController

@property (nonatomic, strong) UIView *sourceView;
@property (nonatomic, copy) SwitchModeBlock videModeBlock;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end
