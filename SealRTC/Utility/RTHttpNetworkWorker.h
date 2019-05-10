//
//  RTHttpNetworkWorker.h
//  RTCTester
//
//  Created by birney on 2019/1/23.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTHttpNetworkWorker : NSObject

+ (instancetype)shareInstance;

- (void)fetchSMSValidateCode:(NSString *)phoneNum
                  regionCode:(NSString*)code
                     success:(void (^)(NSString* code))sucess
                       error:(void (^)(NSError* error))errorBlock;

- (void)validateSMSPhoneNum:(NSString *)phoneNum
                 regionCode:(NSString*)regionCode
                       code:(NSString *)code
                   response:(void (^)(NSDictionary *respDict))resp
                      error:(void (^)(NSError* error))errorBlock;

@end


NS_ASSUME_NONNULL_END
