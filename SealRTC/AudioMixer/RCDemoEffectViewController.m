//
//  RCDemoEffectViewController.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/8/19.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCDemoEffectViewController.h"
#import "RCEffectCell.h"
#import "RCEffectModel.h"
#import "RCRTCEffectBottomView.h"
#import <RongRTCLib/RongRTCLib.h>
#import "LoginManager.h"
#import "RCDemoEffectCell.h"
#import "RCEffectProtol.h"
#import "RCRTCDemoEffectBottomView.h"
#define KEffectCell @"AutoTestEffectCell"
#define KDemoEffectCell @"EffectCell"

@interface RCDemoEffectViewController ()<RCDemoEffectAllProtocol,RCEffectProtol,RCRTCSoundEffectProtocol>

/**
 sounds
 */
@property (nonatomic , strong) NSMutableArray *sounds;

/**
 bottom
 */
@property (nonatomic , strong) RCRTCDemoEffectBottomView *bottom  ;
@end

@implementation RCDemoEffectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"音效";
    NSArray *arr = @[@"狗吠",@"鼓掌",@"怪物",@"庆祝"];
    self.sounds = [NSMutableArray array];
    [RCRTCEngine sharedInstance].audioEffectManager.delegate = self;
    for (NSInteger i = 0 ; i < arr.count; i ++) {
        RCEffectModel *model = [[RCEffectModel alloc] init];
        model.name = arr[i];
        model.index = i;
        NSString *path =[[NSBundle mainBundle] pathForResource:model.name ofType:@"mp3"];
        if (path != nil) {
            model.filePath = path;
        }
        [self.sounds addObject:model];
    }
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    [self.tableView registerClass:[RCDemoEffectCell class] forCellReuseIdentifier:KDemoEffectCell];
    UIVisualEffectView* effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    effectView.alpha = 0.8;
    self.tableView.backgroundView = effectView;
    self.tableView.backgroundColor = [UIColor clearColor];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RCDemoEffectCell *cell = [tableView dequeueReusableCellWithIdentifier:KDemoEffectCell];
    cell.delegate = self;
    [cell setModel:self.sounds[indexPath.row]];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sounds.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    RCRTCDemoEffectBottomView *bottom = [[RCRTCDemoEffectBottomView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 150)];
    bottom.delegate = self;
    self.bottom = bottom;
    return bottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 150;
}

- (void)didSelectPause:(nonnull RCEffectModel *)model {
    RCRTCCode code = [[RCRTCEngine sharedInstance].audioEffectManager pauseEffect:model.index];
    [self alert:code];
}

- (void)didSelectPlay:(nonnull RCEffectModel *)model publish:(BOOL)publish{
    int count = [[self.bottom getLoopCount] intValue];
    RCRTCCode code = [[RCRTCEngine sharedInstance].audioEffectManager playEffect:model.index filePath:model.filePath loopCount:count>0 ?count:1 publish:publish];
    [self alert:code];
}

- (void)didSelectResume:(nonnull RCEffectModel *)model {
    RCRTCCode code = [[RCRTCEngine sharedInstance].audioEffectManager resumeEffect:model.index];
    [self alert:code];
}

- (void)didSelectStop:(nonnull RCEffectModel *)model {
    RCRTCCode code = [[RCRTCEngine sharedInstance].audioEffectManager stopEffect:model.index];
    [self alert:code];
}

- (void)didSelectVolome:(nonnull RCEffectModel *)model volume:(NSUInteger)volume {
    RCRTCCode code = [[RCRTCEngine sharedInstance].audioEffectManager setVolumeOfEffect:model.index withVolume:volume];
    [self alert:code];
}
- (void)didSelectPause {
    RCRTCCode code =  [[RCRTCEngine sharedInstance].audioEffectManager pauseAllEffects];
    [self alert:code];
}

- (void)didSelectResume {
    RCRTCCode code = [[RCRTCEngine sharedInstance].audioEffectManager resumeAllEffects];
    [self alert:code];
}

- (void)didSelectStop {
    RCRTCCode code = [[RCRTCEngine sharedInstance].audioEffectManager stopAllEffects];
    [self alert:code];
    for (int i = 0 ; i < self.sounds.count; i ++) {
        dispatch_async(dispatch_get_main_queue(), ^{
            RCDemoEffectCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [cell reset];
        });
    }
}

- (void)didSelectVolome:(double)volume {
    RCRTCCode code = [[RCRTCEngine sharedInstance].audioEffectManager setEffectsVolume:volume];
    [self alert:code];
}
- (void)didSelectPreload:(RCEffectModel *)model preload:(BOOL)preload {
    if (preload) {
        RCRTCCode code = [[RCRTCEngine sharedInstance].audioEffectManager preloadEffect:model.index filePath:model.filePath];
        [self alert:code];
    } else {
        RCRTCCode code = [[RCRTCEngine sharedInstance].audioEffectManager unloadEffect:model.index];
        [self alert:code];
    }
}

- (void)alert:(RCRTCCode)code {
    NSDictionary *dic = @{@(RCRTCCodeEffectFileCountHasBeenReached):@"当前混音文件数量到达最大值",@(RCRTCCodeHandlingIllegalEffectSoundId):@"操作不存在的 soundId"};
    if (code != RCRTCCodeSuccess) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误提示" message:dic[@(code)] preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道啦" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController presentViewController:alert animated:YES completion:nil];
        });
    }
}
- (void)didEffectFinished:(NSUInteger)effectId {
    NSLog(@"%@",@(effectId));
    dispatch_async(dispatch_get_main_queue(), ^{
        RCDemoEffectCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:effectId inSection:0]];
        [cell reset];
    });
    
}
- (void)preload:(BOOL)preload model:(RCEffectModel *)model {
    if (preload) {
        [[RCRTCEngine sharedInstance].audioEffectManager preloadEffect:model.index filePath:model.filePath];
    } else {
        [[RCRTCEngine sharedInstance].audioEffectManager unloadEffect:model.index];
    }
    
}
@end
