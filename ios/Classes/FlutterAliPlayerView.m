//
//  FlutterAliPlayer.m
//  flutter_aliplayer
//
//  Created by aliyun on 2020/9/24.
//
#import "FlutterAliPlayerView.h"

// 容器视图：尺寸变化（如横竖屏切换）时，主动把 AliPlayer SDK 添加的渲染子视图
// 同步到自身 bounds。子视图的 backing layer 会随 frame 自动更新，无需直接操作 SDK 内部图层。
//
// 注意：容器自身的 frame 完全由 Flutter 引擎管理（UiKitView 合成 + autoresizing），
// 不得通过 MethodChannel 从 Dart 手动写入，否则与引擎构成双写竞争，旋转中交错写入
// 会把 frame 永久写坏（横竖屏都只剩一小块区域）。引擎管不到的只有 SDK 内部渲染层，
// 即本方法同步的部分。
@interface FlutterAliRenderContainerView : UIView
@end

@implementation FlutterAliRenderContainerView

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    if (CGRectIsEmpty(bounds)) {
        return;
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    for (UIView *subview in self.subviews) {
        if (!CGRectEqualToRect(subview.frame, bounds)) {
            subview.frame = bounds;
        }
    }
    [CATransaction commit];
}
@end

@interface FlutterAliPlayerView ()

@end

@implementation FlutterAliPlayerView{
    UIView * _videoView;
}

#pragma mark - life cycle

- (instancetype)initWithWithFrame:(CGRect)frame
                   viewIdentifier:(int64_t)viewId
                        arguments:(id _Nullable)args
                  binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    if ([super init]) {
        _viewId = viewId;
        _videoView = [FlutterAliRenderContainerView new];
        _videoView.autoresizesSubviews = YES;
        [self updateWithWithFrame:frame arguments:args];
    }
    return self;
}

-(void)updateWithWithFrame:(CGRect)frame
                 arguments:(id _Nullable)args{
    NSDictionary *dic = args;
    CGFloat x = [dic[@"x"] floatValue];
    CGFloat y = [dic[@"y"] floatValue];
    CGFloat width = [dic[@"width"] floatValue];
    CGFloat height = [dic[@"height"] floatValue];
    _videoView.frame = CGRectMake(x, y, width, height);
}

- (nonnull UIView *)view {
    return _videoView;
}

@end
