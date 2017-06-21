//
//  MKImagesReViewController.m
//  MKImageReview
//
//  Created by Liujh on 16/4/6.
//  Copyright © 2016年 com.minstone. All rights reserved.
//

#import "MKImagesReViewController.h"
#import "UIImageView+MKImageView.h"


const NSInteger ImageViewTag = 999;

const NSInteger ImageScrollViewFirstTag = 1000;
const NSInteger ImageScrollViewSecondTag = 1001;


#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface MKImagesReViewController ()<UIScrollViewDelegate>

@end

@implementation MKImagesReViewController
{
    UIImageView *currentImageView;
    NSInteger currentIndex;
    
    NSArray<NSString *> *_imagesPathArray;
    
    void (^dismissPhotoSkimBlock)(NSInteger);
}

-(instancetype)init
{
    self = [super init];
    if(self){
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showImages:(NSArray<NSString *> *)imagesPathArray
            index:(NSInteger)index
afterDismissBlock:(void (^)(NSInteger))dismissBlock
{
    dismissPhotoSkimBlock = dismissBlock;
    _imagesPathArray = [NSArray arrayWithArray:imagesPathArray];
    
    for(int i=0; i<2; i++){
        UIScrollView *imageScrollView = [self.view viewWithTag:ImageScrollViewFirstTag+i];
        if(imageScrollView == nil){
            imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            imageScrollView.decelerationRate = 0;
            imageScrollView.delegate = self;
            imageScrollView.backgroundColor = [UIColor blackColor];
            imageScrollView.showsHorizontalScrollIndicator = NO;
            imageScrollView.showsVerticalScrollIndicator = NO;
            imageScrollView.tag = ImageScrollViewFirstTag + i;
            [self.view addSubview:imageScrollView];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageScrollView.bounds];
            imageView.tag = ImageViewTag;
            imageView.backgroundColor = [UIColor clearColor];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.userInteractionEnabled = YES;
            [imageScrollView addSubview:imageView];
            
            //单击消失
            UITapGestureRecognizer *dismissTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPhotoAlbum:)];
            dismissTapGesture.numberOfTapsRequired = 1;
            [imageView addGestureRecognizer:dismissTapGesture];
            
            //双击放大
            UITapGestureRecognizer *scaleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScaleImage:)];
            scaleTapGesture.numberOfTapsRequired = 2;
            [imageView addGestureRecognizer:scaleTapGesture];
            
            [dismissTapGesture requireGestureRecognizerToFail:scaleTapGesture];
            
            
            //左右横扫切换图片
            UISwipeGestureRecognizer *rightSwipeGestur = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchImage:)];
            rightSwipeGestur.direction = UISwipeGestureRecognizerDirectionRight;
            [imageView addGestureRecognizer:rightSwipeGestur];
            
            UISwipeGestureRecognizer *leftSwipeGestur = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchImage:)];
            leftSwipeGestur.direction = UISwipeGestureRecognizerDirectionLeft;
            [imageView addGestureRecognizer:leftSwipeGestur];
            
            //捏合缩放
            imageScrollView.maximumZoomScale = 2;
            [imageScrollView.pinchGestureRecognizer addTarget:self action:@selector(scaleImage:)];
            
            //长按询问是否保存图片
            UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(askSaveImg)];
            [imageView addGestureRecognizer: longPressGesture];
            
            //拖拉切换
//            UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panSwitchImage:)];
//            [imageView addGestureRecognizer:panGesture];
//            [panGesture requireGestureRecognizerToFail: rightSwipeGestur];
//            [panGesture requireGestureRecognizerToFail: leftSwipeGestur];
        }
    }
    
    if(currentImageView == nil){
        currentImageView = [[self.view viewWithTag:ImageScrollViewSecondTag] viewWithTag:ImageViewTag];
    }
    
    currentIndex = index;
    
//    UIImage *image = nil;
//    if(index < imagesPathArray.count){
//        image = [UIImage imageWithContentsOfFile: imagesPathArray[index]];
//    }
//    currentImageView.image = image;
    
    NSData *imageData = nil;
    if(index < imagesPathArray.count){
        imageData = [NSData dataWithContentsOfFile: imagesPathArray[index]];
    }
    [currentImageView setImageData: imageData];
    [self imageView:currentImageView sizeToFitData:imageData];
    
    [[self getCurrentViewController] presentViewController:self animated:YES completion:NULL];
}

-(void)imageView:(UIImageView *)imageView sizeToFitData:(NSData *)imageData {
    //设置imageView的大小
    
    UIImage *image = [UIImage imageWithData: imageData];
    CGSize size = [self image:image sizeThatFit:imageView.frame.size];
    
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    imageView.frame = CGRectMake((imageView.frame.size.width-width)/2.0, (imageView.frame.size.height - height)/2.0, width, height);
}

//一张图片可以全部显示在某个size中的size
-(CGSize)image:(UIImage *)image sizeThatFit:(CGSize)size {
    CGFloat imageViewWidth = size.width;
    CGFloat imageViewHeight = size.height;
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGFloat resultWidth = width;
    CGFloat resultHeight = height;
    
    if(resultWidth > imageViewWidth){
        resultWidth = imageViewWidth;
        resultHeight = resultWidth * height / width;
        if(resultHeight > imageViewHeight){
            resultHeight = imageViewHeight;
            resultWidth = resultHeight * width / height;
        }
    }
    
    if(resultHeight > imageViewHeight){
        resultHeight = imageViewHeight;
        resultWidth = resultHeight * width / height;
        if(resultWidth > imageViewWidth){
            resultWidth = imageViewWidth;
            resultHeight = resultWidth * height / width;
        }
    }
    return CGSizeMake(resultWidth, resultHeight);
}

#pragma mark - 消失图片
-(void)dismissPhotoAlbum:(UITapGestureRecognizer *)tapGesture
{
    if(tapGesture.numberOfTapsRequired == 1){
        [self dismissViewControllerAnimated:YES completion:^{
            if(dismissPhotoSkimBlock){
                dismissPhotoSkimBlock(currentIndex);
            }
        }];
    }
}

#pragma mark - 放大缩小图片
-(void)tapScaleImage:(UITapGestureRecognizer *)tapGesture
{
    if(tapGesture.numberOfTapsRequired == 2){
        UIImageView *imageView = (UIImageView *)tapGesture.view;
        UIScrollView *contView = (UIScrollView *)imageView.superview;
        UIImage *image = imageView.image;
        
        //没被放大或缩小的size
        CGSize originSize = [self image:image sizeThatFit: contView.frame.size];
        
        //现在imageView的size
        CGSize nowSize = imageView.frame.size;
        
        CGFloat scale = 1.0;
        //如果现在的size比原本size放大两倍小，则放大到最大，一样大就缩小
        if(nowSize.width < originSize.width * 2.0){
            //放大
            scale = 2.0;
        }
        [self scaleImageView: imageView scale: scale];
    }
}

#pragma mark - 捏合缩放图片
-(void)scaleImage:(UIPinchGestureRecognizer *)pinchGesture
{
    UIScrollView *contView = (UIScrollView *)pinchGesture.view;
    UIImageView *imageView = [contView viewWithTag:ImageViewTag];
    
    CGFloat scale = pinchGesture.scale;
    
    if(scale >= 1 && scale <= 2){
        [self scaleImageView:imageView scale:scale];
    }
}

-(void)scaleImageView:(UIImageView *)imageView scale:(CGFloat)scale {
    UIScrollView *contView = (UIScrollView *)imageView.superview;
    UIImage *image = imageView.image;
    
    CGSize originSize = [self image:image sizeThatFit:contView.frame.size];
    
    CGFloat zoomWidth = originSize.width * scale;
    CGFloat zoomHeigth = originSize.height * scale;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat deltaWidth = zoomWidth - contView.frame.size.width;
        CGFloat deltaHeight = zoomHeigth - contView.frame.size.height;
        
        imageView.frame = CGRectMake((deltaWidth < 0? -(deltaWidth/2.0): 0), (deltaHeight < 0? -(deltaHeight/2.0): 0), zoomWidth, zoomHeigth);
        contView.contentOffset = CGPointMake(deltaWidth > 0? deltaWidth/2: 0, deltaHeight > 0? deltaHeight/2: 0);
        
    } completion:^(BOOL finished) {
        contView.contentSize = imageView.frame.size;
    }];
}

#pragma mark - 切换图片
-(void)switchImage:(UISwipeGestureRecognizer *)swipeGesture
{
    BOOL isRight = YES;
    if(swipeGesture.direction == UISwipeGestureRecognizerDirectionRight){
        isRight = YES;
    }else if(swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft){
        isRight = NO;
    }
    [self switchImageDirection:isRight];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat xOffset = scrollView.contentOffset.x;
    if(xOffset < -80.0){
        [self switchImageDirection:YES];
    }else if(xOffset > (scrollView.contentSize.width - SCREEN_WIDTH + 80)){
        [self switchImageDirection:NO];
    }
    
}

//#pragma mark - 拖拉切换图片
//-(void)panSwitchImage:(UIPanGestureRecognizer *)panGesture
//{
//    NSLog(@"%@", NSStringFromCGPoint([panGesture translationInView:panGesture.view]));
//}

-(void)switchImageDirection:(BOOL)isRight
{
    UIImageView *imageView = currentImageView;
    UIScrollView *contView = (UIScrollView *)imageView.superview;
    
    UIScrollView *nextContView = nil;
    UIImageView *nextImageView = nil;
    
    if(contView.tag == ImageScrollViewFirstTag){
        nextContView = [self.view viewWithTag:ImageScrollViewSecondTag];
    }else{
        nextContView = [self.view viewWithTag:ImageScrollViewFirstTag];
    }
    nextImageView = [nextContView viewWithTag:ImageViewTag];
    
    
    NSInteger change = 0;
    CGFloat xOffset = 0;
    if(isRight){
        //向右
        change = -1;
        currentIndex += change;
        if(currentIndex == -1){
            currentIndex = _imagesPathArray.count-1;
        }
        xOffset = contView.frame.size.width/2 * 3;
    }else{
        //向左
        change = 1;
        currentIndex += change;
        if(currentIndex == _imagesPathArray.count){
            currentIndex = 0;
        }
        xOffset = -contView.frame.size.width/2 * 3;
    }
    
    NSData *imageData = [NSData dataWithContentsOfFile: _imagesPathArray[currentIndex]];
    [nextImageView setImageData: imageData];
    [self imageView:nextImageView sizeToFitData:imageData];
    
    if(xOffset != 0){
        
        [UIView animateWithDuration:0.3 animations:^{
            contView.center = CGPointMake(xOffset, contView.center.y);
            
            imageView.userInteractionEnabled = NO;
            nextImageView.userInteractionEnabled = NO;
        } completion:^(BOOL finished) {
            [self.view bringSubviewToFront:nextContView];
            //还原
            contView.center = nextContView.center;
            contView.contentOffset = CGPointZero;
            contView.contentSize = contView.bounds.size;
            imageView.frame = contView.bounds;
            
            imageView.userInteractionEnabled = YES;
            nextImageView.userInteractionEnabled = YES;
            
            currentImageView = nextImageView;
        }];
        
    }
}

-(UIViewController *)getCurrentViewController
{
    UIWindow *currentWindow = [[UIApplication sharedApplication] keyWindow];
    if (currentWindow.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                currentWindow = tmpWin;
                break;
            }
        }
    }
    
    UIViewController *currentViewController = currentWindow.rootViewController;
    UIViewController *presentViewController = currentViewController.presentedViewController;
    if(presentViewController != nil){
        return presentViewController;
    }
    return currentViewController;
}

#pragma mark - 询问是否保存图片
-(void)askSaveImg {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle: nil message: nil preferredStyle: UIAlertControllerStyleActionSheet];
    [alertCtl addAction: [UIAlertAction actionWithTitle: @"保存图片" style: UIAlertActionStyleDefault handler: ^(UIAlertAction * _Nonnull action) {
        __strong typeof(self) self = weakSelf;
        UIImage *image = [UIImage imageWithContentsOfFile: _imagesPathArray[currentIndex]];
        [self saveImg: image];
    }]];
    [alertCtl addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler: nil]];
    [self presentViewController: alertCtl animated: YES completion: nil];
}

-(void)saveImg:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertController *ctrl = [UIAlertController alertControllerWithTitle: @"保存成功" message: nil preferredStyle: UIAlertControllerStyleAlert];
    [ctrl addAction: [UIAlertAction actionWithTitle: @"确定" style: UIAlertActionStyleCancel handler: nil]];
    [self presentViewController: ctrl animated: YES completion: nil];
    
    //延时处理
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    dispatch_after(start, dispatch_get_main_queue(), ^{
        [ctrl dismissViewControllerAnimated: YES completion: nil];
    });
}

@end
