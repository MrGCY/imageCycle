//
//  UIImageView+webCache.m
//  bannerCycleDemo
//
//  Created by Mr.GCY on 2017/7/10.
//  Copyright © 2017年 Mr.GCY. All rights reserved.
//

#import "UIImageView+webCache.h"
#import "CYImageCacheManager.h"

@implementation UIImageView (webCache)
- (void)cy_setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder
{
    NSString *fileDir  = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"imagesCache"];
    NSFileManager *fm  = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *fileName = [fileDir stringByAppendingPathComponent:[CYImageCacheManager md5:url]];//MD5加密图片名全路径
    UIImage *image     = [UIImage imageWithContentsOfFile:fileName];
    if (image) {
        self.image = image;
    }else {
        self.image = placeholder;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *path = [NSURL URLWithString:url];
            NSData *data = [NSData dataWithContentsOfURL:path];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage * downLoadImage = [UIImage imageWithData:data];
                if (downLoadImage) {
                    self.image = downLoadImage;
                }
            });
            [data writeToFile:fileName atomically:YES];
        });
    }
}
@end
