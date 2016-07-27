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

@implementation NSMutableArray (QGTableView)

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
@interface NSMutableDictionary (QGTableView)
-(void)removeAllObjectsInSection:(NSInteger )section;
@end

@implementation NSMutableDictionary (QGTableView)

-(void)removeAllObjectsInSection:(NSInteger )section{
    NSArray *array = [self allKeys];
    for (NSIndexPath *indexPath  in array) {
        if (indexPath.section == section) {
            [self removeObjectForKey:indexPath];
        }
    }
}

@end

@interface QGTableView ()<UITableViewDelegate,UITableViewDataSource>
//用于存储所有的
@property (nonatomic ,strong) NSMutableArray *expandedPaths;
@property (nonatomic ,strong ) NSMutableDictionary *expandedCells;
@property (nonatomic ,strong ) UILongPressGestureRecognizer *longPress;

@end

@implementation QGTableView

-(void)setQgDelegate:(id<QGTableViewDelegate>)qgDelegate{
    if (_qgDelegate != qgDelegate) {
        _qgDelegate = qgDelegate;
        self.dataSource = self;
        self.delegate = self;
    }
}
//设置是否添加长按手势
-(void)setIsCanLongPress:(BOOL)isCanLongPress{
    if (isCanLongPress == YES) {
        _isCanLongPress = YES;
        //如果设置的是yes 需要添加长安手势
        if ([self.qgDelegate respondsToSelector:@selector(longPressActionWithGes:WithIndexPath:)]) {
            self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTododWithLongPress:)];
            [self addGestureRecognizer:self.longPress];
        }
    }else{
        _isCanLongPress = NO;
        [self removeGestureRecognizer:self.longPress];
        self.longPress = nil;
    }
}

-(void)longPressTododWithLongPress:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if ([self.qgDelegate respondsToSelector:@selector(longPressActionWithGes:WithIndexPath:)]) {
            NSIndexPath *touchIndexPath = [self indexPathForRowAtPoint:[longPress locationInView:longPress.view]];
            NSIndexPath *nowIndexPath = [self backShowIndexPathWithRealIndexPath:touchIndexPath];
//            UITableViewCell *cell = [self cellForRowAtIndexPath:touchIndexPath];
//            if (![cell isKindOfClass:[QGTableViewCell class ]]) {
//                realRow -- ;
//            }
            [self.qgDelegate longPressActionWithGes:longPress WithIndexPath:nowIndexPath];
            
        }
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

-(NSMutableArray *)openIndexPaths{
    if (!_openIndexPaths) {
        _openIndexPaths = [NSMutableArray arrayWithCapacity:[self numberOfSectionsInTableView:self]];
    }
    return _openIndexPaths;
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
    return [self.qgDelegate tableView:tableView numberOfSubRowsInSection:[self backShowIndexPathWithRealIndexPath:indexPath]];
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
    UITableViewCell *cell ;
    if ([self.qgDelegate respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
        if (![[self.expandedCells allKeys] containsObject:indexPath]) {
            cell = [self.qgDelegate tableView:tableView cellForRowAtIndexPath:[self backShowIndexPathWithRealIndexPath:indexPath]];
        }else{
            cell = [self.qgDelegate tableView:(QGTableView *)tableView cellForSubRowAtIndexPath:[self backShowIndexPathWithRealIndexPath:indexPath]];
        }
    }
    return cell;
}
//返回Cell高度
-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[self.expandedCells allKeys] containsObject:indexPath]) {
        if ([self.qgDelegate respondsToSelector:@selector(tableView:heightForSubRowAtIndexPath:)]) {
            return [self.qgDelegate tableView:tableView heightForSubRowAtIndexPath:indexPath];
        }else{
            return 44;
        }
    }else{
        if ([self.qgDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
            return [self.qgDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
        }else{
            return 44;
        }
    }
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
            if (self.canOpenMore == NO) {
                for(int i = 0 ; i < [self tableView:tableView numberOfRowsInSection:indexPath.section]; i ++){
                    QGTableViewCell *otherCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
                    if ([otherCell isKindOfClass:[QGTableViewCell class]] && otherCell !=cell) {
                        otherCell.isOpened = NO;
                    }
                }
                [self insertSubRowToRowWhenNoMoreOpenWithTableView:tableView WithIndexPath:indexPath];
            }
            else{
                //如果不是多开状态的话
                [self insertSubRowToRowWithTableView:tableView WithIndexPath:indexPath];
            }
        }else{
            //如果是已经打开的状态
            
            [self removeSubRowToRowWithTableView:tableView WithIndexPath:indexPath];
        }
    }
    
}
#pragma mark -- 不可以多开的情况下的插入
-(void)insertSubRowToRowWhenNoMoreOpenWithTableView:(UITableView *)tableView WithIndexPath:(NSIndexPath *)indexPath{
    //首先要知道有多少个subRow
    NSInteger numOfSubRow = [self tableView:(QGTableView *)tableView numberOfSubRowsInSection:indexPath];
    NSInteger realRow = [self backRealRowWhenNoMoreOpenWithTableView:tableView AndIndexPath:indexPath];
    NSIndexPath *realIndexPath =  [NSIndexPath indexPathForRow:[self backRealRowWithTableView:tableView AndIndexPath:indexPath] inSection:indexPath.section];
    //首先判断一下有没有打开状态的cell
    NSArray *removeIndexPaths;
    //判断一下对应的section内有没有组的打开的
    if ([self isSomeCellOpenInSection:indexPath.section]) {
        removeIndexPaths = [self getRemoveArrWithSection:indexPath.section];
        //先删除exPanIndexPath里面的内容
        NSMutableArray *sectionArr = self.expandedPaths[indexPath.section];
        for (NSMutableArray *rowArr in sectionArr) {
            [rowArr removeAllObjects];
        }
        
        [tableView deleteRowsAtIndexPaths:removeIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.expandedCells removeAllObjectsInSection:indexPath.section];
    }
    //将subRow插入到Row
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (NSInteger i = numOfSubRow ; i >= 1; i --) {
        NSIndexPath *subIndexPath = [NSIndexPath indexPathForRow:realRow + i inSection:indexPath.section];
        [indexPaths addObject:subIndexPath];
        indexPath.subRow = i;
        [(NSMutableArray *)self.expandedPaths[indexPath.section][realRow] addObject:subIndexPath];
        [self.expandedCells setObject:realIndexPath forKey:subIndexPath];
    }
    [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
}

-(NSInteger )backRealRowWhenNoMoreOpenWithTableView:(UITableView *)tableView AndIndexPath:(NSIndexPath *)indexPath{
    NSArray *array = [self getRemoveArrWithSection:indexPath.section];
    NSMutableArray *subRows = [NSMutableArray array];
    for (NSIndexPath *allIndexPath in array) {
        if (allIndexPath.row < indexPath.row) {
            [subRows addObject:allIndexPath];
        }
    }
    NSInteger backIntger = indexPath.row - subRows.count;
    return backIntger;
}




#pragma mark -- 可以多开的情况下的插入
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
#pragma mark -- 可以多开的情况下的删除
-(void)removeSubRowToRowWithTableView:(UITableView *)tableView WithIndexPath:(NSIndexPath *)indexPath{
    NSInteger realRow = [self backRealRowWithTableView:tableView AndIndexPath:indexPath];
    NSInteger numOfSubRow = [self tableView:(QGTableView *)tableView numberOfSubRowsInSection:indexPath];
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 1; i <= numOfSubRow; i++) {
        NSIndexPath *subIndexPath = [NSIndexPath indexPathForRow:indexPath.row +i inSection:indexPath.section];
        [indexPaths addObject:subIndexPath];
        [(NSMutableArray *)self.expandedPaths[indexPath.section][realRow] removeObject:subIndexPath];
    }
    NSArray *subRows = [self getRemoveArrWithSection:indexPath.section];
    for (NSIndexPath *keyIndexPath in subRows) {
        NSIndexPath *valueIndexPath = [self.expandedCells objectForKey:keyIndexPath];
        if (valueIndexPath == [NSIndexPath indexPathForRow:realRow inSection:indexPath.section]) {
            [self.expandedCells removeObjectForKey:keyIndexPath];
        }
    }

    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
}

//根据indexPath 和 self.expandCells 判断得到点击的到底是哪个Row
-(NSInteger )backRealRowWithTableView:(UITableView *)tableView AndIndexPath:(NSIndexPath *)indexPath{
    NSArray *array = [self getRemoveArrWithSection:indexPath.section];
    NSMutableArray *subRows = [NSMutableArray array];
    for (NSIndexPath *allIndexPath in array) {
        if (allIndexPath.row < indexPath.row) {
            [subRows addObject:allIndexPath];
        }
    }
    return indexPath.row - subRows.count;
}

-(BOOL )isSomeCellOpenInSection:(NSInteger )section{
    NSArray *sectionInfos = [self.expandedCells allKeys];
    for (NSIndexPath *indexPath in sectionInfos) {
        if (indexPath.section == section) {
            return YES;
        }
    }
    return NO;
    
}
#pragma mark -- 获取当前组的所有的cell
-(NSArray *)getRemoveArrWithSection:(NSInteger )section{
    NSArray *allIndexPath = [self.expandedCells allKeys];
    NSMutableArray *removeIndexPaths = [NSMutableArray array];
    for (NSIndexPath *removeIndexPath in allIndexPath) {
        if (removeIndexPath.section == section) {
            [removeIndexPaths addObject:removeIndexPath];
        }
    }
    return (NSArray *)removeIndexPaths;
}
-(NSIndexPath *)backShowIndexPathWithRealIndexPath:(NSIndexPath *)indexPath{
    //首先获取当前组的在这个indexPath 之上的所有额indexpath
    int krow = 0;
    int ksection = indexPath.section;
    int ksubRow = 0;
    NSArray *allIndexPaths = [self getRemoveArrWithSection:indexPath.section];
    NSMutableArray *upIndexPaths = [NSMutableArray array];
    for (NSIndexPath *oneIndexPath in allIndexPaths) {
        if (oneIndexPath.row < indexPath.row) {
            [upIndexPaths addObject:oneIndexPath];
        }
    }
    krow = indexPath.row  - upIndexPaths.count;
    if ([[self.expandedCells allKeys] containsObject:indexPath]) {
        //判断包含indexPath  如果包含的话就证明是subRow
//        那么Row 就需要-1
        krow = krow - 1;
        ksubRow = indexPath.row - krow - 1;
    }else{
        ksubRow = -1;
    }
    NSIndexPath *returnIndexPath = [NSIndexPath indexPathForRow:krow inSection:ksection];
    returnIndexPath.subRow = ksubRow;
    return returnIndexPath;
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
