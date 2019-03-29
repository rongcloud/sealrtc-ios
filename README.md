# sealrtc-ios

1. Demo工程中缺少RongRTCLib.framework库, 请到官网: http://www.rongcloud.cn/downloads/rtc 下载iOS SDK后, 添加到 /SealRTC/framework/ 下

2. 请注意, V3.0.0版本与之前版本无法互通, 所用 RongRTCLib.framework 也请选用3.0.0之后版本

3. 工程中缺少必须的AppKey,  该宏定义在SealRTC_Prefix.pch中, 如: #define RCIMAPPKey @"", 请在官网 https://www.rongcloud.cn/ 注册账号后, 登录获取

