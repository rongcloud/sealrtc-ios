//
//  STAudioModelViewController.m
//  SealRTC
//
//  Created by birney on 2020/3/8.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "STAudioModeViewController.h"
#import <RongRTCLib/RongRTCLib.h>

@interface STAudioModeViewController ()

@property (nonatomic, strong) NSDictionary<NSNumber*, NSNumber*>* modesMap;
@property (nonatomic, assign) NSInteger checkMarkIndex;
@end

@implementation STAudioModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.checkMarkIndex = self.mixerModeIndex;
//    [self.modesMap enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull index, NSNumber * _Nonnull mode, BOOL * _Nonnull stop) {
//        if ([mode isEqualToNumber:@(self.mixerModeIndex)]) {
//            *stop = YES;
//          
//        }
//    }];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.checkMarkIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate didSelectedModeOptions:(STAudioMixingOption)[self.modesMap[@(indexPath.row)] integerValue]
                                  atIndex:indexPath.row];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getters
- (NSDictionary<NSNumber*, NSNumber*>*) modesMap {
    if (!_modesMap) {
        const STAudioMixingOption mixAndPlay = STAudioMixingOptionMixing |
                                               STAudioMixingOptionPlaying;
        const STAudioMixingOption onlyMix = STAudioMixingOptionMixing;
        const STAudioMixingOption onlyPlay = STAudioMixingOptionPlaying;
        const STAudioMixingOption mixPlayAndReplace = STAudioMixingOptionReplaceMic |
                                                      STAudioMixingOptionMixing |
                                                      STAudioMixingOptionPlaying;
        _modesMap = @{@(0):@(mixAndPlay),
                      @(1):@(onlyMix),
                      @(2):@(onlyPlay),
                      @(3):@(mixPlayAndReplace),
                    };
    }
    return _modesMap;
}
@end
