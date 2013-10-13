//
//  MakeListTableViewController.h
//  MakeList
//
//  Created by Felix Santiago on 10/13/13.
//  Copyright (c) 2013 Felix Santiago. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MakeListTableViewController : UITableViewController  <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSDictionary *listItems;
@property (nonatomic, strong) NSArray *listItemKeys;

@end
