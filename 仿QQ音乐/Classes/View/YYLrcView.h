//
//  YYLrcView.h
//  仿QQ音乐
//
//  Created by 叶俊有 on 2017/6/8.
//  Copyright © 2017年 yejunyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYLrcLabel;
@interface YYLrcView : UIScrollView

@property (nonatomic, copy) NSString *lrcName;

@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, weak) YYLrcLabel *lrcLabel; 
@end
