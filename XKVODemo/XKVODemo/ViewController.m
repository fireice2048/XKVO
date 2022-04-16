//
//  ViewController.m
//  XKVODemo
//
//  Created by yangcy on 2022/4/6.
//

#import "ViewController.h"
#import "TopbarViewController.h"
#import "XKVO.h"
#import "AudioPlayer.h"

@interface ViewController ()

@property (nonatomic, strong) TopbarViewController * topbar;
@property (nonatomic, strong) AudioPlayer * audioPlayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    CGRect bounds = self.view.bounds;
    self.topbar = [[TopbarViewController alloc] init];
    self.topbar.view.frame = (CGRectMake(0, 20, bounds.size.width - 0, 40));
    
    [self.view addSubview:self.topbar.view];
    
    NSLog(@"ViewController XKVO 启动监听");
    
    [self.topbar.jumpUrlSignal subscribe:^(NSString * _Nullable x) {
        NSLog(@"1. From Topbar, Jump to URL: %@", x);
    } observer:self];
    
    __block XSignalMonitor * monitor = [self.topbar.jumpUrlSignal subscribe:^(NSString * _Nullable x) {
        NSLog(@"2. From Topbar, Jump to URL: %@", x);
        [monitor close];
    } observer:self];
    
    
    [self monitorGoBtnClickCount];
    
    self.audioPlayer = [[AudioPlayer alloc] init];
    [self.audioPlayer play:@"file.mp3"];
    
    [self.audioPlayer onPlayStart:^{
        NSLog(@"\n");
        NSLog(@"\n");
        NSLog(@"音乐已经开始播放...");
    }];
    
    [self.audioPlayer onPlayFinish:^{
        NSLog(@"音乐播放结束.");
    }];
    
    [self.audioPlayer onPlayProgress:^(NSNumber * _Nonnull progress) {
        NSLog(@"音乐播放进度：%@",  progress);
    }];
}

- (void)monitorGoBtnClickCount
{
    [XKVO xkvo_addObserver:self object:self.topbar property:@"goBtnClickCount" changedBlock:^(XKVOValue * _Nonnull kvoValue) {
            NSLog(@"属性新值：%@", kvoValue.changedNewValue);
            NSLog(@"属性旧值：%@", kvoValue.oldValue);
            NSLog(@"是否初值：%@", @(kvoValue.isInitialNotify));
    } initialNotify:YES];
}

@end
