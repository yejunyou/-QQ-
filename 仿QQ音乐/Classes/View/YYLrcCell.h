//
//  YYLrcCell.h
//  仿QQ音乐
//
//  Created by 叶俊有 on 2017/6/10.
//  Copyright © 2017年 yejunyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYLrcLabel;
@interface YYLrcCell : UITableViewCell

@property (nonatomic, weak) YYLrcLabel *lrcLabel;

+ (instancetype)lrcCellWithTableView:(UITableView *)tableView;
@end
