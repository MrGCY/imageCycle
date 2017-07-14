//
//  CYImageCycleView.h
//  bannerCycleDemo
//
//  Created by Mr.GCY on 2017/7/7.
//  Copyright © 2017年 Mr.GCY. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CustomImageCycleIndictorPatternDelegate;
@class CYImageCycleView;
@protocol CYImageCycleViewDelegate <NSObject>
/**
 *  图片点击回调
 */
- (void)imageCycleVie:(CYImageCycleView *)imageCycleView didSelectImageAtIndex:(NSInteger)index;

@end
@interface CYImageCycleView : UIView

/**
 *  是否自动滚动 默认YES
 */
@property (nonatomic, assign) BOOL autoScroll;
/**
 *  滚动间隔时间 默认2秒
 */
@property (nonatomic, assign) NSTimeInterval scrollIntervalTime;
/**
 *  是否隐藏分页指示器 默认NO
 */
@property (nonatomic, assign) BOOL hidePageControl;
/**
 *  分页指示器选中颜色
 */
@property (nonatomic, strong) UIColor * currentPageIndicatorTintColor;
/**
 *  分页指示器未选中颜色
 */
@property (nonatomic, strong) UIColor * pageIndicatorTintColor;
/**
 *  图片默认图
 */
@property (nonatomic, strong) UIImage * placeholderImage;
/**
 *  图片填充模式
 */
@property (nonatomic, assign) UIViewContentMode imageContentMode;
/**
 *  当前展示的图片数组
 */
@property (strong, nonatomic, readonly) NSArray *images;
//自定义指示器代理
@property(weak,nonatomic) id<CustomImageCycleIndictorPatternDelegate> indicatorPatternDelegate;
@property(weak,nonatomic) id<CYImageCycleViewDelegate> delegate;
#pragma mark- function
//加载本地图片
-(instancetype)initWithLocalImages:(NSArray<NSString*>*)images placeholder:(UIImage *)placeholder;
//加载网络图片
-(instancetype)initWithNetWorkImages:(NSArray<NSString*>*)images placeholder:(UIImage *)placeholder;
/**
 *  添加本地图片数组
 */
- (void)addLocalImages:(NSArray<NSString *> *)images;
/**
 *  添加网络图片数组
 */
- (void)addNetWorkImages:(NSArray <NSString *> *)images placeholder:(UIImage *)placeholder;
/**
 *  计算缓存图片大小
 */
-(CGFloat)calculateImageCache;
/**
 *  移除缓存图片
 */
-(void)removeAllImageCache;
@end

#pragma mark- 自定义指示器样式
/**
 *  指示器样式
 */
@protocol CustomImageCycleIndictorPatternDelegate <NSObject, UITableViewDelegate>

@required
/**
 *  设置分页指示器的样式  自定义指示器样式
 */
- (UIView *)indicatorViewInImageCycleView:(CYImageCycleView *)imageCycleView;
@optional
/**
 *  图片交换完成时调用
 */
- (void)imageCycleView:(CYImageCycleView *)imageCycleView didChangedIndex:(NSInteger)index count:(NSInteger)count;

@end
