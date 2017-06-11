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
@end
