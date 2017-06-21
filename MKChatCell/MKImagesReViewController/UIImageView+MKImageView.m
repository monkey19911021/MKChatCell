//
//  MKImageView+UIImageView.m
//  MKImageReview
//
//  Created by DONLINKS on 16/9/20.
//  Copyright © 2016年 com.minstone. All rights reserved.
//

#import "UIImageView+MKImageView.h"
#import "NSData+MKData.h"
#import <ImageIO/ImageIO.h>
#import <objc/runtime.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation UIImageView (MKImageView)

-(void)setImageData:(NSData *)imageData {
    self.image = nil;
    self.animationImages = nil;
    if([imageData getImageDataFormat] == GIF){
        if([self isAnimating]){
            [self stopAnimating];
        }
        NSArray *images= [self getGIFImageArrayWithData: imageData];
        if(images.count > 0){
            self.image = images[0];
            self.animationImages = images;
            self.animationRepeatCount = 0;
            [self startAnimating];
        }else{
            self.image = [UIImage imageWithData: imageData];
        }
    }else if(imageData.length > 0){
        self.image = [UIImage imageWithData: imageData];
    }
    
    //设置imageView的大小
//    UIImage *image = [UIImage imageWithData: imageData];
//    CGFloat width = image.size.width;
//    CGFloat height = image.size.height;
//    if(width > self.frame.size.width){
//        width = self.frame.size.width;
//        height = self.frame.size.height;
//    }
//    self.frame = CGRectMake((self.frame.size.width-width)/2.0, (self.frame.size.height - height)/2.0, width, height);
}

-(NSArray<UIImage *> *)getGIFImageArrayWithData:(NSData *)imageData {
    // kCGImageSourceShouldCache : 表示是否在存储的时候就解码
    // kCGImageSourceTypeIdentifierHint : 指明source type
    CFDictionaryRef options = (__bridge CFDictionaryRef)@{(NSString *)kCGImageSourceShouldCache: @(YES), (NSString *)kCGImageSourceTypeIdentifierHint: (NSString *)kUTTypeGIF};
    CGImageSourceRef imageSoucrceRef = CGImageSourceCreateWithData((CFDataRef)imageData, options);
    
    //获取 gif 帧数
    NSInteger frameCount = CGImageSourceGetCount(imageSoucrceRef);
    //帧率
    NSTimeInterval gifDuration = 0.0;
    NSMutableArray<UIImage *> *imageArray = @[].mutableCopy;
    
    if(frameCount == 1){
        //单帧
        return imageArray;
    }
    
    for(int i=0; i<frameCount; i++){
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSoucrceRef, i, options);
        if(imageRef == nil){
            return imageArray;
        }
        
        // gif 动画
        // 获取到 gif每帧时间间隔
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(imageSoucrceRef, i, nil);
        NSDictionary *gifInfo = [((__bridge NSDictionary *)properties) objectForKey: (NSString *)kCGImagePropertyGIFDictionary];
        NSNumber *frameDuration = gifInfo[(NSString *)kCGImagePropertyGIFDelayTime];
        
        gifDuration += frameDuration.doubleValue;
        // 获取帧的img
        UIImage *image = [UIImage imageWithCGImage: imageRef scale: [UIScreen mainScreen].scale orientation: UIImageOrientationUp];
        // 添加到数组
        [imageArray addObject: image];
    }
    
    self.animationDuration = gifDuration;
    return imageArray;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([keyPath isEqualToString: @"image"]){
        self.animationImages = nil;
    }
}

@end

