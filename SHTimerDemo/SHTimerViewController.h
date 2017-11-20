//
//  SHTimerViewController.h
//  SHTimerDemo
//
//  Created by Criss on 2017/11/20.
//  Copyright © 2017年 Criss. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SHTimerType) {
    SHTimerTypeNormal = 0,
    SHTimerTypeScheduled,
};

@interface SHTimerViewController : UIViewController

- (instancetype)initWithTimerType:(SHTimerType)type;

@end
