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

}
-(void)creatTableView{
    self.qgTableView = [[QGTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.qgTableView.qgDelegate = self;
    [self.view addSubview:self.qgTableView];
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
    NSLog(@"subRow = %ld === %ld === %ld",indexPath.section ,indexPath.row,indexPath.subRow);
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
    return 80;
}

@end
