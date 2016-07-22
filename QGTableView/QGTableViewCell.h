//
//  QGTableViewCell.h
//  QGTableView
//
//  Created by qikai on 16/7/21.
//  Copyright © 2016年 qikai. All rights reserved.
//


//QGTableView实现的功能为点击打开或者点击收起
#import <UIKit/UIKit.h>

@interface QGTableViewCell : UITableViewCell

@property (nonatomic ,assign )BOOL isCanOpen;//是否可以被打开
@property (nonatomic ,assign )BOOL isOpened;//是否是打开状态


@end