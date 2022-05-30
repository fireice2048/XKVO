//
//  XKVO.m
//  XKVO
//
//  Created by yangcy on 2021/08/28.
//

#import "XKVO.h"
#import <objc/runtime.h>

@implementation XKVOValue

@end


@interface XKVO ()

@property (nonatomic, strong) NSMutableDictionary * kvoSignalBlockMap;

@end

@implementation XKVO

/**
 禅与Objective-C编程艺术，单例优雅写法，复制粘贴即可使用
 */
+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == instance)
        {
            instance = [[[self class] alloc] init];
        }
    });

    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _kvoSignalBlockMap = [NSMutableDictionary dictionaryWithCapacity:15];
    }
    
    return self;
}

+ (XSignalMonitor *)xkvo_addObserver:(id)observer object:(id)object property:(NSString *)property changedBlock:(void (^)(XKVOValue* kvoValue))block
{
    return [[XKVO sharedInstance] xkvo_addObserver:observer object:object property:property changedBlock:block initialNotify:NO];
}

+ (XSignalMonitor *)xkvo_addObserver:(id)observer object:(id)object property:(NSString *)property changedBlock:(void (^)(XKVOValue* kvoValue))block initialNotify:(BOOL)initialNotify
{
    return [[XKVO sharedInstance] xkvo_addObserver:observer object:object property:property changedBlock:block initialNotify:initialNotify];
}

- (XSignalMonitor *)xkvo_addObserver:(id)observer object:(id)object property:(NSString *)property changedBlock:(void (^)(XKVOValue* kvoValue))block initialNotify:(BOOL)initialNotify
{
    if (nil == _kvoSignalBlockMap[@([object hash])])
    {
        _kvoSignalBlockMap[@([object hash])] = [NSMutableDictionary dictionaryWithCapacity:15];
    }
        
    if (nil == _kvoSignalBlockMap[@([object hash])][property])
    {
        _kvoSignalBlockMap[@([object hash])][property] = [[XSignal alloc] init];
        [object addObserver:self forKeyPath:property options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    
    XSignal * signal = (XSignal *)_kvoSignalBlockMap[@([object hash])][property];
    XSignalMonitor * monitor = [signal subscribe:block observer:observer];
    
    if (initialNotify && (nil != block))
    {
        id value = [object valueForKeyPath:property];
        XKVOValue * kvoValue = [[XKVOValue alloc] init];
        kvoValue.oldValue = value;
        kvoValue.changedNewValue = value;
        kvoValue.isInitialNotify = YES;
        block(kvoValue);
    }
    
    return monitor;
}

- (XSignal *)findKVOSignalWithObject:(id)object property:(NSString *)property
{
    return _kvoSignalBlockMap[@([object hash])][property];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
//    NSLog(@"%@ 对象的 %@ 属性改变，change：%@", object, keyPath, change);
//    NSLog(@"属性新值：%@", change[NSKeyValueChangeNewKey]);
//    NSLog(@"属性旧值：%@", change[NSKeyValueChangeOldKey]);
    
    XSignal * signal = [self findKVOSignalWithObject:object property:keyPath];
    if (signal) {
        XKVOValue * kvoValue = [[XKVOValue alloc] init];
        kvoValue.oldValue = change[NSKeyValueChangeOldKey];
        kvoValue.changedNewValue = change[NSKeyValueChangeNewKey];
        kvoValue.isInitialNotify = NO;
        signal.emit(kvoValue);
    }
}

@end



@interface _XMonitor ()

@property (nonatomic, strong) id observer;
@property (nonatomic, strong) id object;
@property (nonatomic, copy) NSString * property;

@end


@implementation _XMonitor

- (XSignalMonitor *)subscribe:(void (^)(XKVOValue* kvoValue))block initialNotify:(BOOL)initialNotify
{
    return [[XKVO sharedInstance] xkvo_addObserver:self.observer object:self.object property:self.property changedBlock:block initialNotify:initialNotify];;
}

+ (_XMonitor *)xkvo_addObserver:(id)observer object:(id)object property:(NSString *)property
{
    _XMonitor * xmonitor = [[_XMonitor alloc] init];
    xmonitor.observer = observer;
    xmonitor.object = object;
    xmonitor.property = property;

    return xmonitor;
}

@end
