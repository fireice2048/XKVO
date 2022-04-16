//
//  XSignal.h
//  XKVO
//
//  轻量级信号通知工具，使用Block来代替Delegate与Notification，支持一对多通信
//  支持取消监听，不支持skip（跳过信号通知）
//
//  Created by yangcy on 2022/4/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface XSignalMonitor : NSObject

@property (nonatomic, copy) void (^block)(id _Nullable x);

// 关闭当前监听（取消监听）
- (void)close;

@end

@interface XSignal<__covariant ValueType> : NSObject

// 订阅监听，observer 为监听者对象，当observer销毁后，会自动移除 XSignalMonitor
- (XSignalMonitor *)subscribe:(void (^)(ValueType _Nullable x))monitorBlock observer:(id)observer;


// 发送信号，所有订阅者都将得到通知
- (XSignal *(^)(ValueType _Nullable x))emit;

@end

NS_ASSUME_NONNULL_END
