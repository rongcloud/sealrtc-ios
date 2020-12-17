//
//  RCEffectViewController.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/8/16.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCEffectViewController.h"
#import "RCEffectCell.h"
#import "RCEffectModel.h"
#import "RCRTCEffectBottomView.h"
#import <RongRTCLib/RongRTCLib.h>
#import "LoginManager.h"
#import "RCDemoEffectCell.h"
#import "RCEffectProtol.h"
#define KEffectCell @"AutoTestEffectCell"
#define KDemoEffectCell @"EffectCell"
@interface RCEffectViewController ()<RCEffectAllProtocol,RCEffectProtol,RCRTCSoundEffectProtocol>

/**
 sounds
 */
@property (nonatomic , strong) NSMutableArray *sounds;

/**
 bottom
 */
@property (nonatomic , strong) RCRTCEffectBottomView *bottom  ;
@end

@implementation RCEffectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *arr = @[@"狗吠",@"鼓掌",@"怪物笑声",@"庆祝"];
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
    if ([LoginManager sharedInstance].isAutoTest) {
        [self.tableView registerClass:[RCEffectCell class] forCellReuseIdentifier:KEffectCell];
    } else {
        [self.tableView registerClass:[RCEffectCell class] forCellReuseIdentifier:KDemoEffectCell];
        
    }
       UIVisualEffectView* effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
       effectView.alpha = 0.8;
       self.tableView.backgroundView = effectView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([LoginManager sharedInstance].isAutoTest) {
        RCEffectCell *cell = [tableView dequeueReusableCellWithIdentifier:KEffectCell];
        cell.delegate = self;
        [cell setModel:self.sounds[indexPath.row]];
        return cell;
    } else {
        RCDemoEffectCell *cell = [tableView dequeueReusableCellWithIdentifier:KDemoEffectCell];
        cell.delegate = self;
        [cell setModel:self.sounds[indexPath.row]];
        return cell;
        
    }
    
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
    RCRTCEffectBottomView *bottom = [[RCRTCEffectBottomView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
    bottom.delegate = self;
    self.bottom = bottom;
    return bottom;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCEffectModel *model = self.sounds[indexPath.row];
    NSUInteger volume = [[RCRTCEngine sharedInstance].audioEffectManager getVolumeOfEffectId:model.index];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结果" message:[NSString stringWithFormat:@"%@音量为%lu",model.name,volume] preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道啦" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController presentViewController:alert animated:YES completion:nil];
    });
    
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

- (void)didSelectGetTotalVolume {
    NSUInteger volume = [[RCRTCEngine sharedInstance].audioEffectManager getEffectsVolume];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结果" message:[NSString stringWithFormat:@"当前全局音量为%lu",volume] preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道啦" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController presentViewController:alert animated:YES completion:nil];
    });
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
}
- (void)didReportEffectPlayingProgress:(float)progress effectId:(NSUInteger)effectId {
    NSLog(@"------%f",progress);
}
@end
