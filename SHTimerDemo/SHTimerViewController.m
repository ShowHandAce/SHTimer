//
//  SHTimerViewController.m
//  SHTimerDemo
//
//  Created by Criss on 2017/11/20.
//  Copyright © 2017年 Criss. All rights reserved.
//

#import "SHTimerViewController.h"

#import "SHTimer.h"

@interface SHTimerViewController () <SHTimerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@property (nonatomic, strong) SHTimer *timer;

@property (nonatomic, assign) CGFloat sec;

@property (nonatomic, assign) SHTimerType timerType;

@end

@implementation SHTimerViewController

#pragma mark - Setter
- (void)setSec:(CGFloat)sec {
    _sec = sec;
    
    self.timerLabel.text = [NSString stringWithFormat:@"%.2f S",_sec];
}

#pragma mark - Initialize
- (instancetype)initWithTimerType:(SHTimerType)type {
    if (self = [super init]) {
        self.timerType = type;
    }
    return self;
}

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.sec = 0;
    
    __weak typeof(self) weakSelf = self;
    
    SHTimerHandler handler = ^(SHTimer *timer) {
        weakSelf.sec += 0.01;
        NSLog(@"%.2f",weakSelf.sec);
    };
    
    if (self.timerType == SHTimerTypeNormal) {
        
        self.navigationItem.title = @"Normal";
        
        self.timer = [SHTimer timerWithTimeInterval:0.01 repeats:YES timerHandler:handler];
        
//        self.timer = [SHTimer timerWithTimeInterval:0.01 repeats:YES timerHandler:^(SHTimer *timer) {
//
//        }];
        
    }else{
        
        self.navigationItem.title = @"Scheduled";
        
        self.timer = [SHTimer scheduledTimerWithTimeInterval:0.01 repeats:YES timerHandler:handler];
    }
    
    self.timer.delegate = self;
}

#pragma mark - Timer Operation
- (IBAction)start:(id)sender {
    
    [self.timer start];
}

- (IBAction)stop:(id)sender {
    self.sec = 0;
    [self.timer stop];
}

- (IBAction)pause:(id)sender {
    [self.timer pause];
}

- (IBAction)reset:(id)sender {
    self.sec = 0;
    [self.timer reset];
}

#pragma mark - RSTimerDelegate
- (void)timer:(SHTimer *)timer didEnterBackgroundWhenActionInTime:(double)timePoint {
    NSLog(@"%s -- %lf",__func__,timePoint);
}
- (void)timer:(SHTimer *)timer willEnterForegroundWhenActionInTime:(double)timePoint sinceEnterBackground:(double)durationTime {
    NSLog(@"%s -- %lf -- %lf",__func__,timePoint, durationTime);
    
    NSInteger intTime = durationTime * 100;
    
    CGFloat floatTime = intTime / 100.0;
    
    NSLog(@"%f",floatTime);
    
    //    if (self.sec - floatTime <= 0) {
    //
    //    }
    
    self.sec += floatTime;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
