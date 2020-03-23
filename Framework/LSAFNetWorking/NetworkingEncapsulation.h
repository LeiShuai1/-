//
//  NetworkingEncapsulation.h
//  Framework
//
//  Created by HYAPP on 17/2/15.
//  Copyright © 2017年 LSFramework. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NetworkingLoading) {
    NetworkingLoadingNone,
    NetworkingLoadingProgress
};

@interface NetworkingEncapsulation : NSObject

//暂停下载
- (void)stopDownload;

//开始下载
- (void)startDownload;

// 断点下载
- (void)downFileFromServerRequestURL:(NSString *)urlString
                          parameters:(NSDictionary *)parameters
                            progress:(void (^)(NSProgress *downloadProgress))progress
                             urlPath:(NSURL *(^)(NSString *pathString))urlPath
                             success:(void (^)(NSString *pathString))success
                             failure:(void (^)(NSError *error))failure
                      viewController:(UIViewController *)viewController
                      networkingLoading:(NetworkingLoading)networkingLoading;

// GET 网络请求
- (void)getRequestURL:(NSString *)urlString
           parameters:(NSDictionary *)parameters
             progress:(void (^)(NSProgress *downloadProgress))progress
              success:(void (^)(id responds))success
              failure:(void (^)(NSError *error))failure
              timeout:(NSTimeInterval)timeoutInterval
       viewController:(UIViewController *)viewController
    networkingLoading:(NetworkingLoading)networkingLoading;

// POST 网络请求
- (void)postRequestURL:(NSString *)urlString
            parameters:(NSDictionary *)parameters
              progress:(void (^)(NSProgress *downloadProgress))progress
               success:(void (^)(id responds))success
               failure:(void (^)(NSError *error))failure
               timeout:(NSTimeInterval)timeoutInterval
        viewController:(UIViewController *)viewController
     networkingLoading:(NetworkingLoading)networkingLoading;

// Delete 方式
- (void)deleteAreaURL:(NSString *)urlString
           parameters:(NSDictionary *)parameters
              success:(void (^)(id responds))success
              failure:(void (^)(NSError *error))failure
              timeout:(NSTimeInterval)timeoutInterval
       viewController:(UIViewController *)viewController
       networkingLoading:(NetworkingLoading)networkingLoading;

// Put 方式
- (void)putAreaURL:(NSString *)urlString
        parameters:(NSDictionary *)parameters
           success:(void (^)(id responds))success
           failure:(void (^)(NSError *error))failure
           timeout:(NSTimeInterval)timeoutInterval
    viewController:(UIViewController *)viewController
    networkingLoading:(NetworkingLoading)networkingLoading;

+ (instancetype)sharedObject;

@end
