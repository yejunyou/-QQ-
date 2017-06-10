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

#pragma mark - slider事件
- (IBAction)sliderTouchDown;
- (IBAction)sliderValueChange;
- (IBAction)sliderTouchEnd;
- (IBAction)sliderTap:(UITapGestureRecognizer *)sender;


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
    
    // iconView动画
    [self startIconViewAnimation];
    
    // 添加定时器更新进度信息
    [self updateProgressInfo];
    [self removeProgressTimer];
    [self addProgressTimer];
}

#pragma mark - 进度定时器操作
- (void)addProgressTimer
{
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
}

- (void)removeProgressTimer
{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

// 更新进度信息
- (void)updateProgressInfo
{
    // 播放时间
    self.currentTimeLabel.text = [NSString stringWithTime:self.currentPlayer.currentTime];
    
    // 进度条
    self.progressSlider.value = self.currentPlayer.currentTime / self.currentPlayer.duration;
}

- (void)startIconViewAnimation
{
    CABasicAnimation *rotationAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnim.fromValue = @(0);
    rotationAnim.toValue = @(M_PI * 2);
    rotationAnim.repeatCount = NSIntegerMax;
    rotationAnim.duration = 30;
    
    [self.iconView.layer addAnimation:rotationAnim forKey:nil];
}

#pragma mark - 切换和暂停歌曲操作
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

#pragma mark - slider事件
- (IBAction)sliderTouchDown {
    // 暂停定时器
    [self removeProgressTimer];
}

- (IBAction)sliderValueChange {
    // 更新当前播放时间
    self.currentTimeLabel.text = [NSString stringWithTime:self.progressSlider.value * self.currentPlayer.duration];
}

- (IBAction)sliderTouchEnd {
    // 播放当前时间歌曲
    self.currentPlayer.currentTime = self.progressSlider.value * self.currentPlayer.duration;
    
    // 恢复定时器
    [self addProgressTimer];
}

- (IBAction)sliderTap:(UITapGestureRecognizer *)sender {
    // 获取点击位置
    CGPoint point = [sender locationInView:self.progressSlider];
    CGFloat ratio = point.x / self.progressSlider.bounds.size.width;
    
    // 更该当前播放时间
    self.currentPlayer.currentTime = ratio * self.currentPlayer.duration;
    
    // 更新进度信息
    [self updateProgressInfo];
}
@end
