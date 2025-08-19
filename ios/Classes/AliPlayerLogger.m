//
//  AliPlayerLogger.m
//  flutter_aliplayer
//
//  Created by aliyun on 2021/5/18.
//

#import "AliPlayerLogger.h"

@implementation AliPlayerLogger

+ (void)logDebug:(NSString *)format, ... {
#ifdef DEBUG
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSLog(@"[AliPlayer-DEBUG] %@", message);
#endif
}

+ (void)logInfo:(NSString *)format, ... {
#ifdef DEBUG
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSLog(@"[AliPlayer-INFO] %@", message);
#endif
}

+ (void)logWarning:(NSString *)format, ... {
#ifdef DEBUG
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSLog(@"[AliPlayer-WARNING] %@", message);
#endif
}

+ (void)logError:(NSString *)format, ... {
    // 错误日志在Debug和Release模式下都输出
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NSLog(@"[AliPlayer-ERROR] %@", message);
}

@end