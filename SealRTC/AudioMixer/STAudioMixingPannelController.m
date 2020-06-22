//
//  STAudioMixingPannelController.m
//  SealRTC
//
//  Created by birney on 2020/3/8.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <RongRTCLib/RongRTCLib.h>
#import "STAudioMixingPannelController.h"
#import "STAudioModeViewController.h"
#import "STAudioMixerConfiguration.h"
#import "RTActiveWheel.h"

@interface STAudioMixingPannelController () <STAudioModeViewControllerDelegate,
                                             UIDocumentPickerDelegate,
                                             RCRTCAudioMixerAudioPlayDelegate>
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *mixerModelLabel;
@property (weak, nonatomic) IBOutlet UILabel *localVolumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *micVolumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *remoteVolumeLabel;
@property (weak, nonatomic) IBOutlet UISlider *localVolumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *micVolumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *remoteVolueSlider;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *playingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (nonatomic, assign) Float64 audioFileDuration;
@property (nonatomic, assign) BOOL updatePlayingTimeDisable;
@end

/**
 "play_and_mix"="Playing and mixing";
 "only_mix"="Only mixing";
 "only_play"="Only Playing";
 "play_and_mix_and_disbale_mic"="Playing and mixing, disable mic";
 */

NSString* desc(NSInteger mode) {
    switch (mode) {
        case 0:
            return NSLocalizedString(@"play_and_mix", nil);
        case 1:
            return NSLocalizedString(@"only_mix", nil);
        case 2:
            return NSLocalizedString(@"only_play", nil);
        case 3:
            return NSLocalizedString(@"play_and_mix_and_disbale_mic", nil);
        default:
            return @"unknown";
    }
}

@implementation STAudioMixingPannelController

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //      self.navigationController.navigationBarHidden = YES;
    
    if (self.config.audioFileURL.absoluteString.length <= 0) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"my_homeland" ofType:@"aac"];
        NSURL* fileURL = [NSURL fileURLWithPath:path];
        self.config.audioFileURL = fileURL;
    }
    
    [self setup];
}

- (void)setup {
    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 350);
    UIVisualEffectView* effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    effectView.alpha = 0.8;
    self.tableView.backgroundView = effectView;
    
    NSString* fileName = self.config.audioFileURL.lastPathComponent;
    Float64 duration =  [RCRTCAudioMixer durationOfAudioFile:self.config.audioFileURL];
    self.endTimeLabel.text = [self textFormatOfDuration:duration];
    self.audioFileDuration = duration;
    [RCRTCAudioMixer sharedInstance].delegate = self;
    self.fileNameLabel.text = fileName;
    self.localVolumeSlider.value = self.config.localVolume;
    self.micVolumeSlider.value = self.config.micVolume;
    self.remoteVolueSlider.value = self.config.remoteVolume;
    self.localVolumeLabel.text = [NSString stringWithFormat:@"%@",@((NSInteger)self.config.localVolume)];
    self.micVolumeLabel.text = [NSString stringWithFormat:@"%@",@((NSInteger)self.config.micVolume)];
    self.remoteVolumeLabel.text = [NSString stringWithFormat:@"%@",@((NSInteger)self.config.remoteVolume)];
    self.mixerModelLabel.text = desc(self.config.mixerModeIndex);
    if ([RCRTCAudioMixer sharedInstance].status == RTCMixEngineStatusPlaying) {
        self.playBtn.selected = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.title = NSLocalizedString(@"mixer_control", nil);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
    self.title = @" ";
}
#pragma mark - Helper
- (NSString*)textFormatOfDuration:(Float64)duration {
    Float64 fmiutes = duration / 60.0f;
    NSUInteger minutes = fmiutes;
    NSUInteger seconds = duration - minutes * 60;
    return [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)minutes, (unsigned long)seconds];
}
#pragma mark - Target Action
- (IBAction)closeAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)localVolumeChanged:(UISlider*)sender {
    self.localVolumeLabel.text = [NSString stringWithFormat:@"%@",@((NSInteger)sender.value)];
    self.config.localVolume = (NSInteger)sender.value;
    [[RCRTCAudioMixer sharedInstance] setPlayingVolume:sender.value];
}
- (IBAction)micVolumeChanged:(UISlider *)sender {
    self.micVolumeLabel.text = [NSString stringWithFormat:@"%@",@((NSInteger)sender.value)];
    self.config.micVolume = (NSInteger)sender.value;
    [[RCRTCEngine sharedInstance].defaultAudioStream setRecordingVolume:sender.value];
}
- (IBAction)remoteVolumeChanged:(UISlider *)sender {
    self.remoteVolumeLabel.text = [NSString stringWithFormat:@"%@",@((NSInteger)sender.value)];
    self.config.remoteVolume = (NSInteger)sender.value;
    [[RCRTCAudioMixer sharedInstance] setMixingVolume:sender.value];
}

- (IBAction)progressDidChanged:(UISlider *)sender {
    [[RCRTCAudioMixer sharedInstance] setPlayProgress:sender.value];
    self.updatePlayingTimeDisable = NO;
    self.playBtn.selected = YES;
}
- (IBAction)progressTouchDown:(id)sender {
    self.updatePlayingTimeDisable = YES;
}

- (IBAction)resetAction:(id)sender {
    [[RCRTCAudioMixer sharedInstance] stop];
    self.playBtn.selected = NO;
}

- (IBAction)playAction:(UIButton *)sender {
    if (!sender.isSelected) {
        if ([RCRTCAudioMixer sharedInstance].status == RTCMixEngineStatusPause) {
            [[RCRTCAudioMixer sharedInstance] resume];
        } else {
            NSURL* audioURL = self.config.audioFileURL;
            @try {
                BOOL isPlay = NO;
                RCRTCMixerMode mode = RCRTCMixerModeNone;
                if (self.config.mixingOption & STAudioMixingOptionPlaying) {
                    isPlay = YES;
                }
                if (self.config.mixingOption & STAudioMixingOptionMixing) {
                    mode = RCRTCMixerModeMixing;
                }
                
                if (self.config.mixingOption & STAudioMixingOptionReplaceMic) {
                    mode = RCRTCMixerModeReplace;
                }
                [[RCRTCAudioMixer sharedInstance] startMixingWithURL:audioURL
                                                            playback:isPlay
                                                           mixerMode:mode
                                                           loopCount:NSUIntegerMax];
            } @catch (NSException* e) {
                UIWindow* keyWin = [UIApplication sharedApplication].keyWindow;
                [RTActiveWheel showPromptHUDAddedTo:keyWin
                                               text:NSLocalizedString(@"audio_file_type_unsupport", nil)];
                return;
            }
        }
    } else {
        [[RCRTCAudioMixer sharedInstance] pause];
    }
    sender.selected = !sender.isSelected;
}

#pragma makr - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > -44) {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = nil;
    } else {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
    }
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.row) {
        UIDocumentPickerViewController *dpvc =
            [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.audio"]
                                                                   inMode:UIDocumentPickerModeImport];
        dpvc.delegate = self;
        if (@available(iOS 13, *)) {
            dpvc.shouldShowFileExtensions = YES;
        }
        [self presentViewController:dpvc animated:YES completion:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    self.config.audioFileURL = url;
    self.fileNameLabel.text = url.lastPathComponent;
    [[RCRTCAudioMixer sharedInstance] stop];
    self.playBtn.selected = NO;
    Float64 duration =  [RCRTCAudioMixer durationOfAudioFile:self.config.audioFileURL];
    self.audioFileDuration = duration;
    self.playingTimeLabel.text = @"00:00";
    self.endTimeLabel.text = [self textFormatOfDuration:duration];
    self.progressSlider.value = 0;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"push_audio_mode"]) {
        STAudioModeViewController* amvc = segue.destinationViewController;
        amvc.mixerModeIndex = self.config.mixerModeIndex;
        amvc.delegate = self;
    }
}


#pragma mark -STAudioModeViewControllerDelegate

- (void)didSelectedModeOptions:(STAudioMixingOption)option atIndex:(NSInteger)index {
    self.mixerModelLabel.text = desc(index);
    self.config.mixerModeIndex = index;
    self.config.mixingOption = option;
    [[RCRTCAudioMixer sharedInstance] stop];
    self.playBtn.selected = NO;
}

#pragma mark - RongRTCAudioMixerDelegate
- (void)didReportPlayingProgress:(float)progress {
    if (!self.updatePlayingTimeDisable) {
        [self.progressSlider setValue:progress animated:YES];
        Float64 playAt = self.audioFileDuration * progress;
        self.playingTimeLabel.text = [self textFormatOfDuration:playAt];
    }
    
}
- (void)didPlayToEnd {
    if (!self.updatePlayingTimeDisable) {
        self.progressSlider.value = 1;
    }
}

@end
