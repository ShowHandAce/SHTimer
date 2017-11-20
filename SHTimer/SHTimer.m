//
//  SHTimer.m
//  TimerDemo
//
//  Created by Criss on 2017/11/15.
//  Copyright © 2017年 Criss. All rights reserved.
//

#import "SHTimer.h"
#import <UIKit/UIKit.h>

@interface SHTimerApplicationObserver : NSObject

@property (nonatomic, copy) void (^enterBackgroundHandler)(SHTimerApplicationObserver *observer);

@property (nonatomic, copy) void (^enterForegroundHandler)(SHTimerApplicationObserver *observer);

@property (nonatomic, assign) double enterBackgroundTime;

@property (nonatomic, assign) double enterForegroundTime;

@end

@implementation SHTimerApplicationObserver

- (instancetype)init {
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)applicationDidEnterBackground {
    
    self.enterBackgroundTime = CFAbsoluteTimeGetCurrent();
    
    if (self.enterBackgroundHandler) self.enterBackgroundHandler(self);
}

- (void)applicationWillEnterForeground {
    
    self.enterForegroundTime = CFAbsoluteTimeGetCurrent();
    
    if (self.enterForegroundHandler) self.enterForegroundHandler(self);
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

@end

//SHTimerTarget 类中 NSTimer 执行句柄
typedef void(^SHTimerTargetHandler)(NSTimer *timer);

@interface SHTimerTarget : NSObject

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) NSTimeInterval timeInterval;

@property (nonatomic, copy) SHTimerTargetHandler timerTargetHandler;

@property (nonatomic, assign) BOOL repeatsEnable;

@end

@implementation SHTimerTarget

- (instancetype)initWithTimeInterval:(NSTimeInterval)ti
                             repeats:(BOOL)yesOrNo
                           scheduled:(BOOL)bools
                        timerHandler:(SHTimerTargetHandler)timerTargetHandler {
    if (self = [super init]) {
        
        //记录 timer 基本信息
        self.timeInterval = ti;
        self.timerTargetHandler = timerTargetHandler;
        self.repeatsEnable = yesOrNo;
//        self.hasScheduled = bools;
        
        if (bools) {
            //启动 timer
            [self targetReset];
        }
    }
    return self;
}

- (void)stop {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)pause {
    if (self.timer) self.timer.fireDate = [NSDate distantFuture];
}
- (void)start {
    if (self.timer) self.timer.fireDate = [NSDate date];
}

- (void)targetReset {
    [self stop];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(timerTargetTimeChanged:) userInfo:nil repeats:self.repeatsEnable];
    //将 NSTimer 在 RunLoop 中的 mode 改为 NSRunLoopCommonModes
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    self.timer = timer;
}

//NSTimer 调用方法
- (void)timerTargetTimeChanged:(NSTimer *)timer {
    
    if (self.timerTargetHandler) self.timerTargetHandler(timer);
}

@end

/**
 私有枚举 timer 的运行状态
 默认情况下,状态均为 Default;
 当 Timer 正在计时过程中,应用进入后台,状态进入 Background;应用回到前台,状态变回 Default
 当 Timer 没有计时(停止或暂停),状态不变.

 - SHTimerActionDefault: timer 正常运行
 - SHTimerActionInBackground: timer 在应用进入后台运行
 */
typedef NS_ENUM(NSUInteger, SHTimerActionStatus) {
    SHTimerActionDefault,
    SHTimerActionInBackground,
};

@interface SHTimer()

@property (nonatomic, assign) SHTimerStatus status; /**< 计时器状态 [Public Readonly] */


@property (nonatomic, strong) SHTimerTarget *timerTarget;   /**< SHTimer 中真实 NStimer 的 Target [Private] */

@property (nonatomic, strong) SHTimerApplicationObserver *observer; /**< Application 的 Observer [Private] */

@property (nonatomic, assign) SHTimerActionStatus actionStatus; /**< Timer 的运行状态 [Private] */

@property (nonatomic, assign) BOOL hasScheduled;

@end

@implementation SHTimer

#pragma mark - Setter
- (void)setDelegate:(id<SHTimerDelegate>)delegate {
    if (!_delegate) {
        self.observer = [[SHTimerApplicationObserver alloc] init];
        
        __weak typeof(self) weakSelf = self;
        [self.observer setEnterBackgroundHandler:^(SHTimerApplicationObserver *observer) {
            
            // 当 SHTimer 的状态不是正在计时,进入后台回调不做处理直接 return
            if (weakSelf.status != SHTimerStatusAction) return;
            
            weakSelf.actionStatus = SHTimerActionInBackground;
            
            // 真实 NSTimer 暂停; 不修改 SHTimer 的 status
            [weakSelf.timerTarget pause];
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(timer:didEnterBackgroundWhenActionInTime:)]) {
                [weakSelf.delegate timer:weakSelf didEnterBackgroundWhenActionInTime:observer.enterBackgroundTime];
            }
        }];
        
        [self.observer setEnterForegroundHandler:^(SHTimerApplicationObserver *observer) {
            
            // 回到前台时,如果发现 Timer 并不是后台计时状态,不做处理直接 return
            if (weakSelf.actionStatus != SHTimerActionInBackground) return;
            
            weakSelf.actionStatus = SHTimerActionDefault;
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(timer:willEnterForegroundWhenActionInTime:sinceEnterBackground:)]) {
                
                double enterBgTime = observer.enterBackgroundTime;
                double enterFgTime = observer.enterForegroundTime;
                
                [weakSelf.delegate timer:weakSelf willEnterForegroundWhenActionInTime:enterFgTime sinceEnterBackground:enterFgTime - enterBgTime];
            }
            
            [weakSelf.timerTarget start];
        }];
    }
    _delegate = delegate;
}

#pragma mark - Initialize
+ (instancetype)timerWithTimeInterval:(NSTimeInterval)ti
                              repeats:(BOOL)yesOrNo
                         timerHandler:(SHTimerHandler)timerHandler {
    
    return [[self alloc] initWithTimeInterval:ti repeats:yesOrNo scheduled:NO timerHandler:timerHandler];
}
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)ti
                                       repeats:(BOOL)yesOrNo
                                  timerHandler:(SHTimerHandler)timerHandler {
    
    return [[self alloc] initWithTimeInterval:ti repeats:yesOrNo scheduled:YES timerHandler:timerHandler];
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)ti
                             repeats:(BOOL)yesOrNo
                           scheduled:(BOOL)bools
                        timerHandler:(SHTimerHandler)timerHandler {
    
    if (self = [super init]) {
        
        self.status = bools ? SHTimerStatusAction : SHTimerStatusStop;
        
        self.actionStatus = SHTimerActionDefault;
        self.hasScheduled = bools;
        
        __weak typeof(self) weakSelf = self;
        self.timerTarget = [[SHTimerTarget alloc] initWithTimeInterval:ti repeats:yesOrNo scheduled:(BOOL)bools timerHandler:^(NSTimer *timer) {
            
            if (timerHandler) timerHandler(weakSelf);
        }];
    }
    return self;
}

#pragma mark - SHTimer 操作方法
/**
 停止
 */
- (void)stop {
    if (self.status == SHTimerStatusStop) return;
    
    self.status = SHTimerStatusStop;
    [self.timerTarget stop];
}

/**
 暂停
 */
- (void)pause {
    if (self.status != SHTimerStatusAction) return;
    
    self.status = SHTimerStatusPaused;
    [self.timerTarget pause];
}

/**
 开始计时
 */
- (void)start {
    
    SHTimerStatus status = self.status;
    if (status == SHTimerStatusAction) return;
    
    self.status = SHTimerStatusAction;
    
    if (status == SHTimerStatusPaused) {
        [self.timerTarget start];
    } else if (status == SHTimerStatusStop) {
        [self.timerTarget targetReset];
    }
}

/**
 复位
 */
- (void)reset {
    
    if (self.hasScheduled) {
        // Scheduled Timer 复位
        [self.timerTarget targetReset];
        self.status = SHTimerStatusAction;
    } else {
        // Normal Timer 复位
        [self stop];
    }
}
#pragma mark - 重写销毁方法
//在 SHTimer 对象销毁时,同时销毁 target 类中的 timer 消除循环引用
- (void)dealloc {
    [self.timerTarget stop];
}

@end
