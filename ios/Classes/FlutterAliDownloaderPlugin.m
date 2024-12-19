//
//  FlutterAliDownloaderPlugin.m
//  flutter_aliplayer
//
//  Created by aliyun on 2020/11/29.
//

#import "FlutterAliDownloaderPlugin.h"
#import "NSDictionary+ext.h"

#if __has_include(<AliVCSDK_Standard/AliVCSDK_Standard.h>)
#import <AliVCSDK_Standard/AliVCSDK_Standard.h>

#elif __has_include(<AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>)
#import <AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>

#elif __has_include(<AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>)
#import <AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>

#elif __has_include(<AliVCSDK_UGC/AliVCSDK_UGC.h>)
#import <AliVCSDK_UGC/AliVCSDK_UGC.h>

#endif

#if __has_include(<AliyunMediaDownloader/AliyunMediaDownloader.h>)
#import <AliyunMediaDownloader/AliyunMediaDownloader.h>
#endif
#import "AliDownloaderProxy.h"

@interface FlutterAliDownloaderPlugin ()<FlutterStreamHandler>{
    NSString *mSavePath;
    NSString *mSaveKeyPath;
}

@property(strong,nonatomic) NSMutableDictionary * mAliMediaDownloadMap;
@property(strong,nonatomic) NSMutableDictionary * mProxyMap;
@property (nonatomic, strong) FlutterEventSink eventSink;

@end

@implementation FlutterAliDownloaderPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"plugins.flutter_alidownload"
                                     binaryMessenger:[registrar messenger]];
    FlutterAliDownloaderPlugin* instance = [[FlutterAliDownloaderPlugin alloc] init];
    instance.mAliMediaDownloadMap = @{}.mutableCopy;
    instance.mProxyMap = @{}.mutableCopy;
    [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"plugins.flutter_alidownload_event" binaryMessenger:[registrar messenger]];
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

-(void)setSaveDir:(NSArray*)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
//    NSLog(@"savePath==%@",call.arguments);
    mSavePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    if (mSavePath) {
        mSaveKeyPath = call.arguments;
        mSavePath = [mSavePath stringByAppendingPathComponent:call.arguments];
    }
    result(nil);
}

- (void)getFullSaveDir:(NSArray*)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
    NSString *fullSaveDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    fullSaveDir = [fullSaveDir stringByAppendingPathComponent:call.arguments];
    result(fullSaveDir);
}

- (void)prepare:(NSArray*)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
    NSDictionary *dic = [call.arguments removeNull];
    NSNumber *idxNum = dic[@"index"];
    NSString *type = dic[@"type"];
    NSString *vid = dic[@"vid"];
    if(type.length>0){
        if([type isEqualToString:@"download_sts"]){
            AVPVidStsSource *source = [[AVPVidStsSource alloc] init];
            [source setVid:vid];
            [source setRegion:dic[@"region"]];
            [source setAccessKeyId:dic[@"accessKeyId"]];
            [source setAccessKeySecret:dic[@"accessKeySecret"]];
            [source setSecurityToken:dic[@"securityToken"]];
            if ([idxNum isKindOfClass:NSNumber.class]) {
                [self prepareVidSts:source result:result idx:idxNum.intValue];
            }else{
                [self prepareVidSts:source result:result idx:-1];
            }
        }else if([type isEqualToString:@"download_auth"]){
            AVPVidAuthSource *source = [[AVPVidAuthSource alloc] init];
            [source setVid:vid];
            [source setRegion:dic[@"region"]];
            [source setPlayAuth:dic[@"playAuth"]];
            if ([idxNum isKindOfClass:NSNumber.class]) {
                [self prepareVidAuth:source result:result idx:idxNum.intValue];
            }else{
                [self prepareVidAuth:source result:result idx:-1];
            }
        }
    }
    // result(nil);
}

- (void)updateSource:(NSArray*)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
    NSDictionary *dic = [call.arguments removeNull];
    NSNumber *idxNum = dic[@"index"];
    NSString *type = dic[@"type"];
    NSString *vid = dic[@"vid"];
    if(type.length>0){
        if([type isEqualToString:@"download_sts"]){
            AVPVidStsSource *source = [[AVPVidStsSource alloc] init];
            [source setVid:vid];
            [source setRegion:dic[@"region"]];
            [source setAccessKeyId:dic[@"accessKeyId"]];
            [source setAccessKeySecret:dic[@"accessKeySecret"]];
            [source setSecurityToken:dic[@"securityToken"]];
            AliMediaDownloader *downloader = [self.mAliMediaDownloadMap objectForKey:[NSString stringWithFormat:@"%@_%@",vid,idxNum]];
            if (downloader) {
                [downloader updateWithVid:source];
            }
        }else if([type isEqualToString:@"download_auth"]){
            AVPVidAuthSource *source = [[AVPVidAuthSource alloc] init];
            [source setVid:vid];
            [source setRegion:dic[@"region"]];
            [source setPlayAuth:dic[@"playAuth"]];
            AliMediaDownloader *downloader = [self.mAliMediaDownloadMap objectForKey:[NSString stringWithFormat:@"%@_%@",vid,idxNum]];
            if (downloader) {
                [downloader updateWithPlayAuth:source];
            }
        }
    }
    result(nil);
}

- (void)prepareVidSts:(AVPVidStsSource*)vidSts result:(FlutterResult)result idx:(int)idx{
    AliMediaDownloader *downloader = [self.mAliMediaDownloadMap objectForKey:vidSts.vid];
    if(!downloader){
        downloader = [[AliMediaDownloader alloc] init];
        [self.mAliMediaDownloadMap setObject:downloader forKey:vidSts.vid];
    }
    
    //TODO 后续移走
    if (idx>=0) {
        downloader = [[AliMediaDownloader alloc] init];
        [downloader selectTrack:idx];
        [self.mAliMediaDownloadMap setObject:downloader forKey:[NSString stringWithFormat:@"%@_%i",vidSts.vid,idx]];
    }
    
    AliDownloaderProxy *proxy = [self.mProxyMap objectForKey:vidSts.vid];
    if (!proxy) {
        proxy = [[AliDownloaderProxy alloc] init];
        [self.mProxyMap setObject:proxy forKey:vidSts.vid];
    }
    
    //TODO 后续移走
    if (idx>=0) {
        proxy = [[AliDownloaderProxy alloc] init];
        [self.mProxyMap setObject:proxy forKey:[NSString stringWithFormat:@"%@_%i",vidSts.vid,idx]];
    }
    
    [proxy setMVideoId:vidSts.vid];
    [proxy setResult:result];
    [downloader setDelegate:proxy];
    [downloader prepareWithVid:vidSts];
}

- (void)prepareVidAuth:(AVPVidAuthSource*)vidAuth result:(FlutterResult)result idx:(int)idx{
    AliMediaDownloader *downloader = [self.mAliMediaDownloadMap objectForKey:vidAuth.vid];
    if(!downloader){
        downloader = [[AliMediaDownloader alloc] init];
        [self.mAliMediaDownloadMap setObject:downloader forKey:vidAuth.vid];
    }
    
    //TODO 后续移走
    if (idx>=0) {
        downloader = [[AliMediaDownloader alloc] init];
        [downloader selectTrack:idx];
        [self.mAliMediaDownloadMap setObject:downloader forKey:[NSString stringWithFormat:@"%@_%i",vidAuth.vid,idx]];
    }
    
    AliDownloaderProxy *proxy = [self.mProxyMap objectForKey:vidAuth.vid];
    if (!proxy) {
        proxy = [[AliDownloaderProxy alloc] init];
        [self.mProxyMap setObject:proxy forKey:vidAuth.vid];
    }
    
    //TODO 后续移走
    if (idx>=0) {
        proxy = [[AliDownloaderProxy alloc] init];
        [self.mProxyMap setObject:proxy forKey:[NSString stringWithFormat:@"%@_%i",vidAuth.vid,idx]];
    }
    
    [proxy setMVideoId:vidAuth.vid];
    [proxy setResult:result];
    [downloader setDelegate:proxy];
    [downloader prepareWithPlayAuth:vidAuth];
}


- (void)selectItem:(NSArray*)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
    NSDictionary *dic = [call.arguments removeNull];
    NSNumber *idxNum = dic[@"index"];
    NSString *vid = dic[@"vid"];
    AliMediaDownloader *downloader = [self.mAliMediaDownloadMap objectForKey:vid];
    if(downloader){
        [self.mAliMediaDownloadMap removeObjectForKey:vid];
        [self.mAliMediaDownloadMap setObject:downloader forKey:[NSString stringWithFormat:@"%@_%@",vid,idxNum]];
        
        AliDownloaderProxy *proxy = [self.mProxyMap objectForKey:vid];
        if (proxy) {
            [self.mProxyMap removeObjectForKey:vid];
            [self.mProxyMap setObject:proxy forKey:[NSString stringWithFormat:@"%@_%@",vid,idxNum]];
        }
        
        [downloader selectTrack:idxNum.intValue];
    }
    result(nil);
}

- (void)start:(NSArray*)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
    NSDictionary *dic = [call.arguments removeNull];
    NSString *vid = dic[@"vid"];
    NSString *index = dic[@"index"];
    AliMediaDownloader *downloader = [self.mAliMediaDownloadMap objectForKey:[NSString stringWithFormat:@"%@_%@",vid,index]];
    if (downloader) {
        [downloader setSaveDirectory:mSavePath];
        AliDownloaderProxy *proxy = [self.mProxyMap objectForKey:[NSString stringWithFormat:@"%@_%@",vid,index]];
        if (proxy) {
            proxy.eventSink = self.eventSink;
            proxy.argMap = dic.mutableCopy;
            proxy.saveKeyPath = mSaveKeyPath;
            [downloader setDelegate:proxy];
        }
        [downloader start];
    }
    result(nil);
}

- (void)stop:(NSArray*)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
    NSDictionary *dic = [call.arguments removeNull];
    NSString *vid = dic[@"vid"];
    NSString *index = dic[@"index"];
    AliMediaDownloader *downloader = [self.mAliMediaDownloadMap objectForKey:[NSString stringWithFormat:@"%@_%@",vid,index]];
    if (downloader) {
        [downloader stop];
    }
    result(nil);
}

- (void)delete:(NSArray*)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
    NSDictionary *dic = [call.arguments removeNull];
    NSString *vid = dic[@"vid"];
    NSString *index = dic[@"index"];
    AliMediaDownloader *downloader = [self.mAliMediaDownloadMap objectForKey:[NSString stringWithFormat:@"%@_%@",vid,index]];
    if (downloader) {
        [downloader deleteFile];
    }
    result(nil);
}

- (void)release:(NSArray*)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
    NSDictionary *dic = [call.arguments removeNull];
    NSString *vid = dic[@"vid"];
    NSString *index = dic[@"index"];
    AliMediaDownloader *downloader = [self.mAliMediaDownloadMap objectForKey:[NSString stringWithFormat:@"%@_%@",vid,index]];
    if (downloader) {
        [downloader destroy];
    }
    result(nil);
}

- (void)getFilePath:(NSArray*)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
    NSDictionary *dic = [call.arguments removeNull];
    NSString *vid = dic[@"vid"];
    NSString *index = dic[@"index"];
    AliMediaDownloader *downloader = [self.mAliMediaDownloadMap objectForKey:[NSString stringWithFormat:@"%@_%@",vid,index]];
    if (downloader) {
        NSMutableDictionary *argMap = dic.mutableCopy;
        [argMap setObject:downloader.downloadedFilePath forKey:@"savePath"];
        result(argMap);
    }
}

@end
