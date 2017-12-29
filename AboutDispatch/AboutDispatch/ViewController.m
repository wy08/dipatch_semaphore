//
//  ViewController.m
//  AboutDispatch
//
//  Created by mac on 2017/12/29.
//  Copyright © 2017年 baby. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self testDispatch_sempaphore];
    [self testDispatch_group];
}

/**
 关于异步操作按照信号量的顺序进行一步步返回
 * dispatch_semaphore_t 创建信号量，如果value小0 的话，这个信号量为空，
 * dispatch_semaphore_wait 可以让信号量减1，如果信号量是0，会等到信号量为非0再次进行下一步操作
 * dispatch_semaphore_signal 可以让信号量加1
 * 可以使用sleep进行区分执行顺序
 */
- (void)testDispatch_sempaphore {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    //进行异步操作
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSLog(@"异步操作1：%@", [NSThread currentThread]);
        dispatch_semaphore_signal(semaphore);
    });

    //异步操作2
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(2);
        NSLog(@"异步操作2：%@", [NSThread currentThread]);
        dispatch_semaphore_signal(semaphore);
    });
    //异步操作3
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(3);
        NSLog(@"异步操作3：%@", [NSThread currentThread]);
        dispatch_semaphore_signal(semaphore);
    });

}
    
    

/**
 * dispatch_queue_t 操作
 * dispatch_group_t 任务组(进出规则：先进先出)
 * dispatch_group_enter  添加任务
 * dispatch_group_leave 任务完成
 * dispatch_group_wait 对子线程阻塞式超时操作，也就是所谓的任务最大时长
 * dispatch_enter和dispatch_leave要成对出现
 
 */
- (void)testDispatch_group {
    //创建
    dispatch_queue_t quete = dispatch_queue_create("baby", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    dispatch_group_async(group, quete, ^{
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            sleep(5);
            NSLog(@"使用dispatch_group1进行网络请求：%@", [NSThread currentThread]);
            dispatch_group_leave(group);
        });
        sleep(2);
//        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5*NSEC_PER_SEC)));
        NSLog(@"队列1完成任务1：%@", [NSThread currentThread]);
    });
    
    dispatch_group_enter(group);
    dispatch_group_async(group, quete, ^{
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            sleep(5);
            NSLog(@"使用dispatch_group2进行网络请求：%@", [NSThread currentThread]);
            dispatch_group_leave(group);
        });
        sleep(2);
        NSLog(@"完成任务2：%@", [NSThread currentThread]);
    });

    dispatch_group_enter(group);
    dispatch_group_async(group, quete, ^{
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            sleep(5);
            NSLog(@"使用dispatch_group3进行网络请求：%@", [NSThread currentThread]);
            dispatch_group_leave(group);
        });
        sleep(2);
        NSLog(@"完成任务3：%@", [NSThread currentThread]);
    });
    sleep(2);
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"最后执行 ---- %@", [NSThread currentThread]);
    });

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
