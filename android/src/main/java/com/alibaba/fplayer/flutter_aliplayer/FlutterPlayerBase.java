package com.alibaba.fplayer.flutter_aliplayer;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.aliyun.player.AliLiveShiftPlayer;
import com.aliyun.player.IPlayer;
import com.aliyun.player.bean.ErrorInfo;
import com.aliyun.player.bean.InfoBean;
import com.aliyun.player.nativeclass.MediaInfo;
import com.aliyun.player.nativeclass.TrackInfo;
import com.cicada.player.utils.FrameInfo;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.ScheduledThreadPoolExecutor;

public abstract class FlutterPlayerBase {

    protected Context mContext;
    protected String mSnapShotPath;
    protected String mPlayerId;
    protected FlutterAliPlayerListener mFlutterAliPlayerListener;
    private ExecutorService executorService = new ScheduledThreadPoolExecutor(10);

    private Handler mHandler = new Handler(Looper.getMainLooper());

    public void setOnFlutterListener(FlutterAliPlayerListener listener) {
        this.mFlutterAliPlayerListener = listener;
    }

    public abstract IPlayer getAliPlayer();

    public void initListener(final IPlayer player) {
        player.setOnPreparedListener(new IPlayer.OnPreparedListener() {
            @Override
            public void onPrepared() {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onPrepared");
                map.put("playerId", mPlayerId);
//                mEventSink.success(map);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onPrepared(map);
                }
            }
        });

        player.setOnRenderingStartListener(new IPlayer.OnRenderingStartListener() {
            @Override
            public void onRenderingStart() {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onRenderingStart");
                map.put("playerId", mPlayerId);
//                mEventSink.success(map);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onRenderingStart(map);
                }
            }
        });

        player.setOnChooseTrackIndexListener(new IPlayer.OnChooseTrackIndexListener() {
            @Override
            public int onChooseTrackIndex(TrackInfo[] trackInfos) {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onChooseTrackIndex");
                map.put("trackInfos", trackInfos);
                map.put("playerId", mPlayerId);
//                mEventSink.success(map);
                if (mFlutterAliPlayerListener != null) {
                    return mFlutterAliPlayerListener.onChooseTrackIndex(map);
                } else {
                    return 0;
                }
            }
        });

        player.setOnReportEventListener(new IPlayer.OnReportEventListener() {
            @Override
            public void onEventParam(Map<String, String> param) {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onEventReportParams");
                map.put("params", param);
                map.put("playerId", mPlayerId);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onReportEventListener(map);
                }
            }
        });

        player.setOnVideoSizeChangedListener(new IPlayer.OnVideoSizeChangedListener() {
            @Override
            public void onVideoSizeChanged(int width, int height) {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onVideoSizeChanged");
                map.put("width", width);
                map.put("height", height);
                map.put("playerId", mPlayerId);
//                mEventSink.success(map);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onVideoSizeChanged(map);
                }
            }
        });

        player.setOnVideoRenderedListener(new IPlayer.OnVideoRenderedListener() {
            @Override
            public void onVideoRendered(long timeMs, long pts) {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onVideoRendered");
                map.put("playerId", mPlayerId);
                map.put("timeMs", timeMs);
                map.put("pts", pts);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onVideoRendered(map);
                }
            }
        });

        player.setOnSnapShotListener(new IPlayer.OnSnapShotListener() {
            @Override
            public void onSnapShot(final Bitmap bitmap, int width, int height) {
                final Map<String, Object> map = new HashMap<>();
                map.put("method", "onSnapShot");
                map.put("snapShotPath", mSnapShotPath);
                map.put("playerId", mPlayerId);


                executorService.execute(new Runnable() {
                    @Override
                    public void run() {
                        if (bitmap != null) {
                            File f = new File(mSnapShotPath);
                            FileOutputStream out = null;
                            if (f.exists()) {
                                f.delete();
                            }
                            try {
                                out = new FileOutputStream(f);
                                bitmap.compress(Bitmap.CompressFormat.PNG, 100, out);
                                out.flush();
                                out.close();
                            } catch (FileNotFoundException e) {
                                e.printStackTrace();
                            } catch (IOException e) {
                                e.printStackTrace();
                            } finally {
                                if (out != null) {
                                    try {
                                        out.close();
                                    } catch (IOException e) {
                                        e.printStackTrace();
                                    }
                                }
                            }
                        }

                        mHandler.post(new Runnable() {
                            @Override
                            public void run() {
                                if (mFlutterAliPlayerListener != null) {
                                    mFlutterAliPlayerListener.onSnapShot(map);
                                }
                            }
                        });
                    }
                });
//                mEventSink.success(map);
            }
        });

        player.setOnTrackChangedListener(new IPlayer.OnTrackChangedListener() {
            @Override
            public void onChangedSuccess(TrackInfo trackInfo) {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onTrackChanged");
                map.put("playerId", mPlayerId);
                Map<String, Object> infoMap = new HashMap<>();
                infoMap.put("vodFormat", trackInfo.getVodFormat());
                infoMap.put("videoHeight", trackInfo.getVideoHeight());
                infoMap.put("videoWidth", trackInfo.getVideoHeight());
                infoMap.put("subtitleLanguage", trackInfo.getSubtitleLang());
                infoMap.put("trackBitrate", trackInfo.getVideoBitrate());
                infoMap.put("vodFileSize", trackInfo.getVodFileSize());
                infoMap.put("trackIndex", trackInfo.getIndex());
                infoMap.put("trackDefinition", trackInfo.getVodDefinition());
                infoMap.put("audioSampleFormat", trackInfo.getAudioSampleFormat());
                infoMap.put("audioLanguage", trackInfo.getAudioLang());
                infoMap.put("vodPlayUrl", trackInfo.getVodPlayUrl());
                infoMap.put("trackType", trackInfo.getType().ordinal());
                infoMap.put("audioSamplerate", trackInfo.getAudioSampleRate());
                infoMap.put("audioChannels", trackInfo.getAudioChannels());
                map.put("info", infoMap);
//                mEventSink.success(map);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onTrackChangedSuccess(map);
                }
            }

            @Override
            public void onChangedFail(TrackInfo trackInfo, ErrorInfo errorInfo) {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onChangedFail");
                map.put("playerId", mPlayerId);
//                mEventSink.success(map);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onTrackChangedFail(map);
                }
            }
        });

        player.setOnSeekCompleteListener(new IPlayer.OnSeekCompleteListener() {
            @Override
            public void onSeekComplete() {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onSeekComplete");
                map.put("playerId", mPlayerId);
//                mEventSink.success(map);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onSeekComplete(map);
                }
            }
        });

        player.setOnSeiDataListener(new IPlayer.OnSeiDataListener() {
            @Override
            public void onSeiData(int type, byte[] uuid, byte[] data) {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onSeiData");
                map.put("type", type);
                map.put("uuid", uuid);
                map.put("data", data);
                map.put("playerId", mPlayerId);

                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onSeiData(map);
                }
            }
        });

        player.setOnLoadingStatusListener(new IPlayer.OnLoadingStatusListener() {
            @Override
            public void onLoadingBegin() {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onLoadingBegin");
                map.put("playerId", mPlayerId);
//                mEventSink.success(map);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onLoadingBegin(map);
                }
            }

            @Override
            public void onLoadingProgress(int percent, float netSpeed) {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onLoadingProgress");
                map.put("percent", percent);
                map.put("netSpeed", netSpeed);
                map.put("playerId", mPlayerId);
//                mEventSink.success(map);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onLoadingProgress(map);
                }
            }

            @Override
            public void onLoadingEnd() {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onLoadingEnd");
                map.put("playerId", mPlayerId);
//                mEventSink.success(map);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onLoadingEnd(map);
                }
            }
        });

        player.setOnStateChangedListener(new IPlayer.OnStateChangedListener() {
            @Override
            public void onStateChanged(int newState) {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onStateChanged");
                map.put("newState", newState);
                map.put("playerId", mPlayerId);
//                mEventSink.success(map);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onStateChanged(map);
                }
            }
        });

        player.setOnSubtitleDisplayListener(new IPlayer.OnSubtitleDisplayListener() {
            @Override
            public void onSubtitleExtAdded(int trackIndex, String url) {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onSubtitleExtAdded");
                map.put("trackIndex", trackIndex);
                map.put("url", url);
                map.put("playerId", mPlayerId);
//                mEventSink.success(map);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onSubtitleExtAdded(map);
                }
            }

            @Override
            public void onSubtitleShow(int trackIndex, long id, String data) {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onSubtitleShow");
                map.put("trackIndex", trackIndex);
                map.put("subtitleID", id);
                map.put("subtitle", data);
                map.put("playerId", mPlayerId);
//                mEventSink.success(map);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onSubtitleShow(map);
                }
            }

            @Override
            public void onSubtitleHide(int trackIndex, long id) {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onSubtitleHide");
                map.put("trackIndex", trackIndex);
                map.put("subtitleID", id);
                map.put("playerId", mPlayerId);
//                mEventSink.success(map);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onSubtitleHide(map);
                }
            }

            @Override
            public void onSubtitleHeader(int trackIndex, String header) {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onSubtitleHeader");
                map.put("trackIndex", trackIndex);
                map.put("header", header);
                map.put("playerId", mPlayerId);

                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onSubtitleHeader(map);
                }
            }
        });

        player.setOnInfoListener(new IPlayer.OnInfoListener() {
            @Override
            public void onInfo(InfoBean infoBean) {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onInfo");
                map.put("infoCode", infoBean.getCode().getValue());
                map.put("extraValue", infoBean.getExtraValue());
                map.put("extraMsg", infoBean.getExtraMsg());
                map.put("playerId", mPlayerId);
//                mEventSink.success(map);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onInfo(map);
                }
            }
        });

        player.setOnErrorListener(new IPlayer.OnErrorListener() {
            @Override
            public void onError(ErrorInfo errorInfo) {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onError");
                map.put("errorCode", errorInfo.getCode().getValue());
                map.put("errorExtra", errorInfo.getExtra());
                map.put("errorMsg", errorInfo.getMsg());
                map.put("playerId", mPlayerId);
//                mEventSink.success(map);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onError(map);
                }
            }
        });

        player.setOnTrackReadyListener(new IPlayer.OnTrackReadyListener() {
            @Override
            public void onTrackReady(MediaInfo mediaInfo) {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onTrackReady");
                map.put("playerId", mPlayerId);
//                mEventSink.success(map);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onTrackReady(map);
                }
            }
        });

        player.setOnCompletionListener(new IPlayer.OnCompletionListener() {
            @Override
            public void onCompletion() {
                Map<String, Object> map = new HashMap<>();
                map.put("method", "onCompletion");
                map.put("playerId", mPlayerId);
//                mEventSink.success(map);
                if (mFlutterAliPlayerListener != null) {
                    mFlutterAliPlayerListener.onCompletion(map);
                }
            }
        });

        if (player instanceof AliLiveShiftPlayer) {
            ((AliLiveShiftPlayer) player).setOnTimeShiftUpdaterListener(new AliLiveShiftPlayer.OnTimeShiftUpdaterListener() {
                @Override
                public void onUpdater(long currentTime, long shiftStartTime, long shiftEndTime) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("method", "onUpdater");
                    map.put("currentTime", currentTime);
                    map.put("shiftStartTime", shiftStartTime);
                    map.put("shiftEndTime", shiftEndTime);
                    map.put("playerId", mPlayerId);
                    if (mFlutterAliPlayerListener != null) {
                        mFlutterAliPlayerListener.onTimeShiftUpdater(map);
                    }
                }
            });

            ((AliLiveShiftPlayer) player).setOnSeekLiveCompletionListener(new AliLiveShiftPlayer.OnSeekLiveCompletionListener() {
                @Override
                public void onSeekLiveCompletion(long playTime) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("method", "onSeekLiveCompletion");
                    map.put("playTime", playTime);
                    map.put("playerId", mPlayerId);
                    if (mFlutterAliPlayerListener != null) {
                        mFlutterAliPlayerListener.onSeekLiveCompletion(map);
                    }
                }
            });
        }

    }
}
