//
//  STParticipantsTableViewController.h
//  SealRTC
//
//  Created by birney on 2019/4/2.
//  Copyright © 2019 BridgeMind. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RongRTCRoom;
@class STParticipantsInfo;
@interface STParticipantsTableViewController : UITableViewController

- (instancetype)initWithRoom:(RongRTCRoom*)room
           participantsInfos:(NSMutableArray<STParticipantsInfo*>*) array;

@end

NS_ASSUME_NONNULL_END
