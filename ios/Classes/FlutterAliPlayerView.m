//
//  FlutterAliPlayer.m
//  flutter_aliplayer
//
//  Created by aliyun on 2020/9/24.
//
#import "FlutterAliPlayerView.h"

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
        _videoView = [UIView new];
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
