//
//  LoginTextFieldDelegateImpl.h
//  RongCloud
//
//  Created by LiuLinhong on 2016/12/01.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#define KMaxInpuNumber 12

@interface LoginTextFieldDelegateImpl : NSObject <UITextFieldDelegate>

- (instancetype)initWithViewController:(UIViewController *)vc;

@end
