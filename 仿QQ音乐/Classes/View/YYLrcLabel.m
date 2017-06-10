//
//  YYLrcLabel.m
//  仿QQ音乐
//
//  Created by 叶俊有 on 2017/6/10.
//  Copyright © 2017年 yejunyou. All rights reserved.
//

#import "YYLrcLabel.h"

@implementation YYLrcLabel


- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    // 立即刷新
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    CGRect fillRect = CGRectMake(0, 0, self.progress * self.bounds.size.width, self.bounds.size.height);
    
    [[UIColor redColor] set];
    
    UIRectFillUsingBlendMode(fillRect, kCGBlendModeSourceIn);
}


@end
