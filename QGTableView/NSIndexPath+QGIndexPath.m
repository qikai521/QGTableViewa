//
//  NSIndexPath+QGIndexPath.m
//  QGTableView
//
//  Created by qikai on 16/7/20.
//  Copyright © 2016年 qikai. All rights reserved.
//

#import "NSIndexPath+QGIndexPath.h"
#import <objc/runtime.h>
static char kIndexPath_isOpen;

@implementation NSIndexPath (QGIndexPath)

-(void)setIsOpen:(BOOL)isOpen{
    objc_setAssociatedObject(self, &kIndexPath_isOpen, @(isOpen), OBJC_ASSOCIATION_ASSIGN);
}
-(BOOL)isOpen{
    return [objc_getAssociatedObject(self, &kIndexPath_isOpen) boolValue];
}

@end
