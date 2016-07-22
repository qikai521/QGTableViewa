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

-(void)initRowObjcetForCapacity:(NSInteger)numItems WithSection:(NSInteger )section {
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
//Row的数量
-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numOfRowInSection ;
    if ([self.qgDelegate respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        numOfRowInSection = [self.qgDelegate tableView:tableView numberOfRowsInSection:section];
        
        if (numOfRowInSection != [self.expandedPaths[section] count]) {
            [(NSMutableArray *)self.expandedPaths[section] initRowObjcetForCapacity:numOfRowInSection WithSection:section];
        }
        numOfRowInSection = 0;
        for (int i = 0; i <[self.expandedPaths[section] count]; i++) {
            NSArray *array = self.expandedPaths[section][i];
            numOfRowInSection += array.count;
        }
    }
    return numOfRowInSection + [self.expandedPaths[section] count];
}
//SubRow的数量
-(NSInteger )tableView:(QGTableView *)tableView numberOfSubRowsInSection:(NSIndexPath *)indexPath{
    return [self.qgDelegate tableView:tableView numberOfSubRowsInSection:indexPath];
}
//Section的数量
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
//SubRowCell
//-(UITableViewCell *)tableView:(QGTableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell ;
//    if ([self.qgDelegate respondsToSelector:@selector(tableView:cellForSubRowAtIndexPath:)]) {
//        cell = [self.qgDelegate tableView:tableView cellForSubRowAtIndexPath:indexPath];
//        cell.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
//         return cell;
//    }
//    return nil;
//}
//RowCell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"indexPath ===== %ld ------%ld",indexPath.section,indexPath.row);
    UITableViewCell *cell ;
    if ([self.qgDelegate respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
        if (![[self.expandedCells allKeys] containsObject:indexPath]) {
            cell = [self.qgDelegate tableView:tableView cellForRowAtIndexPath:indexPath];
        }else{
            cell = [self.qgDelegate tableView:(QGTableView *)tableView cellForSubRowAtIndexPath:indexPath];
        }
    }
    return cell;
}
//组头名
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if([self.qgDelegate respondsToSelector:@selector(tableView:titleForHeaderInSection:)]){
        return [self.qgDelegate tableView:tableView titleForHeaderInSection:section];
    }else{
        return nil;
    }
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
            //首先需要将subRow插入到Row之中去
            [self insertSubRowToRowWithTableView:tableView WithIndexPath:indexPath];
            
        }else{
            //如果要从打开状态变成关闭状态需要removeCell
            [self removeSubRowToRowWithTableView:tableView WithIndexPath:indexPath];
        }
    }
    
    
}

-(void)insertSubRowToRowWithTableView:(UITableView *)tableView WithIndexPath:(NSIndexPath *)indexPath{
    //首先要知道有多少个subRow
    NSInteger numOfSubRow = [self tableView:(QGTableView *)tableView numberOfSubRowsInSection:indexPath];
    //将subRow插入到Row
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSInteger realRow = [self backRealRowWithTableView:tableView AndIndexPath:indexPath];
    for (NSInteger i = numOfSubRow ; i >= 1; i --) {
        NSIndexPath *subIndexPath = [NSIndexPath indexPathForRow:indexPath.row + i inSection:indexPath.section];
        [indexPaths addObject:subIndexPath];
        indexPath.subRow = i;
        [(NSMutableArray *)self.expandedPaths[indexPath.section][realRow] addObject:subIndexPath];
        [self.expandedCells setObject:indexPath forKey:subIndexPath];
    }
    [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];

}
-(void)removeSubRowToRowWithTableView:(UITableView *)tableView WithIndexPath:(NSIndexPath *)indexPath{
    NSInteger realRow = [self backRealRowWithTableView:tableView AndIndexPath:indexPath];
    NSInteger numOfSubRow = [self tableView:(QGTableView *)tableView numberOfSubRowsInSection:indexPath];
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 1; i <= numOfSubRow; i++) {
        NSIndexPath *subIndexPath = [NSIndexPath indexPathForRow:indexPath.row +i inSection:indexPath.section];
        [indexPaths addObject:subIndexPath];
        [(NSMutableArray *)self.expandedPaths[indexPath.section][realRow] removeObject:subIndexPath];
        NSArray *subRows = [self.expandedCells allKeys];
        for (NSIndexPath *keyIndexPath in subRows) {
            NSIndexPath *valueIndexPath = [self.expandedCells objectForKey:keyIndexPath];
            if (valueIndexPath == indexPath) {
                [self.expandedCells removeObjectForKey:keyIndexPath];
            }
        }
    }
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
}

//根据indexPath 和 self.expandCells 判断得到点击的到底是哪个Row
-(NSInteger )backRealRowWithTableView:(UITableView *)tableView AndIndexPath:(NSIndexPath *)indexPath{
    NSArray *array = [self.expandedCells allKeys];
    NSMutableArray *subRows = [NSMutableArray array];
    for (NSIndexPath *allIndexPath in array) {
        if (allIndexPath.row < indexPath.row) {
            [subRows addObject:allIndexPath];
        }
    }
    return indexPath.row - subRows.count;
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
