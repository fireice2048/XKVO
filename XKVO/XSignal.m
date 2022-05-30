//
//  XSignal.m
//  XKVO
//
//  Created by yangcy on 2022/4/6.
//

#import "XSignal.h"

@interface XSignal ()

@property (nonatomic, strong) NSMutableArray<XSignalMonitor *> * monitorArray;

- (void)removeMonitorLater:(XSignalMonitor *)monitor;

@end


@interface XSignalMonitor ()

@property (nonatomic, weak) XSignal * signal;
@property (nonatomic, weak) id observer;

@end

@implementation XSignalMonitor

- (void)close
{
    [_signal removeMonitorLater:self];
}

@end



@implementation XSignal

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _monitorArray = [NSMutableArray arrayWithCapacity:5];
    }
    
    return self;
}

- (XSignalMonitor *)subscribe:(void (^)(id _Nullable x))monitorBlock observer:(id)observer

{
    XSignalMonitor * monitor = [XSignalMonitor new];
    monitor.block = monitorBlock;
    monitor.signal = self;
    monitor.observer = observer ? observer : [NSNull null];

    [_monitorArray addObject:monitor];
    
    return monitor;
}

- (XSignal *(^)(id _Nullable x))emit
{
    __weak typeof(self) weakSelf = self;
    return ^(id x) {
        //NSLog(@"- [XSignal emit] x: %@", x);
        
        __block NSMutableArray<XSignalMonitor *> * removeArray = [NSMutableArray arrayWithCapacity:10];
        __strong typeof(self) self = weakSelf;
        [self.monitorArray enumerateObjectsUsingBlock:^(XSignalMonitor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.observer) {
                obj.block(x);
            } else {
                [removeArray addObject:obj];
            }
        }];
        
        [self.monitorArray removeObjectsInArray:removeArray];
        
        return self;
    };
}

- (void)removeMonitorLater:(XSignalMonitor *)monitor
{
    [self.monitorArray removeObject:monitor];
    //NSLog(@"removeMonitor %@", monitor);
    //NSLog(@" 剩余监听者：%@", self.monitorArray);
}

@end


