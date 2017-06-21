//
//  NSData+MKData.m
//  MKImageReview
//
//  Created by DONLINKS on 16/9/20.
//  Copyright © 2016年 com.minstone. All rights reserved.
//

#import "NSData+MKData.h"

const UInt8 pngHeader[] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A};
const UInt8 jpgHeaderSOI[] = {0xFF, 0xD8};
const UInt8 jpgHeaderIF[] = {0xFF};
const UInt8 gifHeader[] = {0x47, 0x49, 0x46};

@implementation NSData (MKData)

-(MKImageFormat)getImageDataFormat {
    
    UInt8 buffer[8] = {0};
    [self getBytes: &buffer length: 8];
    
    BOOL isPng = YES;
    for(int i=0; i<8; i++){
        if(buffer[i] != pngHeader[i]){
            isPng = NO;
            break;
        }
    }
    
    if (isPng) {
        return PNG;
    } else if (buffer[0] == jpgHeaderSOI[0] &&
        buffer[1] == jpgHeaderSOI[1] &&
        buffer[2] == jpgHeaderIF[0])
    {
        return JPEG;
    } else if (buffer[0] == gifHeader[0] &&
        buffer[1] == gifHeader[1] &&
        buffer[2] == gifHeader[2])
    {
        return GIF;
    }
    
    return Unknown;
}

@end
