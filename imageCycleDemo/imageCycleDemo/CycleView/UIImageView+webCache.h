//
//  UIImageView+webCache.h
//  bannerCycleDemo
//
//  Created by Mr.GCY on 2017/7/10.
//  Copyright © 2017年 Mr.GCY. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIImageView (webCache)
- (void)cy_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder;
@end
