package com.alibaba.fplayer.flutter_aliplayer;

import android.content.Context;

import androidx.annotation.NonNull;

import com.aliyun.aio.aio_env.AlivcEnv;
import com.aliyun.common.AlivcBase;
import com.aliyun.player.AliPlayerGlobalSettings;

import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * @author junhuiYe
 * @date 2024/11/19
 * @brief
 */
public class FlutterAliPlayerGlobalSettings implements FlutterPlugin, MethodChannel.MethodCallHandler{
    private MethodChannel mMethodChannel;
    private EventChannel.EventSink mEventSink;
    private Context mContext;

    public FlutterAliPlayerGlobalSettings(Context context, FlutterPlugin.FlutterPluginBinding flutterPluginBinding){
        this.mContext = context;
        this.mMethodChannel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "plugins.flutter_global_setting");
        this.mMethodChannel.setMethodCallHandler(this);
    }
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method){
            case "setGlobalEnvironment":
                int config = (int) call.arguments();
                setGlobalEnvironment(config);
                result.success(null);
                break;
            case "setOption":
                Map<String, Object> optionMaps = call.arguments();
                Integer opt1 = (Integer) optionMaps.get("opt1");
                Object opt2 = (Object) optionMaps.get("opt2");
                setOption(opt1,opt2);
                result.success(null);
                break;
            case "disableCrashUpload":
                Boolean disableCrashUpload = call.arguments();
                AliPlayerGlobalSettings.disableCrashUpload(disableCrashUpload);
                break;
            case "enableEnhancedHttpDns":
                Boolean enableEnhancedHttpDns = call.arguments();
                AliPlayerGlobalSettings.enableEnhancedHttpDns(enableEnhancedHttpDns);
                break;
            default:
                break;
        }
    }

    private void setOption(int opt1, Object opt2) {
            if (opt2 instanceof Integer) {
                AliPlayerGlobalSettings.setOption(opt1, (Integer) opt2);
            } else if (opt2 instanceof String) {
                AliPlayerGlobalSettings.setOption(opt1, (String) opt2);
            }
        }

    private void setGlobalEnvironment(int GlobalEnv) {
        switch (GlobalEnv) {
            case 1:
                AlivcBase.getEnvironmentManager().setGlobalEnvironment(AlivcEnv.GlobalEnv.ENV_CN);
                break;
            case 2:
                AlivcBase.getEnvironmentManager().setGlobalEnvironment(AlivcEnv.GlobalEnv.ENV_SEA);
                break;
            default:
                AlivcBase.getEnvironmentManager().setGlobalEnvironment(AlivcEnv.GlobalEnv.ENV_GLOBAL_DEFAULT);
                break;
        }
    }
}
