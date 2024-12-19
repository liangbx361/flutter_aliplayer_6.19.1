package com.alibaba.fplayer.flutter_aliplayer;

import com.aliyun.player.AliLiveShiftPlayer;
import com.aliyun.player.AliPlayerFactory;
import com.aliyun.player.IPlayer;
import com.aliyun.player.source.LiveShift;

import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FlutterAliLiveShiftPlayer extends FlutterPlayerBase{

    private final AliLiveShiftPlayer mAliLiveShiftPlayer;

    public FlutterAliLiveShiftPlayer(FlutterPlugin.FlutterPluginBinding flutterPluginBinding, String playerId) {
        this.mPlayerId = playerId;
        this.mContext = flutterPluginBinding.getApplicationContext();
        mAliLiveShiftPlayer = AliPlayerFactory.createAliLiveShiftPlayer(mContext);
        initListener(mAliLiveShiftPlayer);
    }

    @Override
    public IPlayer getAliPlayer() {
        return mAliLiveShiftPlayer;
    }

    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "getCurrentLiveTime":
                result.success(getCurrentLiveTime());
                break;
            case "getCurrentTime":
                result.success(getCurrentTime());
                break;
            case "seekToLiveTime":
                int seekToLiveTime = methodCall.argument("arg");
                seekToLiveTime(seekToLiveTime);
                result.success(null);
                break;
            case "setDataSource":
                Map<String,Object> dataSourceMap = (Map<String,Object>)methodCall.argument("arg");
                LiveShift liveShift = new LiveShift();
                liveShift.setTimeLineUrl((String) dataSourceMap.get("timeLineUrl"));
                liveShift.setUrl((String) dataSourceMap.get("url"));
                liveShift.setCoverPath((String) dataSourceMap.get("coverPath"));
                liveShift.setFormat((String) dataSourceMap.get("format"));
                liveShift.setTitle((String) dataSourceMap.get("title"));
                setDataSource(liveShift);
                result.success(null);
                break;
            case "prepare":
                prepare();
                result.success(null);
                break;
            case "play":
                start();
                result.success(null);
                break;
            case "pause":
                pause();
                result.success(null);
                break;
            case "stop":
                stop();
                result.success(null);
                break;
            case "destroy":
                release();
                result.success(null);
                break;
            case "releaseAsync":
                releaseAsync();
                result.success(null);
                break;
        }
    }

    private void prepare(){
        if(mAliLiveShiftPlayer != null){
            mAliLiveShiftPlayer.prepare();
        }
    }

    private void start(){
        if(mAliLiveShiftPlayer != null){
            mAliLiveShiftPlayer.start();
        }
    }

    private void pause(){
        if(mAliLiveShiftPlayer != null){
            mAliLiveShiftPlayer.pause();
        }
    }

    private void stop(){
        if(mAliLiveShiftPlayer != null){
            mAliLiveShiftPlayer.stop();
        }
    }

    private void release(){
        if(mAliLiveShiftPlayer != null){
            mAliLiveShiftPlayer.release();
        }
    }

    private void releaseAsync(){
        if(mAliLiveShiftPlayer != null){
            mAliLiveShiftPlayer.releaseAsync();
        }
    }

    private long getCurrentLiveTime() {
        if(mAliLiveShiftPlayer != null){
            return mAliLiveShiftPlayer.getCurrentLiveTime();
        }
        return 0;
    }

    private long getCurrentTime(){
        if(mAliLiveShiftPlayer != null){
            return mAliLiveShiftPlayer.getCurrentTime();
        }
        return 0;
    }

    private void setDataSource(LiveShift liveShift){
        if(mAliLiveShiftPlayer != null){
            mAliLiveShiftPlayer.setDataSource(liveShift);
        }
    }

    private void seekToLiveTime(long liveTime){
        if(mAliLiveShiftPlayer != null){
            mAliLiveShiftPlayer.seekToLiveTime(liveTime);
        }
    }
}
