//
//  ChatCell.h
//  RongCloud
//
//  Created by LiuLinhong on 2016/11/16.
//  Copyright © 2016年 Beijing Rongcloud Network Technology Co. , Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ChatType) {
    ChatTypeVideo,
    ChatTypeAudio,
    ChatTypeDefault = ChatTypeVideo
};

@interface ChatCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) UILabel *subscribeLabel;
@property (strong, nonatomic) UILabel *connectLabel;
@property (assign, nonatomic) ChatType type;
- (void)refreshAutoTestLabel:(BOOL)hideSubscribeLabel connectLabel:(BOOL)hideConnect subscribeLog:(NSString *)log connectLog:(NSString *)log1;
@end
