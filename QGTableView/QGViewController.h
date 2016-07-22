//
//  QGViewController.h
//  QGTableView
//
//  Created by qikai on 16/7/20.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QGTableView.h"
@interface QGViewController : UIViewController<QGTableViewDelegate>


@property (nonatomic ,strong)QGTableView *qgTableView;
@end
