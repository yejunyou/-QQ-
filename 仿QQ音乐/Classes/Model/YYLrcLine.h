//
//  YYLrcLine.h
//  仿QQ音乐
//
//  Created by 叶俊有 on 2017/6/10.
//  Copyright © 2017年 yejunyou. All rights reserved.
//  单行歌词模型

#import <Foundation/Foundation.h>

@interface YYLrcLine : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSTimeInterval time;

- (instancetype)initWithLrcLineString:(NSString *)lrcLineString;
+ (instancetype)lrcLineWithLrcLineString:(NSString *)lrcLineString;
@end
