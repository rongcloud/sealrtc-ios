//
//  STParticipantsTableViewController.m
//  SealRTC
//
//  Created by birney on 2019/4/2.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "STParticipantsTableViewController.h"
#import "STParticipantsTableViewHeader.h"
#import <RongRTCLib/RongRTCLib.h>
#import "STParticipantsInfo.h"
#import "STSetRoomInfoMessage.h"
#import "STDeleteRoomInfoMessage.h"
#import "STKickOffInfoMessage.h"
#import "LoginManager.h"

extern NSNotificationName const STParticipantsInfoDidRemove;
extern NSNotificationName const STParticipantsInfoDidAdd;
extern NSNotificationName const STParticipantsInfoDidUpdate;

@interface STParticipantsTableViewController ()

@property (nonatomic, strong) STParticipantsTableViewHeader* tableHeader;
@property (nonatomic, strong) RongRTCRoom* room;
@property (nonatomic, weak) NSMutableArray<STParticipantsInfo*>* dataSource;
@property (nonatomic, strong) NSMutableArray* removeUserButtonArray;
@property (nonatomic, strong) NSMutableSet<NSString*>* userSet;
@property (nonatomic, strong) NSMutableSet<NSString*>* currentAllUser;
@end

@implementation STParticipantsTableViewController

- (instancetype)initWithRoom:(RongRTCRoom*)room
           participantsInfos:(NSMutableArray<STParticipantsInfo*>*) array {
    if (self  = [super initWithStyle:UITableViewStylePlain]) {
        self.room = room;
        for (RongRTCRemoteUser* user  in room.remoteUsers) {
            if (user.userId.length > 0) {
                [self.currentAllUser addObject:user.userId];
            }
        }
        if (room.localUser.userId.length > 0) {
            [self.currentAllUser addObject:room.localUser.userId];
        }
        self.dataSource  = array;
        NSArray* source = [array copy];
        NSMutableIndexSet* mutableSet = [[NSMutableIndexSet alloc] init];
        for (int i = 0; i < source.count; i++) {
            STParticipantsInfo* info  = source[i];
            if (![self.currentAllUser containsObject:info.userId]) {
                [mutableSet addIndex:i];
            }
        }
        [self.dataSource removeObjectsAtIndexes:[mutableSet copy]];
        
        for (STParticipantsInfo* info in source) {
            if (info.userId.length > 0) {
                [self.userSet addObject:info.userId];
            }
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNotificationCenter* defalutCenter = [NSNotificationCenter defaultCenter];
    [defalutCenter addObserver:self
                      selector:@selector(participantsInfoDidChange:)
                          name:STParticipantsInfoDidRemove
                        object:nil];
    [defalutCenter addObserver:self
                      selector:@selector(participantsInfoDidChange:)
                          name:STParticipantsInfoDidAdd
                        object:nil];
    [defalutCenter addObserver:self
                      selector:@selector(participantsInfoDidChange:)
                          name:STParticipantsInfoDidUpdate
                        object:nil];
    [self.room getRoomAttributes:nil completion:^(BOOL isSuccess, RongRTCCode desc, NSDictionary * _Nullable attr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [attr enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSString*  _Nonnull obj, BOOL * _Nonnull stop) {
                NSDictionary* dicInfo = [NSJSONSerialization JSONObjectWithData:[obj dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                STParticipantsInfo* info = [[STParticipantsInfo alloc] initWithDictionary:dicInfo];
                if (![self.userSet containsObject:key]) {
                    if (info.userId.length > 0 && [self.currentAllUser containsObject:key]) {
                        [self.dataSource addObject:info];
                        [self.userSet addObject:info.userId];
                    }
                }
            }];
            
            [self.dataSource sortUsingComparator:^NSComparisonResult(STParticipantsInfo*  _Nonnull obj1, STParticipantsInfo*  _Nonnull obj2) {
                if (obj1.joinTime < obj2.joinTime) {
                    return NSOrderedAscending;
                } else {
                    return NSOrderedDescending;
                }
            }];
            
            NSInteger masterIndex = 0;
            for (NSInteger i = 0; i < [self.dataSource count]; i++) {
                STParticipantsInfo *tmpInfo = self.dataSource[i];
                if (tmpInfo.master) {
                    masterIndex = i;
                    break;
                }
            }
            
            if (masterIndex && [self.dataSource count] > masterIndex) {
                STParticipantsInfo *masterInfo = self.dataSource[masterIndex];
                [self.dataSource removeObjectAtIndex:masterIndex];
                [self.dataSource insertObject:masterInfo atIndex:0];
            }
            
            [self.tableView reloadData];
            [self updateParticipantsCount];
        });
    }];

    [self updateParticipantsCount];
    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height / 2);
    //[self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"ParticipantsCell"];
    self.tableView.tableHeaderView = self.tableHeader;
    self.tableView.backgroundColor = [UIColor clearColor];
    //bself.tableView.tableFooterView = [UIView new];
    [self.tableHeader.closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    UIVisualEffectView* effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    effectView.alpha = 0.8;
    self.tableView.backgroundView = effectView;
}

- (void)updateParticipantsCount {
    NSString* cout_fmt = NSLocalizedString(@"online_user_cout_fmt", nil);
    self.tableHeader.tipsLabel.text = [NSString stringWithFormat:cout_fmt,@(self.dataSource.count)];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParticipantsCell"];
    NSInteger row = indexPath.row;
    STParticipantsInfo *info = self.dataSource[row];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ParticipantsCell"];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", info.userName, stringForJoinMode(info.joinMode)]; ;
    
    if (kLoginManager.isMaster) {
        if ([info.userId isEqualToString:kLoginManager.userID]) {
            cell.detailTextLabel.text = NSLocalizedString(@"chat_user_kick_master", nil);
        }
        else {
            cell.detailTextLabel.text = @"";
            UIButton *btn;
            for (NSInteger i = 0; i < [self.removeUserButtonArray count]; i++) {
                UIButton *tmpBtn = (UIButton *)self.removeUserButtonArray[i];
                if (tmpBtn.tag == row) {
                    btn = tmpBtn;
                }
            }
            
            if (!btn) {
                btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                btn.frame = CGRectMake(ScreenWidth - 80, 0, 80, 44);
                btn.titleLabel.font = [UIFont systemFontOfSize:16];
                [btn setTitle:NSLocalizedString(@"chat_user_kick", nil) forState:UIControlStateNormal];
                [btn setTitle:NSLocalizedString(@"chat_user_kick", nil) forState:UIControlStateHighlighted];
                [btn addTarget:self action:@selector(cellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                [self.removeUserButtonArray addObject:btn];
            }
            
            btn.tag = row;
            [cell.contentView addSubview:btn];
        }
    }
    else {
        cell.detailTextLabel.text = info.master ? NSLocalizedString(@"chat_user_kick_master", nil) : @"";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - notification selector
- (void)participantsInfoDidChange:(NSNotification*)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([notification.name isEqualToString:STParticipantsInfoDidRemove]
            || [notification.name isEqualToString:STParticipantsInfoDidUpdate]) {
            [self.tableView reloadData];;
        } else if ([notification.name isEqualToString:STParticipantsInfoDidAdd]) {
            NSIndexPath *indexPath = notification.object;
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
        [self updateParticipantsCount];
    });
}

#pragma mark - Target Action
- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cellButtonPressed:(UIButton *)button {
    DLog(@"LLH...... button.tag: %zd", button.tag);
    STParticipantsInfo *info = self.dataSource[button.tag];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"setting_OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSDictionary *msgDict = @{@"userId" : info.userId};
        STKickOffInfoMessage *message = [[STKickOffInfoMessage alloc] initKickOffMessage:msgDict];
        [self.room sendRTCMessage:message success:^(long messageId) {
        } error:^(RCErrorCode nErrorCode, long messageId) {
        }];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"setting_Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"chat_user_kick_msg", nil), info.userName];
    UIAlertController *controler = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
    [controler addAction:cancelAction];
    [controler addAction:okAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:controler animated:YES completion:^{}];
    });
}

#pragma mark - getters
- (STParticipantsTableViewHeader*)tableHeader {
    if (!_tableHeader) {
        _tableHeader = [[STParticipantsTableViewHeader alloc] initWithFrame:(CGRect){0,0,200,44}];
    }
    return _tableHeader;
}

- (NSMutableSet<NSString*>*)userSet {
    if (!_userSet) {
        _userSet = [[NSMutableSet alloc] initWithCapacity:20];
    }
    return _userSet;
}

- (NSMutableSet<NSString*>*)currentAllUser {
    if (!_currentAllUser) {
        _currentAllUser = [[NSMutableSet alloc] initWithCapacity:20];
    }
    return _currentAllUser;
}

- (NSMutableArray *)removeUserButtonArray {
    if (!_removeUserButtonArray) {
        _removeUserButtonArray = [[NSMutableArray alloc] initWithCapacity:20];
    }
    return _removeUserButtonArray;
}

NSString* stringForJoinMode(STJoinMode mode) {
    NSString* result;
    switch (mode) {
        case STJoinModeAV:
            result = NSLocalizedString(@"video_mode", nil);
            break;
        case STJoinModeAudioOnly:
            result = NSLocalizedString(@"audio_mode", nil);
            break;
        case STJoinModeObserver:
            result = NSLocalizedString(@"receive_only_mode", nil);
            break;
        default:
            break;
    }
    return result;
}

@end
