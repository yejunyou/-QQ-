//
//  YYAudioTool.m
//  仿QQ音乐
//
//  Created by 叶俊有 on 2017/6/4.
//  Copyright © 2017年 yejunyou. All rights reserved.
//

#import "YYAudioTool.h"

@implementation YYAudioTool
static NSMutableDictionary *_soundDict;
static NSMutableDictionary *_musicDict;

+ (void)initialize
{
    _soundDict = [NSMutableDictionary dictionary];
    _musicDict = [NSMutableDictionary dictionary];
}

+ (void)playSoundWithName:(NSString *)soundName
{
    // 取出声音文件对应的id
    SystemSoundID soundID = [_soundDict[soundName] unsignedIntValue];
    
    // 如果等于0，则创建对应的音效文件
    if (0 == soundID) {
        // 获取音频url
        CFURLRef urlRef = (__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:soundName withExtension:nil];
        
        // 创建对应的音效文件
        AudioServicesCreateSystemSoundID( urlRef, &soundID);
        
        [_musicDict setObject:@(soundID) forKey:soundName];
    }
    // 播放音效
    AudioServicesPlaySystemSound(soundID);
}

+ (AVAudioPlayer *)playMusicWithName:(NSString *)musicName
{
    // 判断名称是否为空
    assert(musicName);
    
    // 取出播放器
    AVAudioPlayer *player = _musicDict[musicName];
    
    if (player == nil) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:musicName withExtension:nil];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [_musicDict setObject:player forKey:musicName];
    }
    
    [player prepareToPlay];
    [player play];
    
    return player;
}

+ (void)pauseMusicWithName:(NSString *)musicName
{
    assert(musicName);
    
    AVAudioPlayer *player = _musicDict[musicName];
    
    if (player && player.isPlaying)
    {
        [player pause];
    }
}

+ (void)stopMusicWithName:(NSString *)musicName
{
    assert(musicName);
    
    AVAudioPlayer *player = _musicDict[musicName];
    
    if (player)
    {
        [player stop];
        [_musicDict removeObjectForKey:musicName];
        player = nil;
    }
}
@end


