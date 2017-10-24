//
//  MultiDownloadController.m
//  ZCBackgroundDownloadDemo
//
//  Created by 张三弓 on 2017/10/21.
//  Copyright © 2017年 张三弓. All rights reserved.
//

#import "MultiDownloadController.h"
#import "AppDelegate.h"

@interface MultiDownloadController ()<NSURLSessionDownloadDelegate>

@end

@implementation MultiDownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self back_download];
}

- (void)back_download{
    
    NSArray * urlArr = @[@"http://sw.bos.baidu.com/sw-search-sp/software/e601e72f00f/MacDict_mac_2.0.2.dmg",
                         @"http://sw.bos.baidu.com/sw-search-sp/software/c11d0f8193b26/FormatFactory_bd_4.0.5.0_setup.exe",
                         @"http://dl1sw.baidu.com/soft/38/10041/xcn-dvd-creator_6.1.4.0124.exe?version=3807236358"];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"zc string 1"];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    
    for (NSString * urlString in urlArr) {
        [self startTaskWithUrl:urlString session:session];
    }
}

- (void)startTaskWithUrl:(NSString *)urlString session:(NSURLSession *)session{
    NSURL * url = [NSURL URLWithString:urlString];
    NSURLSessionDownloadTask * downloadTask = [session downloadTaskWithURL:url];
    [downloadTask resume];
}

#pragma mark NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error{
    NSLog(@"zc NSURLSessionDelegate 1");
}
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    NSLog(@"zc NSURLSessionDelegate 2");
}

typedef void(^CompletionHandlerType)();

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"zc NSURLSessionDelegate 3");
    CompletionHandlerType block = ((AppDelegate *)[UIApplication sharedApplication].delegate).muDic[session.configuration.identifier];
    if (block) {
        block();
    }
}

#pragma mark NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    NSLog(@"zc NSURLSessionTaskDelegate 8");
}

#pragma mark NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@"zc NSURLSessionDownloadDelegate 1");
    NSString * libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString * fullPath  =[NSString stringWithFormat:@"%@/dl.data", libPath];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:fullPath] error:nil];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    NSLog(@"zc NSURLSessionDownloadDelegate 2 %f",totalBytesWritten/(totalBytesExpectedToWrite*1.0));
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes{
    NSLog(@"zc NSURLSessionDownloadDelegate 3");
}

@end
