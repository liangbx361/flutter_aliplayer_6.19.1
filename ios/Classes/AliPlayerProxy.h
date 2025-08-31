//
//  AliPlayerProxy.h
//  flutter_aliplayer
//
//  Created by aliyun on 2021/5/18.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "FlutterAliPlayerView.h"

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

#define kAliPlayerMethod    @"method"
#define kAliPlayerId        @"playerId"

NS_ASSUME_NONNULL_BEGIN

@interface AliPlayerProxy : NSObject<AVPDelegate, AVPEventReportParamsDelegate, AliPlayerPictureInPictureDelegate,CicadaRenderingDelegate,CicadaRenderDelegate>

//@property(nonatomic,strong) FlutterResult result;
@property (nonatomic, copy) FlutterEventSink eventSink;

@property(nonatomic,strong) NSString *snapshotPath;

@property(nonatomic,strong,nullable)AliPlayer *player;

@property(nonatomic,strong) NSString *playerId;

@property(nonatomic,assign) int playerType;

@property(nonatomic,strong) FlutterAliPlayerView *fapv;

// 设置画中画控制器，在画中画即将启动的回调方法中设置，并需要在页面准备销毁时主动将其设置为nil，建议设置
@property (nonatomic, strong) AVPictureInPictureController *pipController;

-(void)bindPlayerView:(FlutterAliPlayerView*)fapv;

// 🛡️ PIP 安全相关方法
-(void)safeInvalidatePlaybackStateWithDelay:(NSTimeInterval)delay context:(NSString *)context;
-(void)safeSyncPipPausedState:(BOOL)paused context:(NSString *)context;

@end

NS_ASSUME_NONNULL_END
