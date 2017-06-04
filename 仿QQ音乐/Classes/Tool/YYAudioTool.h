//
//  YYAudioTool.h
//  仿QQ音乐
//
//  Created by 叶俊有 on 2017/6/4.
//  Copyright © 2017年 yejunyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface YYAudioTool : NSObject

+ (void)playSoundWithName:(NSString *)soundName;

+ (AVAudioPlayer *)playMusicWithName:(NSString *)musicName;

+ (void)pauseMusicWithName:(NSString *)musicName;

+ (void)stopMusicWithName:(NSString *)musicName;
@end
