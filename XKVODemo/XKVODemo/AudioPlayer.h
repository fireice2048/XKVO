//
//  AudioPlayer.h
//  XKVODemo
//
//  Created by medie on 2022/4/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioPlayer : NSObject

- (void)play:(NSString *)filePath;

// 注册播放事件通知
- (void)onPlayStart:(void (^ _Nonnull)(void))onSartBlock;
- (void)onPlayProgress:(void (^ _Nonnull)(NSNumber * progress))onProgressBlock;
- (void)onPlayFinish:(void (^ _Nonnull)(void))onFinishBlock;

@end

NS_ASSUME_NONNULL_END
