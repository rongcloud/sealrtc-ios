//
//  LoginManager.m
//  SealViewer
//
//  Created by LiuLinhong on 2018/08/10.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "LoginManager.h"
#import "CommonUtility.h"

static LoginManager *sharedLoginManager = nil;


@interface LoginManager ()
{
    NSUserDefaults *settingUserDefaults, *userDefaults;
}
@end


@implementation LoginManager

+ (LoginManager *)sharedInstance
{
    static dispatch_once_t once_dispatch;
    dispatch_once(&once_dispatch, ^{
        sharedLoginManager = [[LoginManager alloc] init];
    });
    return sharedLoginManager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.isIMConnectionSucc = NO;
        self.isLoginTokenSucc = NO;
        self.isObserver = NO;
        self.isBackCamera = NO;
        self.isCloseCamera = NO;
        self.isSpeaker = YES;
        self.isMuteMicrophone = NO;
        self.isSwitchCamera = NO;
        
        [self initUserDefaults];
    }
    
    return self;
}

- (void)initUserDefaults
{
    userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL everLaunched = [userDefaults boolForKey:kEverLaunched];
    if (everLaunched)
    {
        self.roomNumber = [userDefaults valueForKey:kDefaultRoomNumber];
        self.username = [userDefaults valueForKey:kDefaultUserName];
    } else {
        [userDefaults setBool:YES forKey:kEverLaunched];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *docDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Preferences"];
    NSString *settingUserDefaultPath = [docDir stringByAppendingPathComponent:File_SettingUserDefaults_Plist];
    settingUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"settingUserDefaults"];
    
    BOOL isPlistExist = [CommonUtility isFileExistsAtPath:settingUserDefaultPath];
    if (isPlistExist)
    {
        _isGPUFilter = [[settingUserDefaults valueForKey:Key_GPUFilter] boolValue];
        _isSRTPEncrypt = [[settingUserDefaults valueForKey:Key_SRTPEncrypt] boolValue];
        _isTinyStream = [[settingUserDefaults valueForKey:Key_TinyStreamMode] integerValue];
        _resolutionRatioIndex = [[settingUserDefaults valueForKey:Key_ResolutionRatio] integerValue];
        _frameRateIndex = [[settingUserDefaults valueForKey:Key_FrameRate] integerValue];
        _maxCodeRateIndex = [[settingUserDefaults valueForKey:Key_MaxCodeRate] integerValue];
        _minCodeRateIndex = [[settingUserDefaults valueForKey:Key_MinCodeRate] integerValue];
        _codingStyleIndex = [[settingUserDefaults valueForKey:Key_CodingStyle] integerValue];
        _isWarterMark = [[settingUserDefaults valueForKey:Key_WaterMark] integerValue];
        _isAutoTest = [[settingUserDefaults valueForKey:Key_AutoTest] boolValue];
        _phoneNumber = [settingUserDefaults valueForKey:Key_PhoneNumber];
        _countryCode = [settingUserDefaults valueForKey:Key_CountryCode];
        _regionName = [settingUserDefaults valueForKey:Key_RegionName];
    }
    else
    {
        self.isGPUFilter = Value_Default_GPUFilter;
        self.isSRTPEncrypt = Value_Default_SRTPEncrypt;
        self.isTinyStream = Value_Default_TinyStream;
        self.resolutionRatioIndex = Value_Default_ResolutionRatio;
        self.frameRateIndex = Value_Default_FrameRate;
        self.maxCodeRateIndex = Value_Default_MaxCodeRate;
        self.minCodeRateIndex = Value_Default_MinCodeRate;
        self.codingStyleIndex = Value_Default_Coding_Style;
        self.isWarterMark = Value_Default_WaterMark;
        self.isAutoTest = Valie_Default_AutoTest;
        self.phoneNumber = @"";
    }
}

- (RongRTCEngine*)rongRTCEngine {
    return [RongRTCEngine sharedEngine];
}

- (void)setIsGPUFilter:(BOOL)isGPUFilter
{
    _isGPUFilter = isGPUFilter;
    [settingUserDefaults setObject:@(isGPUFilter) forKey:Key_GPUFilter];
    [settingUserDefaults synchronize];
}

- (void)setIsWarterMark:(BOOL)isWarterMark
{
    _isWarterMark = isWarterMark;
    [settingUserDefaults setObject:@(isWarterMark) forKey:Key_WaterMark];
    [settingUserDefaults synchronize];
}

- (void)setIsSRTPEncrypt:(BOOL)isSRTPEncrypt
{
    _isSRTPEncrypt = isSRTPEncrypt;
    [settingUserDefaults setObject:@(isSRTPEncrypt) forKey:Key_SRTPEncrypt];
    [settingUserDefaults synchronize];
}

- (void)setIsTinyStream:(BOOL)isTinyStream
{
    _isTinyStream = isTinyStream;
    [settingUserDefaults setObject:@(isTinyStream) forKey:Key_TinyStreamMode];
    [settingUserDefaults synchronize];
}

- (void)setResolutionRatioIndex:(NSInteger)resolutionRatioIndex
{
    _resolutionRatioIndex = resolutionRatioIndex;
    [settingUserDefaults setObject:@(resolutionRatioIndex) forKey:Key_ResolutionRatio];
    [settingUserDefaults synchronize];
}

- (void)setFrameRateIndex:(NSInteger)frameRateIndex
{
    _frameRateIndex = frameRateIndex;
    [settingUserDefaults setObject:@(frameRateIndex) forKey:Key_FrameRate];
    [settingUserDefaults synchronize];
}

- (void)setMaxCodeRateIndex:(NSInteger)maxCodeRateIndex
{
    _maxCodeRateIndex = maxCodeRateIndex;
    [settingUserDefaults setObject:@(maxCodeRateIndex) forKey:Key_MaxCodeRate];
    [settingUserDefaults synchronize];
}

- (void)setMinCodeRateIndex:(NSInteger)minCodeRateIndex
{
    _minCodeRateIndex = minCodeRateIndex;
    [settingUserDefaults setObject:@(minCodeRateIndex) forKey:Key_MinCodeRate];
    [settingUserDefaults synchronize];
}

- (void)setCodingStyleIndex:(NSInteger)codingStyleIndex
{
    _codingStyleIndex = codingStyleIndex;
    [settingUserDefaults setObject:@(codingStyleIndex) forKey:Key_CodingStyle];
    [settingUserDefaults synchronize];
}

- (void)setIsAutoTest:(BOOL)isAutoTest
{
    _isAutoTest = isAutoTest;
    [settingUserDefaults setObject:@(isAutoTest) forKey:Key_AutoTest];
    [settingUserDefaults synchronize];
}

-(void)setUsername:(NSString *)username{
    if (!username) {
        username = @"";
    }
    _username = username;
    [userDefaults setObject:username forKey:kDefaultUserName];
}

- (void)setRoomNumber:(NSString *)roomNumber
{
    _roomNumber = roomNumber;
    [userDefaults setObject:roomNumber forKey:kDefaultRoomNumber];
    [userDefaults synchronize];
}

- (void)setPhoneNumber:(NSString *)phoneNumber
{
    _phoneNumber = phoneNumber;
    [settingUserDefaults setObject:phoneNumber forKey:Key_PhoneNumber];
    [settingUserDefaults synchronize];
    
    _userID = [NSString stringWithFormat:@"%@%@", phoneNumber, kDeviceUUID];
}

- (void)setCountryCode:(NSString *)countryCode {
    _countryCode = countryCode;
    [settingUserDefaults setObject:countryCode forKey:Key_CountryCode];
    [settingUserDefaults synchronize];
}

- (void)setRegionName:(NSString *)regionName {
    _regionName = regionName;
    [settingUserDefaults setObject:regionName forKey:Key_RegionName];
    [settingUserDefaults synchronize];
}

- (void)setKeyToken:(NSString *)keyToken
{
    [settingUserDefaults setObject:keyToken forKey:self.phoneNumber];
    [settingUserDefaults synchronize];
}

- (NSString *)keyTokenFrom:(NSString *)num
{
    return [settingUserDefaults valueForKey:num];
}

- (NSString *)keyToken
{
    if (self.phoneNumber) {
        return [settingUserDefaults valueForKey:self.phoneNumber];
    } else {
        return @"";
    }
}

@end
