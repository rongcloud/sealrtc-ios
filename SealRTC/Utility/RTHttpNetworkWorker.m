//
//  RTHttpNetworkWorker.m
//  RTCTester
//
//  Created by birney on 2019/1/23.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "RTHttpNetworkWorker.h"
//#include <CommonCrypto/CommonHMAC.h>


static RTHttpNetworkWorker* defaultWorker = nil;

@interface RTHttpNetworkWorker () <NSURLSessionDelegate>

@end

@implementation RTHttpNetworkWorker

+ (instancetype)shareInstance {
    if (!defaultWorker) {
        defaultWorker = [[RTHttpNetworkWorker alloc] init];
    }
    return defaultWorker;
}

+ (instancetype) allocWithZone:(struct _NSZone *)zone {
    if (!defaultWorker) {
        defaultWorker = [super allocWithZone:zone];
    }
    return defaultWorker;
}

- (instancetype) copy{
    return defaultWorker;
}


- (void)fetchSMSValidateCode:(NSString *)phoneNum
                  regionCode:(NSString*)code
                     success:(void (^)(NSString* code))sucess
                       error:(void (^)(NSError* error))errorBlock {
    
    NSString *host = RCDEMOServerURL;
    if (![host hasPrefix:@"http"]) {
        host = [@"https://" stringByAppendingString:RCDEMOServerURL];
    }
    NSURL* urlPost = [NSURL URLWithString:[NSString stringWithFormat:@"%@/user/send_code",host]];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:urlPost];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *dic = @{@"phone":phoneNum, @"region":code,@"key":[NSString stringWithFormat:@"%@%@", phoneNum, kDeviceUUID]};
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
    request.HTTPBody = data;
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            errorBlock(error);
        }
        else{
            NSDictionary* responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSString *code = responseObject[@"code"];
            sucess(code);
        }
        [session finishTasksAndInvalidate];
    }];
    [task  resume];
}

- (void)validateSMSPhoneNum:(NSString *)phoneNum
                 regionCode:(NSString*)regionCode
                       code:(NSString *)code
                   response:(void (^)(NSDictionary *respDict))resp
                      error:(void (^)(NSError* error))errorBlock;
{
    NSString *host = RCDEMOServerURL;
    if (![host hasPrefix:@"http"]) {
        host = [@"https://" stringByAppendingString:RCDEMOServerURL];
    }
    NSURL* urlPost = [NSURL URLWithString:[NSString stringWithFormat:@"%@/user/verify_code",host]];
    NSMutableURLRequest *request  = [NSMutableURLRequest requestWithURL:urlPost];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *dic = @{@"phone":phoneNum, @"region":regionCode, @"code":code, @"key":[NSString stringWithFormat:@"%@%@", phoneNum, kDeviceUUID]};
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:nil];
    request.HTTPBody = data;
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            errorBlock(error);
        }
        else{
            NSDictionary* responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            resp(responseObject);
        }
        [session finishTasksAndInvalidate];
    }];
    [task  resume];
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}





@end
