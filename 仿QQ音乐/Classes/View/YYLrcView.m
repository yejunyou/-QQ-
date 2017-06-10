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
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lrcList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YYLrcCell *cell = [YYLrcCell lrcCellWithTableView:tableView];
    
    YYLrcLine *line = self.lrcList[indexPath.row];
    cell.lrcLabel.text = line.text;
    return cell;
}

#pragma mark - 重写setLrcName方法
- (void)setLrcName:(NSString *)lrcName
{
    _lrcName = [lrcName copy];
    
    self.lrcList = [YYLrcLineTool lrcLineToolWithLrcName:lrcName];
    
    [self.tableView reloadData];
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
