//
//  ResumeMultiDownloadController.m
//  ZCBackgroundDownloadDemo
//
//  Created by 张三弓 on 2017/10/22.
//  Copyright © 2017年 张三弓. All rights reserved.
//

#import "ResumeMultiDownloadController.h"
#import "AppDelegate.h"
#import "NSURLSession+CorrectedResumeData.h"

@interface ResumeMultiDownloadController ()<NSURLSessionDownloadDelegate>

@end

@implementation ResumeMultiDownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self resume_back_download];
}

- (void)resume_back_download{
    NSArray * urlArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"urlArr"];
    
    if (urlArr.count > 0) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"zc string 1"];
        NSURLSession * session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    }else{
        urlArr = @[@"http://sw.bos.baidu.com/sw-search-sp/software/e601e72f00f/MacDict_mac_2.0.2.dmg",
                   @"http://sw.bos.baidu.com/sw-search-sp/software/c11d0f8193b26/FormatFactory_bd_4.0.5.0_setup.exe",
                   @"http://dl1sw.baidu.com/soft/38/10041/xcn-dvd-creator_6.1.4.0124.exe?version=3807236358"];
        [[NSUserDefaults standardUserDefaults] setObject:urlArr forKey:@"urlArr"];
        
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"zc string 1"];
        NSURLSession * session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
        
        for (NSString * urlString in urlArr) {
            [self startTaskWithUrl:urlString session:session];
        }
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
    CompletionHandlerType block = ((AppDelegate *)[UIApplication sharedApplication].delegate).muDic[session.configuration.identifier];
    if (block) {
        block();
    }
}

#pragma mark NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    if (error) {
        // check if resume data are available
        if ([error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData]) {
            NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            //通过之前保存的resumeData，获取断点的NSURLSessionTask，调用resume恢复下载
            [self getDownloadTaskRenewWithData:resumeData session:session];
            NSLog(@"zc %@ 开始断点下载",task.originalRequest.URL.absoluteString);
        }
    }
}

#pragma mark NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@"zc %@ 下载完成",downloadTask.originalRequest.URL.absoluteString);
    NSString * libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString * fullPath  =[NSString stringWithFormat:@"%@/dl.data", libPath];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:fullPath] error:nil];
    
    NSArray * urlArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"urlArr"];
    NSMutableArray * muArr = [urlArr mutableCopy];
    [muArr removeObject:downloadTask.originalRequest.URL.absoluteString];
    if (muArr.count) {
        [[NSUserDefaults standardUserDefaults] setObject:[muArr copy] forKey:@"urlArr"];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"urlArr"];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    NSLog(@"下载进度 %f",totalBytesWritten/(totalBytesExpectedToWrite*1.0));
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes{
    NSLog(@"didResumeAtOffset");
}

-(void)getDownloadTaskRenewWithData:(NSData *)resumeData session:(NSURLSession *)session
{
    NSURLSessionDownloadTask * downloadTask = nil;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 11.0) {
        downloadTask = [session downloadTaskWithCorrectResumeData:resumeData];
    } else {
        downloadTask = [session downloadTaskWithResumeData:resumeData];
    }
    
    [downloadTask resume];
}

@end
