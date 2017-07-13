//
//  CYImageCacheManager.h
//  bannerCycleDemo
//
//  Created by Mr.GCY on 2017/7/12.
//  Copyright © 2017年 Mr.GCY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface CYImageCacheManager : NSObject
//MD5加密
+ (NSString *)md5:(NSString *)string;
//计算图片缓存
+ (CGFloat)calculateCacheImagesMemory;
//移除图片缓存
+ (void)removeCacheMemory;
@end
