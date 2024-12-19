package com.alibaba.fplayer.flutter_aliplayer;

import android.content.Context;

import androidx.annotation.NonNull;

import com.aliyun.loader.MediaLoader;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FlutterAliMediaLoader implements FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private Context mContext;
    private MethodChannel mMethodChannel;
    private EventChannel.EventSink mEventSink;
    private EventChannel mEventChannel;
    private final MediaLoader mMediaLoader;

    public FlutterAliMediaLoader(Context context, FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        this.mContext = context;
        mMediaLoader = MediaLoader.getInstance();
        this.mMethodChannel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "plugins.flutter_aliplayer_media_loader");
        mMethodChannel.setMethodCallHandler(this);

        mEventChannel = new EventChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_aliplayer_media_loader_event");
        mEventChannel.setStreamHandler(this);

        mMediaLoader.setOnLoadStatusListener(new MediaLoader.OnLoadStatusListener() {
            @Override
            public void onError(String url, int code, String msg) {
                Map<String, String> resultMap = new HashMap<>();
                resultMap.put("method", "onError");
                resultMap.put("url", url);
                resultMap.put("code", String.valueOf(code));
                resultMap.put("msg", msg);
                mEventSink.success(resultMap);
            }

            @Override
            public void onCompleted(String url) {
                Map<String, String> resultMap = new HashMap<>();
                resultMap.put("method", "onCompleted");
                resultMap.put("url", url);
                mEventSink.success(resultMap);
            }

            @Override
            public void onCanceled(String url) {
                Map<String, String> resultMap = new HashMap<>();
                resultMap.put("method", "onCanceled");
                resultMap.put("url", url);
                mEventSink.success(resultMap);
            }
        });
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "load":
                Map<String, String> loadMap = call.arguments();
                String url = loadMap.get("url");
                String duration = loadMap.get("duration");
                mMediaLoader.load(url, Long.valueOf(duration));
                break;
            case "resume":
                String resumeUrl = call.arguments();
                mMediaLoader.resume(resumeUrl);
                break;
            case "pause":
                String pauseUrl = call.arguments();
                mMediaLoader.pause(pauseUrl);
                break;
            case "cancel":
                String cancelUrl = call.arguments();
                mMediaLoader.cancel(cancelUrl);
                break;
        }
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {

    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.mEventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {

    }
}