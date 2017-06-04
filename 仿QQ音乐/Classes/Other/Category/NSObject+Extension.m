//
//  NSObject+Extension.m
//  仿QQ音乐
//
//  Created by 叶俊有 on 2017/6/4.
//  Copyright © 2017年 yejunyou. All rights reserved.
//

#import "NSObject+Extension.h"

@implementation NSObject (Extension)
+ (instancetype)stringWithTime:(NSTimeInterval)time
{
    NSInteger min = time / 60;
    NSInteger second = (NSInteger)time % 60;
    return [NSString stringWithFormat:@"%02zd:%02zd",min, second];
}
@end
