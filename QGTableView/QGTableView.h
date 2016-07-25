//
//  QGTableView.h
//  QGTableView
//
//  Created by qikai on 16/7/20.
//  Copyright © 2016年 qikai. All rights reserved.
//

//能够显示三层组成分的tableView
 //  1. 和tableView 相同结构的组信息
 //  2. 和tableView 相同结构的row
 //  3. 在row下面一层的subRow

#import <UIKit/UIKit.h>
#import "QGTableViewCell.h"

@class QGTableView;
#pragma mark -- qgtableView需要走的代理方法，
@protocol QGTableViewDelegate <UITableViewDelegate,UITableViewDataSource>

@required

-(NSInteger )tableView:(QGTableView *)tableView numberOfSubRowsInSection:(NSIndexPath *)indexPath;

-(UITableViewCell *)tableView:(QGTableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath;

-(CGFloat )tableView:(UITableView *)tableView heightForSubRowAtIndexPath:(NSIndexPath *)indexPath;
@optional  // 如果设置将qgtableView 的iscanLongPress设置YES 的话必须实现这个方法
-(void)longPressActionWithGes:(UILongPressGestureRecognizer *)longPress
                WithIndexPath:(NSIndexPath *)touchIndexPath;
@end

#pragma mark -- QGTableView
@interface QGTableView : UITableView

@property (nonatomic ,strong )id <QGTableViewDelegate> qgDelegate;//设置qgDelagte之后就无须设置tableviewdelegate 和 dataSource
@property (nonatomic ,assign )BOOL canOpenMore; //可以多开在一个组当中
@property (nonatomic ,strong )NSMutableArray *openIndexPaths;
@property (nonatomic ,assign )BOOL isCanLongPress;
-(NSInteger )backRealRowWhenNoMoreOpenWithTableView:(UITableView *)tableView AndIndexPath:(NSIndexPath *)indexPath;

@end

#pragma mark --为NSIndexPath开辟一个方法 和一个属性（必须在这里写 ，因为需要用到indexPathForRow InSection  , 这个方法也是一个类目）
@interface NSIndexPath (QGTableView)

@property (nonatomic ,assign)NSInteger subRow;

//开辟一个类方法 输入subRow row section 获得一个indexPath
+(NSIndexPath *)indexPathForSubRow:(NSInteger )subRow InRow:(NSInteger )row InSection:(NSInteger )section;

@end






