//
//  TrangleView.m
//  imyvoa
//
//  Created by yzx on 12-6-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TrangleView.h"

@implementation TrangleView

- (id)init
{
    self = [self initWithFrame:CGRectZero];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [UIColor blackColor];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, width / 2, 0);
    CGContextAddLineToPoint(context, 0, height);
    CGContextAddLineToPoint(context, width, height);
    
    CGContextClosePath(context);
    
    CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
    CGContextSetLineWidth(context, 1);
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextDrawPath(context, kCGPathFill);
}

@end
