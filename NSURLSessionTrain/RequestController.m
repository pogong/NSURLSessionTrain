//
//  RequestController.m
//  NetworkTrain
//
//  Created by Shendou on 2017/10/20.
//  Copyright © 2017年 Shendou. All rights reserved.
//

#import "RequestController.h"

@interface RequestController ()<NSURLSessionDataDelegate>
{
    NSMutableData * _allData;
}

@end

@implementation RequestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self request_delegate];
}

- (void)request_block{
    NSURL *url = [NSURL URLWithString:@"http://c.3g.163.com/photo/api/list/0096/4GJ60096.json"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data,
                                                                NSURLResponse *response,
                                                                NSError *error) {
                                                id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                                NSLog(@"result: %@", result);
                                            }];
    [dataTask resume];
}

- (void)request_delegate{
    _allData = [NSMutableData data];
    
    NSURLSessionConfiguration *configura = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configura delegate:self delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:@"http://c.3g.163.com/photo/api/list/0096/4GJ60096.json"];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url];
    [dataTask resume];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
        return;
    }
    
    NSError *er = nil;
    id result = [NSJSONSerialization JSONObjectWithData:_allData options:NSJSONReadingMutableContainers error:&er];
    NSLog(@"result: %@", result);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [_allData appendData:data];
}

@end
