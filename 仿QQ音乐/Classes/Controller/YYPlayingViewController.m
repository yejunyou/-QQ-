//
//  YYPlayingViewController.m
//  仿QQ音乐
//
//  Created by 叶俊有 on 2017/6/3.
//  Copyright © 2017年 yejunyou. All rights reserved.
//

#import "YYPlayingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+FrameAdjust.h"
#import "YYMusicTool.h"
#import "YYMusic.h"
#import "YYAudioTool.h"
#import "NSObject+Extension.h"

#define YYRGBA(A,B,C,a) [UIColor colorWithRed:A/255.0 green:B/255.0 blue:C/255.0 alpha:a]
#define YYRGB(A,B,C)   YYRGBA(A,B,C,1.0)

@interface YYPlayingViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *albunView;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

/* 播放或暂停按钮 */
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseBtn;

/* 歌词视图 */
@property (weak, nonatomic) IBOutlet UIScrollView *lrcView;

/* 进度条的Timer */
@property (nonatomic, strong) NSTimer *progressTimer;

/* 歌词的Timer */
@property (nonatomic, strong) CADisplayLink *lrcTimer;

/* 播放器 */
@property (nonatomic, strong) AVAudioPlayer *currentPlayer;

@end

@implementation YYPlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置滑块头
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
    
    // 播放音乐
    [self startPlayingMusic];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.iconView.layer.cornerRadius = self.iconView.width * 0.5;
    self.iconView.layer.masksToBounds = YES;
    self.iconView.layer.borderWidth = 8.0;
    self.iconView.layer.borderColor = YYRGB(36, 36, 36).CGColor;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - 开始播放音乐
- (void)startPlayingMusic
{
    // 当前正在播放的音乐
    YYMusic *playingMusic = [YYMusicTool playingMusic];
    
    // 更新歌曲信息
    self.albunView.image = [UIImage imageNamed:playingMusic.icon];
    self.iconView.image = [UIImage imageNamed:playingMusic.icon];
    self.songLabel.text = playingMusic.name;
    self.singerLabel.text = playingMusic.singer;
    
    
    // 开始播放音乐
    self.currentPlayer = [YYAudioTool playMusicWithName:playingMusic.filename];
    self.totalTimeLabel.text = [NSString stringWithTime:self.currentPlayer.duration];
    self.currentTimeLabel.text = [NSString stringWithTime:self.currentPlayer.currentTime];
}

#pragma mark - 切换和暂停歌曲
- (IBAction)playOrPause:(UIButton *)playButton {
    
    if (self.currentPlayer.isPlaying)
    {
        playButton.selected = !playButton.isSelected;
        
        // 暂停
        [self.currentPlayer pause];
    }
    else
    {
        playButton.selected = !playButton.isSelected;
        
        // 播放
        [self.currentPlayer play];
    }
}

- (IBAction)previous{
    [self playMusicWithMusic:[YYMusicTool previousMusic]];
}

- (IBAction)next{
    [self playMusicWithMusic:[YYMusicTool nextMusic]];
}

- (void)playMusicWithMusic:(YYMusic *)music
{
    // 停止当前播放的歌曲
    YYMusic *playingMusic = [YYMusicTool playingMusic];
    [YYAudioTool stopMusicWithName:playingMusic.filename];
    
    // 播放将要要播放的歌曲
    [YYMusicTool setPlayingMusic:music];
    
    // 跟新界面信息
    [self startPlayingMusic];
}
@end
