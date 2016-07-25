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
}
-(void)creatTableView{
    self.qgTableView = [[QGTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.qgTableView.qgDelegate = self;
    [self.view addSubview:self.qgTableView];
}


-(NSInteger)tableView:(QGTableView *)tableView numberOfSubRowsInSection:(NSIndexPath *)indexPath{
    if ((indexPath.section + indexPath.row)%2 == 0) {
        return 3;
    }
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0 ) {
        return 3;
    }
    return 5;
}
-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(UITableViewCell *)tableView:(QGTableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *subCellId = @"subCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:subCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:subCellId];
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"     Im SubRow IndexPath = %ld ==== %ld ====%ld",indexPath.section,indexPath.row,indexPath.subRow];
    return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellId";
    QGTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[QGTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.isCanOpen = YES;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"Section = %ld ======Row = %ld",indexPath.section,indexPath.row];
    return cell;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [NSString stringWithFormat:@"section = %ld",section];
}

@end
