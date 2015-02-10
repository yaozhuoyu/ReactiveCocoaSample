//
//  ViewController.m
//  ReactiveCocoaSample
//
//  Created by 姚卓禹 on 15/2/2.
//  Copyright (c) 2015年 姚卓禹. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController (){
    NSTimer *timer;
}
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *catName;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //1. 测试监视对象的一个属性的变化
    //[self testObserveUserNameChanged];
    
    //2.测试集合的转换
    //[self testCollectionTransformations];
    
    //3.测试subscription
    //[self testSubscription];
    
    //4.conmbin stream
    //[self testCombineStreams];
    
    //5.合并signals
    //[self testCombineSignals];
    
    //6.测试RACSequence
    //[self testSequence];
    
    //7.测试Signal
    //[self testSignal];
    
    //8.测试distinctUntilChanges
    //[self testDistinctUntilChanges];
    
    //9.测试RACDefault
    //[self testRACDefault];
    
    //10. Signal then测试
    //[self testSignalThen];
    
    //11. Signal Throttling 测试
    //[self testSignalThrottle];
    
    //12. subscribeNext函数分析
    //[self analyzeSubscribeNext];
    
    //13. signal concat
    //[self testSignalConcat];
    
    //14. signal defer
    //[self testSignalDefer];
    
    //15. signal take
    //[self testSignalTake];

    //16.signal switchToLatest
    //[self testSignalSwitchToLatest];

    //17. signal flatten:(NSUInteger)maxConcurrent
    //[self testSignalFlattenMaxcount];
    
    //18. signla catch测试
    //[self testSignalCatch];

    //19. signal doNext测试
    //[self testSignalDoNext];
    
    //20. signal mapReplace
    //[self testSignalMapReplace];
    
    //21. signal 测试 flattenMap subscribe RACSubject
    //[self testFlattenMapAndSubscribeAndTake];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/////////////////////////////////////////////////////////////////

- (void)testObserveUserNameChanged{
    [RACObserve(self, userName) subscribeNext:^(id newName) {
        NSLog(@"newName %@", newName);
    }];
    
    self.userName = @"userName1";
    _userName = @"userName2";   //没有效果，必须self.
    self.userName = @"userName3";
    
    /*
     2015-02-02 11:45:38.309 ReactiveCocoaSample[4190:81161] newName (null)
     2015-02-02 11:45:38.310 ReactiveCocoaSample[4190:81161] newName userName1
     2015-02-02 11:45:38.310 ReactiveCocoaSample[4190:81161] newName userName3
     */
    
}

- (void)testCollectionTransformations{
    
    NSArray *strings = @[@"str1",@"str2", @"st", @"str3"];
    RACSequence *stringsSequence =
    [[strings.rac_sequence filter:^BOOL(NSString *str) {
        return str.length > 2;
    }] map:^id(NSString *str) {
        return [str stringByAppendingString:@"t"];
    }];
    NSLog(@"Stings \n%@", stringsSequence.array);
    /*
     2015-02-02 14:18:59.462 ReactiveCocoaSample[5364:133734] Stings
     (
     str1t,
     str2t,
     str3t
     )
     */
    
    //map
    RACSequence *letters = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence;
    RACSequence *mapped = [letters map:^(NSString *value) {
        return [value stringByAppendingString:value];
    }];
    NSLog(@"map: %@", mapped.array);
    /*
     2015-02-02 15:09:02.965 ReactiveCocoaSample[6268:157148] map: (
     AA,
     BB,
     CC,
     DD,
     EE,
     FF,
     GG,
     HH,
     II
     )
     */
    
    
    //filter
    RACSequence *numbers = [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence;
    RACSequence *filtered = [numbers filter:^ BOOL (NSString *value) {
        return (value.intValue % 2) == 0;
    }];
    NSLog(@"map: %@", filtered.array);
    /*
     2015-02-02 15:10:33.364 ReactiveCocoaSample[6332:158191] map: (
     2,
     4,
     6,
     8
     )
     */
}

- (void)testSubscription{
    //
    RACSignal *letters = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence.signal;
    [letters subscribeNext:^(NSString *str) {
        NSLog(@"%@",str);
    }];
    
    
    
    {
        //signal和它的subscriber是 side effects的。
        __block NSUInteger subscriptions = 0;
        RACSignal *loggingSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            subscriptions ++;
            [subscriber sendCompleted];
            return nil;
        }];
        
        [loggingSignal subscribeCompleted:^{
            NSLog(@"1.subscription %tu", subscriptions);
        }];
        
        [loggingSignal subscribeCompleted:^{
            NSLog(@"2.subscription %tu", subscriptions);
        }];
        
        /*
         2015-02-02 14:41:22.708 ReactiveCocoaSample[5927:146447] 1.subscription 1
         2015-02-02 14:41:22.709 ReactiveCocoaSample[5927:146447] 2.subscription 2
         */
    }
    
    
    {
        //-do 方法能给signal添加side effect。
        __block unsigned subscriptions = 0;
        
        RACSignal *loggingSignal = [RACSignal createSignal:^ RACDisposable * (id<RACSubscriber> subscriber) {
            subscriptions++;
            [subscriber sendCompleted];
            return nil;
        }];
        
        loggingSignal = [loggingSignal doCompleted:^{
            NSLog(@"about to complete subscription %u", subscriptions);
        }];
        // 此处不会有任何的输出，既不会输出 about to complete subscription
        

        [loggingSignal subscribeCompleted:^{
            NSLog(@"subscription %u", subscriptions);
        }];
        // about to complete subscription 1
        // subscription 1
        
        /*
         2015-02-02 15:03:51.686 ReactiveCocoaSample[6139:154415] about to complete subscription 1
         2015-02-02 15:03:51.686 ReactiveCocoaSample[6139:154415] subscription 1
         */
    }
    
    
}

- (void)testCombineStreams{
    
    {
        //concat，此方法会将一个stream的值，添加到另外一个stream上
        RACSequence *letters = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence;
        RACSequence *numbers = [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence;
        RACSequence *concatenated = [letters concat:numbers];
        NSLog(@"concatenated: %@", concatenated.array);
        
        /*
         A B C D E F G H I 1 2 3 4 5 6 7 8 9
         */
    }
    
    {
        //flattening
        //flatten操作主要应用在 stream of stream上，并合并他们的值在一个单独的新的stream里面。
        
        RACSequence *letters = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence;
        RACSequence *numbers = [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence;
        RACSequence *sequenceOfSequences = @[ letters, numbers ].rac_sequence;
        NSLog(@"sequenceOfSequences:\n %@", sequenceOfSequences.array);
        
        /*
         sequenceOfSequences:
         (
         "<RACArraySequence: 0x7f91e5907f70>{ name = , array = (\n    A,\n    B,\n    C,\n    D,\n    E,\n    F,\n    G,\n    H,\n    I\n) }",
         "<RACArraySequence: 0x7f91e5905100>{ name = , array = (\n    1,\n    2,\n    3,\n    4,\n    5,\n    6,\n    7,\n    8,\n    9\n) }"
         )
         */
        
        RACSequence *flattened = [sequenceOfSequences flatten];
        NSLog(@"flattend:\n %@", flattened.array);
        /*
         A B C D E F G H I 1 2 3 4 5 6 7 8 9
         */
    }
    
    {
        RACSubject *letters = [RACSubject subject];
        RACSubject *numbers = [RACSubject subject];
        RACSignal *signalOfSignals = [RACSignal createSignal:^ RACDisposable * (id<RACSubscriber> subscriber) {
            [subscriber sendNext:letters];
            [subscriber sendNext:numbers];
            [subscriber sendCompleted];
            return nil;
        }];
        
        RACSignal *flattened = [signalOfSignals flatten];
        
        [flattened subscribeNext:^(NSString *x) {
            NSLog(@"%@", x);
        }];
        
        [letters sendNext:@"A"];
        [numbers sendNext:@"1"];
        [letters sendNext:@"B"];
        [letters sendNext:@"C"];
        [numbers sendNext:@"2"];
        /*
         2015-02-02 15:36:14.727 ReactiveCocoaSample[7077:174522] A
         2015-02-02 15:36:14.727 ReactiveCocoaSample[7077:174522] 1
         2015-02-02 15:36:14.727 ReactiveCocoaSample[7077:174522] B
         2015-02-02 15:36:14.728 ReactiveCocoaSample[7077:174522] C
         2015-02-02 15:36:14.728 ReactiveCocoaSample[7077:174522] 2
         */
    }
    
    {
        //flattenMap
        // flattenMap会转换stream的每一个值到一个新的stream中，所有的stream会flatten down 到一个单独的stream。
        
        RACSequence *numbers = [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence;
        RACSequence *extended = [numbers flattenMap:^(NSString *num) {
            return @[num, num].rac_sequence;
        }];
        NSLog(@"array %@", extended.array);
        /*
         1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9
         */
        
        RACSequence *edited = [numbers flattenMap:^(NSString *num) {
            if (num.intValue % 2 == 0) {
                return [RACSequence empty];
            } else {
                NSString *newNum = [num stringByAppendingString:@"_"];
                return [RACSequence return:newNum]; 
            }
        }];
        NSLog(@"edit array: %@", edited.array);
        /*
         2015-02-02 16:14:40.354 ReactiveCocoaSample[7550:187674] edit array: (
         "1_",
         "3_",
         "5_",
         "7_",
         "9_"
         )
         */
    }
}

- (void)testCombineSignals{
    {
        //sequencing
        //then 会开始最初的signal，等待其完成，然后转发新的signal。
        RACSignal *letters = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence.signal;
        RACSignal *sequenced = [[letters doNext:^(NSString *letter) {
            NSLog(@"%@", letter);
        }] then:^RACSignal *{
            return [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence.signal;
        }];
        
        [sequenced subscribeNext:^(id x) {
            NSLog(@"= %@", x);
        }];
        
        /*
         2015-02-02 16:29:49.803 ReactiveCocoaSample[8030:196388] A
         2015-02-02 16:29:49.804 ReactiveCocoaSample[8030:196388] B
         2015-02-02 16:29:49.805 ReactiveCocoaSample[8030:196388] C
         2015-02-02 16:29:49.805 ReactiveCocoaSample[8030:196388] D
         2015-02-02 16:29:49.805 ReactiveCocoaSample[8030:196388] E
         2015-02-02 16:29:49.805 ReactiveCocoaSample[8030:196388] F
         2015-02-02 16:29:49.805 ReactiveCocoaSample[8030:196388] G
         2015-02-02 16:29:49.806 ReactiveCocoaSample[8030:196388] H
         2015-02-02 16:29:49.806 ReactiveCocoaSample[8030:196388] I
         2015-02-02 16:29:49.806 ReactiveCocoaSample[8030:196390] = 1
         2015-02-02 16:29:49.806 ReactiveCocoaSample[8030:196390] = 2
         2015-02-02 16:29:49.807 ReactiveCocoaSample[8030:196390] = 3
         2015-02-02 16:29:49.807 ReactiveCocoaSample[8030:196390] = 4
         2015-02-02 16:29:49.807 ReactiveCocoaSample[8030:196390] = 5
         2015-02-02 16:29:49.807 ReactiveCocoaSample[8030:196390] = 6
         2015-02-02 16:29:49.807 ReactiveCocoaSample[8030:196390] = 7
         2015-02-02 16:29:49.807 ReactiveCocoaSample[8030:196390] = 8
         2015-02-02 16:29:49.807 ReactiveCocoaSample[8030:196390] = 9
         */
    }
    
    {
        //merging
        //将多个signals的值转发到一个stream中，
        
        RACSubject *letters = [RACSubject subject];
        RACSubject *numbers = [RACSubject subject];
        RACSignal *merged = [RACSignal merge:@[ letters, numbers ]];
        
        [merged subscribeNext:^(NSString *x) {
            NSLog(@"%@", x);
        }];
        
        [letters sendNext:@"A"];
        [numbers sendNext:@"1"];
        [letters sendNext:@"B"];
        [letters sendNext:@"C"];
        [numbers sendNext:@"2"];
        /*
         2015-02-02 16:36:35.847 ReactiveCocoaSample[8439:201881] A
         2015-02-02 16:36:35.848 ReactiveCocoaSample[8439:201881] 1
         2015-02-02 16:36:35.848 ReactiveCocoaSample[8439:201881] B
         2015-02-02 16:36:35.848 ReactiveCocoaSample[8439:201881] C
         2015-02-02 16:36:35.848 ReactiveCocoaSample[8439:201881] 2
         */
        
    }
    
    
    {
        //combineLatest
        //这个方法会watch multiple signals for changes, and then send the latest values from all of them when a change occurs
        RACSubject *letters = [RACSubject subject];
        RACSubject *numbers = [RACSubject subject];
        RACSignal *combined = [RACSignal
                               combineLatest:@[ letters, numbers ]
                               reduce:^(NSString *letter, NSString *number) {
                                   return [letter stringByAppendingString:number];
                               }];
        
        [combined subscribeNext:^(id x) {
            NSLog(@"%@", x);
        }];
        
        [letters sendNext:@"A"];
        [letters sendNext:@"B"];
        [numbers sendNext:@"1"];
        [numbers sendNext:@"2"];
        [letters sendNext:@"C"];
        [numbers sendNext:@"3"];
        
        /*
         2015-02-02 16:38:27.510 ReactiveCocoaSample[8558:203355] B1
         2015-02-02 16:38:27.511 ReactiveCocoaSample[8558:203355] B2
         2015-02-02 16:38:27.511 ReactiveCocoaSample[8558:203355] C2
         2015-02-02 16:38:27.511 ReactiveCocoaSample[8558:203355] C3
         */
        
    }
    
    {
        //switchToLatest
        //-switchToLatest operator is applied to a signal-of-signals, and always forwards the values from the latest signal:
        RACSubject *letters = [RACSubject subject];
        RACSubject *numbers = [RACSubject subject];
        RACSubject *signalOfSignals = [RACSubject subject];
        
        RACSignal *switched = [signalOfSignals switchToLatest];
        
        [switched subscribeNext:^(NSString *x) {
            NSLog(@"%@", x);
        }];
        
        [signalOfSignals sendNext:letters];
        [letters sendNext:@"A"];
        [letters sendNext:@"B"];
        
        [signalOfSignals sendNext:numbers];
        [letters sendNext:@"C"];
        [numbers sendNext:@"1"];
        
        [signalOfSignals sendNext:letters];
        [numbers sendNext:@"2"];
        [letters sendNext:@"D"];
        
        /*
         2015-02-02 16:45:37.122 ReactiveCocoaSample[8762:206848] A
         2015-02-02 16:45:37.122 ReactiveCocoaSample[8762:206848] B
         2015-02-02 16:45:37.122 ReactiveCocoaSample[8762:206848] 1
         2015-02-02 16:45:37.123 ReactiveCocoaSample[8762:206848] D
         */
    }
}


///////////////////////////////////////////////////////////////

- (void)testSequence {
    {
        //RACSequence的计算缺省情况下是lazily的，只有在访问的时候才回去计算,一旦计算完成，再次请求的时候就不需要计算。
        NSArray *strings = @[@"A", @"B", @"C", @"D", @"E"];
        RACSequence *sequence = [strings.rac_sequence map:^id(NSString *str) {
            NSLog(@"====");
            return [str stringByAppendingString:@"_"];
        }];
        
        NSLog(@"head:%@, tail:%@", sequence.head, sequence.tail.head);
        
        //但是想要一下就计算出所有的值的话，可以访问属性eagerSequence
        sequence = sequence.eagerSequence;
        
        /*
         2015-02-02 19:06:05.204 ReactiveCocoaSample[9922:258201] ====
         2015-02-02 19:06:05.205 ReactiveCocoaSample[9922:258201] ====
         2015-02-02 19:06:05.205 ReactiveCocoaSample[9922:258201] head:A_, tail:B_
         2015-02-02 19:06:05.205 ReactiveCocoaSample[9922:258201] ====
         2015-02-02 19:06:05.205 ReactiveCocoaSample[9922:258201] ====
         2015-02-02 19:06:05.205 ReactiveCocoaSample[9922:258201] ====
         */
    }
    
    {
        //side effect只会发生一次
        NSArray *strings = @[ @"A", @"B", @"C" ];
        RACSequence *sequence = [strings.rac_sequence map:^(NSString *str) {
            NSLog(@"%@", str);
            return [str stringByAppendingString:@"_"];
        }];
        
        // Logs "A" during this call.
        NSString *concatA = sequence.head;
        
        // Logs "B" during this call.
        NSString *concatB = sequence.tail.head;
        
        // Does not log anything.
        NSString *concatB2 = sequence.tail.head;
        
        RACSequence *derivedSequence = [sequence map:^(NSString *str) {
            return [@"_" stringByAppendingString:str];
        }];
        
        // Still does not log anything, because "B_" was already evaluated, and the log
        // statement associated with it will never be re-executed.
        NSString *concatB3 = derivedSequence.tail.head;
        
        NSLog(@"concatA:%@, concatB:%@, concatB2:%@, concatB3:%@", concatA, concatB, concatB2, concatB3);
        /*
         2015-02-02 19:13:10.574 ReactiveCocoaSample[10031:261329] A
         2015-02-02 19:13:10.574 ReactiveCocoaSample[10031:261329] B
         2015-02-02 19:13:10.575 ReactiveCocoaSample[10031:261329] concatA:A_, concatB:B_, concatB2:B_, concatB3:_B_
         */
    }

}

- (void)testSignal{
    {
        //每一次subscription，队徽产生side effects
        __block int missilesToLaunch = 0;
        
        RACSignal *processedSignal = [[RACSignal
                                       return:@"missiles"]
                                      map:^(id x) {
                                          missilesToLaunch++;
                                          return [NSString stringWithFormat:@"will launch %d %@", missilesToLaunch, x];
                                      }];
        
        // This will print "First will launch 1 missiles"
        [processedSignal subscribeNext:^(id x) {
            NSLog(@"First %@", x);
        }];
        
        // This will print "Second will launch 2 missiles"
        [processedSignal subscribeNext:^(id x) {
            NSLog(@"Second %@", x);
        }];
        
        /*
         2015-02-02 19:54:32.078 ReactiveCocoaSample[10426:278385] First will launch 1 missiles
         2015-02-02 19:54:32.078 ReactiveCocoaSample[10426:278385] Second will launch 2 missiles
         */
    }
}

- (void)testDistinctUntilChanges{
    RACSignal *signal = [RACObserve(self, userName) map:^id(NSString *value) {
        return value;
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"normal :%@", x);
    }];
    
    RACSignal *untilChangeSignal = [signal distinctUntilChanged];
    
    [untilChangeSignal subscribeNext:^(id x) {
        NSLog(@"untilChange :%@", x);
    }];
    
    self.userName = @"1";
    self.userName = @"2";
    self.userName = @"2";
    self.userName = @"1";
    
    /*
     2015-02-03 15:29:18.999 ReactiveCocoaSample[11338:170150] normal :(null)
     2015-02-03 15:29:19.005 ReactiveCocoaSample[11338:170150] untilChange :(null)
     2015-02-03 15:29:19.006 ReactiveCocoaSample[11338:170150] untilChange :1
     2015-02-03 15:29:19.006 ReactiveCocoaSample[11338:170150] normal :1
     2015-02-03 15:29:19.006 ReactiveCocoaSample[11338:170150] untilChange :2
     2015-02-03 15:29:19.006 ReactiveCocoaSample[11338:170150] normal :2
     2015-02-03 15:29:19.006 ReactiveCocoaSample[11338:170150] normal :2
     2015-02-03 15:29:19.007 ReactiveCocoaSample[11338:170150] untilChange :1
     2015-02-03 15:29:19.007 ReactiveCocoaSample[11338:170150] normal :1
     */
}

- (void)testRACDefault{
    {
        [RACObserve(self, userName) subscribeNext:^(id x) {
            NSLog(@"1.userName:%@", x);
        }];
        
        RAC(self, userName, @"default") = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"userName1"];
            [subscriber sendNext:nil];
            [subscriber sendNext:@"userName2"];
            [subscriber sendCompleted];
            return nil;
        }];
        /*
         2015-02-04 12:02:51.998 ReactiveCocoaSample[5285:89165] userName:(null)
         2015-02-04 12:02:51.999 ReactiveCocoaSample[5285:89165] userName:userName1
         2015-02-04 12:02:51.999 ReactiveCocoaSample[5285:89165] userName:default
         2015-02-04 12:02:51.999 ReactiveCocoaSample[5285:89165] userName:userName2
         */
    }
    
    {
        [RACObserve(self, userName) subscribeNext:^(id x) {
            NSLog(@"2.userName:%@", x);
        }];
        
        RAC(self, userName) = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"userName1"];
            [subscriber sendNext:nil];
            [subscriber sendNext:@"userName2"];
            [subscriber sendCompleted];
            return nil;
        }];
        /*
         2015-02-04 12:04:58.310 ReactiveCocoaSample[5418:91099] userName:(null)
         2015-02-04 12:04:58.311 ReactiveCocoaSample[5418:91099] userName:userName1
         2015-02-04 12:04:58.311 ReactiveCocoaSample[5418:91099] userName:(null)
         2015-02-04 12:04:58.312 ReactiveCocoaSample[5418:91099] userName:userName2
         */
    }
    
}

- (void)testSignalThen{
//    {
//        [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//            [subscriber sendCompleted];
//            //[subscriber sendError:[NSError errorWithDomain:@"test" code:100 userInfo:nil]];
//            return nil;
//        }] then:^RACSignal *{
//            return [RACSignal return:@"then signal"];
//        }] subscribeNext:^(id x) {
//            NSLog(@"sub next: %@", x);
//        } error:^(NSError *error) {
//            NSLog(@"sub error: %@", error);
//        } completed:^{
//            NSLog(@"sub completed");
//        }];
//        /*
//         对于then，只有前一个signal发送completed之后，才能往下进行，
//         如果subscriber直接senderror，则跳过所有的，到最后的error block打印错误
//         */
//        
//    }
    
    {
        [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendCompleted];
            return nil;
        }] then:^RACSignal *{
            return RACObserve(self, userName);
        }] subscribeNext:^(id x) {
            NSLog(@"sub next: %@", x);
        } error:^(NSError *error) {
            NSLog(@"sub error: %@", error);
        } completed:^{
            NSLog(@"sub completed");
        }];
        
        self.userName = @"userName1";
        self.userName = @"userName2";
        self.userName = @"userName3";
        
        
        /*
         2015-02-04 20:57:05.955 ReactiveCocoaSample[8643:285400] sub next: (null)
         2015-02-04 20:57:05.956 ReactiveCocoaSample[8643:285400] sub next: userName1
         2015-02-04 20:57:05.956 ReactiveCocoaSample[8643:285400] sub next: userName2
         2015-02-04 20:57:05.956 ReactiveCocoaSample[8643:285400] sub next: userName3
         */
    }
    
}

- (void)testSignalThrottle{
    [[RACObserve(self, userName) throttle:1] subscribeNext:^(id x) {
        NSLog(@"x %@", x);
    }];
    self.userName = @"userName1";
    self.userName = @"userName2";
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.userName = @"userName3";
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.userName = @"userName4";
    });
    
    /*
     2015-02-05 10:32:24.909 ReactiveCocoaSample[1692:38218] x userName3
     2015-02-05 10:32:26.559 ReactiveCocoaSample[1692:38218] x userName4
     */
}

- (void)analyzeSubscribeNext{
    RACSignal *normalSignal =
    [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"next"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    [normalSignal subscribeNext:^(id x) {
        NSLog(@"x:%@", x);
    } completed:^{
        NSLog(@"completed");
    }];
    
    /*
     1.当开始subscribe一个signal的时候，signal会创建一个RACSubscriber，然后调用subscribe函数
     2.signal的subscribe函数会执行创建signal的时候传入的block
     3.block中的sendNext函数会接着调用RACSubscriber的next block，所以就打印出log了。
     */
}

- (void)testSignalConcat{
    {
        RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"signalA-1"];
            [subscriber sendNext:@"signalA-2"];
            [subscriber sendCompleted];
            //[subscriber sendError:nil];
            return nil;
        }];
        
        RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"signalB-1"];
            [subscriber sendNext:@"signalB-2"];
            [subscriber sendCompleted];
            return nil;
        }];
        
        [[signalA concat:signalB] subscribeNext:^(id x) {
            NSLog(@"next: %@",x);
        } error:^(NSError *error) {
            NSLog(@"error: %@",error);
        } completed:^{
            NSLog(@"completed");
        }];
        
        /*
         2015-02-07 11:15:40.403 ReactiveCocoaSample[16371:160451] next: signalA-1
         2015-02-07 11:15:40.404 ReactiveCocoaSample[16371:160451] next: signalA-2
         2015-02-07 11:15:40.404 ReactiveCocoaSample[16371:160451] next: signalB-1
         2015-02-07 11:15:40.404 ReactiveCocoaSample[16371:160451] next: signalB-2
         2015-02-07 11:15:40.404 ReactiveCocoaSample[16371:160451] completed
         */
    }
    
    {
        RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"signalA-1"];
            [subscriber sendNext:@"signalA-2"];
            [subscriber sendCompleted];
            return nil;
        }];
        
        RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"signalB-1"];
            [subscriber sendNext:@"signalB-2"];
            [subscriber sendCompleted];
            return nil;
        }];
        
        
        [[signalA then:^RACSignal *{
            return signalB;
        }] subscribeNext:^(id x) {
            NSLog(@"next %@", x);
        } error:^(NSError *error) {
            NSLog(@"error: %@",error);
        } completed:^{
            NSLog(@"completed");
        }];
        
        /*
         2015-02-07 15:18:21.929 ReactiveCocoaSample[17899:197875] next signalB-1
         2015-02-07 15:18:21.930 ReactiveCocoaSample[17899:197875] next signalB-2
         2015-02-07 15:18:21.931 ReactiveCocoaSample[17899:197875] completed
         */
    }
}

- (void)testSignalDefer{
    {
        RACSignal *signal =
        [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"create sigal");
            [[RACObserve(self, userName) filter:^BOOL(NSString *str) {
                return [str length] > 1;
            }] subscribe:subscriber];
            
            return nil;
        }];
        
        [signal subscribeNext:^(id x) {
            NSLog(@"next %@", x);
        } error:^(NSError *error) {
            NSLog(@"error %@", error);
        } completed:^{
            NSLog(@"completed");
        }];
        
        self.userName = @"111";
        self.userName = @"2";
        self.userName = @"333";
        /*
         2015-02-07 16:10:09.961 ReactiveCocoaSample[18717:217705] create sigal
         2015-02-07 16:10:09.964 ReactiveCocoaSample[18717:217705] next 111
         2015-02-07 16:10:09.964 ReactiveCocoaSample[18717:217705] next 333
         */
    }
    
    {
        RACSignal *signal = [RACSignal defer:^RACSignal *{
            NSLog(@"create sigal");
            return
            [RACObserve(self, userName) filter:^BOOL(NSString *str) {
                return [str length] > 1;
            }];
        }];
        
        [signal subscribeNext:^(id x) {
            NSLog(@"next %@", x);
        } error:^(NSError *error) {
            NSLog(@"error %@", error);
        } completed:^{
            NSLog(@"completed");
        }];
        
        self.userName = @"111";
        self.userName = @"2";
        self.userName = @"333";
        
        /*
         2015-02-07 16:10:44.294 ReactiveCocoaSample[18758:218189] create sigal
         2015-02-07 16:10:44.297 ReactiveCocoaSample[18758:218189] next 111
         2015-02-07 16:10:44.298 ReactiveCocoaSample[18758:218189] next 333
         */
    }
}

- (void)testSignalTake{
    RACSignal *signal =
    [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"2"];
        [subscriber sendNext:@"3"];
        //[subscriber sendCompleted];
        
        return nil;
    }] take:2];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"next:%@", x);
    } error:^(NSError *error) {
        NSLog(@"error:%@", error);
    } completed:^{
        NSLog(@"completed");
    }];
    
    /*
     2015-02-08 17:42:50.167 ReactiveCocoaSample[941:19481] next:1
     2015-02-08 17:42:50.168 ReactiveCocoaSample[941:19481] next:2
     2015-02-08 17:42:50.169 ReactiveCocoaSample[941:19481] completed
     */
}

- (void)testSignalSwitchToLatest{
    {
        [[[RACObserve(self, userName) map:^id(NSString *un) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [subscriber sendNext:[NSString stringWithFormat:@"1.%@", un]];
                [subscriber sendNext:[NSString stringWithFormat:@"2.%@", un]];
                [subscriber sendCompleted];
                return nil;
            }];
        }] switchToLatest] subscribeNext:^(id x) {
            NSLog(@"next:%@", x);
        } error:^(NSError *error) {
            NSLog(@"error:%@", error);
        } completed:^{
            NSLog(@"completed");
        }];
        
        
        
        self.userName = @"u1";
        self.userName = @"u2";
        
        /*
         2015-02-08 18:47:01.789 ReactiveCocoaSample[1657:38092] next:1.(null)
         2015-02-08 18:47:01.789 ReactiveCocoaSample[1657:38092] next:2.(null)
         2015-02-08 18:47:01.790 ReactiveCocoaSample[1657:38092] next:1.u1
         2015-02-08 18:47:01.790 ReactiveCocoaSample[1657:38092] next:2.u1
         2015-02-08 18:47:01.790 ReactiveCocoaSample[1657:38092] next:1.u2
         2015-02-08 18:47:01.791 ReactiveCocoaSample[1657:38092] next:2.u2
         */
    }
    
    {
        RACSubject *letters = [RACSubject subject];
        RACSubject *numbers = [RACSubject subject];
        RACSubject *signalOfSignals = [RACSubject subject];
        
        RACSignal *switched = [signalOfSignals switchToLatest];
        
        [switched subscribeNext:^(NSString *x) {
            NSLog(@"%@", x);
        } completed:^{
            NSLog(@"completed");
        }];
        
        [signalOfSignals sendNext:letters];
        [letters sendNext:@"A"];
        [letters sendNext:@"B"];
        
        [signalOfSignals sendNext:numbers];
        [letters sendNext:@"C"];
        [numbers sendNext:@"1"];
        
        [signalOfSignals sendNext:letters];
        [numbers sendNext:@"2"];
        [letters sendNext:@"D"];
        
        [letters sendCompleted];
        [signalOfSignals sendCompleted];
        //只有当signalOfSignals和最新的signal都compltetd的时候，才算完成
        //sends `completed` when both the receiver and the last sent signal complete.
    }
    
}

- (void)testSignalFlattenMaxcount{
    
    {
        RACSubject *subject1 = [RACSubject subject];
        RACSubject *subject2 = [RACSubject subject];
        RACSubject *subject3 = [RACSubject subject];
        
        RACSubject *signalOfSignal = [RACSubject subject];
        
        RACSignal *flattenSignal = [signalOfSignal flatten:2];
        [flattenSignal subscribeNext:^(id x) {
            NSLog(@"flatten count next: %@", x);
        } completed:^{
            NSLog(@"completed");
        }];
        
        [signalOfSignal sendNext:subject1];
        [signalOfSignal sendNext:subject2];
        [signalOfSignal sendNext:subject3];
        
        [subject1 sendNext:@"subject1_1"];
        [subject2 sendNext:@"subject2_1"];
        [subject3 sendNext:@"subject3_1"];
        
        [subject1 sendNext:@"subject1_2"];
        [subject2 sendNext:@"subject2_2"];
        [subject3 sendNext:@"subject3_2"];
        
        /*
         2015-02-09 13:16:06.191 ReactiveCocoaSample[2921:117640] flatten count next: subject1_1
         2015-02-09 13:16:06.193 ReactiveCocoaSample[2921:117640] flatten count next: subject2_1
         2015-02-09 13:16:06.193 ReactiveCocoaSample[2921:117640] flatten count next: subject1_2
         2015-02-09 13:16:06.193 ReactiveCocoaSample[2921:117640] flatten count next: subject2_2
         */
    }
    
    {
        RACSubject *subject1 = [RACSubject subject];
        RACSubject *subject2 = [RACSubject subject];
        RACSubject *subject3 = [RACSubject subject];
        
        RACSubject *signalOfSignal = [RACSubject subject];
        
        RACSignal *flattenSignal = [signalOfSignal flatten];
        [flattenSignal subscribeNext:^(id x) {
            NSLog(@"flatten next: %@", x);
        } completed:^{
            NSLog(@"completed");
        }];
        
        [signalOfSignal sendNext:subject1];
        [signalOfSignal sendNext:subject2];
        [signalOfSignal sendNext:subject3];
        
        [subject1 sendNext:@"subject1_1"];
        [subject2 sendNext:@"subject2_1"];
        [subject3 sendNext:@"subject3_1"];
        
        [subject1 sendNext:@"subject1_2"];
        [subject2 sendNext:@"subject2_2"];
        [subject3 sendNext:@"subject3_2"];
        
        /*
         2015-02-09 13:16:06.193 ReactiveCocoaSample[2921:117640] flatten next: subject1_1
         2015-02-09 13:16:06.193 ReactiveCocoaSample[2921:117640] flatten next: subject2_1
         2015-02-09 13:16:06.193 ReactiveCocoaSample[2921:117640] flatten next: subject3_1
         2015-02-09 13:16:06.193 ReactiveCocoaSample[2921:117640] flatten next: subject1_2
         2015-02-09 13:16:06.193 ReactiveCocoaSample[2921:117640] flatten next: subject2_2
         2015-02-09 13:16:06.194 ReactiveCocoaSample[2921:117640] flatten next: subject3_2
         */
    }
    
    
}

- (void)testSignalCatch{
    /*
     /// Subscribes to the returned signal when an error occurs.
     - (RACSignal *)catch:(RACSignal * (^)(NSError *error))catchBlock;
     */
    
    RACSubject *subject = [RACSubject subject];
    
    [[subject catch:^RACSignal *(NSError *error) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"catch send next"];
            [subscriber sendCompleted];
            return nil;
        }];
    }] subscribeNext:^(id x) {
        NSLog(@"next %@", x);
    } error:^(NSError *error) {
        NSLog(@"error %@", error);
    } completed:^{
        NSLog(@"completed");
    }];
    
    
    [subject sendNext:@"next1"];
    [subject sendError:[NSError errorWithDomain:@"domain" code:11 userInfo:nil]];
    
    /*
     2015-02-10 13:57:07.012 ReactiveCocoaSample[3251:142730] next next1
     2015-02-10 13:57:07.012 ReactiveCocoaSample[3251:142730] next catch send next
     2015-02-10 13:57:07.013 ReactiveCocoaSample[3251:142730] completed
     */
}

- (void)testSignalDoNext{
    //doNext  在相应next事件之前多一点事情
    RACSignal *doNextSignal =
    [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"next1"];
        [subscriber sendNext:@"next2"];
        [subscriber sendCompleted];
        return nil;
    }] doNext:^(id x) {
        NSLog(@"begin do next %@",x);
    }];
    
    [doNextSignal subscribeNext:^(id x) {
        NSLog(@"next %@",x);
    } error:^(NSError *error) {
        NSLog(@"error %@",error);
    } completed:^{
        NSLog(@"completed");
    }];
    
    /*
     2015-02-10 15:16:21.609 ReactiveCocoaSample[4573:177725] begin do next next1
     2015-02-10 15:16:21.609 ReactiveCocoaSample[4573:177725] next next1
     2015-02-10 15:16:21.609 ReactiveCocoaSample[4573:177725] begin do next next2
     2015-02-10 15:16:21.610 ReactiveCocoaSample[4573:177725] next next2
     2015-02-10 15:16:21.610 ReactiveCocoaSample[4573:177725] completed
     */
}

- (void)testSignalMapReplace{
    RACSignal *signal =
    [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"12"];
        [subscriber sendNext:@"34"];
        [subscriber sendNext:@"56"];
        [subscriber sendCompleted];
        return nil;
    }] mapReplace:@"num"];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"next %@",x);
    } error:^(NSError *error) {
        NSLog(@"error %@",error);
    } completed:^{
        NSLog(@"completed");
    }];
    /*
     2015-02-10 15:27:45.623 ReactiveCocoaSample[4982:185232] next num
     2015-02-10 15:27:45.624 ReactiveCocoaSample[4982:185232] next num
     2015-02-10 15:27:45.624 ReactiveCocoaSample[4982:185232] next num
     2015-02-10 15:27:45.624 ReactiveCocoaSample[4982:185232] completed
     */
}

- (void)testFlattenMapAndSubscribeAndTake{
//    {
//        RACSubject *subject = [RACSubject subject];
//        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//            [[[subject flattenMap:^RACStream *(NSString *str) {
//                return [RACSignal return:str];
//            }]
//            take:1]
//            subscribe:subscriber];
//            
//            return nil;
//        }];
//        
//        [signal subscribeNext:^(id x) {
//            NSLog(@"next : %@", x);
//        } error:^(NSError *error) {
//            NSLog(@"error: %@", error);
//        } completed:^{
//            NSLog(@"completed");
//        }];
//        
//        [subject sendNext:@"1"];
//        
//        /*
//         
//         如果把take 1 删除，就不会打印completed
//         
//         2015-02-11 00:32:32.823 ReactiveCocoaSample[6175:280955] next : 1
//         2015-02-11 00:32:32.824 ReactiveCocoaSample[6175:280955] completed
//         */
//    }
    
    {
        RACSubject *subject = [RACSubject subject];
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            [[[subject map:^id(id value) {
                return value;
            }] take:1] subscribe:subscriber];
            
            return nil;
        }];
        
        [signal subscribeNext:^(id x) {
            NSLog(@"next : %@", x);
        } error:^(NSError *error) {
            NSLog(@"error: %@", error);
        } completed:^{
            NSLog(@"completed");
        }];
        
        [subject sendNext:@"1"];
        
        /*
         
         如果把take 1 删除，就不会打印completed
         
         2015-02-11 00:32:32.823 ReactiveCocoaSample[6175:280955] next : 1
         2015-02-11 00:32:32.824 ReactiveCocoaSample[6175:280955] completed
         */
    }
}

#pragma mark - 
#pragma mark - private

//- (RACSignal *)createHotSignal{
//    
//}
































@end
