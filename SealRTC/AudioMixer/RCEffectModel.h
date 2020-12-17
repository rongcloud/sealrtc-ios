//
//  RCEffectModel.h
//  SealRTC
//
//  Created by 孙承秀 on 2020/8/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCEffectModel : NSObject

/**
 name
 */
@property (nonatomic , copy) NSString *name;

/**
 filepath
 */
@property (nonatomic , copy) NSString *filePath;

/**
 index
 */
@property (nonatomic , assign) NSInteger index;

@end

NS_ASSUME_NONNULL_END
