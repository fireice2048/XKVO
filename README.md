# XKVO

## 介绍
**轻量级通信工具** 使用 Block 的方式实现一对多的事件通知（可代替 Delegate 与 Notification），使用 Block 封装系统 KVO 方法，让监听事件与属性变化变得非常简单。

### 特点
 * 非常轻量，一共只有 200 行代码
 * 运行时不会出现冗长的 Stack 调用
 * 事件监听者销毁后，XKVO 持有的 Block 会自动释放，不产生内存泄漏
 * 支持一对多的通信

### 软件架构
[XKVO](https://gitee.com/fireice2048/xkvo) 分为两个部分，准确的说，其实只有两个类：
1. **XSignal**  
   XSignal - 轻量级简易信号通知工具，使用 Block 来代替 Delegate 与 Notification，支持一对多通信。

   信号-Block监听管理, 使用时创建一个 XSignal 对象，监听者拿到这个对象，向该信号注册监听 Block，一个信号对象（XSignal）可以注册多个监听者，当有事件发生的时候，信号对象的 Owner 调用 signal.emit(id) 发送信号，各监听者便能收到通知，先注册先到达。 
   
   注册监听时，会返回一个 XSignalMonitor 对象，用于中途取消监听，调用其 close 即可。
   
2. **XKVO**  
   使用 XSignal 来封装系统的 KVO 方法，使用者可以使用 Block 来监听 KVO 的回调，简单易用。 
   

## 用法举例

### 安装教程
```c
1.  在 Podfile 中引入 XKVO： 
    pod 'XKVO', :git => 'https://gitee.com/fireice2048/xkvo.git', :branch => 'master'
2.  执行 pod install
3.  #import <XKVO/XKVO.h>
```
或者，将代码下载下来，从中找到 XKVO 目录下四个文件，XKVO.h/XKVO.m，XSignal.h/XSignal.m 拷贝并加入到工程中，然后 #import "XKVO.h" 即可使用。
### KVO属性监听

1.  #import  <XKVO/XKVO.h>
2.  添加KVO监听代码

```c
@interface ViewController ()

@property (nonatomic, assign) NSInteger testCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [XKVO xkvo_addObserver:self object:self property:@"testCount" changedBlock:^(XKVOValue * _Nonnull kvoValue) {
        NSLog(@"监听到 testCount 属性变化 %@ ==> %@", kvoValue.oldValue, kvoValue.changedNewValue);
    }];
    
    self.testCount ++;
}

@end

```

3.  运行程序，会看到如下日志输出：
```
   监听到 testCount 属性变化 0 ==> 1
```

4.  将监听代码添加 initialNotify:YES，
```c
    [XKVO xkvo_addObserver:self object:self property:@"testCount" changedBlock:^(XKVOValue * _Nonnull kvoValue) {
        NSLog(@"监听到 testCount 属性变化 %@ %@ ==> %@", isInitialNotify ? @"初始值" : @"", kvoValue.oldValue, kvoValue.changedNewValue);
    } initialNotify:YES];
```
运行程序，会看到如下日志输出：
```
   监听到 testCount 属性变化 初始值 0 ==> 0
   监听到 testCount 属性变化 0 ==> 1
```
 * initialNotify : 初始值是否回调block通知，默认为 NO。由于iOS的KVO在监听到变化前，拿不到即将变化的新值，所以没必要实现 priorNotify
 * kvoValue.isInitialNotify : YES 表示该次监听回调的是当前的值，并非变更事件，此时 kvoValue.changedNewValue 跟 kvoValue.oldValue 是相同的值
 * 当添加的observer对象销毁后，XKVO内部维持的Block将自动清理

### 信号发送与监听

1.  #import  <XKVO/XKVO.h>
```c
@property (nonatomic, strong) XSignal * loginSignal; // 登录信号
```
2.  创建信号对象
```c
    _loginSignal = [[XSignal alloc] init];
```
3.  添加信号发送代码
```c
    if (_loginSignal)
    {
        _loginSignal.emit(@"小白菜");
    }
```
4.  添加信号监听代码
```c
    [_loginSignal addBlock:^(NSString * x){
        NSLog(@"监听者1号 收到账号登录事件 nick:%@", x);
    } observer:self];
    
    XSignalMonitor * monitor =
    [_loginSignal addBlock:^(NSString * x){
        NSLog(@"监听者2号 收到账号登录事件 nick:%@", x); 
    } observer:self];
    [monitor close]; // 监听者2号不会打印，因为调用了 [monitor close]
    
    [_loginSignal addBlock:^(NSString * x){
        NSLog(@"监听者3号 收到账号登录事件 nick:%@", x);
    } observer:self];
```
运行程序，会看到如下日志输出：
```
   监听者1号 收到账号登录事件 nick:小白菜
   监听者3号 收到账号登录事件 nick:小白菜
```
两个监听者都收到了账号登录事件，因为2号监听者取消了监听，所以不再会收到信号。

**注意事项**  
+ 如果想中途取消信号监听，那么在 subscribe 或 xkvo_addObserver 时记录返回值 XSignalMonitor，在适当的时机调用 -[XSignalMonitor **close**] 即可取消监听，参考 XKVODemo 示例代码。
+ 如果信号需要传递多个参数，那么 XSignal 构造的时候，可以将字典作为 ValueType，XSignal<NSDictionary *>，这样监听的时候，block回调的声明参数也会变成 NSDictionary * x，发送信号的时候，将多个参数组装成字典即可。
+ 对于KVO监听，只是对系统KVO的二次封装，因此跟系统KVO一样，调用方必须是调用其 setter 方法才有效，另外如果调用时传入了原来的值，也会收到监听。
+ 监听方必须传入监听者 Observer，目的是确保监听者销毁后，XKVO 持有的 Block 会自动释放，不产生内存泄漏。
+ **防重入：为了避免多次添加相同的Block，尽量不要在某个事件发生时再添加监听，推荐在一个对象初始化时就设置好监听，确保一个监听只设置一次。**

