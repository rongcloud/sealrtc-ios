//
//  RCRTCVideoTextureView.h
//  RongRTCLib
//
//  Created by 潘铭达 on 2020/10/21.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCRTCLibDefine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RCRTCVideoTextureViewDelegate <NSObject>

- (int)I420Rotate:(const uint8_t*)src_y
     src_stride_y:(int)src_stride_y
            src_u:(const uint8_t*)src_u
     src_stride_u:(int)src_stride_u
            src_v:(const uint8_t*)src_v
     src_stride_v:(int)src_stride_v
            dst_y:(uint8_t*)dst_y
     dst_stride_y:(int)dst_stride_y
            dst_u:(uint8_t*)dst_u
     dst_stride_u:(int)dst_stride_u
            dst_v:(uint8_t*)dst_v
     dst_stride_v:(int)dst_stride_v
            width:(int)width
           height:(int)height
             mode:(int)mode;

- (int)I420ToARGB:(const uint8_t*)src_y
     src_stride_y:(int)src_stride_y
            src_u:(const uint8_t*)src_u
     src_stride_u:(int)src_stride_u
            src_v:(const uint8_t*)src_v
     src_stride_v:(int)src_stride_v
         dst_argb:(uint8_t*)dst_argb
  dst_stride_argb:(int)dst_stride_argb
            width:(int)width
           height:(int)height;

- (void)changeSize:(int)width height:(int)height;

- (void)changeRotation:(int)rotation;

- (void)firstFrameRendered;

- (void)frameRendered;

@end

@interface RCRTCVideoTextureView : NSObject

@property (nonatomic, weak) id<RCRTCVideoTextureViewDelegate> delegate;

- (CVPixelBufferRef)pixelBufferRef;

@end

NS_ASSUME_NONNULL_END
