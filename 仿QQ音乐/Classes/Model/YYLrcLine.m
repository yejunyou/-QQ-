//
//  YYLrcLine.m
//  仿QQ音乐
//
//  Created by 叶俊有 on 2017/6/10.
//  Copyright © 2017年 yejunyou. All rights reserved.
//

#import "YYLrcLine.h"

@implementation YYLrcLine

- (instancetype)initWithLrcLineString:(NSString *)lrcLineString
{
    if (self = [super init]) {
        NSArray *lrcArray = [lrcLineString componentsSeparatedByString:@"]"];
        self.text = lrcArray[1];
        NSString *timeString = lrcArray[0];
        self.time = [self timeStringWithString:[timeString substringFromIndex:1]];
    }
    return self;
}

+ (instancetype)lrcLineWithLrcLineString:(NSString *)lrcLineString
{
    return [[self alloc] initWithLrcLineString:lrcLineString];
}

#pragma mark - 私有方法 
- (NSTimeInterval)timeStringWithString:(NSString *)timeString
{
    NSInteger min = [[timeString componentsSeparatedByString:@":"][0] integerValue];
    NSInteger second = [[timeString substringWithRange:NSMakeRange(3, 2)] integerValue];
    NSInteger millisecond = [[timeString componentsSeparatedByString:@"."][1] integerValue];
    return min * 60 + second + millisecond * 0.01;
}
@end
