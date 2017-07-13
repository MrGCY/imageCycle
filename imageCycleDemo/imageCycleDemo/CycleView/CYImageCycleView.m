//
//  CYImageCycleView.m
//  bannerCycleDemo
//
//  Created by Mr.GCY on 2017/7/7.
//  Copyright © 2017年 Mr.GCY. All rights reserved.
//

#import "CYImageCycleView.h"
#import "UIImageView+webCache.h"
#import "CYImageCacheManager.h"
#define imageCount self.dataArray.count
#define W self.frame.size.width
#define H self.frame.size.height
#define identifierCollectionViewCell @"UICollectionViewCell"
#define repeatCount 30 //必须是大于4 的偶数
@interface CYImageCycleView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic)UICollectionViewFlowLayout *flow;
//定时器
@property (strong, nonatomic) NSTimer *timer;
/**
 *  分页指示器
 */
@property (strong, nonatomic) UIPageControl * indicatorView;
/**
 *  数据源
 */
@property (strong, nonatomic) NSMutableArray * dataArray;
/**
 *  记录滚动前偏移量
 */
@property (assign, nonatomic) CGFloat previousOffsetX;
@end
@implementation CYImageCycleView
#pragma mark- 重写setter
-(void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;
}
-(void)setHidePageControl:(BOOL)hidePageControl{
    _hidePageControl = hidePageControl;
    self.indicatorView.hidden = hidePageControl;
}
-(void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor{
    _pageIndicatorTintColor = pageIndicatorTintColor;
    self.indicatorView.pageIndicatorTintColor = pageIndicatorTintColor;
}
-(void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor{
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    self.indicatorView.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}
//设置自定义视图代理
-(void)setIndicatorPatternDelegate:(id<customImageCycleIndictorPattern>)indicatorPatternDelegate{
    _indicatorPatternDelegate = indicatorPatternDelegate;
    if (indicatorPatternDelegate) {
        [self.indicatorView removeFromSuperview];
        [self layoutIfNeeded];
        //添加自定义视图
        [self addSubview:[self.indicatorPatternDelegate indicatorViewInImageCycleView:self]];
    }
}
#pragma mark- 懒加载数据
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}
-(UIPageControl *)indicatorView{
    if (!_indicatorView) {
        _indicatorView = [[UIPageControl alloc] init];
        _indicatorView.pageIndicatorTintColor = [UIColor grayColor];
        _indicatorView.currentPageIndicatorTintColor = [UIColor whiteColor];
    }
    return _indicatorView;
}
-(UICollectionViewFlowLayout *)flow{
    if (!_flow) {
        _flow = [[UICollectionViewFlowLayout alloc] init];
        _flow.minimumLineSpacing                       = 0.0;
        _flow.scrollDirection                          = UICollectionViewScrollDirectionHorizontal;
    }
    return _flow;
}
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flow];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:identifierCollectionViewCell];
    }
    return _collectionView;
}
#pragma 创建视图 构造函数
-(instancetype)init{
    if (self = [super init]) {
        [self setupSubviews];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    return self;
}
-(instancetype)initWithLocalImages:(NSArray<NSString*>*)images placeholder:(UIImage *)placeholder{
    CYImageCycleView * imageCycleView = [[CYImageCycleView alloc] init];
    [imageCycleView addNetWorkImages:images placeholder:placeholder];
    return imageCycleView;
}
-(instancetype)initWithNetWorkImages:(NSArray<NSString*>*)images placeholder:(UIImage *)placeholder{
    return [self initWithLocalImages:images placeholder:placeholder];
}
/**
 *  添加本地图片数组
 */
- (void)addLocalImages:(NSArray<NSString *> *)images{
    //审查元素
    [CYImageCycleView checkElementOfImages:images];
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:images];
    _images = [NSArray arrayWithArray:self.dataArray];
    
    //刷新pageControl
    self.indicatorView.numberOfPages = images.count;
    [self.indicatorView updateCurrentPageDisplay];
    
    //在Updates里执行完更新操作后再执行completion回调
    __weak typeof(self) ws = self;
    [self.collectionView performBatchUpdates:^{
        [ws.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished) {
        //滚动到中间
        [self scrollToCenterOrigin];
        [ws.collectionView reloadData];
        //初始化偏移量
        self.previousOffsetX = self.collectionView.contentOffset.x;
        //通知指示器的初始值
        if ([self.indicatorPatternDelegate respondsToSelector:@selector(imageCycleView:didChangedIndex:count:)]) {
            [self.indicatorPatternDelegate imageCycleView:self didChangedIndex:0 count:imageCount];
        }
        //开启定时器
        [self addTimer];
    }];
}
/**
 *  添加网络图片数组
 */
- (void)addNetWorkImages:(NSArray <NSString *> *)images placeholder:(UIImage *)placeholder{
    [self addLocalImages:images];
    self.placeholderImage = placeholder;
}
/**
 *  计算缓存图片大小
 */
-(CGFloat)calculateImageCache{
    return [CYImageCacheManager calculateCacheImagesMemory];
}
/**
 *  移除缓存图片
 */
-(void)removeAllImageCache{
    return [CYImageCacheManager removeCacheMemory];
}
#pragma mark- 定时器相关
//添加定时器
- (void)addTimer
{
    if (!self.autoScroll) return;
    [self removeTimer];
    NSTimeInterval interval = self.scrollIntervalTime > 0 ? self.scrollIntervalTime : 2;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
}
//移除定时器
- (void)removeTimer
{
    [self.timer invalidate];
    self.timer = nil;
}
- (void)nextImage
{
    if ((int)self.collectionView.contentOffset.x % (int)W == 0) {
        CGFloat offsetX = self.collectionView.contentOffset.x + W;
        [self.collectionView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }else {
        NSInteger count = round(self.collectionView.contentOffset.x / W);
        [self.collectionView setContentOffset:CGPointMake(count * W, 0) animated:NO];
    }
}
#pragma mark- 初始化视图
-(void)setupSubviews{
    self.hidePageControl = NO;
    self.autoScroll = YES;
    [self addSubview:self.collectionView];
    [self addSubview:self.indicatorView];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.flow.itemSize        = self.frame.size;
    self.collectionView.frame = self.bounds;
    self.indicatorView.frame  = CGRectMake(W * 0.5, H - 15.0, 0, 0);
}
#pragma mark- private
//滚动到中间的第一个
-(void)scrollToCenterOrigin{
    NSInteger centerOrigin = imageCount * repeatCount * 0.5;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:centerOrigin inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}
// 滚动到中间结束位置
- (void)scrollToCenterEnd
{
    NSInteger centerEnd = imageCount * repeatCount * 0.5 - 1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:centerEnd inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}
#pragma mark - Public 公共方法
//检查添加的images数组中的元素
+ (void)checkElementOfImages:(NSArray *)images
{
    for (id obj in images) {
        if (![obj isKindOfClass:[NSString class]]) {
            NSException *e = [NSException exceptionWithName:@"PathVailed" reason:@"必须为图片名、图片本地路径或是图片地址" userInfo:nil];
            @throw e;
        }
    }
}
#pragma mark- UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return imageCount * repeatCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifierCollectionViewCell forIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = cell.contentView.bounds;
    imageView.contentMode = self.imageContentMode;
    imageView.userInteractionEnabled = YES;
    NSString *imageName = self.dataArray[indexPath.item % imageCount];
    UIImage *image  = [UIImage imageNamed:imageName];
    if (image) {//本地图片
        imageView.image = image;
    }else {//网络图片
        [imageView cy_setImageWithURL:imageName placeholderImage:self.placeholderImage];
    }
    cell.backgroundView = imageView;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.item % imageCount;
    if ([self.delegate respondsToSelector:@selector(imageCycleVie:didSelectImageAtIndex:)]) {
        [self.delegate imageCycleVie:self didSelectImageAtIndex:index];
    }
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat width = self.flow.itemSize.width;
    if ((int)offsetX % (int)width == 0) {
        NSInteger index = (NSInteger)(offsetX / width);
        NSInteger number = [self.collectionView numberOfItemsInSection:0];
        if (index == 0) {
            [self scrollToCenterOrigin];
        }
        if (index == number - 1) {
            [self scrollToCenterEnd];
        }
    }
}
//结束滚动
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSInteger page = (NSInteger)(scrollView.contentOffset.x / W ) % imageCount;
    self.indicatorView.currentPage = page;
    //通知代理更新自定义分页指示器
    if ([self.indicatorPatternDelegate respondsToSelector:@selector(imageCycleView:didChangedIndex:count:)]) {
        [self.indicatorPatternDelegate imageCycleView:self didChangedIndex:page count:imageCount];
    }
}
//减速 结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = (NSInteger)(scrollView.contentOffset.x / W )% imageCount;
    self.indicatorView.currentPage = page;
    //通知代理更新自定义分页指示器
    if ([self.indicatorPatternDelegate respondsToSelector:@selector(imageCycleView:didChangedIndex:count:)]) {
        [self.indicatorPatternDelegate imageCycleView:self didChangedIndex:page count:imageCount];
    }
}
//开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeTimer];
}
//结束拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self addTimer];
}
@end
