//
//  LSProgressView.h
//  Framework
//
//  Created by HYAPP on 17/2/15.
//  Copyright © 2017年 LSFramework. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSProgressView : UIView

@property (nonatomic, assign) CGFloat progressValue;// 范围: 0 ~ 1

//背景圆环
@property (nonatomic, strong) CAShapeLayer *backCircle;
//前面圆环
@property (nonatomic, strong) CAShapeLayer *foreCircle;

//初始化方法
//size = CGRectMake(背景圆环半径, 背景圆环线宽, 前面圆环半径, 后面圆环线宽)
+ (instancetype)viewWithFrame:(CGRect)frame circlesSize:(CGRect)size;

@end
