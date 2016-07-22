//
//  QGTableViewCell.m
//  QGTableView
//
//  Created by qikai on 16/7/21.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import "QGTableViewCell.h"

@implementation QGTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initProperty];
    }
    return self;
}
-(void)initProperty{
    self.backgroundColor = [UIColor whiteColor];
}


@end
