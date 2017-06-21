//
//  MKImagesReViewController.h
//  MKImageReview
//
//  Created by Liujh on 16/4/6.
//  Copyright © 2016年 com.minstone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKImagesReViewController : UIViewController

/**
 *  浏览图片集
 *
 *  @param imagesPathArray 图片集地址数组
 *  @param index           显示第几张
 *  @param dismissBlock    浏览完之后的事件
 */
-(void)showImages:(NSArray<__kindof NSString *> *)imagesPathArray
            index:(NSInteger)index
afterDismissBlock:(void (^)(NSInteger))dismissBlock;



@end
