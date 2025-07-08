#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_aliplayer.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_aliplayer'
  s.version          = '6.19.0'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  # 定义 SDK 内核
  useAIOFramework = false

  # 定义 SDK 版本
  # 1. 音视频终端SDK及版本，建议使用最新版本，详情参考官网：https://help.aliyun.com/zh/apsara-video-sdk/developer-reference/fast-integration-for-android
  aio_sdk_version = '6.17.0'
  # 2. 播放器SDK及版本，建议使用最新版本，详情参考官网：https://help.aliyun.com/zh/vod/developer-reference/release-notes-for-apsaravideo-player-sdk-for-android
  player_sdk_version = '7.5.0'

  # 根据 useAIOFramework 的值选择相应的 SDK
  if useAIOFramework
    s.subspec 'AliVCSDKFrameworks' do |ss|
    # 音视频终端SDK（互动直播）：直播推流（含超低延时直播、RTC连麦）＋播放器
    ss.dependency 'AliVCSDK_InteractiveLive', aio_sdk_version
  end
  else
  s.subspec 'AliPlayerSDKFrameworks' do |ss|
    # 阿里云播放器独立SDK
    ss.dependency 'AliPlayerSDK_iOS', player_sdk_version
    end
  end

  s.dependency 'MJExtension'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
