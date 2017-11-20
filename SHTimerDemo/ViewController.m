//
//  ViewController.m
//  SHTimerDemo
//
//  Created by Criss on 2017/11/20.
//  Copyright © 2017年 Criss. All rights reserved.
//

#import "ViewController.h"

#import "SHTimerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)normalTimer:(id)sender {
    
    SHTimerViewController *VC = [[SHTimerViewController alloc] initWithTimerType:SHTimerTypeNormal];
    
    [self.navigationController pushViewController:VC animated:YES];
}

- (IBAction)scheduledTimer:(id)sender {
    
    SHTimerViewController *VC = [[SHTimerViewController alloc] initWithTimerType:SHTimerTypeScheduled];
    
    [self.navigationController pushViewController:VC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
