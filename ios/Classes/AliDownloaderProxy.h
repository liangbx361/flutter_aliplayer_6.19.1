//
//  AliDownloaderProxy.h
//  flutter_aliplayer
//
//  Created by aliyun on 2020/11/29.
//

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

#if __has_include(<AliyunMediaDownloader/AliyunMediaDownloader.h>)
#import <AliyunMediaDownloader/AliyunMediaDownloader.h>
#endif

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface AliDownloaderProxy : NSObject<AMDDelegate>

@property(nonatomic,strong) FlutterResult result;
@property (nonatomic, copy) FlutterEventSink eventSink;
@property(nonatomic,strong) NSMutableDictionary *argMap;

@property(nonatomic,strong) NSString *mVideoId;
@property(nonatomic,copy) NSString *saveKeyPath;

@end

NS_ASSUME_NONNULL_END
