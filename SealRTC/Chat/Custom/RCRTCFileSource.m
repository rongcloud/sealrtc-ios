//
//  RCRTCFileSource.m
//  RongRTCLib
//
//  Created by jfdreamyang on 2019/1/18.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCRTCFileSource.h"

NSString *const kIMFileVideoCapturerErrorDomain = @"cn.rongcloud.RCRTCFileVideoCapturer";

typedef NS_ENUM(NSInteger, IMFileVideoCapturerErrorCode) {
    RCRTCFileVideoCapturerErrorCode_CapturerRunning = 2000,
    RCRTCFileVideoCapturerErrorCode_FileNotFound
};

typedef NS_ENUM(NSInteger, RCRTCFileVideoCapturerStatus) {
    RCRTCFileVideoCapturerStatusNotInitialized,
    RCRTCFileVideoCapturerStatusStarted,
    RCRTCFileVideoCapturerStatusStopped
};

@implementation RCRTCFileSource
{
    AVAssetReader *_reader;
    AVAssetReaderTrackOutput *_outVideoTrack;
    AVAssetReaderTrackOutput *_outAudioTrack;
    RCRTCFileVideoCapturerStatus _status;
    CMTime _lastPresentationTime;
    NSURL *_fileURL;
    
    Float64 _currentMediaTime;
    Float64 _currentVideoTime;
    NSThread* _audioDecodeThread;
    NSThread* _videoThread;
}

@synthesize observer = _observer;

- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];

    if (self) {
        _currentPath = filePath;
    }

    return self;
}

#pragma mark - RCRTCVideoSourceInterface
- (void)setObserver: (id <RCRTCVideoObserverInterface>)observer {
    _observer = observer;
}

- (void)didInit {
}

- (void)didStart {
    [self start];
}

- (void)didStop {
    [self stop];
}

- (BOOL)start {
    if (_status == RCRTCFileVideoCapturerStatusStarted) {
        return NO;
    } else {
        _status = RCRTCFileVideoCapturerStatusStarted;
        self->_lastPresentationTime = CMTimeMake(0, 0);
        self->_fileURL = [NSURL fileURLWithPath:self->_currentPath];
        [self.delegate didWillStartRead];
        [self setupReader];
    }

    return YES;
}

- (BOOL)stop {
    _status = RCRTCFileVideoCapturerStatusStopped;
    [_audioDecodeThread cancel];
    [_videoThread cancel];
    return YES;
}

#pragma mark - Private

- (void)setupAudioTrakOutput:(AVURLAsset*)asset {
    AVAssetTrack* audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    AudioStreamBasicDescription asbd = RCRTCAudioMixer.writeAsbd;
    NSDictionary* settings = @{AVFormatIDKey:               @(kAudioFormatLinearPCM),
                               AVSampleRateKey:             @(asbd.mSampleRate),
                               AVNumberOfChannelsKey:       @(asbd.mChannelsPerFrame),
                               AVLinearPCMIsNonInterleaved: @(NO)};
    _outAudioTrack = 
        [[AVAssetReaderTrackOutput alloc] initWithTrack:audioTrack outputSettings:settings];
    if ([_reader canAddOutput:_outAudioTrack]) {
        [_reader addOutput:_outAudioTrack];
    }
}

- (void)audioDecode {
    SInt64 sampleTime = 0;
    while (![NSThread currentThread].isCancelled) {
        CMSampleBufferRef sample = [_outAudioTrack copyNextSampleBuffer];
        if (!sample) break;
        AudioBufferList abl = {0};
        CMBlockBufferRef blockBuffer;
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sample,
                                                                NULL,
                                                                &abl,
                                                                sizeof(abl),
                                                                NULL,
                                                                NULL,
                                                                0,
                                                                &blockBuffer);
        CMItemCount count =  CMSampleBufferGetNumSamples(sample);
        [[RCRTCAudioMixer sharedInstance] writeAudioBufferList:&abl 
                                                        frames:(UInt32)count 
                                                    sampleTime:sampleTime 
                                                      playback:YES];
        sampleTime += count;
        CFRelease(blockBuffer);
        CFRelease(sample);
    }

    _audioDecodeThread = nil;
    [NSThread exit];
}

- (void)setupReader {
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_fileURL options:nil];
    NSArray *allTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    // 可以矫正由于时间偏差导致输出不准确的问题，也可以解决循环播放导致的中间播放延迟，中间会丢弃一部分视频帧
    _currentMediaTime = CACurrentMediaTime();
    _reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    if (error) {
        return;
    }
    
    NSDictionary *options = @{
                              (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
                              };
    _outVideoTrack =
        [[AVAssetReaderTrackOutput alloc] initWithTrack:allTracks.firstObject 
                                         outputSettings:options];
    //_outVideoTrack.alwaysCopiesSampleData = NO;
    [_reader addOutput:_outVideoTrack];
    [self setupAudioTrakOutput:asset];
    [_reader startReading];
    if (!_audioDecodeThread) {
        _audioDecodeThread = 
            [[NSThread alloc] initWithTarget:self selector:@selector(audioDecode) object:nil];
        _audioDecodeThread.name = @"com.rongcloud.filecapturer.audio";
    }
    [_audioDecodeThread start];
    if (!_videoThread) {
        _videoThread = 
            [[NSThread alloc] initWithTarget:self selector:@selector(videoProcess) object:nil];
        _videoThread.name = @"com.rongcloud.filecapturer.video";
    }
    [_videoThread start];
}

- (nullable NSString *)pathForFileName:(NSString *)fileName {
    NSArray *nameComponents = [fileName componentsSeparatedByString:@"."];
    if (nameComponents.count != 2) {
        return nil;
    }
    
    NSString *path =
    [[NSBundle mainBundle] pathForResource:nameComponents[0] ofType:nameComponents[1]];
    return path;
}

- (void)checkStatus {
    if (_status == RCRTCFileVideoCapturerStatusStopped) {
        [_reader cancelReading];
        _reader = nil;
        [_audioDecodeThread cancel];
        _outAudioTrack = nil;
        [_videoThread cancel];
        _outVideoTrack = nil;
        return;
    }
    
    if (_reader.status == AVAssetReaderStatusCompleted) {
        [_reader cancelReading];
        _reader = nil;
        [_audioDecodeThread cancel];
        _outAudioTrack = nil;
        [_videoThread cancel];
        _outVideoTrack = nil;
        [self.delegate didReadCompleted];
        [self setupReader];
        return;
    }
}

- (void)videoProcess {
    _lastPresentationTime = CMTimeMakeWithSeconds(0.0, 1);
    _currentVideoTime = CACurrentMediaTime();
    while (![NSThread currentThread].isCancelled) {
        CMSampleBufferRef sampleBuffer = [_outVideoTrack copyNextSampleBuffer];
        if (!sampleBuffer) break;
        if (CMSampleBufferGetNumSamples(sampleBuffer) != 1 || 
            !CMSampleBufferIsValid(sampleBuffer) ||
            !CMSampleBufferDataIsReady(sampleBuffer)) {
            FwLogD(RC_Type_DEB, @"L-customVideoProcess-S", @"sample buffer is error");
            CFRelease(sampleBuffer);
            continue;
        }
    
        CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        Float64 presentationDifference =
            CMTimeGetSeconds(CMTimeSubtract(presentationTime, _lastPresentationTime));
        // FwLogD(RC_Type_DEB, @"L-customVideoProcess-S", 
        //        @"presentationTime is %@, _lastPresentationTime is %@", 
        //        CMTimeCopyDescription(NULL, presentationTime), 
        //        CMTimeCopyDescription(NULL, _lastPresentationTime));
        if (isnan(presentationDifference)) {
            CFRelease(sampleBuffer);
            continue;
        }
        _currentMediaTime = CACurrentMediaTime();
    
        Float64 delta = fabs(_currentMediaTime - _currentVideoTime - presentationDifference);
        // FwLogD(RC_Type_DEB, @"L-customVideoProcess-S", 
        //        @"presentationDifference is %lf, _currentVideoTime is %lf, _currentMediaTime is %lf", 
        //        presentationDifference, _currentVideoTime, _currentMediaTime);
        if (delta > 0.025 && presentationDifference != 0) {
            if (_currentMediaTime < _currentVideoTime + presentationDifference) {
//                FwLogD(RC_Type_DEB, @"L-customVideoProcess-S", @"%lf microseconds", delta * 1000000);
                usleep(delta * 1000000);
            } else {
                FwLogD(RC_Type_DEB, @"L-customVideoProcess-S", @"video buffer time is expired");
                CFRelease(sampleBuffer);
                continue;
            }
        }

//        FwLogD(RC_Type_DEB, @"L-customVideoProcess-S", @"prepare writing sample buffer!");
        [self.observer write:sampleBuffer error:nil];
        CFRelease(sampleBuffer);
    }

    _videoThread = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self checkStatus];
    });
    [NSThread exit];
}

- (void)dealloc {
    [self stop];
}

@end

