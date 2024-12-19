//
//  VideoViewFactory.h
//  flutter_aliplayer
//
//  Created by aliyun on 2020/10/9.
//
#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>

#if __has_include(<AliVCSDK_Standard/AliVCSDK_Standard.h>)
#import <AliVCSDK_Standard/AliVCSDK_Standard.h>

#elif __has_include(<AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>)
#import <AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>

#elif __has_include(<AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>)
#import <AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>

#elif __has_include(<AliVCSDK_UGC/AliVCSDK_UGC.h>)
#import <AliVCSDK_UGC/AliVCSDK_UGC.h>

#endif

#if __has_include(<RtsSDK/RtsSDK.h>)
#define RTS_SUPPORT
#import <RtsSDK/RtsSDK.h>
#endif

#if __has_include(<AliyunPlayer/AliyunPlayer.h>)
#import <AliyunPlayer/AliyunPlayer.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface AliPlayerFactory : NSObject<FlutterPlatformViewFactory,FlutterStreamHandler,CicadaAudioSessionDelegate>

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

@end

NS_ASSUME_NONNULL_END
