//
//  UIView+FrameAdjust.m
//  CoreText1.0
//
//  Created by 叶俊有 on 2017/5/7.
//  Copyright © 2017年 yejunyou. All rights reserved.
//

#import "UIView+FrameAdjust.h"


@implementation UIView (FrameAdjust)
- (void)setX:(CGFloat)x
{
    self.frame = CGRectMake(x, self.y, self.width, self.height);
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    self.frame = CGRectMake(self.x, y, self.width, self.height);
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setRight:(CGFloat)right
{
    self.frame = CGRectMake(right - self.width, self.y, self.width, self.height);
}

- (CGFloat)right
{
    return self.x = self.width;
}

- (void)setBottom:(CGFloat)bottom
{
    self.frame = CGRectMake(self.x, bottom - self.y, self.width, self.height);
}

- (CGFloat)bottom
{
    return self.y + self.height;
}

- (void)setWidth:(CGFloat)width
{
    self.frame = CGRectMake(self.x, self.y, width, self.height);
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    self.frame = CGRectMake(self.x, self.y, self.width, height);
}

- (CGFloat)height
{
    return self.frame.size.height;
}
@end
