//
//  HomeController.m
//  Framework
//
//  Created by HYAPP on 17/2/15.
//  Copyright © 2017年 LSFramework. All rights reserved.
//

#import "MJExtension.h"
#import "ProductList.h"
#import "HomeController.h"
#import "DemoViewController.h"
#import "NetworkingEncapsulation.h"
#import "GCDSocketManager.h"

@interface HomeController ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"HomeController");
    
    [self data];
    
    NSLog(@"%@", NSHomeDirectory());
    
//    [self chaXun];
    
    [[GCDSocketManager sharedSocketManager] connectToServer];
    
    [self.view addSubview:self.button];
}

- (void)chaXun {
//    NSLog(@"%@", [ProductList findFirstByCriteria:@" WHERE ID = 161 "]);
//    ProductList *productList = [ProductList findFirstByCriteria:@" WHERE ID = 161 "];
//    productList.Hdj3 = @"110";
    [ProductList deleteObjectsByCriteria:@"WHERE Hdj3 = 2000, ZbId = 2"];
    NSLog(@"完成");
}

- (void)data {
    
    [[NetworkingEncapsulation sharedObject] getRequestURL:@"http://api.hysware.com:8999/api/Product" parameters:@{@"Czbs":@"CPLB"} progress:nil success:^(id responds) {
        
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responds options:NSJSONReadingMutableLeaves error:nil];
        
        NSArray *dataArr = [resultDic valueForKey:@"data"];
        
        NSMutableArray *arr = [NSMutableArray array];
        [ProductList clearTable];
        
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [dataArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {

                [arr addObjectsFromArray:[ProductList mj_objectArrayWithKeyValuesArray:dataArr]];
        
        ProductList *productList = [[ProductList alloc] init];
        productList = arr[0];
        
        NSLog(@"%@", productList.Mc);
        
        productList = arr[1];
        
        NSLog(@"%@", productList.Mc);
        
        
        
//                [arr addObject:productList];
            
//            }];
            [ProductList saveObjects:arr];
//        });
        
    } failure:nil timeout:10.f viewController:self networkingLoading:NetworkingLoadingProgress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonAction {
    DemoViewController *demoViewController = [[DemoViewController alloc] init];
    
    [self.navigationController pushViewController:demoViewController animated:YES];
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame = CGRectMake(0, 64, 100, 100);
        [_button setTitle:@"123" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchDown];
    }
    return _button;
}

@end
