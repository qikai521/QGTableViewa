//
//  QGViewController.m
//  QGTableView
//
//  Created by qikai on 16/7/20.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import "QGViewController.h"
#import "QGTableViewCell.h"
@implementation QGViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self creatTableView];
    [self openRun];
    self.titles = @[
                    @{@"title":@"section1",@"array":
                          @[@{@"title":@"row1asd",@"array":@[@"subRow1-----",@"subRow2------"]},
                            @{@"title":@"row23asd",@"array":@[@"subRow*******"]},
                            
                            @{@"title":@"row234523asd",@"array":@[@"subRowwwww1",@"subRowwwww2",@"subRowwwww3",@"subRowwwww4"]}]},
                    @{@"title":@"section2",@"array":
                          @[@{@"title":@"rrrrrow2ssdf",@"array":@[]},
                            @{@"title":@"r======-___",@"array":@[@"11111kkkkkk",@"222222kkkkkk"]},
                            @{@"title":@"rrrsadasdfsdf",@"array":@[@"123",@"234",@"345",@"456"]},
                            @{@"title":@"qqqqqqw2ssdf",@"array":@[@"OhHAyO"]}]}];
    
    for (int i = 0; i < 0 ; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 100+i;
        btn.frame = CGRectMake(100 + 100*i, 400, 50, 30);
        if (i == 0) {
            [btn setTitle:@"star" forState:UIControlStateNormal];
        }else{
            [btn setTitle:@"stop" forState:UIControlStateNormal];
        }
        btn.backgroundColor = [UIColor redColor];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

-(void)btnClick:(UIButton *)btn{
    if (btn.tag == 100) {
        //开始胡乱点击
        
    }else{
        //停止点击
    }
}

-(void)openRun{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshTableView) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] run];
    });
}
-(void)refreshTableView{
    [self.qgTableView performSelector:@selector(reloadData) withObject:nil afterDelay:0 inModes:@[NSRunLoopCommonModes]];
}
-(void)creatTableView{
    self.qgTableView = [[QGTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.qgTableView.qgDelegate = self;
    self.qgTableView.isCanLongPress = YES;
    [self.view addSubview:self.qgTableView];
}

-(void)longPressActionWithGes:(UILongPressGestureRecognizer *)longPress WithIndexPath:(NSIndexPath *)touchIndexPath{
    NSLog(@"============%ld ======%ld======%ld",touchIndexPath.section,touchIndexPath.row,touchIndexPath.subRow);
}

-(NSInteger)tableView:(QGTableView *)tableView numberOfSubRowsInSection:(NSIndexPath *)indexPath{
    return  [_titles[indexPath.section][@"array"][indexPath.row][@"array"] count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_titles[section][@"array"] count];
}
-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView{
    return  _titles.count;
}
-(UITableViewCell *)tableView:(QGTableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *subCellId = @"subCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:subCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:subCellId];
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"====%@====",self.titles[indexPath.section][@"array"][indexPath.row][@"array"][indexPath.subRow]];
    return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellId";
    QGTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[QGTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.isCanOpen = YES;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"****%@",self.titles[indexPath.section][@"array"][indexPath.row][@"title"]];
    return cell;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [NSString stringWithFormat:@"section = %@",self.titles[section][@"title"]];
}

-(CGFloat )tableView:(UITableView *)tableView heightForSubRowAtIndexPath:(NSIndexPath *)indexPath{
    return 20;
}

@end
