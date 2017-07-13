//
//  ViewController.m
//  imageCycleDemo
//
//  Created by Mr.GCY on 2017/7/13.
//  Copyright © 2017年 Mr.GCY. All rights reserved.
//

#import "ViewController.h"
#import "CYImageCycleView.h"
@interface ViewController ()<CYImageCycleViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *netImages = @[@"http://www.ld12.com/upimg358/allimg/c151129/144WW1420B60-401445_lit.jpg",
                           @"http://img4.duitang.com/uploads/item/201508/11/20150811220329_XyZAv.png",
                           @"http://tx.haiqq.com/uploads/allimg/150326/160R95612-10.jpg",
                           @"http://img5q.duitang.com/uploads/item/201507/22/20150722145119_hJnyP.jpeg",
                           @"http://imgsrc.baidu.com/forum/w=580/sign=dc0e6c8c8101a18bf0eb1247ae2e0761/1cb3c90735fae6cd2c5341c109b30f2440a70fc7.jpg",];
    UIImage * image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1_launch" ofType:@"png"]];
    CYImageCycleView * bannerView = [[CYImageCycleView alloc] initWithNetWorkImages:netImages placeholder:image];
    bannerView.delegate = self;
    bannerView.imageContentMode = UIViewContentModeScaleAspectFill;
    bannerView.frame = CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 200);
    [self.view addSubview:bannerView];
}

-(void)imageCycleVie:(CYImageCycleView *)imageCycleView didSelectImageAtIndex:(NSInteger)index{
    NSLog(@"--------点击------%ld",index);
}


@end
