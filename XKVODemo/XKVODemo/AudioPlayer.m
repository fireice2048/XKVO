//
//  AudioPlayer.m
//  XKVODemo
//
//  Created by medie on 2022/4/14.
//

#import "AudioPlayer.h"
#import "XSignal.h"

@interface AudioPlayer ()

@property (nonatomic, strong) XSignal * playStartSignal;
@property (nonatomic, strong) XSignal<NSNumber *> * playProgressSignal;
@property (nonatomic, strong) XSignal * playFinishSignal;

@end

@implementation AudioPlayer


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _playStartSignal = [[XSignal alloc] init];
        _playProgressSignal = [[XSignal alloc] init];
        _playFinishSignal = [[XSignal alloc] init];
    }
    
    return self;
}


- (void)play:(NSString *)filePath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.playStartSignal.emit(nil);
        self.playProgressSignal.emit(@(0));
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.playProgressSignal.emit(@(0.5));
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.playProgressSignal.emit(@(1.0));
        self.playFinishSignal.emit(nil);
    });
}


- (void)onPlayStart:(void (^)(void))onSartBlock
{
    [self.playStartSignal subscribe:^(id  _Nullable x) {
        onSartBlock();
    } observer:self];
}

- (void)onPlayProgress:(void (^ _Nonnull)(NSNumber * progress))onProgressBlock
{
    [self.playProgressSignal subscribe:^(id  _Nullable x) {
        onProgressBlock(x);
    } observer:self];
}

- (void)onPlayFinish:(void (^ _Nonnull)(void))onFinishBlock
{
    [self.playFinishSignal subscribe:^(id  _Nullable x) {
        onFinishBlock();
    } observer:self];
}


@end
