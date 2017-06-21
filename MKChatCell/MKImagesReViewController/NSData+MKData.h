//
//  NSData+MKData.h
//  MKImageReview
//
//  Created by DONLINKS on 16/9/20.
//  Copyright © 2016年 com.minstone. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MKImageFormat) {
    Unknown = 0,
    PNG,
    JPEG,
    GIF
};

@interface NSData (MKData)

-(MKImageFormat)getImageDataFormat;

@end
