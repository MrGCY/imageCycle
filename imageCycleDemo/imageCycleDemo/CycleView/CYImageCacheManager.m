//
//  CYImageCacheManager.m
//  bannerCycleDemo
//
//  Created by Mr.GCY on 2017/7/12.
//  Copyright © 2017年 Mr.GCY. All rights reserved.
//

#import "CYImageCacheManager.h"
#import <CommonCrypto/CommonCrypto.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

@implementation CYImageCacheManager
//MD5加密
+ (NSString *)md5:(NSString *)string
{
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (int)strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}
+ (CGFloat)calculateCacheImagesMemory
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *fileDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"imagesCache"];
    NSDictionary *fileAttr = [manager attributesOfItemAtPath:fileDir error:nil];
    NSUInteger filesSize = [fileAttr fileSize];
    return filesSize / (1000 * 1000);
}

+ (void)removeCacheMemory
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *fileDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"imagesCache"];
    for (NSString *subPath in [manager subpathsOfDirectoryAtPath:fileDir error:nil]) {
        [manager removeItemAtPath:subPath error:nil];
    }
}

@end
