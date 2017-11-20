# SHTimer
* 解决因 `NSTimer` 与 `target` 强引用而可能产生循环引用情况,进而导致的内存问题.
* 内部监听 `UIApplication`,记录应用进入后台/前台的时间,解决计时器进入后台计时停止问题.

# 思路
* 内部构造 `SHTimerTarget` 私有类创建并持有 `NSTimer`,同时作为其 `target`,实际上循环引用的对象为 `SHTimerTarget ` 与 `NSTimer `.当 `SHTimer` 释放时,在 `- dealloc` 方法中将 `NSTimer` 置为 nil,强制打破循环引用链,释放所有相关对象.
* 内部构造 `SHTimerApplicationObserver` 私有类,监听系统 

	```objc
	UIApplicationDidEnterBackgroundNotification
	UIApplicationWillEnterForegroundNotification
	```
两个 Notification.通过 `SHTimer` 的代理回调给计时器持有者,同时将进入后台持续的时间回传,以供计算.


# 使用
### SHTimer

`SHTiemr` 提供了两个初始化方法

```objc
/**
 Timer 初始化方法,需手动调用 Start 方法开始计时
 */
+ (instancetype)timerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo timerHandler:(SHTimerHandler)timerHandler;

/**
 scheduled 方法,timer 初始化会直接安排进 Runloop 开始计时(RunloopCommonMode)
 */
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo timerHandler:(SHTimerHandler)timerHandler;
```

提供四个操作方法

```objc
- (void)stop;   /**< 停止 */
- (void)pause;  /**< 暂停 */
- (void)start;  /**< 开始 */
- (void)reset;  /**< 复位 */
```

其中,停止方法会移除内部的 `NSTimer` 对象;复位方法会先移除 `NSTimer`,而后根据初始化方式重新创建 `NSTimer` 对象.

暂停方法通过 `self.timer.fireDate = [NSDate distantFuture]` 实现.

### SHTimerDelegate

设置 `SHTimer` 的 `delegate` 后,timer 内部会添加对 `UIApplication` 的监听.代理对象中实现方法

```objc
@optional
- (void)timer:(SHTimer *)timer didEnterBackgroundWhenActionInTime:(double)timePoint;
- (void)timer:(SHTimer *)timer willEnterForegroundWhenActionInTime:(double)timePoint sinceEnterBackground:(double)durationTime;
```

当手机进入后台时,回调第一个方法;进入前台,回调第二个方法.形参 `durationTime ` 为应用在后台持续的时间(s).

> 注: 只有设置了 `delegate` 之后,timer 才会添加对 `UIApplication` 的监听,否则不会监听.

# License  
MIT