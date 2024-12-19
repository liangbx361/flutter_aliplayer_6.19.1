package com.alibaba.fplayer.flutter_aliplayer;

import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.aliyun.player.AliPlayerFactory;
import com.aliyun.player.AliPlayerGlobalSettings;
import com.aliyun.player.IPlayer;
import com.aliyun.player.VidPlayerConfigGen;
import com.aliyun.private_service.PrivateService;
import com.cicada.player.utils.Logger;

import java.util.HashMap;
import java.util.Map;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

/**
 * FlutterAliplayerPlugin
 */
public class FlutterAliplayerPlugin extends PlatformViewFactory implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, FlutterAliPlayerView.FlutterAliPlayerViewListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private FlutterAliDownloader mAliyunDownload;
    private FlutterAliPlayerGlobalSettings mAliPlayerGlobalSettings;
    private FlutterAliMediaLoader mAliyunMediaLoader;
    private FlutterPluginBinding flutterPluginBinding;
    private FlutterAliListPlayer mFlutterAliListPlayer;
    private Map<String, FlutterAliPlayer> mFlutterAliPlayerMap = new HashMap<>();
    private Map<String, FlutterAliLiveShiftPlayer> mFlutterAliLiveShiftPlayerMap = new HashMap<>();
    private Map<Integer, FlutterAliPlayerView> mFlutterAliPlayerViewMap = new HashMap<>();
    private EventChannel.EventSink mEventSink;
    private EventChannel mEventChannel;
    private Integer playerType = -1;

    private Handler mMainHandler = new Handler(Looper.getMainLooper());
    private FlutterAliFloatWindowManager flutterAliFloatWindowManager;
    private VidPlayerConfigGen mVidPlayerConfigGen;

    public FlutterAliplayerPlugin() {
        super(StandardMessageCodec.INSTANCE);
    }


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        this.flutterPluginBinding = flutterPluginBinding;
        flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("flutter_aliplayer_render_view", this);
        mAliyunDownload = new FlutterAliDownloader(flutterPluginBinding.getApplicationContext(), flutterPluginBinding);
        mAliyunMediaLoader = new FlutterAliMediaLoader(flutterPluginBinding.getApplicationContext(), flutterPluginBinding);
        mAliPlayerGlobalSettings = new FlutterAliPlayerGlobalSettings(flutterPluginBinding.getApplicationContext(), flutterPluginBinding);
        MethodChannel mAliPlayerFactoryMethodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "plugins.flutter_aliplayer_factory");
        mAliPlayerFactoryMethodChannel.setMethodCallHandler(this);
        mEventChannel = new EventChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_aliplayer_event");
        mEventChannel.setStreamHandler(this);

        flutterAliFloatWindowManager = new FlutterAliFloatWindowManager(flutterPluginBinding.getApplicationContext());

        AliPlayerGlobalSettings.setCacheUrlHashCallback(new AliPlayerGlobalSettings.OnGetUrlHashCallback() {
            @Override
            public String getUrlHashCallback(String s) {
                String result = s;
                if (s.contains("?")) {
                    String[] split = s.split("\\?");
                    result = split[0];
                }
                System.out.println("java urlHashCallback " + s);
                return FlutterAliPlayerStringUtils.stringToMD5(result);
            }
        });
    }

    //   This static function is optional and equivalent to onAttachedToEngine. It supports the old
//   pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
//   plugin registration via this function while apps migrate to use the new Android APIs
//   post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
//
//   It is encouraged to share logic between onAttachedToEngine and registerWith to keep
//   them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
//   depending on the user's project. onAttachedToEngine or registerWith must both be defined
//   in the same class.
    public static void registerWith(Registrar registrar) {
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "showFloatViewForAndroid":
                int showFloatViewId = (int) call.arguments;
                FlutterAliPlayerView showFlutterAliPlayerView = mFlutterAliPlayerViewMap.get(showFloatViewId);
                flutterAliFloatWindowManager.showFloatWindow(showFlutterAliPlayerView);
                result.success(null);
                break;
            case "hideFloatViewForAndroid":
                flutterAliFloatWindowManager.hideFloatWindow();
                result.success(null);
                break;
            case "createAliPlayer":
                playerType = call.argument("arg");
                if (0 == playerType) {
                    //AliPlayer
                    String createPlayerId = call.argument("playerId");
                    FlutterAliPlayer flutterAliPlayer = new FlutterAliPlayer(flutterPluginBinding, createPlayerId);
                    initListener(flutterAliPlayer);
                    mFlutterAliPlayerMap.put(createPlayerId, flutterAliPlayer);
                } else if (1 == playerType) {
                    //AliListPlayer
                    mFlutterAliListPlayer = new FlutterAliListPlayer(flutterPluginBinding);
                    initListener(mFlutterAliListPlayer);
                } else if (2 == playerType) {
                    //AliLiveShiftPlayer
                    String createPlayerId = call.argument("playerId");
                    FlutterAliLiveShiftPlayer flutterAliLiveShiftPlayer = new FlutterAliLiveShiftPlayer(flutterPluginBinding, createPlayerId);
                    initListener(flutterAliLiveShiftPlayer);
                    mFlutterAliLiveShiftPlayerMap.put(createPlayerId, flutterAliLiveShiftPlayer);
                } else {

                }

                result.success(null);
                break;
            case "initService":
                byte[] datas = (byte[]) call.arguments;
                PrivateService.initService(flutterPluginBinding.getApplicationContext(), datas);
                result.success(null);
                break;
            case "loadRtsLibrary":
                Boolean isAliPlayerSDK = (Boolean) call.arguments;
                if (isAliPlayerSDK) {
                    System.loadLibrary("RtsSDK");
                }
                result.success(null);
                break;
            case "getSDKVersion":
                result.success(AliPlayerFactory.getSdkVersion());
                break;
            case "getDeviceUUID":
                result.success(AliPlayerFactory.getDeviceUUID());
                break;
            case "getLogLevel":
                result.success(getLogLevel());
                break;
            case "enableConsoleLog":
                Boolean enableLog = (Boolean) call.arguments;
                enableConsoleLog(enableLog);
                result.success(null);
                break;
            case "setLogLevel":
                Integer level = (Integer) call.arguments;
                setLogLevel(level);
                result.success(null);
                break;
            case "createDeviceInfo":
                result.success(createDeviceInfo());
                break;
            case "addBlackDevice":
                Map<String, String> addBlackDeviceMap = call.arguments();
                String blackType = addBlackDeviceMap.get("black_type");
                String blackDevice = addBlackDeviceMap.get("black_device");
                addBlackDevice(blackType, blackDevice);
                result.success(null);
                break;
            case "setPlayerView":
                Integer viewId = (Integer) call.argument("arg");
                FlutterAliPlayerView flutterAliPlayerView = mFlutterAliPlayerViewMap.get(viewId);

                if (playerType == 0) {
                    String setPlayerViewPlayerId = call.argument("playerId");
                    FlutterAliPlayer mSetPlayerViewCurrentFlutterAliPlayer = mFlutterAliPlayerMap.get(setPlayerViewPlayerId);
//                    if(mSetPlayerViewCurrentFlutterAliPlayer != null){
//                        mSetPlayerViewCurrentFlutterAliPlayer.setViewMap(mFlutterAliPlayerViewMap);
//                    }
                    if (flutterAliPlayerView != null && mSetPlayerViewCurrentFlutterAliPlayer != null) {
                        flutterAliPlayerView.setPlayer(mSetPlayerViewCurrentFlutterAliPlayer.getAliPlayer());
                    }
                } else if (playerType == 1) {
//                    mFlutterAliListPlayer.setViewMap(mFlutterAliPlayerViewMap);
                    if (flutterAliPlayerView != null && mFlutterAliListPlayer != null) {
                        flutterAliPlayerView.setPlayer(mFlutterAliListPlayer.getAliPlayer());
                    }
                } else if (playerType == 2) {
                    String setPlayerViewPlayerId = call.argument("playerId");
                    FlutterAliLiveShiftPlayer mSetPlayerViewCurrentFlutterAliLiveShiftPlayer = mFlutterAliLiveShiftPlayerMap.get(setPlayerViewPlayerId);
                    if (flutterAliPlayerView != null && mSetPlayerViewCurrentFlutterAliLiveShiftPlayer != null) {
                        flutterAliPlayerView.setPlayer(mSetPlayerViewCurrentFlutterAliLiveShiftPlayer.getAliPlayer());
                    }
                }
                break;
            case "setUseHttp2":
                Boolean enableUseHttp2 = call.arguments();
                AliPlayerGlobalSettings.setUseHttp2(enableUseHttp2);
                break;
            case "enableHttpDns":
                Boolean enableHttpDns = call.arguments();
                AliPlayerGlobalSettings.enableHttpDns(enableHttpDns);
                break;
            case "setDNSResolve":
                Map<String, String> dnsResolveMap = call.arguments();
                if (dnsResolveMap != null) {
                    String dnsResolveHost = dnsResolveMap.get("host");
                    String dnsResolveIP = dnsResolveMap.get("ip");
                    AliPlayerGlobalSettings.setDNSResolve(dnsResolveHost, dnsResolveIP);
                }
                result.success(null);
                break;
            case "enableNetworkBalance":
                Boolean enableNetworkBalance = call.arguments();
                AliPlayerGlobalSettings.enableNetworkBalance(enableNetworkBalance);
                result.success(null);
                break;
            case "enableLocalCache":
                Map<String, Object> localCacheMap = call.arguments();
                if (localCacheMap != null) {
                    Boolean enable = (Boolean) localCacheMap.get("enable");
                    String maxBufferMemoryKB = (String) localCacheMap.get("maxBufferMemoryKB");
                    String localCacheDir = (String) localCacheMap.get("localCacheDir");
                    AliPlayerGlobalSettings.enableLocalCache(enable, Integer.valueOf(maxBufferMemoryKB), localCacheDir);
                }
                break;
            case "setCacheFileClearConfig":
                Map<String, Object> cacheFileClearConfig = call.arguments();
                if (cacheFileClearConfig != null) {
                    String expireMin = (String) cacheFileClearConfig.get("expireMin");
                    String maxCapacityMB = (String) cacheFileClearConfig.get("maxCapacityMB");
                    String freeStorageMB = (String) cacheFileClearConfig.get("freeStorageMB");
                    AliPlayerGlobalSettings.setCacheFileClearConfig(Long.parseLong(expireMin), Long.parseLong(maxCapacityMB), Long.parseLong(freeStorageMB));
                }
                break;
            case "clearCaches":
                AliPlayerGlobalSettings.clearCaches();
                break;
            case "isFeatureSupport":
                result.success(AliPlayerFactory.isFeatureSupport(AliPlayerFactory.SupportFeatureType.FeatureDolbyAudio));
                break;
            case "setIPResolveType":
                String setIPResolveTypeStr = call.arguments() == null ? "" : (String) call.arguments();
                switch (setIPResolveTypeStr) {
                    case "v4":
                        AliPlayerGlobalSettings.setIPResolveType(IPlayer.IPResolveType.IpResolveV4);
                        break;
                    case "v6":
                        AliPlayerGlobalSettings.setIPResolveType(IPlayer.IPResolveType.IpResolveV6);
                        break;
                    default:
                        AliPlayerGlobalSettings.setIPResolveType(IPlayer.IPResolveType.IpResolveWhatEver);
                        break;
                }
                break;
            case "forceAudioRendingFormat":
                Map<String, Object> forceAudioRendingFormat = call.arguments();
                Boolean force = Boolean.getBoolean((String) forceAudioRendingFormat.get("force"));
                String fmt = (String) forceAudioRendingFormat.get("fmt");
                Integer channels = Integer.valueOf((String) forceAudioRendingFormat.get("channels"));
                Integer sample_rate = Integer.valueOf((String) forceAudioRendingFormat.get("sample_rate"));
                AliPlayerGlobalSettings.forceAudioRendingFormat(force, fmt, channels, sample_rate);
                break;
            case "createVidPlayerConfigGenerator":
                mVidPlayerConfigGen = new VidPlayerConfigGen();
                result.success(null);
                break;
            case "setPreviewTime":
                String setPreviewTime = call.arguments();
                if (mVidPlayerConfigGen != null && !TextUtils.isEmpty(setPreviewTime)) {
                    mVidPlayerConfigGen.setPreviewTime(Integer.parseInt(setPreviewTime));
                }
                result.success(null);
                break;
            case "setHlsUriToken":
                String setHlsUriToken = call.arguments();
                if (mVidPlayerConfigGen != null) {
                    mVidPlayerConfigGen.setMtsHlsUriToken(setHlsUriToken);
                }
                result.success(null);
                break;
            case "addVidPlayerConfigByStringValue":

            case "addVidPlayerConfigByIntValue":
                Map<String, String> addVidPlayerConfigByStringValue = (Map<String, String>) call.arguments;
                if (mVidPlayerConfigGen != null) {
                    for (String s : addVidPlayerConfigByStringValue.keySet()) {
                        mVidPlayerConfigGen.addPlayerConfig(s, addVidPlayerConfigByStringValue.get(s));
                    }
                }
                result.success(null);
                break;
            case "setEncryptType":
                int encryptType = (int) call.arguments;
                if (mVidPlayerConfigGen != null) {
                    mVidPlayerConfigGen.setEncryptType(VidPlayerConfigGen.EncryptType.values()[encryptType]);
                }
                result.success(null);
                break;
            case "generatePlayerConfig":
                String generatePlayerConfig = mVidPlayerConfigGen.genConfig();
                result.success(generatePlayerConfig);
                break;
            default:
                String otherPlayerId = call.argument("playerId");
                if (mFlutterAliPlayerMap.containsKey(otherPlayerId)) {
                    String playerId = call.argument("playerId");
                    FlutterAliPlayer mCurrentFlutterAliPlayer = mFlutterAliPlayerMap.get(playerId);
                    if (call.method.equals("destroy")) {
                        mFlutterAliPlayerMap.remove(playerId);
                    }
                    if (mCurrentFlutterAliPlayer != null) {
                        mCurrentFlutterAliPlayer.onMethodCall(call, result);
                    }
                } else if (mFlutterAliLiveShiftPlayerMap.containsKey(otherPlayerId)) {
//                    String playerId = call.argument("playerId");
                    FlutterAliLiveShiftPlayer mCurrentFlutterAliLiveShiftPlayer = mFlutterAliLiveShiftPlayerMap.get(otherPlayerId);
                    if (call.method.equals("destroy")) {
                        mFlutterAliLiveShiftPlayerMap.remove(otherPlayerId);
                    }
                    if (mCurrentFlutterAliLiveShiftPlayer != null) {
                        mCurrentFlutterAliLiveShiftPlayer.onMethodCall(call, result);
                    }
                } else {
                    if (mFlutterAliListPlayer != null) {
                        mFlutterAliListPlayer.onMethodCall(call, result);
                    }
                }
                break;
        }
    }

    private Integer getLogLevel() {
        return Logger.getInstance(flutterPluginBinding.getApplicationContext()).getLogLevel().getValue();
    }

    private String createDeviceInfo() {
        AliPlayerFactory.DeviceInfo deviceInfo = new AliPlayerFactory.DeviceInfo();
        deviceInfo.model = Build.MODEL;
        return deviceInfo.model;
    }

    private void addBlackDevice(String blackType, String modelInfo) {
        AliPlayerFactory.DeviceInfo deviceInfo = new AliPlayerFactory.DeviceInfo();
        deviceInfo.model = modelInfo;
        AliPlayerFactory.BlackType aliPlayerBlackType;
        if (!TextUtils.isEmpty(blackType) && blackType.equals("HW_Decode_H264")) {
            aliPlayerBlackType = AliPlayerFactory.BlackType.HW_Decode_H264;
        } else {
            aliPlayerBlackType = AliPlayerFactory.BlackType.HW_Decode_HEVC;
        }
        AliPlayerFactory.addBlackDevice(aliPlayerBlackType, deviceInfo);
    }

    private void enableConsoleLog(Boolean enableLog) {
        Logger.getInstance(flutterPluginBinding.getApplicationContext()).enableConsoleLog(enableLog);
    }

    private void setLogLevel(int level) {
        Logger.LogLevel mLogLevel;
        if (level == Logger.LogLevel.AF_LOG_LEVEL_NONE.getValue()) {
            mLogLevel = Logger.LogLevel.AF_LOG_LEVEL_NONE;
        } else if (level == Logger.LogLevel.AF_LOG_LEVEL_FATAL.getValue()) {
            mLogLevel = Logger.LogLevel.AF_LOG_LEVEL_FATAL;
        } else if (level == Logger.LogLevel.AF_LOG_LEVEL_ERROR.getValue()) {
            mLogLevel = Logger.LogLevel.AF_LOG_LEVEL_ERROR;
        } else if (level == Logger.LogLevel.AF_LOG_LEVEL_WARNING.getValue()) {
            mLogLevel = Logger.LogLevel.AF_LOG_LEVEL_WARNING;
        } else if (level == Logger.LogLevel.AF_LOG_LEVEL_INFO.getValue()) {
            mLogLevel = Logger.LogLevel.AF_LOG_LEVEL_INFO;
        } else if (level == Logger.LogLevel.AF_LOG_LEVEL_DEBUG.getValue()) {
            mLogLevel = Logger.LogLevel.AF_LOG_LEVEL_DEBUG;
        } else if (level == Logger.LogLevel.AF_LOG_LEVEL_TRACE.getValue()) {
            mLogLevel = Logger.LogLevel.AF_LOG_LEVEL_TRACE;
        } else {
            mLogLevel = Logger.LogLevel.AF_LOG_LEVEL_NONE;
        }
        Logger.getInstance(flutterPluginBinding.getApplicationContext()).setLogLevel(mLogLevel);
    }

    /**
     * 设置监听
     */
    private void initListener(FlutterPlayerBase flutterPlayerBase) {
        flutterPlayerBase.setOnFlutterListener(new FlutterAliPlayerListener() {
            @Override
            public void onPrepared(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onTrackReady(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onCompletion(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onRenderingStart(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onVideoSizeChanged(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onVideoRendered(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onSnapShot(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onTrackChangedSuccess(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onTrackChangedFail(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onSeekComplete(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onSeiData(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onLoadingBegin(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onLoadingProgress(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onLoadingEnd(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onStateChanged(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onSubtitleExtAdded(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onSubtitleShow(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onSubtitleHide(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onSubtitleHeader(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onInfo(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onError(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onThumbnailPrepareSuccess(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onThumbnailPrepareFail(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onThumbnailGetSuccess(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onThumbnailGetFail(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onTimeShiftUpdater(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onSeekLiveCompletion(Map<String, Object> map) {
                mEventSink.success(map);
            }

            @Override
            public void onReportEventListener(final Map<String, Object> map) {
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        mEventSink.success(map);
                    }
                });
            }

            @Override
            public int onChooseTrackIndex(Map<String, Object> map) {
                mEventSink.success(map);
                return 0;
            }

        });
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        FlutterAliPlayerView flutterAliPlayerView = new FlutterAliPlayerView(context, viewId, args);
        flutterAliPlayerView.setFlutterAliPlayerViewListener(this);
        mFlutterAliPlayerViewMap.put(viewId, flutterAliPlayerView);
        return flutterAliPlayerView;
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.mEventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
    }

    @Override
    public void onDispose(int viewId) {
        mFlutterAliPlayerViewMap.remove(viewId);
    }
}
