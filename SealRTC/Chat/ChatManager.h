//
//  MeetingManager.h
//  SealViewer
//
//  Created by LiuLinhong on 2018/08/22.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongRTCLib/RongRTCEngine.h>
#import "ChatCellVideoViewModel.h"
#import "LoginManager.h"

#define kChatManager ([ChatManager sharedInstance])
#define kItemRect CGRectMake(0, 0, 112, 84)


@interface ChatManager : NSObject

@property (nonatomic, strong) RongRTCEngine *rongRTCEngine;
@property (nonatomic, strong) RongRTCVideoCaptureParam *captureParam;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSMutableArray *allRemoteUserDataArray, *recentDataArray;
@property (nonatomic, strong) NSMutableArray *observerArray;
@property (nonatomic, strong) ChatCellVideoViewModel *localUserDataModel;
@property (nonatomic, strong) NSString *whiteBoardURL;


+ (ChatManager *)sharedInstance;

- (void)clearAllDataArray;

- (ChatCellVideoViewModel *)getRemoteUserDataModelFromIndex:(NSInteger)index;
- (ChatCellVideoViewModel *)getRemoteUserDataModelFromStreamID:(NSString *)streamID;
- (ChatCellVideoViewModel *)getRemoteUserDataModelFromUserID:(NSString *)userID;
- (ChatCellVideoViewModel *)getRemoteUserDataModelSimilarUserID:(NSString *)userID;
- (NSString *)getUserIDOfRemoteUserDataModelFromIndex:(NSInteger)index;
- (NSArray *)getAllRemoteUserIDArray;
- (void)addRemoteUserDataModel:(ChatCellVideoViewModel *)model;
- (void)setRemoteUserDataModel:(ChatCellVideoViewModel *)model atIndex:(NSInteger)index;
- (void)removeRemoteUserDataModelFromStreamID:(NSString *)streamID;
- (void)removeRemoteUserDataModelFromIndex:(NSInteger)index;
- (NSInteger)indexOfRemoteUserDataArray:(NSString *)streamID;
- (NSInteger)countOfRemoteUserDataArray;
- (BOOL)isContainRemoteUserFromStreamID:(NSString *)streamID;

- (ChatCellVideoViewModel *)getRecentUserDataModelFromIndex:(NSInteger)index;
- (ChatCellVideoViewModel *)getRecentUserDataModelFromUserID:(NSString *)userID;
- (void)addRecentUserDataModel:(ChatCellVideoViewModel *)model;
- (void)addRecentUserDic:(NSDictionary *)dic;
- (void)removeRecentUserDicFromWebId:(NSString *)webId;
- (void)removeAllRecentUserDic;
- (void)removeRecentUserDataModelFromUserID:(NSString *)userID;
- (NSInteger)indexOfRecentUserDataArray:(NSString *)userID;

- (void)configParameter;

@end
