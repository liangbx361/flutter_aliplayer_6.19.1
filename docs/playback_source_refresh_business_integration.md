# 播放器鉴权过期业务接入方案

更新日期：2026-10-20

本方案用于业务播放器接入当前插件的播放源刷新能力，覆盖入口地址鉴权过期、HLS 播放中切片鉴权过期，以及 SDK 只通知 `onError` 时的进度恢复。业务层统一负责获取新凭证、控制恢复次数和维护用户播放意图。

采用两条恢复路径：SDK 发出过期回调时，将新凭证交回 SDK；SDK 只发出错误通知时，由业务重新设置播放源，从保存的位置起播。两条路径共用刷新请求和恢复预算。

## 1 适用范围和场景

适用于普通 `FlutterAliplayer` 的 URL 和 VidAuth 点播。新增回调要求 Android 和 iOS 原生播放器 SDK 7.9.0 及以上；当前仓库配置为 7.18.0。列表播放器、直播时移及直播时间轴恢复不在本方案范围内。

| 失败位置 | 典型表现 | 业务目标 |
| --- | --- | --- |
| 播放入口 | 请求 m3u8 或直接播放地址时，鉴权已过期，尚未起播 | 获取新凭证后从业务保存的起播位置播放；没有历史位置时从 0 开始 |
| HLS 切片 | 播放列表已加载或缓存，后续未缓存切片请求因鉴权失效而失败 | 更新整个播放源，恢复到故障前的播放位置 |

这两种情况与播放源类型是两个维度：`setVidAuth` 对应 `setOnVidAuthExpiredCallback`，`setUrl` 对应 `setOnURLSourceExpiredCallback`。不存在专门对应 ts 切片的第三个刷新回调。

直接通过 `setUrl` 播放 m3u8 时，Android 对接的是原生 `setOnURLSourceExpiredListener(OnURLSourceExpiredListener listener)`。当前插件已经调用这个接口；Flutter 业务侧使用插件封装的 `setOnURLSourceExpiredCallback`。本方案以 URL 源为主要接入示例，VidAuth 是另一种播放方式的对照。

切片 URL 的鉴权失效与文件被删除、权限不足、解密密钥请求失败，需要按实际错误区分。不能将任意 403 都视为凭证过期。

## 2 插件与业务分工

| 承担方 | 职责 |
| --- | --- |
| 插件 | 转发 SDK 原生过期请求；将业务提交的新值或错误交回该请求；保留原播放源的其他配置；在源变化、停止和释放时使旧刷新结果失效 |
| 业务播放器控制器 | 保存位置和播放意图；请求新凭证；协调两条恢复路径；控制超时、并发、重试、切集和销毁；处理错误提示与人工重试 |
| 业务服务端 | 校验当前用户的播放权限，返回同一视频可用的新 PlayAuth 或完整播放 URL，并保证相关切片和密钥访问凭证有效 |

业务刷新接口优先以稳定的视频或剧集标识定位资源。过期 URL 可作排查信息，不宜承担业务资源唯一标识的职责。

以下是业务服务端返回值的接入要求，不代表插件提供了相应 HTTP 接口：

| 播放方式 | 客户端需要的刷新结果 |
| --- | --- |
| URL | 同一视频、同一内容时间轴的新完整播放 URL；HLS 返回 m3u8 地址，不能返回单个 ts 地址 |
| VidAuth | 对应当前 VOD vid 的新 PlayAuth；需要重设源时，还应提供或保留地域、播放配置和清晰度策略 |
| 可选信息 | 凭证或播放地址的有效时间、资源版本、请求追踪标识；不同凭证的有效期需分别表达 |

原生 VidAuth 回调的成功值只支持新 PlayAuth，URL 回调只支持新 URL。如果刷新还要求改变 vid、独立的播放配置或其他源参数，业务应完成原请求的失败回报，并通过重新设置源的路径应用这些参数。

## 3 业务需要保存的状态

每个播放器实例由一个业务控制器管理。播放器监听应在控制器中集中分发，避免不同组件重复调用 setter 覆盖彼此的监听。

| 状态 | 用途 |
| --- | --- |
| `playerId` 与业务视频标识 | 定位实例和当前播放内容 |
| 播放源类型及原始配置 | 恢复时沿用 URL 或 VidAuth 播放方式及相关参数 |
| `mediaGeneration` | 每次用户切换内容、退出或销毁时递增，使业务异步结果失效；即使切回同一视频也生成新值 |
| `lastPositionMs` | 正常播放时从 `onInfo` 的 `FlutterAvpdef.CURRENTPOSITION` 更新，单位为毫秒；不能使用缓冲位置代替 |
| `desiredPositionMs` | 恢复期间用户主动拖动的最新目标；存在时优先于故障时的位置快照 |
| `wantsPlaying` | 用户当前希望播放还是暂停；错误状态不应将它直接覆盖为暂停 |
| 恢复阶段与请求 Future | 区分获取凭证、重新设置源、等待准备、等待恢复和失败；同一轮故障复用一次凭证请求 |
| 恢复预算与进度快照 | 限制当前一轮故障的自动恢复次数，并冻结恢复目标，避免重开期间的 0 位置通知覆盖它 |

恢复期间的用户操作仍需生效：暂停更新 `wantsPlaying`，拖动更新目标位置，切集或销毁立即改变 `mediaGeneration`。业务应将播放器换源操作串行执行，并在异步返回后、每次后续播放器操作前核验快照仍属于当前会话。

业务代数只能校验业务自己的异步任务。当前 SDK 的 `onError`、`onPrepared` 事件只带 `playerId`，没有业务视频标识或代数，不能声称能据此精确识别所有旧源事件；源切换与准备事件还需要结合串行操作和当前恢复阶段处理。

## 4 初始化和原生过期回调

### 播放器初始化

先完成播放器创建，再注册普通监听和所用播放方式的过期回调，然后设置源、调用 `prepare`。恢复流程由业务统一管理时，建议显式关闭自动播放，准备完成后按当前播放意图决定是否播放。

```dart
await player.setAutoPlay(false);
await player.setPlayConfig(
  AVPConfig()..enableStrictAuthMode = true,
);
```

使用 `setPlayConfig` 局部更新严格鉴权配置。不要使用 `setConfig({'enableStrictAuthMode': true})` 代替：旧接口在双端的字段映射和配置更新方式不同。当前 Android 原生侧也没有实现 Dart 声明的 `getPlayConfig`，无需先调用它。

普通监听至少接入 `setOnInfo`、`setOnPrepared`、`setOnRenderingStart` 和 `setOnError`。如果业务还要依据首帧和位置推进判断恢复完成，需把这些事件送入同一个恢复控制器。

### 原生回调处理

同一能力在 Flutter、Android 和 iOS 的命名如下，不能将 Dart 方法名当作 Android SDK 方法名：

| 播放源 | Flutter 业务入口 | Android 原生接口 | iOS 原生接口 |
| --- | --- | --- | --- |
| URL | `setOnURLSourceExpiredCallback` | `setOnURLSourceExpiredListener` | `setOnURLSourceExpiredCallback:` |
| VidAuth | `setOnVidAuthExpiredCallback` | `setOnVidAuthExpiredListener` | `setOnVidAuthExpiredCallback:` |

Android URL 监听收到 `UrlSource` 和 `SourceRefreshCallback<UrlSource>`。插件将过期 URL 交给 Dart，业务提交新 URL 后，插件更新原生源并调用 SDK 的 `onSuccess`；失败则调用原生 `onError`。

| Flutter 注册方法 | Dart 回调参数 | 业务成功提交 |
| --- | --- | --- |
| `setOnURLSourceExpiredCallback` | `expiredUrl, callback, playerId` | `callback.onSuccess(newPlaybackUrl)` |
| `setOnVidAuthExpiredCallback` | `vid, callback, playerId` | `callback.onSuccess(newPlayAuth)` |

业务按会话快照请求新凭证，成功后再次确认当前视频未切换、实例未销毁，再提交结果。每个原生请求都需要有成功或失败终态，不能仅在 async 函数中 `return newUrl`。

下面展示 URL 回调的接入结构。`captureSession`、`refreshSourceOnce` 和 `isCurrentSession` 均由业务实现，其中 `refreshSourceOnce` 需复用当前一轮故障的请求并设置超时；它们不是插件 API。

```dart
await player.setOnURLSourceExpiredCallback((expiredUrl, callback, playerId) async {
  final snapshot = captureSession(playerId);
  try {
    final source = await refreshSourceOnce(snapshot);
    if (!isCurrentSession(snapshot)) {
      callback.onError('Playback session changed');
      return;
    }
    if (!callback.isCompleted) {
      callback.onSuccess(source.url);
    }
  } catch (error) {
    callback.onError(error.toString());
  }
});
```

VidAuth 使用相同的协调流程，额外核对回调 vid 属于当前视频，并将成功值替换为新 PlayAuth。超时、权限拒绝、请求失败或会话变化时调用 `callback.onError`；插件会忽略已经完成或已取消请求的重复提交。

原生回调路径提交新值后由 SDK 继续处理，不再调用 `stop`、`setUrl`、`setVidAuth` 或 `prepare`。`onSuccess` 只表示业务交付了新凭证，不能据此认定视频已经恢复。

## 5 只收到 onError 时的恢复

### 判断是否进入刷新

`onError` 的 `errorCode` 是 SDK 错误码，不能直接写成 `errorCode == 403` 来判断 HTTP 状态。业务应结合明确的鉴权错误、当前凭证有效信息和服务端权限结果判断是否需要刷新；不能确认原因但允许尝试恢复时，也必须受同一轮故障预算约束。

License 无效、确认无播放权限、资源不存在和格式解码失败等错误，应进入相应的业务错误处理。刷新失败产生的新 `onError` 不能再次无条件启动刷新。

### 保存位置并重新设置源

1. 从业务缓存保存故障时的位置。首次起播尚无进度时，使用历史播放位置或 0；不要在停止或重开之后才依赖播放器位置读取。
2. 保存当前视频和 `mediaGeneration` 的快照。取得新源后再次核验；若用户已切集或退出，则丢弃结果。
3. 使用同一轮故障的共享请求取得新源。如果恢复期间用户拖动，采用最新的业务目标位置。
4. 串行执行停止、设置新源、设置起播时间和准备播放；每次异步调用后检查会话仍有效，再继续下一步。

URL 播放的核心调用顺序如下；实际业务需在外层加入上述会话校验、共享请求与恢复状态管理：

```dart
await player.stop();
await player.setUrl(newPlaybackUrl);
await player.setStartTime(resumePositionMs, FlutterAvpdef.ACCURATE);
await player.prepare();
```

VidAuth 将 `setUrl` 替换为 `setVidAuth`，传入新 PlayAuth，并沿用业务保存的 `vid`、`region`、`playConfig`、`definitionList`、`quality` 和 `forceQuality`。服务端明确返回变化的配置时，应应用新值。

`setStartTime` 的时间单位是毫秒，只对紧接着的一次 `prepare` 生效，每次重开都需要重新设置。它让播放器从指定位置起播，恢复仍可能经历重新缓冲，不承诺无缝或逐帧一致。

### 准备完成和播放恢复

`await player.prepare()` 只代表原生调用返回，不代表准备完成。既有 `onPrepared` 监听需要结合当前恢复阶段处理：

- 当前 `wantsPlaying` 为 true 时调用 `play()`；为 false 时保持暂停意图，不能强制播放。
- 准备过程中再次收到真实失败时，结束本次恢复；不能因正在恢复而无条件吞掉所有错误。
- 播放状态持续恢复后才结束当前故障轮次。正在播放时应观察首帧、位置继续推进等证据，不能只依据 `onPrepared`。

暂停状态可以完成新源准备，但还未证明保存位置附近的切片能正常播放。保持当前恢复记录，待用户继续播放并稳定推进后再确认成功；用户恢复期间拖动的目标也应在播放前应用。

## 6 两条路径的协调和重试

建议以一轮连续故障为单位，最多自动获取一次新源，并最多执行一次业务重新起播。该预算是业务策略，可按验证结果调整；不是 SDK 的固定限制。

| 当前情况 | 业务处理 |
| --- | --- |
| 同一会话多个原生过期请求同时到达 | 共用一次获取新源的 Future，但每个原生 callback 都要分别完成 |
| 原生刷新期间又收到鉴权相关 onError | 记录需要业务兜底，不另发一次刷新请求；串行接管恢复，复用正在获取或已经取得的新源 |
| 业务兜底接管时仍有原生请求等待 | 结束原请求或通过停止使其取消；原生回调的迟到结果不得再与业务换源并行执行 |
| 等待新凭证时重复收到同一故障 | 合并到当前恢复任务；不能因重复入口发起多次请求 |
| 新源准备或播放仍失败 | 当前预算耗尽后进入失败状态，显示可重试入口；不继续自动循环 |
| 回调 onError、超时或权限拒绝后又出现 SDK 错误 | 保留失败结果和已消耗预算，禁止把它当作全新一轮故障 |
| 恢复后持续正常播放 | 结束当前故障轮次，允许未来发生的独立过期再次恢复 |
| 用户切集、退出或销毁 | 递增业务代数，使本方任务失效，按顺序取消监听和释放实例；请求返回后禁止再操作该实例 |

不能在 `callback.onSuccess`、`prepare` 返回或 `onPrepared` 时立即重置预算，否则新签名无效或旧缓存仍被使用时，可能进入无限恢复。人工重试可显式创建新的恢复轮次，并仍受会话有效性检查约束。

## 7 缓存与界面处理

显式使用严格鉴权模式，避免重开时沿用缓存中的旧鉴权。SDK 7.18.0 的原生默认值已为严格模式，不应依赖 Dart 旧注释中关于默认 false 的说明。严格模式意味着起播需要联网鉴权，业务应按实际离线播放产品要求采用独立策略。

HLS 获取新入口地址后，还需确认播放器取得了有效的播放列表、切片及必要的密钥访问凭证。只更换入口 URL 的鉴权参数，不能保证所有独立签名的 ts 或 key URL 自动有效。

不要将全局 `clearCaches()` 作为每次恢复的默认动作。若业务自定义缓存 Hash，应确保不同内容不会共用同一缓存标识，尤其不要随意移除解密 key URL 的鉴权参数后共用缓存。旧 m3u8 缓存与未缓存切片的组合需要单独验收。

恢复期间可保持封面或加载提示，进度条保留恢复目标。失败后展示明确的重试入口，用户点击后再启动新一轮恢复。记录恢复路径、业务视频标识、故障轮次、SDK 错误码、恢复位置、耗时和结果即可，日志避免保存完整 PlayAuth、签名 URL 或密钥凭证。

## 8 验收要求和当前状态

入口地址与切片过期都需要在有效 License 的业务包中验收，并分别覆盖 URL 与 VidAuth 两种播放源。使用实际 CDN 鉴权失效条件，普通测试服务器返回 403 不能替代真实过期场景。

| 验收场景 | 通过标准 |
| --- | --- |
| 入口鉴权过期并触发原生回调 | 业务提交新凭证，SDK 请求有效源并正常起播；无历史位置时从 0 开始 |
| 切片鉴权过期并触发原生回调 | SDK 接受新凭证后恢复请求，位置符合续播预期，无额外业务换源 |
| 入口或切片过期只触发 onError | 业务限次获取新源并重开，恢复到保存或用户更新的位置 |
| 旧缓存 m3u8 与未缓存切片 | 刷新后不继续循环使用旧鉴权，缓存内容没有串流 |
| 原生过期回调与 onError 同时到达 | 一轮故障不重复获取凭证，不并行重开播放器，每个原生请求有终态 |
| 暂停或拖动发生在恢复期间 | 保留最新播放意图及目标位置，恢复不能自动覆盖用户操作 |
| 切集或销毁后凭证才返回 | 不修改后续视频，不调用已释放实例，不错误清除新一轮任务状态 |
| 持续过期、刷新超时、接口失败或权限拒绝 | 预算耗尽后停止自动请求，显示失败和人工重试入口 |
| 同一视频稳定恢复后再次独立过期 | 可开启新一轮恢复，不能因第一次恢复已使用预算而永久禁用 |
| 多播放器同时播放 | 进度、共享请求、恢复预算和异步结果均按实例及业务会话隔离 |

截至本方案日期，插件新增的 13 项桥接测试通过，Android 源码通过 SDK 7.18.0 编译，iOS 修改文件通过 SDK 7.18.0 头文件语法检查。独立 Android 测试包受 `LICENSE_ERROR_INVALID / NoDefaultLicense` 阻挡，真实入口和切片鉴权过期续播尚未完成验收。业务恢复控制器及业务服务端接口也尚未在本仓库实现。

## 9 接口和官方资料

- [插件 Dart 接口](../lib/flutter_aliplayer.dart)：过期回调、`SourceRefreshCallback`、`setStartTime`、播放控制及配置。
- [插件接入示例](../README.md#4-播放源鉴权过期刷新)。
- [阿里云自动刷新播放源与本地缓存](https://help.aliyun.com/zh/vod/developer-reference/advanced-features-1)：原生回调及严格鉴权说明。
- [阿里云基础播放功能](https://help.aliyun.com/zh/vod/developer-reference/basic-features-2)：指定位置起播和准备播放。
- [阿里云 iOS 播放器常见问题](https://help.aliyun.com/zh/vod/developer-reference/faq-about-apsaravideo-player-sdk-for-ios)：HLS 缓存旧鉴权导致播放失败的场景。
