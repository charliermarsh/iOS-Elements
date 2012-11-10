//
//  EP3DBarView.m
//  Eat Princeton
//
//  Created by Charles Marsh on 11/10/12.
//  Copyright (c) 2012 Charles Marsh. All rights reserved.
//

#import "EP3DBarView.h"

@implementation EP3DBarView
@synthesize lightColor, darkColor, outlineColor, backdrop_size = _backdrop_size;

- (int)backdrop_size
{
    if (!_backdrop_size) {
        _backdrop_size = 8;
    }
    return _backdrop_size;
}

- (void)drawRect:(CGRect)rect
{
    int frame_o = 1;
    int frame_w = self.frame.size.width - 2*frame_o;
    int frame_h = self.frame.size.height - 2*frame_o;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, self.outlineColor.CGColor);
    const float* colors1 = CGColorGetComponents(self.lightColor.CGColor);
    CGContextSetRGBFillColor(context, *colors1, *(colors1+1), *(colors1+2), *(colors1+3));
    CGContextSetLineWidth(context, 3.0);
        
    // outer rectangle
    
    CGContextMoveToPoint(context, frame_o, self.backdrop_size);
    CGContextAddLineToPoint(context, frame_o, frame_h);
    CGContextAddLineToPoint(context, frame_w - self.backdrop_size, frame_h);
    CGContextAddLineToPoint(context, frame_w - self.backdrop_size, self.backdrop_size);
    CGContextAddLineToPoint(context, frame_o, self.backdrop_size);
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    // backdrop
    const float* colors2 = CGColorGetComponents(self.darkColor.CGColor);
    CGContextSetRGBFillColor(context, *colors2, *(colors2+1), *(colors2+2), *(colors2+3));
    
    double angle = 0.2;
    CGContextMoveToPoint(context, frame_w - self.backdrop_size, self.backdrop_size);
    CGContextAddLineToPoint(context, frame_o, self.backdrop_size);
    CGContextAddLineToPoint(context, angle*(frame_w - self.backdrop_size), frame_o);
    CGContextAddLineToPoint(context, (1+angle)*(frame_w - self.backdrop_size), frame_o);
    CGContextAddLineToPoint(context, frame_w - self.backdrop_size, self.backdrop_size);
    CGContextAddLineToPoint(context, frame_w - self.backdrop_size, frame_h);
    CGContextAddLineToPoint(context, (1+angle)*(frame_w - self.backdrop_size), frame_h - (angle)*(frame_w - self.backdrop_size));
    CGContextAddLineToPoint(context, (1+angle)*(frame_w - self.backdrop_size), frame_o);
    
    CGContextDrawPath(context, kCGPathFillStroke);
}


@end
