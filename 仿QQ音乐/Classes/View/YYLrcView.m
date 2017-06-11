//
//  YYLrcView.m
//  仿QQ音乐
//
//  Created by 叶俊有 on 2017/6/8.
//  Copyright © 2017年 yejunyou. All rights reserved.
//

#import "YYLrcView.h"
#import "Masonry.h"
#import "YYLrcCell.h"
#import "YYLrcLabel.h"
#import "YYLrcLineTool.h"
#import "YYLrcLine.h"
#import "YYMusic.h"
#import "YYMusicTool.h"
#import <MediaPlayer/MediaPlayer.h>

@interface YYLrcView ()<UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *lrcList; // 歌词

@property (nonatomic, assign) NSInteger currentIndex; // 正在播放的歌词所在行数

@end

@implementation YYLrcView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:self.tableView];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self addSubview:self.tableView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left).offset(self.bounds.size.width);
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right);
        make.height.equalTo(self.mas_height);
        make.width.equalTo(self.mas_width);
    }];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(self.bounds.size.height * 0.5, 0, self.bounds.size.height * 0.5, 0);
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lrcList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YYLrcCell *cell = [YYLrcCell lrcCellWithTableView:tableView];
    
    if (self.currentIndex == indexPath.row) {
        cell.lrcLabel.font = [UIFont systemFontOfSize:20];
    }else{
        cell.lrcLabel.font = [UIFont systemFontOfSize:14];
        cell.lrcLabel.progress = 0;
    }

    YYLrcLine *line = self.lrcList[indexPath.row];
    cell.lrcLabel.text = line.text;
    return cell;
}

#pragma mark - 重写setLrcName方法
- (void)setLrcName:(NSString *)lrcName
{
    self.currentIndex = 0;
    
    _lrcName = [lrcName copy];
    
    self.lrcList = [YYLrcLineTool lrcLineToolWithLrcName:lrcName];
    
    [self.tableView reloadData];
}

#pragma mark - 重写setcurrentTime方法
- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    _currentTime = currentTime;
    
    // 匹配当前时间和对应歌词
    NSInteger count = self.lrcList.count;
    for (NSInteger i = 0; i < count; i ++)
    {
        // 获取i位置的歌词
        YYLrcLine *currentLrcLine = self.lrcList[i];
        
        // 获取下一句歌词
        NSInteger nextIndex = i + 1;
        YYLrcLine *nextLrcLine = (nextIndex < count) ? self.lrcList[nextIndex] : nil;
        
        // 显示当前歌词（判断条件：当前时间在 i 位置歌词和 i + 1 位置歌词的时间区间内）
        if (self.currentIndex != i && currentTime >= currentLrcLine.time && currentTime < nextLrcLine.time)
        {
            // 刷新当前行和上一行
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
            self.currentIndex = i; // 在刷新前更新索引
            [self.tableView reloadRowsAtIndexPaths:@[indexPath,previousIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            // 记录当前索引
            
            // 定位到对应的歌词
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            // 更新歌手下方的歌词
            self.lrcLabel.text = currentLrcLine.text;
            
            // 生成锁屏界面
            [self generatorLockImage];
        }
        
        // 依据进度更新歌词颜色
        if (self.currentIndex == i)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            CGFloat progress = (currentTime - currentLrcLine.time) / (nextLrcLine.time - currentLrcLine.time);
            YYLrcCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.lrcLabel.progress = progress;
            self.lrcLabel.progress = progress;
        }
    }
}

#pragma mark - setting and getting
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 35;
    }
    return _tableView;
}

#pragma mark - 生成锁屏信息
- (void)generatorLockImage
{
    // 获取当前歌曲图片
    YYMusic *playingMusic = [YYMusicTool playingMusic];
    UIImage *currentImage = [UIImage imageNamed:playingMusic.icon];
    
    // 获取三句歌词
    YYLrcLine *currentLine = self.lrcList[self.currentIndex];
    YYLrcLine *previousLine = (self.currentIndex >= 1) ? self.lrcList[self.currentIndex - 1] : nil;
    YYLrcLine *nextLine = (self.currentIndex < self.lrcList.count - 1) ? self.lrcList[self.currentIndex + 1] : nil;
    
    // 生成水印图片
    UIGraphicsBeginImageContext(currentImage.size);
    [currentImage drawAtPoint:CGPointZero];
    CGFloat titleH = 25;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    NSDictionary *attr1 = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
                            NSForegroundColorAttributeName:[UIColor lightGrayColor],
                            NSParagraphStyleAttributeName: style};
    NSDictionary *attr2 = @{NSFontAttributeName : [UIFont systemFontOfSize:16],
                            NSForegroundColorAttributeName:[UIColor whiteColor],
                            NSParagraphStyleAttributeName: style};
    
    [previousLine.text  drawInRect:CGRectMake(0, currentImage.size.height - titleH * 3, currentImage.size.width, titleH) withAttributes:attr1];
    [currentLine.text   drawInRect:CGRectMake(0, currentImage.size.height - titleH * 2, currentImage.size.width, titleH) withAttributes:attr2];
    [nextLine.text      drawInRect:CGRectMake(0, currentImage.size.height - titleH * 1, currentImage.size.width, titleH) withAttributes:attr1];
    
    UIImage *lockImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 设置锁屏信息
    [self setupLockScreenInfoWithImg:lockImage];
    
    // 关闭
    UIGraphicsEndImageContext();
}

#pragma mark - 设置界面锁屏信息

- (void)setupLockScreenInfoWithImg:(UIImage *)image
{
    // 获取当前播放歌曲
    YYMusic *playingMusic = [YYMusicTool playingMusic];
    
    // 获取锁屏界面信息
    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
    
    // 设置锁屏展示信息
    NSMutableDictionary *playingInfo = [NSMutableDictionary dictionary];
    [playingInfo setObject:playingMusic.name forKey:MPMediaItemPropertyAlbumTitle]; // 歌曲名字
    [playingInfo setObject:playingMusic.singer forKey:MPMediaItemPropertyArtist];   // 歌手画像
    
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:image];
    [playingInfo setObject:artWork forKey:MPMediaItemPropertyArtwork];
    [playingInfo setObject:@(self.duration) forKey:MPMediaItemPropertyPlaybackDuration];
    [playingInfo setObject:@(self.currentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    
    center.nowPlayingInfo = playingInfo;
    
    // 设置应用为可接受远程事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

@end
