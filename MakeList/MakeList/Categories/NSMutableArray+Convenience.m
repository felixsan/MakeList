//
//  NSMutableArray+Convenience.m
//  MakeList
//
//  Created by Felix Santiago on 10/13/13.
//  Copyright (c) 2013 Felix Santiago. All rights reserved.
//

#import "NSMutableArray+Convenience.h"

@implementation NSMutableArray (Convenience)

- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    id object = [self objectAtIndex:fromIndex];
    [self removeObjectAtIndex:fromIndex];
    [self insertObject:object atIndex:toIndex];
}


@end
