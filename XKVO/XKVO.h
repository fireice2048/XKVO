//
//  XKVO.h
//  XKVO
//
//  使用 XSignal 对系统 KVO 的封装，可以中途取消监听
//
//  Created by yangcy on 2021/08/28.
//

#import <Foundation/Foundation.h>
#import "XSignal.h"

NS_ASSUME_NONNULL_BEGIN

@interface XKVOValue : NSObject

@property (nonatomic, strong) id oldValue;
@property (nonatomic, strong) id changedNewValue;
@property (nonatomic, assign) BOOL isInitialNotify;

@end

@interface XKVO : NSObject

/**
 isInitialNotify : 恒定为NO
 */
+ (XSignalMonitor *)xkvo_addObserver:(id)observer object:(id)object property:(NSString *)property changedBlock:(void (^)(XKVOValue* kvoValue))block;

/**
 initialNotify : 初始值是否回调block通知，默认为 NO。由于iOS的KVO在监听到变化前，拿不到即将变化的新值，所以没必要实现 priorNotify
 isInitialNotify : YES 表示该次监听回调的是当前的值，并非变更事件，此时 newValue 跟 oldValue 是相同的值
 */
+ (XSignalMonitor *)xkvo_addObserver:(id)observer object:(id)object property:(NSString *)property changedBlock:(void (^)(XKVOValue* kvoValue))block initialNotify:(BOOL)initialNotify;

@end

NS_ASSUME_NONNULL_END
