//
//  RCDemoEffectCell.h
//  SealRTC
//
//  Created by 孙承秀 on 2020/8/17.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCEffectCell.h"
#import "RCEffectModel.h"
#import "RCEffectProtol.h"
NS_ASSUME_NONNULL_BEGIN
@class RCEffectModel;
@interface RCDemoEffectCell : UITableViewCell
/**
 effect model
 */
@property (nonatomic , strong) RCEffectModel *model;

/**
 protocol
 */
@property (nonatomic , weak) id <RCEffectProtol> delegate;
- (void)reset;
@end

NS_ASSUME_NONNULL_END
