//
//  YYMusicTool.m
//  仿QQ音乐
//
//  Created by 叶俊有 on 2017/6/4.
//  Copyright © 2017年 yejunyou. All rights reserved.
//

#import "YYMusicTool.h"
#import "YYMusic.h"
#import "MJExtension.h"

@implementation YYMusicTool

static NSArray *_musics;
static YYMusic *_playingMusic;

+ (void)initialize
{
    _musics = [YYMusic mj_objectArrayWithFilename:@"Musics.plist"];
    _playingMusic = _musics[3];
}

+ (NSArray *)musics
{
    return _musics;
}

+ (void)setPlayingMusic:(YYMusic *)playingMusic
{
    _playingMusic = playingMusic;
}

+ (YYMusic *)playingMusic
{
    return _playingMusic;
}

+ (YYMusic *)nextMusic
{
    NSInteger currentIdx = [_musics indexOfObject:_playingMusic];
    
    NSInteger nextIdx =  ++currentIdx;
    if (nextIdx + 1 == _musics.count) {
        nextIdx = 0;
    }
    
    YYMusic *nextMusic = _musics[nextIdx];
    return nextMusic;
}

+ (YYMusic *)previousMusic
{
    NSInteger currentIdx = [_musics indexOfObject:_playingMusic];
    
    NSInteger previousIdx = --currentIdx ;
    if (previousIdx == -1) {
        previousIdx = _musics.count - 1;
    }
    
    YYMusic *previousMusic = _musics[previousIdx];
    return previousMusic;
}
@end
