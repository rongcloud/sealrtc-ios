//
//  ChatRongRTCEngineDelegateImpl.h
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/15.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCEngine.h>
#import "ChatCellVideoViewModel.h"

@interface ChatRongRTCEngineDelegateImpl : NSObject <RongRTCEngineDelegate>

@property (nonatomic, strong) UIImageView *remoteMicImageView;
@property (nonatomic, strong) ChatCellVideoViewModel *degradeCellVideoViewModel;
@property (nonatomic, strong) NSMutableArray *bitrateArray;

- (instancetype)initWithViewController:(UIViewController *)vc;

- (void)adaptUserType:(RongRTC_Device_Type)dType withDataModel:(ChatCellVideoViewModel *)model open:(BOOL)isOpen;


@end
