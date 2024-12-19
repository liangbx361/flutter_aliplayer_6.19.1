//
//  FlutterAliPlayer.h
//  flutter_aliplayer
//
//  Created by aliyun on 2020/9/24.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface FlutterAliPlayerView : NSObject<FlutterPlatformView>

@property(nonatomic,assign) NSInteger viewId;

- (instancetype)initWithWithFrame:(CGRect)frame
 viewIdentifier:(int64_t)viewId
      arguments:(id _Nullable)args
                  binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

-(void)updateWithWithFrame:(CGRect)frame
                 arguments:(id _Nullable)args;

@end

NS_ASSUME_NONNULL_END
