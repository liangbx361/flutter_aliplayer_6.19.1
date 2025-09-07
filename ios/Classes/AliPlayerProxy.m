//
//  AliPlayerProxy.m
//  flutter_aliplayer
//
//  Created by aliyun on 2021/5/18.
//

#import "AliPlayerProxy.h"
#import "AliPlayerLogger.h"
#import <MJExtension/MJExtension.h>

@interface AliPlayerProxy ()
@property(nonatomic,strong) NSTimer *timer;

// 监听画中画当前是否是暂停状态
@property (nonatomic, assign) BOOL isPipPaused;
// 监听播放器当前的播放状态，通过监听播放事件状态变更newStatus回调设置
@property (nonatomic, assign) AVPStatus currentPlayerStatus;

// 监听播放器当前播放进度，currentPosition设置为监听视频当前播放位置回调中的position参数值
@property(nonatomic, assign) int64_t currentPosition;

// PIP状态监控
@property (nonatomic, strong) NSTimer *pipStateMonitor;
@property (nonatomic, assign) BOOL lastKnownPipActiveState;

// 🛡️ PIP 安全机制
@property (nonatomic, assign) NSTimeInterval lastInvalidateTime;
@property (nonatomic, strong) NSString *lastInvalidateContext;
@end

@implementation AliPlayerProxy

#pragma mark AVPDelegate

/**
 @brief 播放器状态改变回调
 @param player 播放器player指针
 @param oldStatus 老的播放器状态 参考AVPStatus
 @param newStatus 新的播放器状态 参考AVPStatus
 */
- (void)onPlayerStatusChanged:(AliPlayer*)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
    [AliPlayerLogger logDebug:@"🛡️ onPlayerStatusChanged - oldStatus:%d, newStatus:%d", (int)oldStatus, (int)newStatus];
    self.currentPlayerStatus = newStatus;
    
    // 🛡️ 安全地同步PIP状态 - 避免直接调用 invalidatePlaybackState
    if (self.pipController) {
        BOOL shouldBePaused = (newStatus != AVPStatusStarted);
        if (self.isPipPaused != shouldBePaused) {
            self.isPipPaused = shouldBePaused;
            [AliPlayerLogger logDebug:@"🛡️ 需要同步PIP状态 - isPipPaused:%d", self.isPipPaused];
            
            // 🚫 移除直接调用，改用安全的延迟调用
            [self safeInvalidatePlaybackStateWithDelay:0.1 context:@"statusChanged"];
        }
    }
    
    self.eventSink(@{kAliPlayerMethod:@"onStateChanged",@"newState":@(newStatus),kAliPlayerId:_playerId});
}

/**
 @brief 错误代理回调
 @param player 播放器player指针
 @param errorModel 播放器错误描述，参考AliVcPlayerErrorModel
 */
- (void)onError:(AliPlayer*)player errorModel:(AVPErrorModel *)errorModel {
    self.eventSink(@{kAliPlayerMethod:@"onError",@"errorCode":@(errorModel.code),@"errorMsg":errorModel.message,kAliPlayerId:_playerId});
}

- (void)onSEIData:(AliPlayer*)player type:(int)type data:(NSData *)data {
    NSString *str = [NSString stringWithUTF8String:data.bytes];
    [AliPlayerLogger logDebug:@"SEI: %@", str];
    self.eventSink(@{kAliPlayerMethod:@"onSeiData",@"data":str?:@"",@"type":@(type),kAliPlayerId:_playerId});
}

/**
 @brief 播放器事件回调
 @param player 播放器player指针
 @param eventType 播放器事件类型，@see AVPEventType
 */
-(void)onPlayerEvent:(AliPlayer*)player eventType:(AVPEventType)eventType {
    switch (eventType) {
        case AVPEventPrepareDone:
            [AliPlayerLogger logDebug:@"AVPEventPrepareDone - 视频准备完成"];
            self.eventSink(@{kAliPlayerMethod:@"onPrepared",kAliPlayerId:_playerId});
            
            // 🔧 视频准备完成后，重新确保PIP配置正确
            [self ensurePipConfigurationAfterPrepare];
            break;
        case AVPEventFirstRenderedStart:
            self.eventSink(@{kAliPlayerMethod:@"onRenderingStart",kAliPlayerId:_playerId});
            break;
        case AVPEventLoadingStart:
            self.eventSink(@{kAliPlayerMethod:@"onLoadingBegin",kAliPlayerId:_playerId});
            break;
        case AVPEventLoadingEnd:
            self.eventSink(@{kAliPlayerMethod:@"onLoadingEnd",kAliPlayerId:_playerId});
            break;
        case AVPEventCompletion:
            self.eventSink(@{kAliPlayerMethod:@"onCompletion",kAliPlayerId:_playerId});
            if (_pipController) {
                   self.isPipPaused = YES; // 播放结束后，将画中画状态变更为暂停
                   // 🛡️ 使用安全方法替代直接调用
                   [self safeInvalidatePlaybackStateWithDelay:0.1 context:@"completion"];
                }
            break;
        case AVPEventSeekEnd:
            self.eventSink(@{kAliPlayerMethod:@"onSeekComplete",kAliPlayerId:_playerId});
            break;
        default:
            break;
    }
}

/**
 @brief 播放器事件回调
 @param player 播放器player指针
 @param eventWithString 播放器事件类型
 @param description 播放器事件说明
 @see AVPEventType
 */
-(void)onPlayerEvent:(AliPlayer*)player eventWithString:(AVPEventWithString)eventWithString description:(NSString *)description {
    self.eventSink(@{kAliPlayerMethod:@"onInfo",@"infoCode":@(eventWithString),@"extraMsg":description,kAliPlayerId:_playerId});
}

/**
 @brief 视频大小变化回调
 @param player 播放器player指针
 @param width 视频宽度
 @param height 视频高度
 @param rotation 视频旋转角度
 */
- (void)onVideoSizeChanged:(AliPlayer*)player width:(int)width height:(int)height rotation:(int)rotation {
    self.eventSink(@{kAliPlayerMethod:@"onVideoSizeChanged",@"width":@(width),@"height":@(height),@"rotation":@(rotation),kAliPlayerId:_playerId});
}

/**
 @brief 播放器渲染信息回调
 @param timeMs 渲染时的系统时间
 @param pts 视频帧pts
 */
- (void) onVideoRendered:(AliPlayer *)player timeMs:(int64_t)timeMs pts:(int64_t)pts {
    self.eventSink(@{kAliPlayerMethod:@"onVideoRendered",@"timeMs":@(timeMs),@"pts":@(pts),kAliPlayerId:_playerId});
}

/**
 @brief 视频当前播放位置回调
 @param player 播放器player指针
 @param position 视频当前播放位置
 */
- (void)onCurrentPositionUpdate:(AliPlayer*)player position:(int64_t)position {
     self.eventSink(@{kAliPlayerMethod:@"onInfo",@"infoCode":@(2),@"extraValue":@(position),kAliPlayerId:_playerId});
}

/**
 @brief 视频当前播放内容对应的utc时间回调
 @param player 播放器player指针
 @param time utc时间
 */
- (void)onCurrentUtcTimeUpdate:(AliPlayer *)player time:(int64_t)time {
    self.eventSink(@{kAliPlayerMethod:@"onCurrentUtcTimeUpdate",@"time":@(time),kAliPlayerId:_playerId});
}

/**
 @brief 视频当前播放缓存命中回调
 @param player 播放器player指针
 @param size 文件大小
 */
- (void)onLocalCacheLoaded:(AliPlayer *)player size:(int64_t)size {
    self.eventSink(@{kAliPlayerMethod:@"onLocalCacheLoaded",@"size":@(size),kAliPlayerId:_playerId});
}

/**
 @brief 视频缓存位置回调
 @param player 播放器player指针
 @param position 视频当前缓存位置
 */
- (void)onBufferedPositionUpdate:(AliPlayer*)player position:(int64_t)position {
    self.eventSink(@{kAliPlayerMethod:@"onInfo",@"infoCode":@(1),@"extraValue":@(position),kAliPlayerId:_playerId});
}

/**
 @brief 获取track信息回调
 @param player 播放器player指针
 @param info track流信息数组 参考AVPTrackInfo
 */
- (void)onTrackReady:(AliPlayer*)player info:(NSArray<AVPTrackInfo*>*)info {
    self.eventSink(@{kAliPlayerMethod:@"onTrackReady",kAliPlayerId:_playerId});
}

/**
 @brief 字幕头信息回调，ass字幕，如果实现了此回调，则播放器不会渲染字幕，由调用者完成渲染，否则播放器自动完成字幕的渲染
 @param player 播放器player指针
 @param trackIndex 字幕显示的索引号
 @param header 头内容
 */
- (void)onSubtitleHeader:(AliPlayer *)player trackIndex:(int)trackIndex Header:(NSString *)header{
    self.eventSink(@{kAliPlayerMethod:@"onSubtitleHeader",@"trackIndex":@(trackIndex),@"header":header?:@"",kAliPlayerId:_playerId});
}

/**
 @brief 外挂字幕被添加
 @param player 播放器player指针
 @param trackIndex 字幕显示的索引号
 @param URL 字幕url
 */
- (void)onSubtitleExtAdded:(AliPlayer*)player trackIndex:(int)trackIndex URL:(NSString *)URL {
    self.eventSink(@{kAliPlayerMethod:@"onSubtitleExtAdded",@"trackIndex":@(trackIndex),@"url":URL,kAliPlayerId:_playerId});
}

/**
 @brief 字幕显示回调
 @param player 播放器player指针
 @param trackIndex 字幕流索引.
 @param subtitleID  字幕ID.
 @param subtitle 字幕显示的字符串
 */
- (void)onSubtitleShow:(AliPlayer*)player trackIndex:(int)trackIndex subtitleID:(long)subtitleID subtitle:(NSString *)subtitle {
    self.eventSink(@{kAliPlayerMethod:@"onSubtitleShow",@"trackIndex":@(trackIndex),@"subtitleID":@(subtitleID),@"subtitle":subtitle,kAliPlayerId:_playerId});
}

/**
 @brief 字幕隐藏回调
 @param player 播放器player指针
 @param trackIndex 字幕流索引.
 @param subtitleID  字幕ID.
 */
- (void)onSubtitleHide:(AliPlayer*)player trackIndex:(int)trackIndex subtitleID:(long)subtitleID {
    self.eventSink(@{kAliPlayerMethod:@"onSubtitleHide",@"trackIndex":@(trackIndex),@"subtitleID":@(subtitleID),kAliPlayerId:_playerId});
}

/**
 @brief 获取截图回调
 @param player 播放器player指针
 @param image 图像
 */
- (void)onCaptureScreen:(AliPlayer *)player image:(UIImage *)image {
    BOOL result =[UIImagePNGRepresentation(image)writeToFile:_snapshotPath atomically:YES]; // 保存成功会返回YES
    if (result == YES) {
        self.eventSink(@{kAliPlayerMethod:@"onSnapShot",@"snapShotPath":_snapshotPath,kAliPlayerId:_playerId});
    }
}

/**
 @brief track切换完成回调
 @param player 播放器player指针
 @param info 切换后的信息 参考AVPTrackInfo
 */
- (void)onTrackChanged:(AliPlayer*)player info:(AVPTrackInfo*)info {
    [AliPlayerLogger logDebug:@"onTrackChanged==%@",info.mj_JSONString];
    self.eventSink(@{kAliPlayerMethod:@"onTrackChanged",@"info":info.mj_keyValues,kAliPlayerId:_playerId});
}

/**
 @brief 获取缩略图成功回调
 @param positionMs 指定的缩略图位置
 @param fromPos 此缩略图的开始位置
 @param toPos 此缩略图的结束位置
 @param image 缩图略图像指针,对于mac是NSImage，iOS平台是UIImage指针
 */
- (void)onGetThumbnailSuc:(int64_t)positionMs fromPos:(int64_t)fromPos toPos:(int64_t)toPos image:(id)image {
    NSData *imageData = UIImageJPEGRepresentation(image,1);
//    FlutterStandardTypedData * fdata = [FlutterStandardTypedData typedDataWithBytes:imageData];
    self.eventSink(@{kAliPlayerMethod:@"onThumbnailGetSuccess",@"thumbnailRange":@[@(fromPos),@(toPos)],@"thumbnailbitmap":imageData,kAliPlayerId:_playerId});
}

/**
 @brief 获取缩略图失败回调
 @param positionMs 指定的缩略图位置
 */
- (void)onGetThumbnailFailed:(int64_t)positionMs {
    self.eventSink(@{kAliPlayerMethod:@"onThumbnailGetFail",kAliPlayerId:_playerId});
}

/**
 @brief 视频缓冲进度回调
 @param player 播放器player指针
 @param progress 缓存进度0-100
 */
- (void)onLoadingProgress:(AliPlayer*)player progress:(float)progress {
    self.eventSink(@{kAliPlayerMethod:@"onLoadingProgress",@"percent":@((int)progress),kAliPlayerId:_playerId});
}

/**
 @brief 当前下载速度回调
 @param player 播放器player指针
 @param speed bits per second
 */
- (void)onCurrentDownloadSpeed:(AliPlayer *)player speed:(int64_t)speed {
    self.eventSink(@{kAliPlayerMethod:@"onCurrentDownloadSpeed",@"speed":@(speed),kAliPlayerId:_playerId});
}

#pragma mark -- AVPEventReportParamsDelegate
/**
 @brief 回调
 @param params  埋点事件参数
 */
- (void)onEventReportParams:(NSDictionary<NSString *, NSString *>*)params {
    self.eventSink(@{kAliPlayerMethod:@"onEventReportParams",@"params":params,kAliPlayerId:_playerId});
}

#pragma mark -- AliPlayerPictureInPictureDelegate
/**
 @brief 画中画窗口尺寸变化
 @param pictureInPictureController  画中画控制器
 @param newRenderSize  新的窗口尺寸
 */
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController didTransitionToRenderSize:(CMVideoDimensions)newRenderSize {
}

/**
 @brief 画中画打开失败
 @param pictureInPictureController 画中画控制器
 */
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error {
}

/**
 @brief 在画中画停止前告诉代理恢复用户接口
 @param pictureInPictureController 画中画控制器
 @param completionHandler 调用并传值YES以允许系统结束恢复播放器用户接口
 */
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler {
    [AliPlayerLogger logDebug:@"restoreUserInterfaceForPictureInPictureStop 被调用"];
    
    // 延迟清理PIP Controller，避免过早清理导致回调失效
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.pipController) {
            [AliPlayerLogger logDebug:@"延迟清理PIP Controller"];
            self.pipController = nil;
        }
    });
    
    completionHandler(YES);
}

/**
 @brief 点击画中画暂停按钮
 @param pictureInPictureController 画中画控制器
 @param playing 是否正在播放
 */
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController setPlaying:(BOOL)playing {
    // 🛡️ 安全地更新PIP播放状态
    @try {
        if (!playing){
              self.isPipPaused = YES;
            } else {
              self.isPipPaused = NO;
          }
        self.eventSink(@{kAliPlayerMethod:@"setPlaying",@"playing":@(playing),kAliPlayerId:_playerId});
        
        // 🛡️ 使用安全方法替代直接调用
        [self safeInvalidatePlaybackStateWithDelay:0.05 context:@"setPlaying"];
    } @catch (NSException *exception) {
        [AliPlayerLogger logError:@"🛡️ setPlaying 异常: %@", exception.description];
    }
}

/**
 @brief 点击快进或快退按钮
 @param pictureInPictureController 画中画控制器
 @param skipInterval 快进快退的事件间隔
 @param completionHandler 一定要调用的闭包，表示跳转操作完成
 */
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController skipByInterval:(CMTime)skipInterval completionHandler:(void (^)(void))completionHandler {
    // 🛡️ 安全地处理快进快退
    @try {
        // iOS 14+ 已通过 requiresLinearPlayback 隐藏按钮，此方法不会被调用
        // iOS 13及以下保持原有的快进快退功能
        int64_t skipTime = skipInterval.value / skipInterval.timescale;
        int64_t currentTime = self.player.currentPosition;
        int64_t skipPosition = currentTime + skipTime * 1000;
        if (skipPosition < 0) {
          skipPosition = 0;
        } else if (skipPosition > self.player.duration) {
          skipPosition = self.player.duration;
        }
        [self.player seekToTime:skipPosition seekMode:AVP_SEEKMODE_ACCURATE];
        
        // 🛡️ 使用安全方法替代直接调用
        [self safeInvalidatePlaybackStateWithDelay:0.1 context:@"skipByInterval"];
        
        if (completionHandler) {
            completionHandler();
        }
    } @catch (NSException *exception) {
        [AliPlayerLogger logError:@"🛡️ skipByInterval 异常: %@", exception.description];
        if (completionHandler) {
            completionHandler();
        }
    }
}

/**
 @brief 画中画已经启动
 @param pictureInPictureController 画中画控制器
 */
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    // 🛡️ 安全地处理PIP启动完成
    @try {
        [AliPlayerLogger logDebug:@"🛡️ DidStartPictureInPicture - Controller地址: %p", pictureInPictureController];
        // 🛡️ 使用安全方法替代直接调用
        [self safeInvalidatePlaybackStateWithDelay:0.1 context:@"didStart"];
    } @catch (NSException *exception) {
        [AliPlayerLogger logError:@"🛡️ didStartPictureInPicture 异常: %@", exception.description];
    }
}

/**
 @brief 画中画已经停止
 @param pictureInPictureController 画中画控制器
 */
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    // 🛡️ 安全地处理PIP停止完成
    @try {
        [AliPlayerLogger logDebug:@"🛡️⭐⭐⭐ DidStopPictureInPicture - Controller地址: %p ⭐⭐⭐", pictureInPictureController];
        
        // 🛡️ 使用安全方法替代直接调用
        [self safeInvalidatePlaybackStateWithDelay:0.1 context:@"didStop"];
        
        // 🔍 确保停止监控
        [self stopPipStateMonitoring];
        
        // 🔧 注意：不在这里清理pipController，因为PIP可能会被重新激活
        // pipController只有在明确调用setPictureInPictureEnable:NO时才清理
        [AliPlayerLogger logDebug:@"🔧 DidStop回调 - 保留PIP Controller以便可能的重新激活"];
        
    } @catch (NSException *exception) {
        [AliPlayerLogger logError:@"🛡️ didStopPictureInPicture 异常: %@", exception.description];
    }
}

/**
 @brief 将暂停或播放状态反映到UI上
 @param pictureInPictureController 画中画控制器
 @return 暂停或播放
 */
- (BOOL)pictureInPictureControllerIsPlaybackPaused:(AVPictureInPictureController *)pictureInPictureController {
    return self.isPipPaused;
}

/**
 @brief 通知画中画控制器当前可播放的时间范围
 @param pictureInPictureController 画中画控制器
 @return 当前可播放的时间范围
 */
 - (CMTimeRange)pictureInPictureControllerTimeRangeForPlayback:(nonnull AVPictureInPictureController *)pictureInPictureController layerTime:(CMTime)layerTime {
    Float64 current64 = CMTimeGetSeconds(layerTime);

    Float64 start;
    Float64 end;

    if (self.player.currentPosition <= self.player.duration) {
        double curPostion = self.player.currentPosition / 1000.0;
        double duration = self.player.duration / 1000.0;
        double interval = duration - curPostion;
        start = current64 - curPostion;
        end = current64 + interval;
        CMTime t1 = CMTimeMakeWithSeconds(start, layerTime.timescale);
        CMTime t2 = CMTimeMakeWithSeconds(end, layerTime.timescale);
        return CMTimeRangeFromTimeToTime(t1, t2);
    } else {
        return CMTimeRangeMake(kCMTimeNegativeInfinity, kCMTimePositiveInfinity);
    }
}

/**
 @brief 画中画将要启动
 @param pictureInPictureController 画中画控制器
 */
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    [AliPlayerLogger logDebug:@"⭐⭐⭐ pictureInPictureControllerWillStartPictureInPicture 被调用 ⭐⭐⭐"];
    [AliPlayerLogger logDebug:@"传入的Controller地址: %p", pictureInPictureController];
    
    self.eventSink(@{kAliPlayerMethod:@"WillStartPip",@"pipStatus":@(YES),kAliPlayerId:_playerId});
    
    if (!_pipController) {
        self.pipController = pictureInPictureController;
        [AliPlayerLogger logDebug:@"设置PIP Controller地址: %p", self.pipController];
        
        // 修复：确保播放器存在时才设置delegate
        if (self.player) {
            [self.player setPictureInPictureShowMode:AVP_SHOW_MODE_DEFAULT];
            [self.player setPictureinPictureDelegate:self];
            [AliPlayerLogger logDebug:@"重新设置播放器PIP delegate"];
        }
    }
    
    // 禁用PIP中的快进快退按钮（iOS 14+）
    if (@available(iOS 14.0, *)) {
        pictureInPictureController.requiresLinearPlayback = YES;
    }
    
    self.isPipPaused = NO;
    // 🛡️ 使用安全方法替代直接调用
    [self safeInvalidatePlaybackStateWithDelay:0.1 context:@"willStart"];
    
    // 🔍 启动PIP状态监控
    [self startPipStateMonitoring];
    
    [AliPlayerLogger logDebug:@"⭐⭐⭐ WillStartPip 设置完成 ⭐⭐⭐"];
}

/**
 @brief 画中画准备停止
 @param pictureInPictureController 画中画控制器
 */
- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    [AliPlayerLogger logDebug:@"⭐⭐⭐ pictureInPictureControllerWillStopPictureInPicture 被调用 ⭐⭐⭐"];
    [AliPlayerLogger logDebug:@"当前PIP Controller地址: %p", self.pipController];
    [AliPlayerLogger logDebug:@"传入的Controller地址: %p", pictureInPictureController];
    [AliPlayerLogger logDebug:@"PIP Controller相等: %@", (self.pipController == pictureInPictureController) ? @"YES" : @"NO"];
    [AliPlayerLogger logDebug:@"当前isPipPaused: %@", self.isPipPaused ? @"YES" : @"NO"];
    
    self.isPipPaused = NO;
    self.eventSink(@{kAliPlayerMethod:@"WillStopPip",@"pipStatus":@(YES),kAliPlayerId:_playerId});
    // 🛡️ 使用安全方法替代直接调用
    [self safeInvalidatePlaybackStateWithDelay:0.05 context:@"willStop"];
    
    [AliPlayerLogger logDebug:@"⭐⭐⭐ WillStopPip 回调完成 ⭐⭐⭐"];
}

-(void)bindPlayerView:(FlutterAliPlayerView*)fapv{
    _fapv = fapv;
    self.player.playerView = fapv.view;
}

#pragma mark - PIP状态监控方法

/**
 @brief 开始PIP状态监控
 */
- (void)startPipStateMonitoring {
    [AliPlayerLogger logDebug:@"🔍 开始PIP状态监控"];
    
    if (self.pipStateMonitor) {
        [self.pipStateMonitor invalidate];
        self.pipStateMonitor = nil;
    }
    
    // 每0.5秒检查一次PIP状态
    self.pipStateMonitor = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                            target:self
                                                          selector:@selector(checkPipStateChange)
                                                          userInfo:nil
                                                           repeats:YES];
    
    // 初始化上次已知状态
    self.lastKnownPipActiveState = self.pipController ? self.pipController.isPictureInPictureActive : NO;
    [AliPlayerLogger logDebug:@"🔍 初始PIP状态: %@", self.lastKnownPipActiveState ? @"激活" : @"未激活"];
}

/**
 @brief 停止PIP状态监控
 */
- (void)stopPipStateMonitoring {
    [AliPlayerLogger logDebug:@"🔍 停止PIP状态监控"];
    
    if (self.pipStateMonitor) {
        [self.pipStateMonitor invalidate];
        self.pipStateMonitor = nil;
    }
}

/**
 @brief 检查PIP状态变化
 */
- (void)checkPipStateChange {
    if (!self.pipController) {
        return;
    }
    
    BOOL currentPipActiveState = self.pipController.isPictureInPictureActive;
    
    // 检测到PIP状态变化
    if (currentPipActiveState != self.lastKnownPipActiveState) {
        [AliPlayerLogger logDebug:@"🔍⚡ 检测到PIP状态变化: %@ → %@", 
              self.lastKnownPipActiveState ? @"激活" : @"未激活",
              currentPipActiveState ? @"激活" : @"未激活"];
        
        if (self.lastKnownPipActiveState && !currentPipActiveState) {
            // PIP从激活变为未激活，手动触发willStopPip逻辑
            [AliPlayerLogger logDebug:@"🔍⚡⚡ 手动触发WillStopPip逻辑 ⚡⚡"];
            [self manuallyTriggerWillStopPip];
            
            // 🔧 注意：不在这里清理pipController，保留以便可能的重新激活
            [AliPlayerLogger logDebug:@"🔧 PIP监控检测到关闭，但保留Controller以便重新激活"];
        } else if (!self.lastKnownPipActiveState && currentPipActiveState) {
            // PIP从未激活变为激活
            [AliPlayerLogger logDebug:@"🔍⚡ PIP激活，开始状态同步"];
            self.isPipPaused = (self.currentPlayerStatus != AVPStatusStarted);
        }
        
        self.lastKnownPipActiveState = currentPipActiveState;
    }
}

/**
 @brief 手动触发WillStopPip逻辑
 */
- (void)manuallyTriggerWillStopPip {
    [AliPlayerLogger logDebug:@"🔍⚡⚡⚡ manuallyTriggerWillStopPip - 手动触发WillStopPip逻辑 ⚡⚡⚡"];
    
    // 模拟原来willStopPip回调的逻辑
    self.isPipPaused = NO;
    self.eventSink(@{kAliPlayerMethod:@"WillStopPip",@"pipStatus":@(YES),kAliPlayerId:_playerId});
    
    // 停止状态监控，因为PIP已经停止
    [self stopPipStateMonitoring];
    
    // 🔧 注意：不清理pipController，保留以便可能的重新激活
    [AliPlayerLogger logDebug:@"🔧 手动WillStopPip逻辑完成，保留Controller以便重新激活"];
}

/**
 @brief 处理视频源切换时的PIP状态
 */
- (void)handleVideoSourceChange {
    NSLog(@"AliPlayerProxy: handleVideoSourceChange - 处理视频源切换");
    
    if (self.pipController && self.pipController.isPictureInPictureActive) {
        NSLog(@"AliPlayerProxy: PIP处于激活状态，需要强制重新关联");
        
        // 强制重新关联PIP Controller
        [self forcePipControllerReassociation];
    }
}

/**
 @brief 强制重新关联PIP Controller与播放器
 */
- (void)forcePipControllerReassociation {
    NSLog(@"AliPlayerProxy: forcePipControllerReassociation - 强制重新关联PIP Controller");
    
    if (!self.pipController || !self.pipController.isPictureInPictureActive) {
        NSLog(@"AliPlayerProxy: PIP未激活，跳过重新关联");
        return;
    }
    
    // 保存当前PIP状态
    BOOL wasPaused = self.isPipPaused;
    
    // 重新设置播放器的PIP delegate
    if (self.player) {
        NSLog(@"AliPlayerProxy: 重新设置播放器PIP delegate");
        [self.player setPictureinPictureDelegate:self];
        
        // 确保PIP模式设置正确
        [self.player setPictureInPictureShowMode:AVP_SHOW_MODE_DEFAULT];
    }
    
    // 恢复PIP状态
    self.isPipPaused = wasPaused;
    
    // 延迟刷新，确保新播放器实例完全初始化
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"AliPlayerProxy: 延迟执行PIP状态刷新");
        [self refreshPipStateIfNeeded];
        
        // 再次确保delegate关联
        if (self.player) {
            [self.player setPictureinPictureDelegate:self];
        }
    });
}

/**
 @brief 刷新PIP状态（如果需要）
 */
- (void)refreshPipStateIfNeeded {
    if (self.pipController && self.pipController.isPictureInPictureActive) {
        NSLog(@"AliPlayerProxy: refreshPipStateIfNeeded - 刷新PIP状态");
        
        // 根据当前播放器状态更新PIP状态
        BOOL shouldBePaused = (self.currentPlayerStatus != AVPStatusStarted);
        if (self.isPipPaused != shouldBePaused) {
            self.isPipPaused = shouldBePaused;
            NSLog(@"AliPlayerProxy: 刷新PIP暂停状态为: %d", self.isPipPaused);
        }
        
        // 🛡️ 使用安全方法替代直接调用
        [self safeInvalidatePlaybackStateWithDelay:0.1 context:@"monitoring"];
        NSLog(@"AliPlayerProxy: PIP状态刷新完成");
    }
}

- (void)timerAction {
    if ([_player isKindOfClass:AVPLiveTimeShift.class]) {
        AVPTimeShiftModel *timeShiftModel = ((AVPLiveTimeShift*)self.player).timeShiftModel;
        if (!timeShiftModel) {
            return;
        }
        self.eventSink(@{kAliPlayerMethod:@"onUpdater",@"currentTime":@((int)(timeShiftModel.currentTime)),@"shiftStartTime":@((int)(timeShiftModel.startTime)),@"shiftEndTime":@((int)(timeShiftModel.endTime)),kAliPlayerId:_playerId});
    }
}

- (void)dealloc
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    // 🔍 清理PIP状态监控
    if (_pipStateMonitor) {
        [_pipStateMonitor invalidate];
        _pipStateMonitor = nil;
    }
}

#pragma --mark getters
- (AliPlayer *)player{
    if (!_player) {
        if (_playerType==1) {
            _player = [[AliListPlayer alloc] init];
            ((AliListPlayer*)_player).stsPreloadDefinition = @"FD";
        }else if(_playerType==2){
            _player = [[AVPLiveTimeShift alloc] init];
            _timer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
            [_timer fire];
        }else{
            _player = [[AliPlayer alloc] init];
        }
        _player.scalingMode =  AVP_SCALINGMODE_SCALEASPECTFIT;
        _player.rate = 1;
        _player.delegate = self;
        
        // 🔧 确保每次创建播放器时都正确设置PIP delegate和模式
        [_player setPictureinPictureDelegate: self];
        [_player setPictureInPictureShowMode:AVP_SHOW_MODE_DEFAULT];
        [AliPlayerLogger logDebug:@"🔧 新播放器实例创建，已设置PIP delegate和显示模式"];
    }
    return _player;
}

#pragma mark - 🛡️ PIP 安全方法

/**
 @brief 安全地调用 invalidatePlaybackState
 @param delay 延迟时间
 @param context 调用上下文，用于日志记录
 */
- (void)safeInvalidatePlaybackStateWithDelay:(NSTimeInterval)delay context:(NSString *)context {
    // 🛡️ 安全检查
    if (!self.pipController) {
        [AliPlayerLogger logDebug:@"🛡️ 跳过 invalidatePlaybackState - pipController 为空 (context: %@)", context];
        return;
    }
    
    if (![self.pipController isKindOfClass:[AVPictureInPictureController class]]) {
        [AliPlayerLogger logError:@"🛡️ pipController 类型错误 (context: %@)", context];
        return;
    }
    
    // 🛡️ 防重复调用机制 - 避免短时间内重复调用
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    if (currentTime - self.lastInvalidateTime < 0.5 && [context isEqualToString:self.lastInvalidateContext]) {
        [AliPlayerLogger logDebug:@"🛡️ 跳过重复的 invalidatePlaybackState 调用 (context: %@)", context];
        return;
    }
    
    self.lastInvalidateTime = currentTime;
    self.lastInvalidateContext = context;
    
    // 🛡️ 主线程安全调用
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.pipController) {
            @try {
                [AliPlayerLogger logDebug:@"🛡️ 准备调用 invalidatePlaybackState (context: %@, delay: %.2f)", context, delay];
                
                if (delay > 0) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (self.pipController) {
                            @try {
                                [self.pipController invalidatePlaybackState];
                                [AliPlayerLogger logDebug:@"✅ invalidatePlaybackState 调用成功 (context: %@)", context];
                            } @catch (NSException *exception) {
                                [AliPlayerLogger logError:@"🛡️ invalidatePlaybackState 异常: %@ (context: %@)", exception.description, context];
                            }
                        }
                    });
                } else {
                    [self.pipController invalidatePlaybackState];
                    [AliPlayerLogger logDebug:@"✅ invalidatePlaybackState 立即调用成功 (context: %@)", context];
                }
            } @catch (NSException *exception) {
                [AliPlayerLogger logError:@"🛡️ invalidatePlaybackState 异常: %@ (context: %@)", exception.description, context];
            }
        }
    });
}

/**
 @brief 安全地设置PIP暂停状态
 @param paused 是否暂停
 @param context 调用上下文
 */
- (void)safeSyncPipPausedState:(BOOL)paused context:(NSString *)context {
    if (self.isPipPaused != paused) {
        self.isPipPaused = paused;
        [AliPlayerLogger logDebug:@"🛡️ PIP状态同步: %@ (context: %@)", paused ? @"暂停" : @"播放", context];
        [self safeInvalidatePlaybackStateWithDelay:0.1 context:[NSString stringWithFormat:@"%@_sync", context]];
    }
}

/**
 @brief 强制清理PIP Controller（如果需要）
 @param forceClean 是否强制清理，即使PIP已停止也清理Controller
 */
- (void)forceClearPipControllerIfNeeded:(BOOL)forceClean {
    [AliPlayerLogger logDebug:@"🔧 forceClearPipControllerIfNeeded 被调用, forceClean: %@", forceClean ? @"YES" : @"NO"];
    
    if (self.pipController) {
        BOOL isPipActive = self.pipController.isPictureInPictureActive;
        [AliPlayerLogger logDebug:@"🔧 当前PIP Controller存在，激活状态: %@", isPipActive ? @"YES" : @"NO"];
        
        if (!isPipActive && forceClean) {
            // PIP已经停止且要求强制清理，才清理Controller
            [AliPlayerLogger logDebug:@"🔧 PIP已停止且要求强制清理，清理Controller"];
            [self stopPipStateMonitoring];
            self.pipController = nil;
            [AliPlayerLogger logDebug:@"🔧 强制清理完成"];
        } else if (!isPipActive && !forceClean) {
            [AliPlayerLogger logDebug:@"🔧 PIP已停止但不强制清理，保留Controller"];
        } else {
            [AliPlayerLogger logDebug:@"🔧 PIP仍在激活状态，不清理"];
        }
    } else {
        [AliPlayerLogger logDebug:@"🔧 没有PIP Controller需要清理"];
    }
}

/**
 @brief 在视频准备完成后确保PIP配置正确
 */
- (void)ensurePipConfigurationAfterPrepare {
    [AliPlayerLogger logDebug:@"🔧 ensurePipConfigurationAfterPrepare - 确保PIP配置正确"];
    
    if (self.player) {
        // 🔧 重新设置PIP delegate，确保回调能正常工作
        [self.player setPictureinPictureDelegate:self];
        [AliPlayerLogger logDebug:@"🔧 视频准备完成后重新设置PIP delegate"];
        
        // 🔧 设置PIP显示模式
        [self.player setPictureInPictureShowMode:AVP_SHOW_MODE_DEFAULT];
        [AliPlayerLogger logDebug:@"🔧 视频准备完成后设置PIP显示模式"];
        
        // 🔧 如果之前有PIP Controller但PIP没有激活，说明可能是切换视频源后的状态
        if (self.pipController && !self.pipController.isPictureInPictureActive) {
            [AliPlayerLogger logDebug:@"🔧 检测到非激活的PIP Controller，可能需要重新关联"];
            // 这里不清理Controller，让上层重新调用enable时处理
        }
    }
}

@end
