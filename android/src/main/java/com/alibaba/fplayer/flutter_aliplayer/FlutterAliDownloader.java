package com.alibaba.fplayer.flutter_aliplayer;

import android.content.Context;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.aliyun.downloader.AliDownloaderFactory;
import com.aliyun.downloader.AliMediaDownloader;
import com.aliyun.downloader.DownloaderConfig;
import com.aliyun.player.bean.ErrorInfo;
import com.aliyun.player.nativeclass.MediaInfo;
import com.aliyun.player.source.VidAuth;
import com.aliyun.player.source.VidSts;
import com.google.gson.Gson;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import com.aliyun.player.nativeclass.TrackInfo;

public class FlutterAliDownloader implements FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private static final String SEPARA_SYMBOLS = "_";
    private MethodChannel mMethodChannel;
    private EventChannel mEventChannel;
    private EventChannel.EventSink mEventSink;
    private Context mContext;
    private String mSavePath;
    private Map<String, AliMediaDownloader> mAliMediaDownloadMap = new HashMap<>();

    public FlutterAliDownloader(Context context, FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        this.mContext = context;
        this.mMethodChannel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "plugins.flutter_alidownload");
        this.mEventChannel = new EventChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "plugins.flutter_alidownload_event");
        this.mEventChannel.setStreamHandler(this);
        this.mMethodChannel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {
        switch (methodCall.method) {
            case "create":
                createMediaDownloader();
                break;
            case "prepare": {
                Map<String, Object> prepareMap = (Map<String, Object>) methodCall.arguments;
                Integer index = (Integer) prepareMap.get("index");
                String type = (String) prepareMap.get("type");
                String vid = (String) prepareMap.get("vid");
                String region = (String) prepareMap.get("region");
                if (type != null && type.equals("download_sts")) {
                    VidSts vidSts = new VidSts();
                    vidSts.setVid(vid);
                    vidSts.setRegion(region);
                    vidSts.setAccessKeyId((String) prepareMap.get("accessKeyId"));
                    vidSts.setAccessKeySecret((String) prepareMap.get("accessKeySecret"));
                    vidSts.setSecurityToken((String) prepareMap.get("securityToken"));
                    if (index == null) {
                        prepare(vidSts, result);
                    } else {
                        prepare(vidSts, index, result);
                    }

                } else if (type != null && type.equals("download_auth")) {
                    VidAuth vidAuth = new VidAuth();
                    vidAuth.setVid(vid);
                    vidAuth.setRegion(region);
                    vidAuth.setPlayAuth((String) prepareMap.get("playAuth"));
                    if (index == null) {
                        prepare(vidAuth, result);
                    } else {
                        prepare(vidAuth, index, result);
                    }
                }
//                result.success(null);
            }
            break;
            case "setSaveDir": {
                mSavePath = (String) methodCall.arguments;
                result.success(null);
            }
            break;
            case "selectItem": {
                Map<String, Object> selectItem = (Map<String, Object>) methodCall.arguments;
                String videoId = (String) selectItem.get("vid");
                Integer index = (Integer) selectItem.get("index");
                if (mAliMediaDownloadMap.containsKey(videoId)) {
                    AliMediaDownloader aliMediaDownloader = mAliMediaDownloadMap.get(videoId);
                    if (aliMediaDownloader != null) {
                        mAliMediaDownloadMap.remove(videoId);
                        mAliMediaDownloadMap.put(videoId + SEPARA_SYMBOLS + index, aliMediaDownloader);
                        selectItem(aliMediaDownloader, index);
                    }
                }
                result.success(null);
            }
            break;
            case "start": {
                Map<String, Object> startMap = (Map<String, Object>) methodCall.arguments;
                String videoId = (String) startMap.get("vid");
                Integer index = (Integer) startMap.get("index");
                AliMediaDownloader aliMediaDownloader = mAliMediaDownloadMap.get(videoId + SEPARA_SYMBOLS + index);
                if (aliMediaDownloader != null) {
                    aliMediaDownloader.setSaveDir(mSavePath);
                    start(aliMediaDownloader, startMap);
                }
                result.success(null);
            }
            break;
            case "stop": {
                Map<String, Object> stopMap = (Map<String, Object>) methodCall.arguments;
                String videoId = (String) stopMap.get("vid");
                Integer index = (Integer) stopMap.get("index");
                AliMediaDownloader aliMediaDownloader = mAliMediaDownloadMap.get(videoId + SEPARA_SYMBOLS + index);
                if (aliMediaDownloader != null) {
                    stop(aliMediaDownloader);
                }
                result.success(null);
            }
            break;
            case "delete": {
                Map<String, Object> deleteMap = (Map<String, Object>) methodCall.arguments;
                String videoId = (String) deleteMap.get("vid");
                Integer index = (Integer) deleteMap.get("index");
                AliMediaDownloader aliMediaDownloader = mAliMediaDownloadMap.get(videoId + SEPARA_SYMBOLS + index);
                if (aliMediaDownloader != null) {
                    delete(aliMediaDownloader);
                }
                result.success(null);
            }
            break;
            case "getFilePath": {
                Map<String, Object> getFilePathMap = (Map<String, Object>) methodCall.arguments;
                String videoId = (String) getFilePathMap.get("vid");
                Integer index = (Integer) getFilePathMap.get("index");
                AliMediaDownloader aliMediaDownloader = mAliMediaDownloadMap.get(videoId + SEPARA_SYMBOLS + index);
                if (aliMediaDownloader != null) {
                    String filePath = getFilePath(aliMediaDownloader);
                    getFilePathMap.put("savePath", filePath);
                    result.success(filePath);
                }
                result.success(null);
            }
            break;
            case "release": {
                Map<String, Object> releasMap = (Map<String, Object>) methodCall.arguments;
                String videoId = (String) releasMap.get("vid");
                Integer index = (Integer) releasMap.get("index");
                AliMediaDownloader aliMediaDownloader = mAliMediaDownloadMap.remove(videoId + SEPARA_SYMBOLS + index);
                if (aliMediaDownloader != null) {
                    release(aliMediaDownloader);
                }
                result.success(null);
            }
            break;
            case "updateSource": {
                Map<String, Object> updateSourceMap = (Map<String, Object>) methodCall.arguments;
                Integer index = (Integer) updateSourceMap.get("index");
                String type = (String) updateSourceMap.get("type");
                String vid = (String) updateSourceMap.get("vid");
                String region = (String) updateSourceMap.get("region");
                AliMediaDownloader aliMediaDownloader = mAliMediaDownloadMap.remove(vid + SEPARA_SYMBOLS + index);
                if (aliMediaDownloader != null) {
                    if (type != null && type.equals("download_sts")) {
                        VidSts vidSts = new VidSts();
                        vidSts.setVid(vid);
                        vidSts.setRegion(region);
                        vidSts.setAccessKeyId((String) updateSourceMap.get("accessKeyId"));
                        vidSts.setAccessKeySecret((String) updateSourceMap.get("accessKeySecret"));
                        vidSts.setSecurityToken((String) updateSourceMap.get("securityToken"));
                        updateSource(aliMediaDownloader, vidSts);

                    } else if (type != null && type.equals("download_auth")) {
                        VidAuth vidAuth = new VidAuth();
                        vidAuth.setVid(vid);
                        vidAuth.setRegion(region);
                        vidAuth.setPlayAuth((String) updateSourceMap.get("playAuth"));
                        updateSource(aliMediaDownloader, vidAuth);
                    }
                }
                result.success(null);
            }
            break;
            case "setDownloaderConfig": {
                Map<String, Object> downloadConfigMap = (Map<String, Object>) methodCall.arguments;
                String videoId = (String) downloadConfigMap.get("vid");
                Integer index = (Integer) downloadConfigMap.get("index");
                AliMediaDownloader aliMediaDownloader = mAliMediaDownloadMap.remove(videoId + SEPARA_SYMBOLS + index);
                if (aliMediaDownloader != null) {
                    DownloaderConfig downloaderConfig = new DownloaderConfig();
                    String mUserAgent = (String) downloadConfigMap.get("UserAgent");
                    downloaderConfig.mUserAgent = TextUtils.isEmpty(mUserAgent) ? "" : mUserAgent;

                    String mReferrer = (String) downloadConfigMap.get("Referrer");
                    downloaderConfig.mReferrer = TextUtils.isEmpty(mReferrer) ? "" : mReferrer;

                    String mHttpProxy = (String) downloadConfigMap.get("HttpProxy");
                    downloaderConfig.mHttpProxy = TextUtils.isEmpty(mHttpProxy) ? "" : mHttpProxy;

                    Integer mConnectTimeoutS = (Integer) downloadConfigMap.get("ConnectTimeoutS");
                    downloaderConfig.mConnectTimeoutS = mConnectTimeoutS == null ? 0 : mConnectTimeoutS;

                    Integer mNetworkTimeoutMs = (Integer) downloadConfigMap.get("NetworkTimeoutMs");
                    downloaderConfig.mNetworkTimeoutMs = mNetworkTimeoutMs == null ? 0 : mNetworkTimeoutMs;

                    setDownloaderConfig(aliMediaDownloader, downloaderConfig);
                }
                result.success(null);
            }
            break;
            default:
                break;
        }
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.mEventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
    }

    private void createMediaDownloader() {
        AliMediaDownloader aliMediaDownloader = AliDownloaderFactory.create(mContext);
    }

    private void prepare(VidAuth vidAuth, final int index, final MethodChannel.Result result) {
        AliMediaDownloader aliMediaDownloader = AliDownloaderFactory.create(mContext);
        mAliMediaDownloadMap.put(vidAuth.getVid(), aliMediaDownloader);
        final AliMediaDownloader finalAliMediaDownloader = aliMediaDownloader;
        aliMediaDownloader.setOnPreparedListener(new AliMediaDownloader.OnPreparedListener() {
            @Override
            public void onPrepared(MediaInfo mediaInfo) {
                Gson gson = new Gson();
                String mediaInfoJson = gson.toJson(mediaInfo);
                finalAliMediaDownloader.selectItem(index);
                mAliMediaDownloadMap.put(mediaInfo.getVideoId() + SEPARA_SYMBOLS + index, finalAliMediaDownloader);
                result.success(mediaInfoJson);
            }
        });

        aliMediaDownloader.setOnErrorListener(new AliMediaDownloader.OnErrorListener() {
            @Override
            public void onError(ErrorInfo errorInfo) {
                result.error(errorInfo.getCode().toString(), errorInfo.getMsg(), errorInfo.getExtra());
            }
        });
        aliMediaDownloader.prepare(vidAuth);
    }

    private void prepare(VidAuth vidAuth, final MethodChannel.Result result) {
        AliMediaDownloader aliMediaDownloader = AliDownloaderFactory.create(mContext);
        mAliMediaDownloadMap.put(vidAuth.getVid(), aliMediaDownloader);
        aliMediaDownloader.setOnPreparedListener(new AliMediaDownloader.OnPreparedListener() {
            @Override
            public void onPrepared(MediaInfo mediaInfo) {
                Gson gson = new Gson();
                String mediaInfoJson = gson.toJson(mediaInfo);
                List<TrackInfo> trackInfos = mediaInfo.getTrackInfos();
                result.success(mediaInfoJson);
            }
        });

        aliMediaDownloader.setOnErrorListener(new AliMediaDownloader.OnErrorListener() {
            @Override
            public void onError(ErrorInfo errorInfo) {
                result.error(errorInfo.getCode().toString(), errorInfo.getMsg(), errorInfo.getExtra());
            }
        });

        aliMediaDownloader.prepare(vidAuth);
    }

    private void prepare(VidSts vidSts, final int index, final MethodChannel.Result result) {
        AliMediaDownloader aliMediaDownloader = AliDownloaderFactory.create(mContext);
        mAliMediaDownloadMap.put(vidSts.getVid(), aliMediaDownloader);
        final AliMediaDownloader finalAliMediaDownloader = aliMediaDownloader;
        aliMediaDownloader.setOnPreparedListener(new AliMediaDownloader.OnPreparedListener() {
            @Override
            public void onPrepared(MediaInfo mediaInfo) {
                Gson gson = new Gson();
                String mediaInfoJson = gson.toJson(mediaInfo);
                finalAliMediaDownloader.selectItem(index);
                mAliMediaDownloadMap.put(mediaInfo.getVideoId() + SEPARA_SYMBOLS + index, finalAliMediaDownloader);
                result.success(mediaInfoJson);
            }
        });

        aliMediaDownloader.setOnErrorListener(new AliMediaDownloader.OnErrorListener() {
            @Override
            public void onError(ErrorInfo errorInfo) {
                result.error(errorInfo.getCode().toString(), errorInfo.getMsg(), errorInfo.getExtra());
            }
        });
        aliMediaDownloader.prepare(vidSts);
    }

    private void prepare(VidSts vidSts, final MethodChannel.Result result) {
        AliMediaDownloader aliMediaDownloader = AliDownloaderFactory.create(mContext);
        mAliMediaDownloadMap.put(vidSts.getVid(), aliMediaDownloader);
        aliMediaDownloader.setOnPreparedListener(new AliMediaDownloader.OnPreparedListener() {
            @Override
            public void onPrepared(MediaInfo mediaInfo) {
                Gson gson = new Gson();
                String mediaInfoJson = gson.toJson(mediaInfo);
                result.success(mediaInfoJson);
            }
        });

        aliMediaDownloader.setOnErrorListener(new AliMediaDownloader.OnErrorListener() {
            @Override
            public void onError(ErrorInfo errorInfo) {
                result.error(errorInfo.getCode().toString(), errorInfo.getMsg(), errorInfo.getExtra());
            }
        });

        aliMediaDownloader.prepare(vidSts);
    }

    private void start(final AliMediaDownloader aliMediaDownloader, final Map<String, Object> startMap) {
        aliMediaDownloader.setOnErrorListener(new AliMediaDownloader.OnErrorListener() {
            @Override
            public void onError(ErrorInfo errorInfo) {
                startMap.put("method", "download_error");
                startMap.put("errorCode", errorInfo.getCode() + "");
                startMap.put("errorMsg", errorInfo.getMsg());
                mEventSink.success(startMap);
            }
        });

        aliMediaDownloader.setOnProgressListener(new AliMediaDownloader.OnProgressListener() {
            @Override
            public void onDownloadingProgress(int i) {
                startMap.put("method", "download_progress");
                startMap.put("download_progress", i + "");
                mEventSink.success(startMap);
            }

            @Override
            public void onProcessingProgress(int i) {
                startMap.put("method", "download_process");
                startMap.put("download_process", i + "");
                mEventSink.success(startMap);
            }
        });

        aliMediaDownloader.setOnCompletionListener(new AliMediaDownloader.OnCompletionListener() {
            @Override
            public void onCompletion() {
                startMap.put("method", "download_completion");
                startMap.put("savePath", aliMediaDownloader.getFilePath());
                mEventSink.success(startMap);
            }
        });
        aliMediaDownloader.start();
    }

    private void selectItem(AliMediaDownloader aliMediaDownloader, int index) {
        aliMediaDownloader.selectItem(index);
    }

    private void stop(AliMediaDownloader aliMediaDownloader) {
        aliMediaDownloader.stop();
    }

    private void delete(AliMediaDownloader aliMediaDownloader) {

        aliMediaDownloader.deleteFile();
    }

    private void release(AliMediaDownloader aliMediaDownloader) {
        aliMediaDownloader.release();
    }

    private void setSaveDir(AliMediaDownloader aliMediaDownloader, String path) {
        aliMediaDownloader.setSaveDir(path);
    }

    private String getFilePath(AliMediaDownloader aliMediaDownloader) {
        return aliMediaDownloader.getFilePath();
    }

    private void updateSource(AliMediaDownloader aliMediaDownloader, VidSts vidSts) {
        aliMediaDownloader.updateSource(vidSts);
    }

    private void updateSource(AliMediaDownloader aliMediaDownloader, VidAuth vidAuth) {
        aliMediaDownloader.updateSource(vidAuth);
    }

    private void setDownloaderConfig(AliMediaDownloader aliMediaDownloader, DownloaderConfig downloaderConfig) {
        aliMediaDownloader.setDownloaderConfig(downloaderConfig);
    }


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {

    }
}
