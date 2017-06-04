//
//  YYMusicTool.h
//  仿QQ音乐
//
//  Created by 叶俊有 on 2017/6/4.
//  Copyright © 2017年 yejunyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YYMusic;
@interface YYMusicTool : NSObject

+ (NSArray *)musics;

+ (void)setPlayingMusic:(YYMusic *)playingMusic;

+ (YYMusic *)playingMusic;

+ (YYMusic *)nextMusic;

+ (YYMusic *)previousMusic;
@end
