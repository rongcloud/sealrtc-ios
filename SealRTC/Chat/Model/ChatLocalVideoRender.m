//
//  ChatLocalVideoRender.m
//  SealRTC
//
//  Created by jfdreamyang on 2019/5/23.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "ChatLocalVideoRender.h"

static void *DemoSampleBufferDisplayLayerStatusObserver = &DemoSampleBufferDisplayLayerStatusObserver;


@interface ChatLocalVideoRender ()
@property (nonatomic,strong) AVSampleBufferDisplayLayer* disPlaylayer;
@end



@implementation ChatLocalVideoRender

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.disPlaylayer = [[AVSampleBufferDisplayLayer alloc]init];
        [self.layer addSublayer:self.disPlaylayer];
        self.disPlaylayer.frame = frame;
        self.disPlaylayer.backgroundColor = [UIColor blackColor].CGColor;
        [self.layer addSublayer:self.disPlaylayer];
        
        [self.disPlaylayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:DemoSampleBufferDisplayLayerStatusObserver];
        
    }
    return self;
}

-(void)renderSampleBuffer:(CMSampleBufferRef)sample{
    if (self.disPlaylayer.isReadyForMoreMediaData) {
        [self.disPlaylayer enqueueSampleBuffer:sample];
    }
}

- (void)flushVideoView
{
    [self.disPlaylayer flushAndRemoveImage];
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.disPlaylayer.frame = self.bounds;
}

- (void)setFillMode:(RCVideoFillMode)filleMode {
    [super setFillMode:filleMode];
    if (RCVideoFillModeAspect == filleMode) {
        self.disPlaylayer.videoGravity = AVLayerVideoGravityResizeAspect;
    } else {
        self.disPlaylayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (context == DemoSampleBufferDisplayLayerStatusObserver) {
        AVQueuedSampleBufferRenderingStatus status = (AVQueuedSampleBufferRenderingStatus)[change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVQueuedSampleBufferRenderingStatusFailed && [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [self.disPlaylayer flushAndRemoveImage];
        }
    }
}

-(void)dealloc{
    [self.disPlaylayer removeObserver:self forKeyPath:@"status"];
}


@end
