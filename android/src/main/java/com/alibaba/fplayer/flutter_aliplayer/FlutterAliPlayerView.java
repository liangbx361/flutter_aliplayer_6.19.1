package com.alibaba.fplayer.flutter_aliplayer;

import android.content.Context;
import android.graphics.SurfaceTexture;
import android.os.Handler;
import android.os.Message;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.TextureView;
import android.view.View;

import androidx.annotation.NonNull;

import com.aliyun.player.AliListPlayer;
import com.aliyun.player.IPlayer;

import java.lang.ref.WeakReference;
import java.util.Map;

import io.flutter.plugin.platform.PlatformView;


public class FlutterAliPlayerView implements PlatformView {

    private static final String SURFACE_VIEW_TYPE = "surfaceview";
    private static final String TEXTURE_VIEW_TYPE = "textureview";
    private Context mContext;
    private IPlayer mPlayer;
    private int mViewId;

    private SurfaceView mSurfaceView;
    private TextureView mTextureView;
    private SurfaceHolder mSurfaceHolder;

    private Surface mSurface;

    private String viewType = SURFACE_VIEW_TYPE;
    private View flutterAttachedView;

    public FlutterAliPlayerView(Context context, int viewId, Object args) {
        if (args != null) {
            Map<String, Object> argsMap = (Map<String, Object>) args;
            viewType = (String) argsMap.get("viewType");
        }
        this.mViewId = viewId;
        this.mContext = context;
        if (isTextureView()) {
            mTextureView = new TextureView(mContext);
            initRenderView(mTextureView);
        } else {
            mSurfaceView = new SurfaceView(mContext);
            initRenderView(mSurfaceView);
        }
    }

    public IPlayer getPlayer() {
        return mPlayer;
    }

    public void setPlayer(IPlayer player) {
        this.mPlayer = player;
        setRenderView();
    }

    public boolean isTextureView() {
        return TEXTURE_VIEW_TYPE.equals(viewType);
    }

    @Override
    public View getView() {
        if (isTextureView()) {
            return mTextureView;
        } else {
            return mSurfaceView;
        }
    }

    @Override
    public void dispose() {
        if (mFlutterAliPlayerViewListener != null) {
            mFlutterAliPlayerViewListener.onDispose(mViewId);
        }
        mSurfaceHolder = null;
    }

    private void initRenderView(SurfaceView surfaceView) {

        if (!isTextureView() && surfaceView != null) {
            surfaceView.getHolder().addCallback(new SurfaceHolder.Callback() {
                @Override
                public void surfaceCreated(@NonNull SurfaceHolder surfaceHolder) {
                    mSurfaceHolder = surfaceHolder;
                    setRenderView();
                }

                @Override
                public void surfaceChanged(@NonNull SurfaceHolder surfaceHolder, int i, int i1, int i2) {
                    if (mPlayer != null) {
                        mPlayer.surfaceChanged();
                    }
                }

                @Override
                public void surfaceDestroyed(@NonNull SurfaceHolder surfaceHolder) {
                    if (mPlayer instanceof AliListPlayer) {
                        /*
                            当使用 pageView 实现列表播放时，会出现画面卡主，声音正常的问题。
                            原因：滑动到下一个界面后，先设置 Surface 给 ListPlayer，然后上一个
                                Surface 销毁，setSurface(null);
                            部分手机如果不设置为 null，多次调用 setSurface 会导致崩溃。因此在 handler
                            的事件里，先设置为 null，再设置 Surface.
                         */
                    } else {
                        if(null==mPlayer)return;
                        mPlayer.setSurface(null);
                    }
                }
            });
        }
    }

    private void initRenderView(TextureView surfaceView) {

        if (surfaceView != null && TEXTURE_VIEW_TYPE.equals(viewType)) {

            surfaceView.setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {
                @Override
                public void onSurfaceTextureAvailable(@NonNull SurfaceTexture surfaceTexture, int i, int i1) {
                    mSurface = new Surface(surfaceTexture);
                    setRenderView();
                }

                @Override
                public void onSurfaceTextureSizeChanged(@NonNull SurfaceTexture surfaceTexture, int i, int i1) {

                }

                @Override
                public boolean onSurfaceTextureDestroyed(@NonNull SurfaceTexture surfaceTexture) {
                    mSurface = null;
                    if (mPlayer instanceof AliListPlayer) {
                        /*
                            当使用 pageView 实现列表播放时，会出现画面卡主，声音正常的问题。
                            原因：滑动到下一个界面后，先设置 Surface 给 ListPlayer，然后上一个
                                Surface 销毁，setSurface(null);
                            部分手机如果不设置为 null，多次调用 setSurface 会导致崩溃。因此在 handler
                            的事件里，先设置为 null，再设置 Surface.
                         */
                    } else {
                        if(null==mPlayer)return false;
                        mPlayer.setSurface(null);
                    }
                    return false;
                }

                @Override
                public void onSurfaceTextureUpdated(@NonNull SurfaceTexture surfaceTexture) {

                }
            });
        }
    }

    public void setRenderView() {
        if (isTextureView()) {
            if (null != mPlayer && null != mSurface) {
                mPlayer.setSurface(mSurface);
            }
        } else {
            if (null != mPlayer && null != mSurfaceHolder&&null!=mSurfaceHolder.getSurface()) {
                mPlayer.setSurface(mSurfaceHolder.getSurface());
            }
        }
    }

    public interface FlutterAliPlayerViewListener {
        void onDispose(int viewId);
    }

    private FlutterAliPlayerViewListener mFlutterAliPlayerViewListener;

    public void setFlutterAliPlayerViewListener(FlutterAliPlayerViewListener listener) {
        this.mFlutterAliPlayerViewListener = listener;
    }

}