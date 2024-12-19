#import "FlutterAliPlayerGlobalSettings.h"
#import "NSDictionary+ext.h"
#import "AliyunPlayer/AlivcEnv.h"
#import "AliyunPlayer/AlivcBase.h"
#import "AliPlayerFactory.h"
@interface FlutterAliPlayerGlobalSettings ()<FlutterStreamHandler>{
    NSString *mSavePath;
    NSString *mSaveKeyPath;
}

@property(strong,nonatomic) NSMutableDictionary * mAliPlayerGlobalSettingsMap;
@property(strong,nonatomic) NSMutableDictionary * mProxyMap;
@property (nonatomic, strong) FlutterEventSink eventSink;
@property (nonatomic, strong) AlivcEnv *alivcEnv;

@end

@implementation FlutterAliPlayerGlobalSettings

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"plugins.flutter_global_setting"
                                     binaryMessenger:[registrar messenger]];
    FlutterAliPlayerGlobalSettings* instance = [[FlutterAliPlayerGlobalSettings alloc] init];
    instance.mAliPlayerGlobalSettingsMap = @{}.mutableCopy;
    instance.mProxyMap = @{}.mutableCopy;
    [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"plugins.flutter_global_setting_event" binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:instance];
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

- (void)setGlobalEnvironment:(NSArray *)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
    NSNumber *config = call.arguments;
    if(config.intValue == 1){
        AlivcBase.EnvironmentManager.globalEnvironment = AlivcGlobalEnv_CN;
    }else if (config.intValue == 2){
        AlivcBase.EnvironmentManager.globalEnvironment = AlivcGlobalEnv_SEA;
    }else{
        AlivcBase.EnvironmentManager.globalEnvironment = AlivcGlobalEnv_GLOBAL_DEFAULT;
    }
    result(nil);
}

- (void)setOption:(NSArray *)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
    NSDictionary *dic = call.arguments;
    NSNumber *opt1 = dic[@"opt1"];
    NSObject *opt2 = dic[@"opt2"];
    if ([opt2 isKindOfClass:[NSNumber class]]) {
        NSNumber * optInt = ( NSNumber *)opt2;
        [AliPlayerGlobalSettings setOption:opt1.intValue valueInt:optInt.intValue];
    }else if ([opt2 isKindOfClass:[NSString class]]) {
        NSString * optVal = ( NSString *)opt2;
        [AliPlayerGlobalSettings setOption:opt1.intValue value:optVal];
    }
    result(nil);
}

- (void)disableCrashUpload:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSNumber *val = [call arguments];
    [AliPlayerGlobalSettings disableCrashUpload:val.boolValue];
    result(nil);
}

- (void)enableEnhancedHttpDns:(NSArray *)arr {
    FlutterResult result = arr[1];
    FlutterMethodCall *call = arr.firstObject;
    NSNumber *val = [call arguments];
    [AliPlayerGlobalSettings enableEnhancedHttpDns:val.boolValue];
    result(nil);
}

@end
