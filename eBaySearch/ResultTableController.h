//
//  ResultTableController.h
//  eBaySearch
//
//  Created by Zheng Li on 4/9/15.
//  Copyright (c) 2015 Zheng Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultTableController : UITableViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray * items;
@property (strong, nonatomic) NSString * keyword;
@end
