//
//  ViewController.m
//  QGTableView
//
//  Created by qikai on 16/7/20.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import "ViewController.h"
#import "NormalViewController.h"
#import "QGViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *sbuttons = [UIButton buttonWithType:UIButtonTypeCustom];
    sbuttons.frame = CGRectMake(100, 100, 100, 100);
    sbuttons.backgroundColor = [UIColor orangeColor];
    [sbuttons setTitle:@"openNormalTableView" forState:UIControlStateNormal];
    [sbuttons addTarget:self action:@selector(openNormal) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sbuttons];
    
    UIButton *sbuttons2 = [UIButton buttonWithType:UIButtonTypeCustom];
    sbuttons2.frame = CGRectMake(100, 300, 100, 100);
    sbuttons2.backgroundColor = [UIColor orangeColor];
    [sbuttons2 setTitle:@"haha" forState:UIControlStateNormal];
    [sbuttons2 addTarget:self action:@selector(sbuttons2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sbuttons2];


}
-(void)openNormal{
    [self presentViewController:[[NormalViewController alloc] init] animated:YES completion:nil];
}
-(void)sbuttons2{
    [self presentViewController:[[QGViewController alloc] init] animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
