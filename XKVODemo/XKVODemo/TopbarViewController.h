//
//  TopbarViewController.h
//  XKVODemo
//
//  Created by yangcy on 2022/4/6.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "XSignal.h"


NS_ASSUME_NONNULL_BEGIN

@interface TopbarViewController : UIViewController

@property (nonatomic, assign) NSInteger goBtnClickCount;

@property (nonatomic, strong) XSignal<NSString *> * jumpUrlSignal; // 当按下 GO 按钮时发送该信号

@end

NS_ASSUME_NONNULL_END
