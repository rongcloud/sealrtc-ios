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

extern NSNotificationName const STParticipantsInfoDidRemove;
extern NSNotificationName const STParticipantsInfoDidAdd;

@interface STParticipantsTableViewController ()

@property (nonatomic, strong) STParticipantsTableViewHeader* tableHeader;
@property (nonatomic, strong) RongRTCRoom* room;
@property (nonatomic, weak) NSMutableArray<STParticipantsInfo*>* dataSource;
@property (nonatomic, strong) NSMutableSet<NSString*>* userSet;
@end

@implementation STParticipantsTableViewController

- (instancetype)initWithRoom:(RongRTCRoom*)room
           participantsInfos:(NSMutableArray<STParticipantsInfo*>*) array {
    if (self  = [super initWithStyle:UITableViewStylePlain]) {
        self.room = room;
        self.dataSource = array;
        for (STParticipantsInfo* info in array) {
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
    [self.room getRoomAttributes:nil completion:^(BOOL isSuccess, RongRTCCode desc, NSDictionary * _Nullable attr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [attr enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSString*  _Nonnull obj, BOOL * _Nonnull stop) {
                NSDictionary* dicInfo = [NSJSONSerialization JSONObjectWithData:[obj dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                STParticipantsInfo* info = [[STParticipantsInfo alloc] initWithDictionary:dicInfo];
                if (![self.userSet containsObject:key]) {
                    if (info.userId.length > 0) {
                        [self.dataSource addObject:info];
                        [self.userSet addObject:info.userId];
                    }
      
                }
            }];
            [self.dataSource sortUsingComparator:^NSComparisonResult(STParticipantsInfo*  _Nonnull obj1, STParticipantsInfo*  _Nonnull obj2) {
                if (obj1.joinTime > obj2.joinTime) {
                    return NSOrderedAscending;
                } else {
                    return NSOrderedDescending;
                }
            }];
            [self.tableView reloadData];
            [self updateParticipantsCount];
        });

    }];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParticipantsCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ParticipantsCell"];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    STParticipantsInfo* info = self.dataSource[indexPath.row];
    cell.textLabel.text = info.userName;
    cell.detailTextLabel.text = stringForJoinMode(info.joinMode);
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - notification selector
- (void)participantsInfoDidChange:(NSNotification*)notification {
    NSIndexPath* indexPath = notification.object;
    if ([notification.name isEqualToString:STParticipantsInfoDidRemove]) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    } else if ([notification.name isEqualToString:STParticipantsInfoDidAdd]) {
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
     [self updateParticipantsCount];
}

#pragma mark - Target Action
- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
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
        _userSet = [[NSMutableSet alloc] initWithCapacity:100];
    }
    return _userSet;
}

//- (NSMutableArray<STParticipantsInfo*>*)dataSource {
//    if (!_dataSource) {
//        _dataSource = [[NSMutableArray alloc] initWithCapacity:100];
//    }
//    return _dataSource;
//}

@end
