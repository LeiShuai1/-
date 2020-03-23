//
//  NetworkingEncapsulation.m
//  Framework
//
//  Created by HYAPP on 17/2/15.
//  Copyright © 2017年 LSFramework. All rights reserved.
//

#import "AFNetworking.h"
#import "LSProgressView.h"
#import "NetworkingEncapsulation.h"

#define NetworkingTimeoutInterval 10.f

@interface NetworkingEncapsulation ()

/**< 用来接收正在请求的任务 */
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

/**< 用来接收正在下载的任务 */
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

/**< 请求进度条 */
@property (nonatomic, strong) LSProgressView *progressView;

@end

@implementation NetworkingEncapsulation

- (void)stopDownload
{
    //暂停下载
    [self.downloadTask suspend];
}
- (void)startDownload
{
    //开始下载
    [self.downloadTask resume];
}

// 断点下载
- (void)downFileFromServerRequestURL:(NSString *)urlString
                          parameters:(NSDictionary *)parameters
                            progress:(void (^)(NSProgress *downloadProgress))progress
                             urlPath:(NSURL *(^)(NSString *pathString))urlPath
                             success:(void (^)(NSString *pathString))success
                             failure:(void (^)(NSError *error))failure
                      viewController:(UIViewController *)viewController
                   networkingLoading:(NetworkingLoading)networkingLoading
{
    if (parameters)
    {
        urlString = [NSString stringWithFormat:@"%@?%@", urlString, parameters];
    }
    
    if ([self IsChinese:urlString])
    {
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //AFN3.0+基于封住URLSession的句柄
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    //请求
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    if (networkingLoading == NetworkingLoadingProgress)
    {
        [self addProgressView:viewController];
    }
    
    __weak typeof (self)weakSelf = self;
    //下载Task操作
    self.downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        // @property int64_t totalUnitCount;  需要下载文件的总大小
        // @property int64_t completedUnitCount; 当前已经下载的大小
    
        // 回到主队列刷新UI
        
        if (networkingLoading == NetworkingLoadingProgress)
        {
            [weakSelf loadingProgressView:downloadProgress];
        }
        
        if (progress)
        {
            progress(downloadProgress);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        [weakSelf removeProgress];
        
    
        //- block的返回值, 要求返回一个URL, 返回的这个URL就是文件的位置的路径
        if (urlPath)
        {
            return urlPath(response.suggestedFilename);
        }
        else
        {
            NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
            return [NSURL fileURLWithPath:path];
        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        [weakSelf removeProgress];
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.progressView.progressValue = 1;
//            NSProgress *progress = nil;
//            self.progressView.progressValue = 1.0 * progress.completedUnitCount / progress.totalUnitCount;
//        });
        
        // filePath就是你下载文件的位置，你可以解压，也可以直接拿来使用
        if (error)
        {
            if (failure)
            {
                failure(error);
            }
        }
        else
        {
            if (success)
            {
                success([filePath path]);
            }
        }
        
        
    }];
}

// GET 网络请求
- (void)getRequestURL:(NSString *)urlString
           parameters:(NSDictionary *)parameters
             progress:(void (^)(NSProgress *downloadProgress))progress
              success:(void (^)(id responds))success
              failure:(void (^)(NSError *error))failure
              timeout:(NSTimeInterval)timeoutInterval
       viewController:(UIViewController *)viewController
    networkingLoading:(NetworkingLoading)networkingLoading
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 设置超时时间
    if (timeoutInterval == 0)
    {
        manager.requestSerializer.timeoutInterval = NetworkingTimeoutInterval;
    } else {
        manager.requestSerializer.timeoutInterval = timeoutInterval;
    }
    
    if ([self IsChinese:urlString]) {
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }

    if (networkingLoading == NetworkingLoadingProgress)
    {
        [self addProgressView:viewController];
    }
    
    [manager.requestSerializer setValue:@"35D0B998A84E48CC9A2B6B0992D59FD1" forHTTPHeaderField:@"apikey"];
    
    [manager.requestSerializer setValue:@"1.7.041921" forHTTPHeaderField:@"BBH"];
    
    [manager.requestSerializer setValue:@"17" forHTTPHeaderField:@"GJBBH"];
    
    [manager.requestSerializer setValue:@"" forHTTPHeaderField:@"TOKEN"];
    
    [manager.requestSerializer setValue:@"0" forHTTPHeaderField:@"HYID"];
    
    self.dataTask = [manager GET:urlString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress)
    {
        if (networkingLoading == NetworkingLoadingProgress)
        {
            [self loadingProgressView:downloadProgress];
        }
        
        if (progress)
        {
            progress(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        [self removeProgress];
        if (success)
        {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        [self removeProgress];
        if (failure)
        {
            failure(error);
        }
    }];
}

// POST 网络请求
- (void)postRequestURL:(NSString *)urlString
            parameters:(NSDictionary *)parameters
              progress:(void (^)(NSProgress *downloadProgress))progress
               success:(void (^)(id responds))success
               failure:(void (^)(NSError *error))failure
               timeout:(NSTimeInterval)timeoutInterval
        viewController:(UIViewController *)viewController
     networkingLoading:(NetworkingLoading)networkingLoading
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 设置超时时间
    if (timeoutInterval == 0)
    {
        manager.requestSerializer.timeoutInterval = NetworkingTimeoutInterval;
    } else {
        manager.requestSerializer.timeoutInterval = timeoutInterval;
    }
    
    if ([self IsChinese:urlString]) {
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
    if (networkingLoading == NetworkingLoadingProgress)
    {
        [self addProgressView:viewController];
    }
    
    __weak typeof (self)weakSelf = self;
    self.dataTask = [manager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        if (networkingLoading == NetworkingLoadingProgress)
        {
            [weakSelf loadingProgressView:downloadProgress];
        }
        if (progress) {
            progress(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [weakSelf removeProgress];
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [weakSelf removeProgress];
        if (failure) {
            failure(error);
        }
    }];
}

// Delete 方式
- (void)deleteAreaURL:(NSString *)urlString
           parameters:(NSDictionary *)parameters
              success:(void (^)(id responds))success
              failure:(void (^)(NSError *error))failure
              timeout:(NSTimeInterval)timeoutInterval
       viewController:(UIViewController *)viewController
    networkingLoading:(NetworkingLoading)networkingLoading
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 设置超时时间
    if (timeoutInterval == 0)
    {
        manager.requestSerializer.timeoutInterval = NetworkingTimeoutInterval;
    } else {
        manager.requestSerializer.timeoutInterval = timeoutInterval;
    }
    
    if ([self IsChinese:urlString]) {
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
    self.dataTask = [manager DELETE:urlString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

// Put 方式
- (void)putAreaURL:(NSString *)urlString
        parameters:(NSDictionary *)parameters
           success:(void (^)(id responds))success
           failure:(void (^)(NSError *error))failure
           timeout:(NSTimeInterval)timeoutInterval
    viewController:(UIViewController *)viewController
 networkingLoading:(NetworkingLoading)networkingLoading
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 设置超时时间
    if (timeoutInterval == 0)
    {
        manager.requestSerializer.timeoutInterval = NetworkingTimeoutInterval;
    } else {
        manager.requestSerializer.timeoutInterval = timeoutInterval;
    }
    
    if ([self IsChinese:urlString]) {
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
    self.dataTask = [manager PUT:urlString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

//判断是否有中文
- (BOOL)IsChinese:(NSString *)str {
    for (int i = 0; i < [str length]; i++)
    {
        int a = [str characterAtIndex:i];
        if (a > 0x4e00 && a < 0x9fff)
        {
            return YES;
        }
    }
    return NO;
}

- (void)loadingProgressView:(NSProgress * _Nonnull)downloadProgress {
    __weak typeof (self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.progressView.progressValue = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
    });
}

- (void)addProgressView:(UIViewController *)viewController {
    self.progressView.center = viewController.view.center;
    [viewController.view addSubview:self.progressView];
}

- (void)removeProgress {
    __weak typeof (self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.progressView removeFromSuperview];
    });
}

//加载提示框
- (LSProgressView *)progressView {
    if (!_progressView) {
        _progressView = [LSProgressView viewWithFrame:CGRectMake(0, 0, 100, 100)
                                          circlesSize:CGRectMake(34, 2, 30, 30)];
        _progressView.layer.cornerRadius = 10;
        
        //阴影
        _progressView.backgroundColor = [UIColor clearColor];
        _progressView.backCircle.shadowColor = [UIColor grayColor].CGColor;
        _progressView.backCircle.shadowRadius = 3;
        _progressView.backCircle.shadowOffset = CGSizeMake(0, 0);
        _progressView.backCircle.shadowOpacity = 1;
        _progressView.backCircle.fillColor = [UIColor colorWithRed:151/255.0 green:151/255.0 blue:151/255.0 alpha:0.8].CGColor;
        _progressView.backCircle.strokeColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1].CGColor;
        
        _progressView.foreCircle.lineCap = @"butt";
        _progressView.foreCircle.strokeColor = [UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1].CGColor;;
        _progressView.progressValue = 0;
    }
    return _progressView;
}

// 单例
+ (instancetype)sharedObject
{
    static NetworkingEncapsulation *sharedObjectInstance = nil;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedObjectInstance = [[super allocWithZone:NULL] init];
    });
    
    return sharedObjectInstance;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedObject];
}

@end
