# XKVO 


## Introduce 
**Lightweight communication tools** use block to realize one to many event notification (instead of delegate and notification), and use block to encapsulate the KVO method of the system, which makes it very easy to monitor events and attribute changes. 



### Features 
 * Very lightweight, only 200 lines of code in total 
 * Runtime without lengthy Stack calls 
 * After the event listener is destroyed, the block held by XKVO will be automatically released, and no memory leak will occur 
 * Support one-to-many communication 

### Software Architecture 
[XKVO](https://github.com/fireice2048/XKVO) Divided into two parts, to be precise, there are actually only two categories： 
1. **XSignal**  
   XSignal - A lightweight and simple signal notification tool, uses Block to replace Delegate and Notification, and supports one-to-many communication. 

   Signal-Block monitoring management, create an XSignal object when using it, the listener gets this object, registers the monitoring block with the signal, a signal object (XSignal) can register multiple listeners, when an event occurs, the signal object's The Owner calls signal.emit(id) to send a signal, and each listener can receive the notification. Register first and arrive first. 
   
   When registering a monitor, an XSignalMonitor object will be returned to cancel the monitor midway, just call its close.  
   
2. **XKVO**  
   Using XSignal to encapsulate the KVO method of the system, users can use Block to monitor the KVO callback, which is simple and easy to use. 
   

## Usage example

### Installation tutorial
```c
1.  Introduce XKVO in Podfile： 
    pod 'XKVO', :git => 'https://gitee.com/fireice2048/xkvo.git', :branch => 'master'
2.  run 'pod install'
3.  #import <XKVO/XKVO.h>
```
Or, download the code, find the four files in the XKVO directory, copy XKVO.h/XKVO.m, XSignal.h/XSignal.m to the project, and then #import "XKVO.h" to use. 
### KVO property listener

1.  #import  <XKVO/XKVO.h>
2.  Add KVO monitoring code

```c
@interface ViewController ()

@property (nonatomic, assign) NSInteger testCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [XKVO xkvo_addObserver:self object:self property:@"testCount" changedBlock:^(XKVOValue * _Nonnull kvoValue) {
        NSLog(@"Listened to testCount changed %@ ==> %@", kvoValue.oldValue, kvoValue.changedNewValue);
    }];
    
    self.testCount ++;
}

@end

```

3.  Run the program and you will see the following log output：
```
   Listened o testCount changed 0 ==> 1
```

4.  将监听代码添加 initialNotify:YES，
```c
    [XKVO xkvo_addObserver:self object:self property:@"testCount" changedBlock:^(XKVOValue * _Nonnull kvoValue) {
        NSLog(@"Listened to testCount changed %@ %@ ==> %@", isInitialNotify ? @"(initial value)" : @"", kvoValue.oldValue, kvoValue.changedNewValue);
    } initialNotify:YES];
```
Run the program and you will see the following log output：
```
   Listened to testCount changed (initial value) 0 ==> 0
   Listened to testCount changed 0 ==> 1
```
 * initialNotify : Whether the initial value calls back block notification, the default is NO. Since iOS KVO cannot get the new value that is about to change before monitoring the change, there is no need to implement priorNotify
 * kvoValue.isInitialNotify : YES indicates that the monitoring callback is the current value, not the change event. At this time, kvoValue.changedNewValue and kvoValue.oldValue are the same value
 * When the added observer object is destroyed, the Block maintained inside XKVO will be automatically cleaned up

### 信号发送与监听

1.  #import  <XKVO/XKVO.h>
```c
@property (nonatomic, strong) XSignal * loginSignal; // login signal
```
2.  Create a signal object
```c
    _loginSignal = [[XSignal alloc] init];
```
3.  Add signaling code
```c
    if (_loginSignal)
    {
        _loginSignal.emit(@"Cabbage");
    }
```
4.  Add signal monitoring code
```c
    [_loginSignal addBlock:^(NSString * x){
        NSLog(@"Listener 1# Receives account login event, nick:%@", x);
    } observer:self];
    
    XSignalMonitor * monitor =
    [_loginSignal addBlock:^(NSString * x){
        NSLog(@"Listener 2# Receives account login event, nick:%@", x); 
    } observer:self];
    [monitor close]; // Monitor No.2 will not print because [monitor close] is called
    
    [_loginSignal addBlock:^(NSString * x){
        NSLog(@"Listener 3# Receives account login eventm nick:%@", x);
    } observer:self];
```
Run the program and you will see the following log output：
```
   Listener 1# Receives account login event, nick:Cabbage
   Listener 3# Receives account login event, nick:Cabbage
```
All listeners have received the account login event, because listener No. 2 canceled the monitoring, so it will no longer receive the signal.

**Attentions**  
+ If you want to cancel the signal monitoring in the middle, then record the return value **XSignalMonitor** when **subscribe** or **xkvo_addObserver**, and call -[XSignalMonitor **close**] at the appropriate time to cancel the monitoring, refer to the **XKVODemo** sample code.
+ If the signal needs to pass multiple parameters, then when **XSignal** is constructed, the dictionary can be used as ValueType, XSignal<NSDictionary *>, so when listening, the declared parameter of the block callback will also become **NSDictionary * x**, when sending the signal, the Multiple parameters can be assembled into a dictionary.
+ For **KVO** monitoring, it is only a secondary encapsulation of the system KVO. Therefore, like the system KVO, the caller must call its setter method to be effective. In addition, if the original value is passed in the call, it will also receive the monitoring.
+ The listener must pass in the observer Observer, the purpose is to ensure that after the listener is destroyed, the block held by XKVO will be automatically released, and no memory leak will occur.
+ **Anti-reentrancy: In order to avoid adding the same block multiple times, try not to add a listener when an event occurs. It is recommended to set a listener when an object is initialized to ensure that a listener is only set once.**

