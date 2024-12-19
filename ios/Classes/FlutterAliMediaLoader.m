#import "FlutterAliMediaLoader.h"

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
#import "NSDictionary+ext.h"

#define kAliPlayerMethod    @"method"

@interface FlutterAliMediaLoader ()<FlutterStreamHandler, AliMediaLoaderStatusDelegate>

@property (nonatomic, copy) FlutterEventSink eventSink;
@property (nonatomic, strong) AliMediaLoader *mediaLoader;

@end

@implementation FlutterAliMediaLoader

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"plugins.flutter_aliplayer_media_loader"
                                     binaryMessenger:[registrar messenger]];
    FlutterAliMediaLoader* instance = [[FlutterAliMediaLoader alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"flutter_aliplayer_media_loader_event" binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* method = [call method];
    SEL methodSel=NSSelectorFromString([NSString stringWithFormat:@"%@:",method]);
    NSArray *arr = @[call,result];
    if([self respondsToSelector:methodSel]){
        IMP imp = [self methodForSelector:methodSel];
        CGRect (*func)(id, SEL, NSArray*) = (void *)imp;
        func(self, methodSel, arr);
    }else{
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - FlutterStreamHandler
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)eventSink{
    self.eventSink = eventSink;
    return nil;
}
 
- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    return nil;
}

- (void)load:(NSArray*)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
    
    NSDictionary *dic = [call.arguments removeNull];
    [self.mediaLoader load:dic[@"url"] duration:[dic[@"duration"] longLongValue]];
    result(nil);
}

- (void)resume:(NSArray*)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
    
    [self.mediaLoader resume:call.arguments];
    result(nil);
}

- (void)pause:(NSArray*)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
    
    [self.mediaLoader pause:call.arguments];
    result(nil);
}

- (void)cancel:(NSArray*)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
    
    [self.mediaLoader cancel:call.arguments];
    result(nil);
}

#pragma mark -- AliMediaLoaderStatusDelegate
- (void)onError:(NSString *)url code:(int64_t)code msg:(NSString *)msg {
    self.eventSink(@{kAliPlayerMethod:@"onError",@"url":url,@"code":[NSString stringWithFormat:@"%lld", code],@"msg":msg});
}

- (void)onCompleted:(NSString *)url {
    self.eventSink(@{kAliPlayerMethod:@"onCompleted",@"url":url});
}

- (void)onCanceled:(NSString *)url {
    self.eventSink(@{kAliPlayerMethod:@"onCancel",@"url":url});
}

#pragma mark -- lazy load
- (AliMediaLoader *)mediaLoader {
    if (!_mediaLoader) {
        _mediaLoader = [AliMediaLoader shareInstance];
        [_mediaLoader setAliMediaLoaderStatusDelegate:self];
    }
    return _mediaLoader;
}

@end
