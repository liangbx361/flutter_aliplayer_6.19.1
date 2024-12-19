## 6.19.0
----------------------------------
1. 更新 Native SDK 至 6.19.0
2. 新增ios画中画状态监听及按钮透出
3. 增加abr升路上限功能
4. 修复部分已知问题

## 6.18.0
----------------------------------
1. 更新 Native SDK 至 6.18.0
2. 新增预渲染功能
3. 修复部分已知问题，加快首帧渲染显示

## 6.17.0
----------------------------------
1. 更新 Native SDK 至 6.17.0，使用独立SDK（AliPlayerSDK）代替一体化SDK（AliVCSDK_InteractiveLive），提供useAIOFramework开关支持SDK内核切换

## 6.7.0
----------------------------------
1. 更新 Native SDK 至 6.7.0
2. 解决与推流插件 flutter_livepush_plugin 冲突问题，使用一体化SDK（AliVCSDK_InteractiveLive）代替独立SDK（AliPlayerSDK）

## 5.5.6
----------------------------------
1. 更新播放器 SDK 至 5.5.6.0，并增加对应 SDK 接口
2. Demo 增加水印，打点，缩略图，画中画等功能

## 5.4.10
----------------------------------
1. 修复 Android 创建 ListPlayer 出现错误日志问题
2. 修复 Android 调用截图接口，在图片未完全保存到本地时，回调截图成功问题
3. iOS 增加接口，用于下载后获取全路径
4. AliPlayerView 增加 aliPlayerViewType 属性，用于指定渲染 View 的类型(仅对 Android 有效)
5. Android 适配低版本 SDK 运行报错问题
6. iOS 修改为本地集成播放器原生SDK

## 5.4.9-dev.1.3
----------------------------------
1. iOS 修改为本地集成播放器原生SDK

## 5.4.9-dev.1.2
----------------------------------
1. Android 适配低版本 SDK 运行报错问题

## 5.4.9-dev.1.1
----------------------------------
1. AliPlayerView 增加 aliPlayerViewType 属性，用于指定渲染 View 的类型(仅对 Android 有效)

## 5.4.9-dev.1.0
----------------------------------
1. 修复 Android 创建 ListPlayer 出现错误日志问题
2. 修复 Android 调用截图接口，在图片未完全保存到本地时，回调截图成功问题
3. iOS 增加接口，用于下载后获取全路径

## 5.4.9
----------------------------------
1. 更新播放器 SDK(更新 OpenSSL)
2. 修复 Android 播放 hdr 视频问题
3. 修复 Android、iOS 部分接口调用报错问题

## 5.4.8-dev.1.2
----------------------------------
1. 修复 Android 播放报错问题
2. 修复 iOS 播放时，偶现 onInfo 没有回调的问题
3. flutter 接口增加空类型支持

## 5.4.8-dev.1.0
----------------------------------
1. 更新 Anddroid、iOS播放器SDK为 5.4.8.0
2. 移除 flutter_aliplayer_artc 和 flutter_rts，需要使用 Rts SDK，请自行在 Android、iOS 项目里添加依赖
3. 新增接口
## 5.4.3-dev.5
----------------------------------
1. 增加 Sei 、SubtitleHeader 接口调用
2. 增加 FlutterAliPlayerFactory.loadRtsLibrary() 接口，(Android)
3. 修复 5.4.2 编译报错问题
4. 修复集成 Rts 低延时直播无法播放问题
5. 修复 AliPlayer、AliListPlayer、AliLiveShiftPlayer 依次创建后，先创建的对象失效问题

## 5.4.2
----------------------------------
阿里云播放器版本更新至：5.4.2.0
flutter_aliplayer_artc : ^5.4.2
flutter_rts : ^1.9.0

1. 增加直播时移功能(测试中)
2. 修复下载无法设置 region 问题
3. 重复创建 AliPlayer 对象，导致先创建的 AliPlayer 对象回调监听失效问题

## 5.4.0
----------------------------------
阿里云播放器版本更新至：5.4.0
flutter_aliplayer_artc : ^5.4.0
flutter_rts : ^1.6.0

1. 支持多个播放实例，具体可以参照demo代码`multiple_player_page.dart`
2. 播放器回调添加playerId参数，用于多实例调用的区分
3. 添加`setPlayerView`方法，创建播放器后，需要绑定view到播发器
4. 去除原列表播放器管道，在android和iOS源码层AliListPlayer与AliPlayer公用一个管道
5. `initService`、`getSDKVersion`以及log级别开关等方法改为静态方法，与原生sdk对齐

## 5.2.2
----------------------------------
1. Docking Aliyun Player SDK (PlatForm include Android、iOS)
2. RenderView: Android uses TextureView,iOS uses UIView

