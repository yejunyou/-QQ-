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
#import "CALayer+PauseAimate.h"
#import "YYLrcView.h"
#import "YYLrcLabel.h"
#import <MediaPlayer/MediaPlayer.h>

#define YYRGBA(A,B,C,a) [UIColor colorWithRed:A/255.0 green:B/255.0 blue:C/255.0 alpha:a]
#define YYRGB(A,B,C)   YYRGBA(A,B,C,1.0)

@interface YYPlayingViewController ()<UIScrollViewDelegate,AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *albunView;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *songLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet YYLrcLabel *lrcLabel;

/* 播放或暂停按钮 */
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseBtn;

/* 歌词视图 */
@property (weak, nonatomic) IBOutlet YYLrcView *lrcView;

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
    
    // 设置内容尺寸
    self.lrcView.contentSize = CGSizeMake(self.view.bounds.size.width * 2, 0);
    self.lrcView.lrcLabel = self.lrcLabel;
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
    self.lrcLabel.text = @"";
    
    // 当前正在播放的音乐
    YYMusic *playingMusic = [YYMusicTool playingMusic];
    
    // 更新歌曲界面信息
    self.albunView.image = [UIImage imageNamed:playingMusic.icon];
    self.iconView.image = [UIImage imageNamed:playingMusic.icon];
    self.songLabel.text = playingMusic.name;
    self.singerLabel.text = playingMusic.singer;
    
    
    // 开始播放音乐
    self.currentPlayer = [YYAudioTool playMusicWithName:playingMusic.filename];
    self.currentPlayer.delegate = self;
    self.totalTimeLabel.text = [NSString stringWithTime:self.currentPlayer.duration];
    self.currentTimeLabel.text = [NSString stringWithTime:self.currentPlayer.currentTime];
    self.playOrPauseBtn.selected = self.currentPlayer.isPlaying;
    
    // 设置歌词
    self.lrcView.lrcName = playingMusic.lrcname;
    
    // iconView动画
    [self startIconViewAnimation];
    
    // 添加定时器更新进度信息
    [self updateProgressInfo];
    
    [self removeProgressTimer];
    [self addProgressTimer];
    [self removeLrcTimer];
    [self addLrcTimer];
    
    [self setupLockScreenInfo];
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

#pragma mark - 歌词定时器
- (void)addLrcTimer
{
    self.lrcTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrcProgress)];
    [self.lrcTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)removeLrcTimer
{
    [self.lrcTimer invalidate];
    self.lrcTimer  = nil;
}

- (void)updateLrcProgress
{
    self.lrcView.currentTime = self.currentPlayer.currentTime;
}

#pragma mark - 歌手动画
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
    playButton.selected = !playButton.isSelected;
    
    if (self.currentPlayer.isPlaying)
    {
        // 暂停
        [self.currentPlayer pause];
        [self.iconView.layer pauseAnimate];
        [self removeProgressTimer];
        [self removeLrcTimer];
    }
    else
    {
        // 播放
        [self.currentPlayer play];
        [self.iconView.layer resumeAnimate];
        [self addProgressTimer];
        [self addLrcTimer];
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

#pragma mark - 设置界面锁屏信息

- (void)setupLockScreenInfo
{
    // 获取当前播放歌曲
    YYMusic *playingMusic = [YYMusicTool playingMusic];
    
    // 获取锁屏界面信息
    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
    
    // 设置锁屏展示信息
    NSMutableDictionary *playingInfo = [NSMutableDictionary dictionary];
    [playingInfo setObject:playingMusic.name forKey:MPMediaItemPropertyAlbumTitle]; // 歌曲名字
    [playingInfo setObject:playingMusic.singer forKey:MPMediaItemPropertyArtist];   // 歌手画像
    
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:playingMusic.icon]];
    [playingInfo setObject:artWork forKey:MPMediaItemPropertyArtwork];
    [playingInfo setObject:@(self.currentPlayer.duration) forKey:MPMediaItemPropertyPlaybackDuration];
    
    center.nowPlayingInfo = playingInfo;
    
    // 设置应用为可接受远程事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat ratio = self.lrcView.contentOffset.x / self.lrcView.width;
    self.iconView.alpha = 1 - ratio;
    self.lrcLabel.alpha = 1 - ratio;
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) [self next];
}

#pragma mark - 处理远程事件
/*
 
 UIEventSubtypeRemoteControlPlay                 = 100,
 UIEventSubtypeRemoteControlPause                = 101,
 UIEventSubtypeRemoteControlStop                 = 102,
 UIEventSubtypeRemoteControlTogglePlayPause      = 103,
 UIEventSubtypeRemoteControlNextTrack            = 104,
 UIEventSubtypeRemoteControlPreviousTrack        = 105,
 UIEventSubtypeRemoteControlBeginSeekingBackward = 106,
 UIEventSubtypeRemoteControlEndSeekingBackward   = 107,
 UIEventSubtypeRemoteControlBeginSeekingForward  = 108,
 UIEventSubtypeRemoteControlEndSeekingForward    = 109,
 */
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        case UIEventSubtypeRemoteControlPause:
            [self playOrPause:self.playOrPauseBtn];
            break;
            
        case UIEventSubtypeRemoteControlNextTrack:
            [self next];
            break;
            
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self previous];
            break;
            
        default:
            break;
    }
}
@end
