//
//  STCountryTableViewController.h
//  SealRTC
//
//  Created by birney on 2019/4/2.
//  Copyright © 2019 BridgeMind. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCDCountry;

@protocol STCountryTableViewControllerDelegate <NSObject>

- (void)fetchCountryPhoneCode:(RCDCountry*)info;

@end

NS_ASSUME_NONNULL_BEGIN

@interface STCountryTableViewController : UITableViewController

@property (nonatomic, weak) id<STCountryTableViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
