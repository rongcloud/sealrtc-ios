//
//  STCountryTableViewController.h
//  SealRTC
//
//  Created by birney on 2019/4/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCDCountry;

@protocol STCountryTableViewControllerDelegate <NSObject>

- (void)fetchCountryPhoneCode:(RCDCountry*_Nonnull)info;

@end

NS_ASSUME_NONNULL_BEGIN

@interface STCountryTableViewController : UITableViewController

@property (nonatomic, weak) id<STCountryTableViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
