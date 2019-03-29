//
//  LoginTextFieldDelegateImpl.m
//  RongCloud
//
//  Created by LiuLinhong on 2016/12/01.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import "LoginTextFieldDelegateImpl.h"
#import "LoginViewController.h"
#import "NSString+length.h"


@interface LoginTextFieldDelegateImpl ()

@property (nonatomic, weak) LoginViewController *loginViewController;

@end


@implementation LoginTextFieldDelegateImpl

- (instancetype)initWithViewController:(UIViewController *)vc
{
    self = [super init];
    if (self)
    {
        self.loginViewController = (LoginViewController *) vc;
    }
    return self;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame = CGRectMake(weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame.origin.x, 0, weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame.size.width, weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame = CGRectMake(0, 186, weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame.size.width, weakSelf.loginViewController.loginViewBuilder.inputNumPasswordView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}
 
- (BOOL)textFieldShouldReturn:(UITextField *)textfield
{
    if (self.loginViewController.isRoomNumberInput && kLoginManager.isLoginTokenSucc)
        [self.loginViewController joinRoomButtonPressed:self.loginViewController.loginViewBuilder.joinRoomButton];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *tobeString = [textField.text stringByAppendingString:string];
    
    if (textField == self.loginViewController.loginViewBuilder.roomNumberTextField) {
        return [self validateRoomID:tobeString withRegex:RegexRoomID];
    }
    else if (textField == self.loginViewController.loginViewBuilder.phoneNumTextField
             || textField == self.loginViewController.loginViewBuilder.phoneNumLoginTextField) {
        return ([tobeString getStringLengthOfBytes] < 12);
    }
    else if (textField == self.loginViewController.loginViewBuilder.validateSMSTextField) {
        return ([tobeString getStringLengthOfBytes] < 7);
    }

    return NO;
}

#pragma mark - validate for username
- (BOOL)validateRoomID:(NSString *)userName withRegex:(NSString *)regex
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:userName];
}

@end
