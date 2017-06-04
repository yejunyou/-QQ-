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

#define YYRGBA(A,B,C,a) [UIColor colorWithRed:A/255.0 green:B/255.0 blue:C/255.0 alpha:a]
#define YYRGB(A,B,C)   YYRGBA(A,B,C,1.0)

@interface YYPlayingViewController ()

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
    
    // 设置滑块的头
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
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

@end
