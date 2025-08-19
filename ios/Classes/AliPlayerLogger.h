//
//  AliPlayerLogger.h
//  flutter_aliplayer
//
//  Created by aliyun on 2021/5/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 阿里播放器日志管理器
 * 在Debug模式下输出日志，Release模式下不输出
 */
@interface AliPlayerLogger : NSObject

/**
 * Debug日志输出 - 仅在DEBUG模式下有效
 * @param format 格式化字符串
 */
+ (void)logDebug:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/**
 * 信息日志输出 - 仅在DEBUG模式下有效
 * @param format 格式化字符串
 */
+ (void)logInfo:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/**
 * 警告日志输出 - 仅在DEBUG模式下有效
 * @param format 格式化字符串
 */
+ (void)logWarning:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

/**
 * 错误日志输出 - 总是输出（Debug和Release都有效）
 * @param format 格式化字符串
 */
+ (void)logError:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end

NS_ASSUME_NONNULL_END