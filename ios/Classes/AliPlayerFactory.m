//
//  VideoViewFactory.m
//  flutter_aliplayer
//
//  Created by aliyun on 2020/10/9.
//
#import "AliPlayerFactory.h"
#import "FlutterAliPlayerView.h"
#import "NSDictionary+ext.h"
#import <MJExtension/MJExtension.h>
#import "AliPlayerProxy.h"
#import<CommonCrypto/CommonDigest.h>

typedef NS_ENUM(NSInteger, AliPlayerAudioSesstionType
) {
AliPlayerAudioSesstionTypeSDKDefault,
AliPlayerAudioSesstionTypeMix,
AliPlayerAudioSesstionTypeNone,
};

@interface AliPlayerFactory () {
    NSObject <FlutterBinaryMessenger> *_messenger;
    FlutterMethodChannel *_commonChannel;
    UIView *playerView;
}

@property(nonatomic, assign) AliPlayerAudioSesstionType audioSessionType;

@property(nonatomic, strong) FlutterEventSink eventSink;
@property(nonatomic, strong) NSMutableDictionary *viewDic;
@property(nonatomic, strong) NSMutableDictionary *playerProxyDic;
@property(nonatomic, strong) VidPlayerConfigGenerator *vidPlayerConfigGenerator;
@property(nonatomic, strong) NSMutableDictionary *globalBackupUrlMap;

@end

@implementation AliPlayerFactory

- (instancetype)initWithMessenger:(NSObject <FlutterBinaryMessenger> *)messenger {
    self = [super init];
    if (self) {
        _messenger = messenger;
        __weak __typeof__(self) weakSelf = self;

        _viewDic = @{}.mutableCopy;
        _playerProxyDic = @{}.mutableCopy;

        _commonChannel = [FlutterMethodChannel methodChannelWithName:@"plugins.flutter_aliplayer_factory" binaryMessenger:messenger];
        [_commonChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
            NSObject *obj = [call arguments];
            if ([obj isKindOfClass:NSDictionary.class]) {
                NSDictionary *dic = (NSDictionary *) obj;
                NSString *playerId = [dic objectForKey:@"playerId"];
                AliPlayerProxy *proxy = [weakSelf.playerProxyDic objectForKey:playerId];

                if (!proxy && playerId.length > 0 &&
                    ![call.method isEqualToString:@"createAliPlayer"]) {
                    NSLog(@"flutter aliplayer sdk err : player whith playerId %@ is not exist",
                          playerId);
                    return;
                }

                NSObject *arguments = [dic objectForKey:@"arg"];
                [weakSelf onMethodCall:call result:result atObj:proxy ?: @"" arg:arguments ?: @""];
            } else {
                [weakSelf onMethodCall:call result:result atObj:@"" arg:@""];
            }
        }];

        FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"flutter_aliplayer_event" binaryMessenger:messenger];
        [eventChannel setStreamHandler:self];
    }
    return self;
}

#pragma mark - FlutterStreamHandler

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments
                                        eventSink:(FlutterEventSink)eventSink {
    self.eventSink = eventSink;
    return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    return nil;
}

- (NSObject <FlutterMessageCodec> *)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

- (nonnull NSObject

<FlutterPlatformView> *)createWithFrame:(CGRect)
frame
        viewIdentifier
:(int64_t)
viewId
        arguments
:(
id _Nullable
)args {
    NSString *viewIdKey = [NSString stringWithFormat:@"%lli", viewId];
    FlutterAliPlayerView *fapv = [_viewDic objectForKey:viewIdKey];
    if (fapv) {
        //更新参数
        [fapv updateWithWithFrame:frame arguments:args];
    } else {
        fapv =
                [[FlutterAliPlayerView alloc] initWithWithFrame:frame
                                                 viewIdentifier:viewId
                                                      arguments:args
                                                binaryMessenger:_messenger];
        [_viewDic setObject:fapv forKey:viewIdKey];
    }

    return fapv;
}

- (void)onMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result atObj:(NSObject *)player arg:(NSObject *)arg {
    NSString *method = [call method];
    SEL methodSel = NSSelectorFromString([NSString stringWithFormat:@"%@:", method]);
    NSArray *arr = @[call, result, player, arg];
    if ([self respondsToSelector:methodSel]) {
        IMP imp = [self methodForSelector:methodSel];
        void (*func)(id, SEL, NSArray *) = (void *) imp;
        func(self, methodSel, arr);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)initLicenseServiceForIOS:(NSArray *)arr {
    FlutterResult result = arr[1];

    [AliPrivateService initLicenseService];
    result(nil);
}

- (void)initService:(NSArray *)arr {
    FlutterMethodCall *call = arr.firstObject;
    FlutterResult result = arr[1];
    FlutterStandardTypedData *fdata = [call arguments];
    [AliPrivateService initKeyWithData:fdata.data];
    result(nil);
}

- (void)createAliPlayer:(NSArray *)arr {
    FlutterMethodCall *call = arr.firstObject;
    FlutterResult result = arr[1];
    NSDictionary *dic = [call arguments];
    NSString *playerId = [dic objectForKey:@"playerId"];
    NSNumber *type = [dic objectForKey:@"arg"];
    AliPlayerProxy *proxy = [AliPlayerProxy new];
    proxy.playerType = type.intValue;
    proxy.playerId = playerId;
    proxy.eventSink = self.eventSink;

    [_playerProxyDic setObject:proxy forKey:playerId];

    result(nil);
}

- (void)setPlayerView:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *viewId = arr[3];
    FlutterAliPlayerView *fapv = [_viewDic objectForKey:[NSString stringWithFormat:@"%@", viewId]];
//    [proxy.player setPlayerView:fapv.view];
    [proxy bindPlayerView:fapv];
    result(nil);
}

- (void)setUrl:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSString *url = arr[3];
    AVPUrlSource *source = [[AVPUrlSource alloc] urlWithString:url];
    [proxy.player setUrlSource:source];
    result(nil);
}

- (void)prepare:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    [proxy.player prepare];
    result(nil);
}

- (void)play:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    [proxy.player start];
    result(nil);
}

- (void)pause:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    [proxy.player pause];
    result(nil);
}

- (void)clearScreen:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    [proxy.player clearScreen];
    result(nil);
}

- (void)clearScreenSync:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    [proxy.player clearScreenSync];
    result(nil);
}

- (void)stop:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    [proxy.player stop];
    result(nil);
}

- (void)destroy:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    [proxy.player destroy];

    if ([_playerProxyDic objectForKey:proxy.playerId]) {
        [_playerProxyDic removeObjectForKey:proxy.playerId];
    }

    if (proxy.fapv) {
        NSString *viewId = [NSString stringWithFormat:@"%li", (long) proxy.fapv.viewId];
        if ([_viewDic objectForKey:viewId]) {
            [_viewDic removeObjectForKey:viewId];
        }
    }
    //TODO 销毁注意移除对应的字典
//    if([player isKindOfClass:AliListPlayer.class]){
//        self.aliListPlayer = nil;
//    }else{
//        self.aliPlayer = nil;
//    }
    result(nil);
}

- (void)releaseAsync:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    [proxy.player destroyAsync];

    if ([_playerProxyDic objectForKey:proxy.playerId]) {
        [_playerProxyDic removeObjectForKey:proxy.playerId];
    }

    if (proxy.fapv) {
        NSString *viewId = [NSString stringWithFormat:@"%li", (long) proxy.fapv.viewId];
        if ([_viewDic objectForKey:viewId]) {
            [_viewDic removeObjectForKey:viewId];
        }
    }
    //TODO 销毁注意移除对应的字典
//    if([player isKindOfClass:AliListPlayer.class]){
//        self.aliListPlayer = nil;
//    }else{
//        self.aliPlayer = nil;
//    }
    result(nil);
}

- (void)setAudioSessionTypeForIOS:(NSArray *)arr {
    FlutterMethodCall *call = arr.firstObject;
    FlutterResult result = arr[1];
    NSNumber *val = [call arguments];
    self.audioSessionType = val.intValue;
    if (val.boolValue) {
        [AliPlayer setAudioSessionDelegate:self];
    } else {
        [AliPlayer setAudioSessionDelegate:nil];
    }
    result(nil);
}

- (void)isLoop:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    result(@([proxy.player isLoop]));
}

- (void)setLoop:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *isLoop = arr[3];
    [proxy.player setLoop:isLoop.boolValue];
    result(nil);
}

- (void)isAutoPlay:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    result(@([proxy.player isAutoPlay]));
}

- (void)setAutoPlay:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *val = arr[3];
    [proxy.player setAutoPlay:val.boolValue];
    result(nil);
}

- (void)isMuted:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    result(@([proxy.player isMuted]));
}

- (void)setMuted:(NSArray *)arr {
    FlutterResult result = arr[1];
    NSNumber *val = arr[3];
    AliPlayerProxy *proxy = arr[2];
    [proxy.player setMuted:val.boolValue];
    result(nil);
}

- (void)enableHardwareDecoder:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    result(@([proxy.player enableHardwareDecoder]));
}

- (void)setEnableHardwareDecoder:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *val = arr[3];
    [proxy.player setEnableHardwareDecoder:val.boolValue];
    result(nil);
}

- (void)getRotateMode:(NSArray *)arr {
    AliPlayerProxy *proxy = arr[2];
    FlutterResult result = arr[1];
    result(@(proxy.player.rotateMode));
}

- (void)setRotateMode:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *val = arr[3];
    [proxy.player setRotateMode:val.intValue];
    result(nil);
}

- (void)setOutputAudioChannel:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *val = arr[3];
    [proxy.player setOutputAudioChannel:val.intValue];
    result(nil);
}

- (void)getScalingMode:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    int mode = 0;
    switch (proxy.player.scalingMode) {
        case AVP_SCALINGMODE_SCALEASPECTFIT:
            mode = 0;
            break;
        case AVP_SCALINGMODE_SCALEASPECTFILL:
            mode = 1;
            break;
        case AVP_SCALINGMODE_SCALETOFILL:
            mode = 2;
            break;

        default:
            break;
    }
    result(@(mode));
}

- (void)setScalingMode:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *val = arr[3];
//    与android保持一致
    int mode = AVP_SCALINGMODE_SCALEASPECTFIT;
    switch (val.intValue) {
        case 0:
            mode = AVP_SCALINGMODE_SCALEASPECTFIT;
            break;
        case 1:
            mode = AVP_SCALINGMODE_SCALEASPECTFILL;
            break;
        case 2:
            mode = AVP_SCALINGMODE_SCALETOFILL;
            break;

        default:
            break;
    }
    [proxy.player setScalingMode:mode];
    result(nil);
}

- (void)getMirrorMode:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    result(@(proxy.player.mirrorMode));
}

- (void)getAlphaRenderMode:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    int mode = AVP_RENDERMODE_ALPHA_NONE;
    switch (proxy.player.alphaRenderMode) {
        case AVP_RENDERMODE_ALPHA_AT_RIGHT:
            mode = AVP_RENDERMODE_ALPHA_AT_RIGHT;
            break;
        case AVP_RENDERMODE_ALPHA_AT_LEFT:
            mode = AVP_RENDERMODE_ALPHA_AT_LEFT;
            break;
        case AVP_RENDERMODE_ALPHA_AT_TOP:
            mode = AVP_RENDERMODE_ALPHA_AT_TOP;
            break;
        case AVP_RENDERMODE_ALPHA_AT_BOTTOM:
            mode = AVP_RENDERMODE_ALPHA_AT_BOTTOM;
            break;
        default:
            break;
    }
    result(@(mode));
}

- (void)setAlphaRenderMode:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *val = arr[3];
//    与android保持一致
    int mode = AVP_RENDERMODE_ALPHA_NONE;
    switch (val.intValue) {
        case AVP_RENDERMODE_ALPHA_AT_RIGHT:
            mode = AVP_RENDERMODE_ALPHA_AT_RIGHT;
            break;
        case AVP_RENDERMODE_ALPHA_AT_LEFT:
            mode = AVP_RENDERMODE_ALPHA_AT_LEFT;
            break;
        case AVP_RENDERMODE_ALPHA_AT_TOP:
            mode = AVP_RENDERMODE_ALPHA_AT_TOP;
            break;
        case AVP_RENDERMODE_ALPHA_AT_BOTTOM:
            mode = AVP_RENDERMODE_ALPHA_AT_BOTTOM;
            break;
        default:
            break;
    }
    [ proxy.player setAlphaRenderMode:mode];
    result(nil);
}

- (void)setMirrorMode:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *val = arr[3];
    [proxy.player setMirrorMode:val.intValue];
    result(nil);
}

- (void)getRate:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    result(@(proxy.player.rate));
}

- (void)setRate:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *val = arr[3];
    [proxy.player setRate:val.floatValue];
    result(nil);
}

- (void)snapshot:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSString *val = arr[3];
    proxy.snapshotPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,
                                                             YES).firstObject;
    if (val.length > 0) {
        proxy.snapshotPath = [proxy.snapshotPath stringByAppendingPathComponent:val];
    }
    [proxy.player snapShot];
    result(nil);
}

- (void)createThumbnailHelper:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSString *val = arr[3];
    [proxy.player setThumbnailUrl:val];
    self.eventSink(@{kAliPlayerMethod: @"thumbnail_onPrepared_Success"});
    result(nil);
}

- (void)requestBitmapAtPosition:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *val = arr[3];
    [proxy.player getThumbnail:val.integerValue];
    result(nil);
}

- (void)setTraceID:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSString *val = arr[3];
    NSString *modifiedVal = [@"fluttersdk" stringByAppendingString:val];
    [proxy.player setTraceID:modifiedVal];
    result(nil);
}

- (void)getVideoWidth:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    result(@(proxy.player.width));
}

- (void)getVideoHeight:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    result(@(proxy.player.height));
}

- (void)getVideoRotation:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    result(@(proxy.player.rotation));
}

- (void)getVolume:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    result(@(proxy.player.volume));
}

- (void)setVolume:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *val = arr[3];
    [proxy.player setVolume:val.floatValue];
    result(nil);
}

- (void)getDuration:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    result(@(proxy.player.duration));
}

- (void)getCurrentPosition:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    result(@(proxy.player.currentPosition));
}

- (void)getCurrentUtcTime:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    result(@(proxy.player.currentUtcTime));
}

- (void)getLocalCacheLoadedSize:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    result(@(proxy.player.localCacheLoadedSize));
}

- (void)getCurrentDownloadSpeed:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    result(@(proxy.player.currentDownloadSpeed));
}

- (void)getBufferedPosition:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    result(@(proxy.player.bufferedPosition));
}

- (void)setVideoBackgroundColor:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *val = arr[3];
    int c = val.intValue;
    UIColor *color = [UIColor colorWithRed:((c >> 16) & 0xFF) / 255.0 green:((c >> 8) & 0xFF) /
                                                                            255.0 blue:
            ((c) & 0xFF) / 255.0 alpha:((c >> 24) & 0xFF) / 255.0];
    [proxy.player setVideoBackgroundColor:color];
    result(nil);
}

- (void)setFastStart:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *val = arr[3];

    [proxy.player setFastStart:[val boolValue]];
    result(nil);
}

- (void)getSDKVersion:(NSArray *)arr {
    FlutterResult result = arr[1];
    result([AliPlayer getSDKVersion]);
}

- (void)getDeviceUUID:(NSArray *)arr {
    FlutterResult result = arr[1];
    result([AliPlayer getDeviceUUID]);
}

- (void)isFeatureSupport:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSNumber *val = [call arguments];
    BOOL callback = [AliPlayer isFeatureSupport:[val intValue]];
    result(@(callback));
}

- (void)enableConsoleLog:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSNumber *val = [call arguments];
    [AliPlayer setEnableLog:val.boolValue];
    result(nil);
}

- (void)getLogLevel:(NSArray *)arr {
    FlutterResult result = arr[1];
    //TODO 拿不到
    result(@(-1));
}

- (void)setLogLevel:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSNumber *val = [call arguments];
    [AliPlayer setLogCallbackInfo:val.intValue callbackBlock:nil];
    result(nil);
}

- (void)setPreferPlayerName:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSString *val = arr[3];

    [proxy.player setPreferPlayerName:val];
    result(nil);
}

- (void)setPictureInPictureShowMode:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *showMode = arr[3];
    [proxy.player setPictureInPictureShowMode:showMode.intValue];
    result(nil);
}

- (void)seekTo:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *dic = arr[3];
    NSNumber *position = dic[@"position"];
    NSNumber *seekMode = dic[@"seekMode"];
    [proxy.player seekToTime:position.integerValue seekMode:seekMode.intValue];
    result(nil);
}



- (void)setStartTime:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *dic = arr[3];
    NSNumber *time = dic[@"time"];
    NSNumber *seekMode = dic[@"seekMode"];
    [proxy.player setStartTime:time.integerValue seekMode:seekMode.integerValue];
    result(nil);
}

- (void)setOption:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *dic = arr[3];
    NSNumber *opt1 = dic[@"opt1"];
    NSObject *opt2 = dic[@"opt2"];
    if ([opt2 isKindOfClass:[NSNumber class]]) {
        NSNumber * optInt = ( NSNumber *)opt2;
        [proxy.player setOption:opt1.intValue valueInt:optInt.intValue];
    }else if ([opt2 isKindOfClass:[NSString class]]) {
        NSString * optVal = ( NSString *)opt2;
        [proxy.player setOption:opt1.intValue value:optVal];
    }
    result(nil);
}

- (void)setMaxAccurateSeekDelta:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *val = arr[3];
    [proxy.player setMaxAccurateSeekDelta:val.intValue];
    result(nil);
}

- (void)setUseHttp2:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSNumber *val = [call arguments];
    [AliPlayerGlobalSettings setUseHttp2:val.boolValue];
    result(nil);
}

- (void)enableHttpDns:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSNumber *val = [call arguments];
    [AliPlayerGlobalSettings enableHttpDns:val.boolValue];
    result(nil);
}

- (void)setDNSResolve:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSDictionary *val = [call arguments];
    NSString *host = val[@"host"];
    NSString *ip = val[@"ip"];
    [AliPlayerGlobalSettings setDNSResolve:host ip:ip];
    result(nil);
}

- (void)setIpResolveType:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSNumber *val = [call arguments];
    [AliPlayerGlobalSettings setIpResolveType:(AVPIpResolveType) val.unsignedIntegerValue];
    result(nil);
}

- (void)enableNetworkBalance:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSNumber *val = [call arguments];
    [AliPlayerGlobalSettings enableNetworkBalance:val.boolValue];
    result(nil);
}

- (void)getOption:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *val = arr[3];
    [proxy.player getOption:(AVPOption)
    [val unsignedIntValue]];
    result(nil);
}

- (void)invokeComponent:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSString *val = arr[3];
    int invoke = [proxy.player invokeComponent:val];
    result(@(invoke));
}

- (void)setFairPlayCertIDForIOS:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSString *val = [call arguments];
    [AliPlayerGlobalSettings setFairPlayCertID:val];
    result(nil);
}

- (void)enableHWAduioTempo:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSNumber *val = [call arguments];
    [AliPlayerGlobalSettings enableHWAduioTempo:val.boolValue];
    result(nil);
}

- (void)forceAudioRendingFormat:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSDictionary *val = [call arguments];

    [AliPlayerGlobalSettings forceAudioRendingFormat:[val[@"force"] boolValue] fmt:val[@"fmt"] channels:[val[@"channels"] intValue] sample_rate:[val[@"sample_rate"] intValue]];
    result(nil);
}

- (void)enableLocalCache:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSDictionary *val = [call arguments];

    BOOL enableLocalCache = [val[@"enable"] boolValue];
    NSString *localCacheDir = val[@"localCacheDir"];
    NSInteger docType = [val[@"docTypeForIOS"] integerValue];

    NSString *docDir = nil;
    switch (docType) {
        case 0:
            docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,
                                                          YES) firstObject];
            break;
        case 1:
            docDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask,
                                                          YES) firstObject];
            break;
        case 2:
            docDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask,
                                                          YES) firstObject];
            break;
        default:
            docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,
                                                          YES) firstObject];
            break;
    }
    if (localCacheDir.length > 0) {
        docDir = [docDir stringByAppendingPathComponent:localCacheDir];
    } else {
        docDir = [docDir stringByAppendingPathComponent:@"localCache"];
    }

    [AliPlayerGlobalSettings enableLocalCache:enableLocalCache maxBufferMemoryKB:[val[@"maxBufferMemoryKB"] intValue] localCacheDir:docDir];

    // if (enableLocalCache) {
    //     [AliPlayerGlobalSettings setCacheUrlHashCallback:hashCallback];
    // }

    result(nil);
}

- (void)setCacheFileClearConfig:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSDictionary *val = [call arguments];

    [AliPlayerGlobalSettings setCacheFileClearConfig:[val[@"expireMin"] longLongValue] maxCapacityMB:[val[@"maxCapacityMB"] longLongValue] freeStorageMB:[val[@"freeStorageMB"] longLongValue]];
    result(nil);
}

- (void)setCacheUrlHashCallback:(NSArray*)arr {
    FlutterResult result = arr[1];

    [AliPlayerGlobalSettings setCacheUrlHashCallback:hashCallback];
    result(nil);
}

NSString *hashCallback(NSString* url) {
    NSArray *array = [[url stringByReplacingOccurrencesOfString:@"https" withString:@"http"] componentsSeparatedByString:@"?"];
    NSString *md5Str = array.firstObject;
    return [AliPlayerFactory md5:md5Str];
}

+ (NSString *)md5:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

- (void)clearCaches:(NSArray *)arr {
    FlutterResult result = arr[1];

    [AliPlayerGlobalSettings clearCaches];
    result(nil);
}

- (void)setPlayConfig:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *val = arr[3];
    AVPConfig *config = [proxy.player getConfig];
    
    [AVPConfig mj_setupReplacedKeyFromPropertyName:^NSDictionary * {
        int maxAllowedAbrVideoPixelNumber = INT_MAX;
        return @{
                @"httpProxy": @"mHttpProxy",
                @"referer": @"mReferrer",
                @"maxAllowedAbrVideoPixelNumber": @"mMaxAllowedAbrVideoPixelNumber",
                @"networkTimeout": @"mNetworkTimeout",
                @"highBufferDuration": @"mHighBufferDuration",
                @"maxDelayTime": @"mMaxDelayTime",
                @"maxBufferDuration": @"mMaxBufferDuration",
                @"startBufferDuration": @"mStartBufferDuration",
                @"maxProbeSize": @"mMaxProbeSize",
                @"clearShowWhenStop": @"mClearFrameWhenStop",
                @"enableVideoTunnelRender": @"mEnableVideoTunnelRender",
                @"enableSEI": @"mEnableSEI",
                @"userAgent": @"mUserAgent",
                @"networkRetryCount": @"mNetworkRetryCount",
                @"liveStartIndex": @"mLiveStartIndex",
                @"customHeaders": @"mCustomHeaders",
                @"disableAudio": @"mDisableAudio",
                @"disableVideo": @"mDisableVideo",
        };
    }];
    config = [AVPConfig mj_objectWithKeyValues:val];
    [proxy.player setConfig:config];
    result(nil);
}

//TODO 应该是根据已经有的key 替换比较合理
- (void)setConfig:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *val = arr[3];
    AVPConfig *config = [proxy.player getConfig];

    [AVPConfig mj_setupReplacedKeyFromPropertyName:^NSDictionary * {
        return @{
                @"httpProxy": @"mHttpProxy",
                @"referer": @"mReferrer",
                @"networkTimeout": @"mNetworkTimeout",
                @"highBufferDuration": @"mHighBufferDuration",
                @"maxDelayTime": @"mMaxDelayTime",
                @"maxBufferDuration": @"mMaxBufferDuration",
                @"startBufferDuration": @"mStartBufferDuration",
                @"maxProbeSize": @"mMaxProbeSize",
                @"clearShowWhenStop": @"mClearFrameWhenStop",
                @"enableVideoTunnelRender": @"mEnableVideoTunnelRender",
                @"enableSEI": @"mEnableSEI",
                @"userAgent": @"mUserAgent",
                @"networkRetryCount": @"mNetworkRetryCount",
                @"liveStartIndex": @"mLiveStartIndex",
                @"customHeaders": @"mCustomHeaders",
                @"disableAudio": @"mDisableAudio",
                @"disableVideo": @"mDisableVideo",
        };
    }];

    config = [AVPConfig mj_objectWithKeyValues:val];

    [proxy.player setConfig:config];
    result(nil);
}

- (void)enableDowngrade:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *val = arr[3];
    NSString *source = val[@"source"];
    NSDictionary *config = val[@"config"];

    AVPUrlSource *urlSource = [[AVPUrlSource alloc] urlWithString:source];

    AVPConfig *playConfig = [proxy.player getConfig];
    playConfig = [AVPConfig mj_objectWithKeyValues:config];

    [proxy.player enableDowngrade:urlSource config:playConfig];
    result(nil);
}

//- (void)getCacheConfig:(NSArray*)arr {
//    FlutterResult result = arr[1];
//    AliPlayer *player = arr[2];
//    [AVPCacheConfig mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
//        return @{
//                 @"enable" : @"mEnable",
//                 @"path" :@"mDir",
//                 @"maxSizeMB" :@"mMaxSizeMB",
//                 @"maxDuration" :@"mMaxDurationS",
//                 };
//    }];
//    result(config.mj_keyValues);
//}

- (void)setCacheConfig:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *val = arr[3];

    [AVPCacheConfig mj_setupReplacedKeyFromPropertyName:^NSDictionary * {
        return @{
                @"enable": @"mEnable",
                @"path": @"mDir",
                @"maxSizeMB": @"mMaxSizeMB",
                @"maxDuration": @"mMaxDurationS",
        };
    }];
    AVPCacheConfig *config = [AVPCacheConfig mj_objectWithKeyValues:val];
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,
                                                         YES).firstObject;
    [config setPath:[path stringByAppendingPathComponent:config.path]];

    [proxy.player setCacheConfig:config];
    result(nil);
}

- (void)setFilterConfig:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSArray < NSDictionary * > *val = [arr[3] mj_JSONObject];

    AVPFilterConfig *filterConfig = [[AVPFilterConfig alloc] init];

    for (int i = 0; i < val.count; i++) {
        NSDictionary *filterDic = val[i];
        NSString *target = filterDic[@"target"];
        NSArray *filterOptions = filterDic[@"options"];
        if ([filterOptions isKindOfClass:[NSNull class]]) {
            filterOptions = @[];
        }

        AVPFilter *filter = [[AVPFilter alloc] initWithTarget:target];

        if (filterOptions && filterOptions.count > 0) {
            AVPFilterOptions *options = [[AVPFilterOptions alloc] init];
            NSString *options_key = filterOptions.firstObject;
            if ([target isEqualToString:@"sharp"]) {
                [options setOptions:options_key value:@0.0];
            }
            [filter setOptions:options];
        }

        [filterConfig addFilter:filter];
    }

    [proxy.player setFilterConfig:filterConfig];
    result(nil);
}

- (void)updateFilterConfig:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *configDic = arr[3];
    NSDictionary *filterOptionsDic = configDic[@"options"];

    AVPFilterOptions *options = [[AVPFilterOptions alloc] init];
    [options setOptions:filterOptionsDic[@"key"] value:filterOptionsDic[@"value"]];

    [proxy.player updateFilterConfig:configDic[@"target"] options:options];
    result(nil);
}

- (void)setFilterInvalid:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *dic = arr[3];

    [proxy.player setFilterInvalid:dic[@"target"] invalid:[dic[@"invalid"] boolValue]];
    result(nil);
}

- (void)getCacheFilePath:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSString *val = arr[3];

    NSString *filePath = [proxy.player getCacheFilePath:val];
    result(filePath);
}

- (void)getCacheFilePathWithVid:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *dic = arr[3];

    NSString *filePath = [proxy.player getCacheFilePath:dic[@"vid"] format:dic[@"format"] definition:dic[@"definition"]];
    result(filePath);
}

- (void)getCacheFilePathWithVidAtPreviewTime:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *dic = arr[3];

    NSString *filePath = [proxy.player getCacheFilePath:dic[@"vid"] format:dic[@"format"] definition:dic[@"definition"] previewTime:[dic[@"previewTime"] intValue]];
    result(filePath);
}

- (void)getConfig:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    AVPConfig *config = [proxy.player getConfig];

    [AVPConfig mj_setupReplacedKeyFromPropertyName:^NSDictionary * {
        return @{
                @"httpProxy": @"mHttpProxy",
                @"referer": @"mReferrer",
                @"networkTimeout": @"mNetworkTimeout",
                @"highBufferDuration": @"mHighBufferDuration",
                @"maxDelayTime": @"mMaxDelayTime",
                @"maxBufferDuration": @"mMaxBufferDuration",
                @"startBufferDuration": @"mStartBufferDuration",
                @"maxProbeSize": @"mMaxProbeSize",
                @"clearShowWhenStop": @"mClearFrameWhenStop",
                @"enableVideoTunnelRender": @"mEnableVideoTunnelRender",
                @"enableSEI": @"mEnableSEI",
                @"userAgent": @"mUserAgent",
                @"networkRetryCount": @"mNetworkRetryCount",
                @"liveStartIndex": @"mLiveStartIndex",
                @"customHeaders": @"mCustomHeaders",
        };
    }];
    result(config.mj_keyValues);
}

- (void)getPlayConfig:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    AVPConfig *config = [proxy.player getConfig];
    result(config.mj_keyValues);
}

- (void)setSource:(AVPSource *)source withDefinitions:(NSDictionary *)dic {
    NSArray *definitionList = [dic objectForKey:@"definitionList"];
    if (definitionList && [definitionList isKindOfClass:NSArray.class] &&
        definitionList.count > 0) {
        NSMutableString *mutStr = @"".mutableCopy;
        for (NSString *str in definitionList) {
            [mutStr appendString:str];
            [mutStr appendString:@","];
        }
        [mutStr deleteCharactersInRange:NSMakeRange(mutStr.length - 1, 1)];
        [source setDefinitions:mutStr];
    }
}

- (void)setVidSts:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *dic = arr[3];
    AVPVidStsSource *source = [AVPVidStsSource mj_objectWithKeyValues:dic];

    NSString *playConfig = [dic getStrByKey:@"playConfig"];
    if (playConfig && playConfig.length > 0) {
        source.playConfig = playConfig;
    }

    [self setSource:source withDefinitions:dic];
    [proxy.player setStsSource:source];
    result(nil);
}

- (void)setVidAuth:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *dic = arr[3];
    AVPVidAuthSource *source = [AVPVidAuthSource mj_objectWithKeyValues:dic];

    NSString *playConfig = [dic getStrByKey:@"playConfig"];
    if (playConfig && playConfig.length > 0) {
        source.playConfig = playConfig;
    }

    [self setSource:source withDefinitions:dic];
    [proxy.player setAuthSource:source];
    result(nil);
}

- (void)setVidMps:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    AVPVidMpsSource *source = [[AVPVidMpsSource alloc] init];
    NSDictionary *dic = [arr[3] removeNull];
    [source setVid:dic[@"vid"]];
    [source setAccId:dic[@"accessKeyId"]];
    [source setRegion:dic[@"region"]];
    [source setStsToken:dic[@"securityToken"]];
    [source setAccSecret:dic[@"accessKeySecret"]];
    [source setPlayDomain:dic[@"playDomain"]];
    [source setAuthInfo:dic[@"authInfo"]];
    [source setMtsHlsUriToken:dic[@"hlsUriToken"]];
    [self setSource:source withDefinitions:dic];
    [proxy.player setMpsSource:source];
    result(nil);
}

- (void)setLiveSts:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *dic = arr[3];
    AVPLiveStsSource *source = [AVPLiveStsSource mj_objectWithKeyValues:dic];
    [self setSource:source withDefinitions:dic];

    [proxy.player setLiveStsSource:source];
    result(nil);
}

- (void)updateLiveStsInfo:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *dic = arr[3];

    [proxy.player updateLiveStsInfo:dic[@"accId"] accKey:dic[@"accKey"] token:dic[@"token"] region:dic[@"region"]];
    result(nil);
}

- (void)addVidSource:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *dic = arr[3];
    [(AliListPlayer *) proxy.player addVidSource:dic[@"vid"] uid:dic[@"uid"]];
    result(nil);
}

- (void)addUrlSource:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *dic = arr[3];
    [(AliListPlayer *) proxy.player addUrlSource:dic[@"url"] uid:dic[@"uid"]];
    result(nil);
}

- (void)moveTo:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *dic = [arr[3] removeNull];

    NSString *aacId = [dic getStrByKey:@"accId"];
    if (aacId.length > 0) {
        [(AliListPlayer *) proxy.player moveTo:dic[@"uid"] accId:dic[@"accId"] accKey:dic[@"accKey"] token:dic[@"token"] region:dic[@"region"]];
    } else {
        [(AliListPlayer *) proxy.player moveTo:dic[@"uid"]];
    }
    result(nil);
}

- (void)moveToPre:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *dic = arr[3];
    if (dic && dic.count > 0) {
        dic = [arr[3] removeNull];
        [(AliListPlayer *) proxy.player moveToPre:dic[@"accId"] accKey:dic[@"accKey"] token:dic[@"token"] region:dic[@"region"]];
    } else {
        [(AliListPlayer *) proxy.player moveToPre];
    }
    result(nil);
}

- (void)moveToNext:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *dic = arr[3];
    if (dic && dic.count > 0) {
        dic = [arr[3] removeNull];
        [(AliListPlayer *) proxy.player moveToNext:dic[@"accId"] accKey:dic[@"accKey"] token:dic[@"token"] region:dic[@"region"]];
    } else {
        [(AliListPlayer *) proxy.player moveToNext];
    }
    result(nil);
}

- (void)setDefinition:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSString *definition = arr[3];
    [(AliListPlayer *) proxy.player setStsPreloadDefinition:definition];
    result(nil);
}

- (void)removeSource:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSString *uid = arr[3];

    [(AliListPlayer *) proxy.player removeSource:uid];
    result(nil);
}

- (void)getCurrentUid:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSString *currentUid = [(AliListPlayer *) proxy.player currentUid];
    result(currentUid);
}

- (void)clear:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    [(AliListPlayer *) proxy.player clear];
    result(nil);
}

- (void)setMaxPreloadMemorySizeMB:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *val = arr[3];
    [(AliListPlayer *) proxy.player setMaxPreloadMemorySizeMB:val.intValue];
    result(nil);
}

- (void)setPreloadCount:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *val = arr[3];
    [(AliListPlayer *) proxy.player setPreloadCount:val.intValue];
    result(nil);
}

- (void)getMediaInfo:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    AVPMediaInfo *info = [proxy.player getMediaInfo];

    //TODO 后面需要统一键值转换规则
    [AVPMediaInfo mj_setupReplacedKeyFromPropertyName:^NSDictionary * {
        return @{
                @"mTitle": @"title",
                @"mCoverUrl": @"coverURL",
                @"mTrackInfos": @"tracks",
        };
    }];

    [AVPTrackInfo mj_setupReplacedKeyFromPropertyName:^NSDictionary * {
        return @{
                @"vodDefinition": @"trackDefinition",
                @"index": @"trackIndex",
        };
    }];

    [AVPThumbnailInfo mj_setupReplacedKeyFromPropertyName:^NSDictionary * {
        return @{
                @"URL": @"url",
        };
    }];
//    NSLog(@"getMediaInfo==%@",info.mj_JSONString);
    result(info.mj_keyValues);
}

- (void)getSubMediaInfo:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    AVPMediaInfo *info = [proxy.player getSubMediaInfo];

    //TODO 后面需要统一键值转换规则
    [AVPMediaInfo mj_setupReplacedKeyFromPropertyName:^NSDictionary * {
        return @{
                @"mTitle": @"title",
                @"mCoverUrl": @"coverURL",
                @"mTrackInfos": @"tracks",
        };
    }];

    [AVPTrackInfo mj_setupReplacedKeyFromPropertyName:^NSDictionary * {
        return @{
                @"vodDefinition": @"trackDefinition",
                @"index": @"trackIndex",
        };
    }];

    [AVPThumbnailInfo mj_setupReplacedKeyFromPropertyName:^NSDictionary * {
        return @{
                @"URL": @"url",
        };
    }];
//    NSLog(@"getSubMediaInfo==%@",info.mj_JSONString);
    result(info.mj_keyValues);
}

- (void)getCurrentTrack:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *idxNum = arr[3];
    AVPTrackInfo *info = [proxy.player getCurrentTrack:idxNum.intValue];
//    NSLog(@"getCurrentTrack==%@",info.mj_JSONString);
    result(info.mj_keyValues);
}

- (void)selectTrack:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *dic = [arr[3] removeNull];
    NSNumber *trackIdxNum = dic[@"trackIdx"];
    NSNumber *accurateNum = dic[@"accurate"];
    if (accurateNum.intValue == -1) {
        [proxy.player selectTrack:trackIdxNum.intValue];
    } else {
        [proxy.player selectTrack:trackIdxNum.intValue accurate:accurateNum.boolValue];
    }
    result(nil);
}

- (void)addExtSubtitle:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSString *url = arr[3];
    [proxy.player addExtSubtitle:url];
    result(nil);
}

- (void)selectExtSubtitle:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *dic = [arr[3] removeNull];
    NSNumber *trackIdxNum = dic[@"trackIndex"];
    NSNumber *enableNum = dic[@"enable"];
    [proxy.player selectExtSubtitle:trackIdxNum.intValue enable:enableNum.boolValue];
    result(nil);
}

- (void)setStreamDelayTime:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSDictionary *dic = [arr[3] removeNull];
    NSNumber *trackIdxNum = dic[@"index"];
    NSNumber *timeNum = dic[@"time"];
    [proxy.player setStreamDelayTime:trackIdxNum.intValue time:timeNum.intValue];
    result(nil);
}

- (void)reload:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    [proxy.player reload];
    result(nil);
}

- (void)getPropertyString:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *val = arr[3];

    NSString * propertyString = [proxy.player getPropertyString:(AVPPropertyKey)
    [val unsignedIntValue]];
    result(propertyString);
}

- (void)setDefaultBandWidth:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *val = arr[3];

    [proxy.player setDefaultBandWidth:[val intValue]];
    result(nil);
}

- (void)getPlayerName:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    result([proxy.player getPlayerName]);
}

- (void)sendCustomEvent:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSString *val = arr[3];

    [proxy.player sendCustomEvent:val];
    result(nil);
}

- (void)setUserData:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSString *val = arr[3];

    [proxy.player setUserData:val];
    result(nil);
}

- (void)getUserData:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];

    NSString *userData = [proxy.player getUserData];
    result(userData);
}

- (void)netWorkReConnect:(NSArray *)arr {
    FlutterResult result = arr[1];

    [AliPlayer netWorkReConnect];
    result(nil);
}

//直播时移相关

- (void)getCurrentLiveTime:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    AVPLiveTimeShift *player = (AVPLiveTimeShift *) proxy.player;
    result(@(((int) player.liveTime)));
}

- (void)getCurrentTime:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    AVPLiveTimeShift *player = (AVPLiveTimeShift *) proxy.player;
    result(@(((int) player.currentPlayTime)));
}

- (void)seekToLiveTime:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    NSNumber *liveTime = arr[3];
    AVPLiveTimeShift *player = (AVPLiveTimeShift *) proxy.player;
    [player seekToLiveTime:liveTime.integerValue];
    result(nil);
}

- (void)setDataSource:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    AVPLiveTimeShift *player = (AVPLiveTimeShift *) proxy.player;
    NSDictionary *dic = [arr[3] removeNull];
    NSString *timeLineUrl = dic[@"timeLineUrl"];
    NSString *url = dic[@"url"];
    [player prepareWithLiveTimeUrl:url];
    [player setLiveTimeShiftUrl:timeLineUrl];
    result(nil);
}

- (void)createVidPlayerConfigGenerator:(NSArray *)arr {
    FlutterResult result = arr[1];
    self.vidPlayerConfigGenerator = [[VidPlayerConfigGenerator alloc] init];
    result(nil);
}

- (void)setPreviewTime:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    int val = [[call arguments] intValue];
    if (self.vidPlayerConfigGenerator) {
        [self.vidPlayerConfigGenerator setPreviewTime:val];
    }
    result(nil);
}

- (void)setHlsUriToken:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSString *val = [call arguments];
    if (self.vidPlayerConfigGenerator) {
        [self.vidPlayerConfigGenerator setHlsUriToken:val];
    }
    result(nil);
}

- (void)addVidPlayerConfigByStringValue:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSDictionary *val = [call arguments];

    if (self.vidPlayerConfigGenerator) {
        for (NSString *key in val.allKeys) {
            [self.vidPlayerConfigGenerator addVidPlayerConfigByStringValue:key value:val[key]];
        }
    }
    result(nil);
}

- (void)addVidPlayerConfigByIntValue:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSDictionary *val = [call arguments];

    if (self.vidPlayerConfigGenerator) {
        for (NSString *key in val.allKeys) {
            int keyValue = [val[key] intValue];
            [self.vidPlayerConfigGenerator addVidPlayerConfigByIntValue:key value:keyValue];
        }
    }
    result(nil);
}

- (void)setEncryptType:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSNumber *val = [call arguments];
    if (self.vidPlayerConfigGenerator) {
        switch (val.intValue) {
            case 0:
                [self.vidPlayerConfigGenerator addVidPlayerConfigByStringValue:@"EncryptType" value:@"Unencrypted"];
                break;
            case 1:
                [self.vidPlayerConfigGenerator addVidPlayerConfigByStringValue:@"EncryptType" value:@"AliyunVoDEncryption"];
                break;
            case 2:
                [self.vidPlayerConfigGenerator addVidPlayerConfigByStringValue:@"EncryptType" value:@"HLSEncryption"];
                break;
        }
    }
    result(nil);
}

- (void)generatePlayerConfig:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSString *callback = @"";
    if (self.vidPlayerConfigGenerator) {
        callback = [self.vidPlayerConfigGenerator generatePlayerConfig];
    }
    if (callback == nil) {
        result(@"");
    }
    result(callback);
}

- (void)setEventReportParamsDelegate:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    [proxy.player setEventReportParamsDelegate:proxy];
    result(nil);
}

- (void)setPictureInPictureEnableForIOS:(NSArray *)arr {
    FlutterResult result = arr[1];
    AliPlayerProxy *proxy = arr[2];
    BOOL enable = [arr[3] boolValue];
    [proxy.player setPictureInPictureEnable:enable];
    result(nil);
}

#pragma --mark CicadaAudioSessionDelegate

- (BOOL)setActive:(BOOL)active error:(NSError **)outError {
    if (self.audioSessionType == AliPlayerAudioSesstionTypeNone) {
        return YES;
    } else {
        return [[AVAudioSession sharedInstance] setActive:active error:outError];
    }
}

- (BOOL)setCategory:(NSString *)category withOptions:(AVAudioSessionCategoryOptions)options error:(NSError **)outError {
    if (self.audioSessionType == AliPlayerAudioSesstionTypeSDKDefault) {
        return [[AVAudioSession sharedInstance] setCategory:category withOptions:options error:outError];
    } else if (self.audioSessionType == AliPlayerAudioSesstionTypeMix) {
        options =
                AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDuckOthers;
        return [[AVAudioSession sharedInstance] setCategory:category withOptions:options error:outError];
    } else {
        return YES;
    }
}

- (BOOL)setCategory:(AVAudioSessionCategory)category mode:(AVAudioSessionMode)mode routeSharingPolicy:(AVAudioSessionRouteSharingPolicy)policy options:(AVAudioSessionCategoryOptions)options error:(NSError **)outError {
    if (self.audioSessionType == AliPlayerAudioSesstionTypeSDKDefault) {
        if (@available
        (iOS
        11.0, tvOS
        11.0, *)) {
            return [[AVAudioSession sharedInstance] setCategory:category mode:mode routeSharingPolicy:policy options:options error:outError];
        }
        return NO;
    } else {
        return YES;
    }
}

@end

