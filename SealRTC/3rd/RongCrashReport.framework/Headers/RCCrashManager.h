//
//  RCCrashManager.h
//  RCCrashReport
//
//  Created by 杨雨东 on 2018/9/11.
//  Copyright © 2018 杨雨东. All rights reserved.
//

#import <Foundation/Foundation.h>

// 崩溃回报的格式
typedef enum : NSUInteger {
    RCCrashReportTypeString,        // 长字符串累心，以 ;; 作为分割符（有 AppleFmt 转化而来）
    RCCrashReportTypeAppleFmt,      // Xcode 奔溃的风格，不带崩溃符号
    RCCrashReportTypeAppleFmtSymbolite,// Xcode 崩溃的风格，带崩溃符号
    RCCrashReportTypeJson,          // 崩详细信息统计
} RCCrashReportType;

@class RCCrashManager;

@protocol RCCrashManagerDelegate <NSObject>

-(void)crashManager:(RCCrashManager *)manager didGenerateCrash:(NSString *)crash;

@end



@interface RCCrashManager : NSObject
+(RCCrashManager *)sharedManager;


@property (nonatomic,weak)id <RCCrashManagerDelegate> delegate;

// 以下两个属性如果不设置，默认采集所有崩溃

/**
 崩溃属于某个类时才会汇报，多个类以 ;; 分割
 */
@property (nonatomic,strong)NSString * filters;

/**
 崩溃属于某个类前缀时才会汇报，多个类前缀以 ;; 分割
 */
@property (nonatomic,strong)NSString * classPrefixs;

/**
 崩溃时线程调用堆栈的数量
 */
@property (nonatomic,assign)NSUInteger threadNumber;

/**
 用户信息，该信息会上传到 server，方便后期比对
 */
@property (nonatomic,strong)NSDictionary * userInfo;

/**
 崩溃报告类型,默认为 RCCrashReportTypeString
 */
@property (nonatomic,assign)RCCrashReportType reportType;

/**
 安装崩溃检测工具
 */
-(void)install;

/**
 崩溃报告
 */
-(void)reports:(void (^)(NSArray <NSString *> *))reportsBlock;

@end
