//
//  YYLrcLineTool.m
//  仿QQ音乐
//
//  Created by 叶俊有 on 2017/6/10.
//  Copyright © 2017年 yejunyou. All rights reserved.
//

#import "YYLrcLineTool.h"
#import "MJExtension.h"
#import "YYLrcLine.h"

@implementation YYLrcLineTool

+ (NSArray *)lrcLineToolWithLrcName:(NSString *)lrcName
{
    // 获取文件录路径
    NSString *path = [[NSBundle mainBundle] pathForResource:lrcName ofType:nil];
    
    // 读取歌词
    NSString *lrcString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    // 分割歌词（单行）
    NSArray *tempArray = [lrcString componentsSeparatedByString:@"\n"];
    
    // 转模型
    NSMutableArray *lrcArray = [NSMutableArray array];
    for (NSString *lrcLineString in tempArray) {
        // 过滤不需要的信息
        /*
         "[ti:I want it that way]",
         "[ar:Backstreet Boys]",
         "[al:Millennium]",
         */
        if ([lrcLineString hasPrefix:@"[ti:"] ||
            [lrcLineString hasPrefix:@"[ar:"]  ||
            [lrcLineString hasPrefix:@"[al:"]  ||
            ![lrcLineString hasPrefix:@"["])
        {
            continue;
        }
        
        
        YYLrcLine *line = [YYLrcLine lrcLineWithLrcLineString:lrcLineString];
        [lrcArray addObject:line];
    }
    
    return lrcArray;
}
@end
