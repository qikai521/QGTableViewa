//
//  NormalViewController.h
//  QGTableView
//
//  Created by qikai on 16/7/20.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSIndexPath+QGIndexPath.h"

@interface NormalViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong)UITableView *tableView;
@property (nonatomic ,strong)NSIndexPath *openIndexPath;
@property (nonatomic ,assign)BOOL isOpenStatue;

@end
