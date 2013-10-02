//
//  ImageView.m
//  WeiShare
//
//  Created by yang on 13-1-22.
//  Copyright (c) 2013年 yang. All rights reserved.
//

#import "ImageView.h"

@implementation ImageView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    if (context==nil)
        return;
 
    CGImageRef image = [shareWindowController getImage];
    if (image==nil)
        return;
    
    //获取缩放比例
    float ratio=fmax(CGImageGetWidth(image)/180.0,CGImageGetHeight(image)/146.0);
    NSSize imageSize = CGSizeMake (
                                   CGImageGetWidth(image)/ratio,
                                   CGImageGetHeight(image)/ratio
                                   );
    
    CGRect imageRect = {{0,0}, imageSize};
    
    /* Use high quality interpolation. */
    CGInterpolationQuality q = NSImageInterpolationHigh;
    CGContextSetInterpolationQuality(context, q);
    
    /* Draw the image! */
    CGContextDrawImage(context, imageRect, image);
}

@end
