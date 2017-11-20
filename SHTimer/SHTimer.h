//
//  SHTimer.h
//  TimerDemo
//
//  Created by Criss on 2017/11/15.
//  Copyright © 2017年 Criss. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 SHTimer 运行状态

 - SHTimerStatusAction: 正在计时
 - SHTimerStatusStop:   计时停止
 - SHTimerStatusPaused: 计时暂停
 */
typedef NS_ENUM(NSUInteger, SHTimerStatus) {
    SHTimerStatusAction = 0,
    SHTimerStatusStop,
    SHTimerStatusPaused,
};

@class SHTimer;
@protocol SHTimerDelegate;

typedef void (^SHTimerHandler)(SHTimer *timer);

@interface SHTimer : NSObject

/**
 Timer 初始化方法,需手动调用 Start 方法开始计时
 */
+ (instancetype)timerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo timerHandler:(SHTimerHandler)timerHandler;

/**
 scheduled 方法,timer 初始化会直接安排进 Runloop 开始计时(RunloopCommonMode)
 */
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo timerHandler:(SHTimerHandler)timerHandler;

/**
 只有设置代理之后,Timer 才会对 Application 进入后台/进入前台 的广播进行监听设置.
 如果需求不需要监听前后台状态,只需不对 delegate 进行设置即可,内部不会设置 Application 的 Observer
 */
@property (nonatomic, weak) id<SHTimerDelegate> delegate;   /**< 代理 */

@property (nonatomic, assign, readonly) SHTimerStatus status;   /**< 计时器状态 */

- (void)stop;   /**< 停止 */

- (void)pause;  /**< 暂停 */
- (void)start;  /**< 开始 */

- (void)reset;  /**< 复位 */

@end

@protocol SHTimerDelegate <NSObject>

/*
 当应用进入后台/回到前台的回调
 注:仅当 Timer 正在计时过程中出现应用前后台切换的时候才会回调,否则不会回调.
 */
@optional
- (void)timer:(SHTimer *)timer didEnterBackgroundWhenActionInTime:(double)timePoint;
- (void)timer:(SHTimer *)timer willEnterForegroundWhenActionInTime:(double)timePoint sinceEnterBackground:(double)durationTime;

@end
