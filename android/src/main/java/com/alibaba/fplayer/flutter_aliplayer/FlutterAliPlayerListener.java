package com.alibaba.fplayer.flutter_aliplayer;

import java.util.Map;

/**
 * AliPlayer 监听接口
 */
public interface FlutterAliPlayerListener {

    void onPrepared(Map<String,Object> map);

    void onTrackReady(Map<String,Object> map);

    void onCompletion(Map<String,Object> map);

    void onRenderingStart(Map<String,Object> map);

    void onVideoSizeChanged(Map<String,Object> map);

    void onVideoRendered(Map<String, Object> map);

    void onSnapShot(Map<String,Object> map);

    void onTrackChangedSuccess(Map<String,Object> map);

    void onTrackChangedFail(Map<String,Object> map);

    void onSeekComplete(Map<String,Object> map);

    void onSeiData(Map<String,Object> map);

    void onLoadingBegin(Map<String,Object> map);

    void onLoadingProgress(Map<String,Object> map);

    void onLoadingEnd(Map<String,Object> map);

    void onStateChanged(Map<String,Object> map);

    void onSubtitleExtAdded(Map<String,Object> map);

    void onSubtitleShow(Map<String,Object> map);

    void onSubtitleHide(Map<String,Object> map);

    void onSubtitleHeader(Map<String,Object> map);

    void onInfo(Map<String,Object> map);

    void onError(Map<String,Object> map);

    void onThumbnailPrepareSuccess(Map<String,Object> map);

    void onThumbnailPrepareFail(Map<String,Object> map);

    void onThumbnailGetSuccess(Map<String,Object> map);

    void onThumbnailGetFail(Map<String,Object> map);

    void onTimeShiftUpdater(Map<String,Object> map);

    void onSeekLiveCompletion(Map<String,Object> map);

    void onReportEventListener(Map<String,Object> map);

    int onChooseTrackIndex(Map<String,Object> map);

}
