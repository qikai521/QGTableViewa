//
//  QGTableView.m
//  QGTableView
//
//  Created by qikai on 16/7/20.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import "QGTableView.h"
#import <objc/runtime.h>

static char kQGTableView_subRowKey;


@interface NSMutableArray (SKSTableView)
// 为NSMutableArray 开辟了一个类目 SKSTableView
- (void)initiateObjectsForCapacity:(NSInteger)numItems;

@end

@implementation NSMutableArray (SKSTableView)

- (void)initiateObjectsForCapacity:(NSInteger)numItems
{
    for (NSInteger index = [self count]; index < numItems; index++) {
        NSMutableArray *array = [NSMutableArray array];
        [self addObject:array];
    }
}
@end

@interface QGTableView ()<UITableViewDelegate,UITableViewDataSource>
//用于存储所有的
@property (nonatomic ,strong) NSMutableArray *expandedPaths;
@property (nonatomic ,strong ) NSMutableDictionary *expandedCells;

@end

@implementation QGTableView

-(void)setQgDelegate:(id<QGTableViewDelegate>)qgDelegate{
    if (_qgDelegate != qgDelegate) {
        _qgDelegate = qgDelegate;
        self.dataSource = self;
        self.delegate = self;
    }
}
//存储着三层结构的数组
/* =========   1.有多少section
   =========   2.有多少row
   =========   3.有多少subRow
 eg:
 @[
 //section1 @[ 
           //row1    @[
                      
                       ]
           //row2    @[]
           //row3    @[]
 
        ]
 //section2 @[
        ]
 ]
 */
-(NSMutableArray *)expandedPaths{
    if (_expandedPaths == nil) {
        _expandedPaths = [NSMutableArray array];
    }
    return _expandedPaths;
}
-(NSMutableDictionary *)expandedCells{
    if (!_expandedCells)
        _expandedCells = [NSMutableDictionary dictionary];
    return _expandedCells;
}

#pragma mark -- UITableViewDataSource
-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numOfRowInSection ;
    if ([self.qgDelegate respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        numOfRowInSection = [self.qgDelegate tableView:tableView numberOfRowsInSection:section] + [self.expandedPaths[section] count];
        
    }
    return numOfRowInSection;
}

-(NSInteger )tableView:(QGTableView *)tableView numberOfSubRowsInSection:(NSIndexPath *)indexPath{
    return [self.qgDelegate tableView:tableView numberOfSubRowsInSection:indexPath];
}

-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView{
    if ([self.qgDelegate respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        NSInteger numOfSection = [self.qgDelegate numberOfSectionsInTableView:tableView];
        if (numOfSection != self.expandedPaths.count) {
            //如果expath没有配置的话需要配置一下()
            [self.expandedPaths initiateObjectsForCapacity:numOfSection];
        }
        return numOfSection;
    }else{
        return 1;
    }
}

-(UITableViewCell *)tableView:(QGTableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.qgDelegate respondsToSelector:@selector(tableView:cellForSubRowAtIndexPath:)]) {
         return [self.qgDelegate tableView:tableView cellForSubRowAtIndexPath:indexPath];
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QGTableViewCell *cell ;
    if ([self.qgDelegate respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
        cell = (QGTableViewCell *)[self.qgDelegate tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    return cell;
}
//点击事件

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.qgDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.qgDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    __block QGTableViewCell *cell = (QGTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[QGTableViewCell class]] && cell.isCanOpen == YES) {
        //点击的是可以被打开的cell
        cell.isOpened = !cell.isOpened;
        NSInteger numOfSubRows = [self tableView:(QGTableView *)tableView numberOfSubRowsInSection:indexPath];
        NSMutableArray *subRowsIndexPath = [NSMutableArray array];
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        for (int i= 1 ; i <= numOfSubRows; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:section inSection:row+i];
            [subRowsIndexPath addObject:indexPath];
        }
        if (cell.isOpened) {
            //如果说要变成打开状态的话那么需要插入cell
            
        }
        
    }
    
    
}




@end


#pragma mark --NSIndexPath 拓展的subRow
@implementation NSIndexPath (QGTableView)
@dynamic subRow;
-(void)setSubRow:(NSInteger)subRow{
    objc_setAssociatedObject(self, &kQGTableView_subRowKey, @(subRow), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSInteger )subRow{
    return [objc_getAssociatedObject(self, &kQGTableView_subRowKey) integerValue];
}

+(NSIndexPath *)indexPathForSubRow:(NSInteger)subRow InRow:(NSInteger)row InSection:(NSInteger)section{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    indexPath.subRow = subRow;
    return indexPath;
}
@end
