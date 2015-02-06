//
//  SecondViewController.m
//  ReactiveCocoaSample
//
//  Created by 姚卓禹 on 15/2/4.
//  Copyright (c) 2015年 姚卓禹. All rights reserved.
//

#import "SecondViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface SecondViewController (){
    RACSignal *siganl;
    NSString *name;
}

@property (nonatomic, strong) NSString *email;

@end

@implementation SecondViewController

- (void)dealloc{
    NSLog(@"dealloc %@", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RAC(self, self.email) = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"11"];
        return nil;
    }];
    NSLog(@"self.email %@", self.email);
    
    //[self testSignalRetainCycle1];
    
    [self testSignalRetainCycle2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)testMethod{
    
}

#pragma mark - test

- (void)testSignalRetainCycle1{
    @weakify(self)
    siganl = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [self testMethod];
        return nil;
    }];
}

- (void)testSignalRetainCycle2{
    [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self testMethod];
        return nil;
    }];
}


@end
