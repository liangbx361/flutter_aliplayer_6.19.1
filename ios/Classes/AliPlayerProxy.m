//
//  AliPlayerProxy.m
//  flutter_aliplayer
//
//  Created by aliyun on 2021/5/18.
//

#import "AliPlayerProxy.h"
#import <MJExtension/MJExtension.h>

@interface AliPlayerProxy ()
@property(nonatomic,strong) NSTimer *timer;

// 监听画中画当前是否是暂停状态
@property (nonatomic, assign) BOOL isPipPaused;
// 监听播放器当前的播放状态，通过监听播放事件状态变更newStatus回调设置
@property (nonatomic, assign) AVPStatus currentPlayerStatus;

// 监听播放器当前播放进度，currentPosition设置为监听视频当前播放位置回调中的position参数值
@property(nonatomic, assign) int64_t currentPosition;
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
    NSLog(@"SEI: %@", str);
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
            self.eventSink(@{kAliPlayerMethod:@"onPrepared",kAliPlayerId:_playerId});
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
                   [self.pipController invalidatePlaybackState];
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
    NSLog(@"onTrackChanged==%@",info.mj_JSONString);
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
    if (_pipController) {
          _pipController = nil;
      }
      completionHandler(YES);
    
}

/**
 @brief 点击画中画暂停按钮
 @param pictureInPictureController 画中画控制器
 @param playing 是否正在播放
 */
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController setPlaying:(BOOL)playing {
    if (!playing){
          self.isPipPaused = YES;
        } else {
          self.isPipPaused = NO;
      }
    self.eventSink(@{kAliPlayerMethod:@"setPlaying",@"playing":@(playing),kAliPlayerId:_playerId});
      [pictureInPictureController invalidatePlaybackState];
}

/**
 @brief 点击快进或快退按钮
 @param pictureInPictureController 画中画控制器
 @param skipInterval 快进快退的事件间隔
 @param completionHandler 一定要调用的闭包，表示跳转操作完成
 */
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController skipByInterval:(CMTime)skipInterval completionHandler:(void (^)(void))completionHandler {
    int64_t skipTime = skipInterval.value / skipInterval.timescale;
    int64_t currentTime = self.player.currentPosition;
    int64_t skipPosition = currentTime + skipTime * 1000;
    if (skipPosition < 0) {
      skipPosition = 0;
    } else if (skipPosition > self.player.duration) {
      skipPosition = self.player.duration;
    }
    [self.player seekToTime:skipPosition seekMode:AVP_SEEKMODE_ACCURATE];
    [pictureInPictureController invalidatePlaybackState];
}

/**
 @brief 画中画已经启动
 @param pictureInPictureController 画中画控制器
 */
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    [pictureInPictureController invalidatePlaybackState];
}

/**
 @brief 画中画已经停止
 @param pictureInPictureController 画中画控制器
 */
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    [pictureInPictureController invalidatePlaybackState];
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
     [self.pipController invalidatePlaybackState];
}

/**
 @brief 画中画将要启动
 @param pictureInPictureController 画中画控制器
 */
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    self.eventSink(@{kAliPlayerMethod:@"WillStartPip",@"pipStatus":@(YES),kAliPlayerId:_playerId});
    if (!_pipController) {
         self.pipController = pictureInPictureController;
        
        
        if (!self.player){
            [self.player setPictureInPictureShowMode:AVP_SHOW_MODE_DEFAULT];
            [self.player setPictureinPictureDelegate:self];
        }
      }
    self.isPipPaused = NO;
    [self.pipController invalidatePlaybackState];
}

/**
 @brief 画中画准备停止
 @param pictureInPictureController 画中画控制器
 */
- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    self.isPipPaused = NO;
    self.eventSink(@{kAliPlayerMethod:@"WillStopPip",@"pipStatus":@(YES),kAliPlayerId:_playerId});
      [self.pipController invalidatePlaybackState];
}

-(void)bindPlayerView:(FlutterAliPlayerView*)fapv{
    _fapv = fapv;
    self.player.playerView = fapv.view;
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
        [_player setPictureinPictureDelegate: self];
    }
    return _player;
}

@end
