//
//  UploadController.m
//  NSURLSessionTrain
//
//  Created by Shendou on 2017/10/24.
//  Copyright © 2017年 Shendou. All rights reserved.
//

#import "UploadController.h"

@interface UploadController ()

@end

@implementation UploadController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 参数1
    NSString *URLString = @"http://192.168.8.11/upload.php";
    // 参数2
    NSString *serverFileName = @"zc[]";
    // 参数3
    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"on_show_1.png" ofType:nil];
    NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"on_show_2.png" ofType:nil];
    NSArray *filePaths = @[filePath1,filePath2];
    // 参数4
    NSDictionary *textDict = @{@"kkk":@"vvv"};
    
    // 调用文件上传的主方法
    [self uploadFilesWithURLString:URLString serverFileName:serverFileName filePaths:filePaths textDict:textDict];
}

- (void)uploadFilesWithURLString:(NSString *)URLString serverFileName:(NSString *)serverFileName filePaths:(NSArray *)filePaths textDict:(NSDictionary *)textDict
{
    // URL
    NSURL *URL = [NSURL URLWithString:URLString];
    
    // 可变请求
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:URL];
    // 设置请求头
    [requestM setValue:@"multipart/form-data; boundary=itcast" forHTTPHeaderField:@"Content-Type"];
    // 设置请求方法
    requestM.HTTPMethod = @"POST";
    // 设置请求体
    requestM.HTTPBody = [self getHTTPBodyWithServerFileName:serverFileName filePaths:filePaths textDict:textDict];
    
    // 发送请求实现文件上传
    [[[NSURLSession sharedSession] dataTaskWithRequest:requestM completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error == nil && data != nil) {
            NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
            NSLog(@"44");
        } else {
            NSLog(@"%@",error);
        }
    }] resume];
}

- (NSData *)getHTTPBodyWithServerFileName:(NSString *)serverFileName filePaths:(NSArray *)filePaths textDict:(NSDictionary *)textDict
{
    // 定义dataM拼接请求体二进制数据
    NSMutableData *dataM = [NSMutableData data];
    
    // 循环拼接文件二进制信息
    [filePaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 用于字符串信息
        NSMutableString *stringM = [NSMutableString string];
        // 拼接文件开始的分隔符
        [stringM appendString:@"--itcast\r\n"];
        // 拼接表单数据
        [stringM appendFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n",serverFileName,[obj lastPathComponent]];
        // 拼接文件类型
        [stringM appendString:@"Content-Type: image/png\r\n"];
        // 拼接单纯的换行
        [stringM appendString:@"\r\n"];
        // 把前面的字符串信息拼接到请求体里面
        [dataM appendData:[stringM dataUsingEncoding:NSUTF8StringEncoding]];
        
        // 拼接文件的二进制数据到dataM
        [dataM appendData:[NSData dataWithContentsOfFile:obj]];
        
        // 拼接二进制数据后面的换行
        [dataM appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
    }];
    
    // 拼接文件的文本信息
    [textDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        // 用于拼接文本信息
        NSMutableString *stringM = [NSMutableString string];
        // 拼接文本信息的开始分割符
        [stringM appendString:@"--itcast\r\n"];
        // 拼接表单数据
        [stringM appendFormat:@"Content-Disposition: form-data; name=%@\r\n",key];
        // 拼接单纯的换行
        [stringM appendString:@"\r\n"];
        // 拼接文本信息
        [stringM appendFormat:@"%@\r\n",obj];
        
        // 把文本信息拼接到请求体
        [dataM appendData:[stringM dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // 拼接文件上传的结束分隔符
    [dataM appendData:[@"--itcast--" dataUsingEncoding:NSUTF8StringEncoding]];
    
    return dataM.copy;
}

/*
 --itcast
 Content-Disposition: form-data; name=zc[]; filename=on_show_1.png
 Content-Type: image/png
 [image]
 --itcast
 Content-Disposition: form-data; name=zc[]; filename=on_show_2.png
 Content-Type: image/png
 [image]
 --itcast
 Content-Disposition: form-data; name=kkk
 vvv
 --itcast--
 */

@end
