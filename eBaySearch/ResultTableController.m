//
//  ResultTableController.m
//  eBaySearch
//
//  Created by Zheng Li on 4/9/15.
//  Copyright (c) 2015 Zheng Li. All rights reserved.
//

#import "ResultTableController.h"
#import "DetailViewController.h"

@interface ResultTableController ()

@end

@implementation ResultTableController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Results for \"%@\"", _keyword];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *item = (NSDictionary *)[[_items objectAtIndex: indexPath.row] objectForKey:@"basicInfo"];
    
    // Configure the cell...
    [(UILabel *)[cell viewWithTag:12] setText: [item objectForKey: @"title"]];
    NSString * price;
    if ([(NSString *)[item objectForKey:@"shippingServiceCost"] floatValue] > 0){
        price = [NSString stringWithFormat:@"Price: $%@ ($%@ for shipping)", [item objectForKey:@"convertedCurrentPrice"], [item objectForKey:@"shippingServiceCost"]];
    }else{
        price = [NSString stringWithFormat:@"Price: $%@ (Free shipping)", [item objectForKey:@"convertedCurrentPrice"]];
    }
    [(UILabel *)[cell viewWithTag:13] setText: price];
    
    ((UIImageView *)[cell viewWithTag:11]).image = nil; // or cell.poster.image = [UIImage imageNamed:@"placeholder.png"];
    
    dispatch_async(kBgQueue, ^{
        NSData *imgData = [NSData dataWithContentsOfURL: [NSURL URLWithString:[item objectForKey:@"galleryURL"]]];
        if (imgData) {
            UIImage *image = [UIImage imageWithData:imgData];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UITableViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                    if (updateCell)
                        ((UIImageView *)[updateCell viewWithTag:11]).image = image;
                });
            }
        }
    });
    //NSURL *url = [NSURL URLWithString:[item objectForKey:@"galleryURL"]];
    //NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    //[(UIImageView *)[cell viewWithTag:11] setImage:[UIImage imageWithData:data]];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"ItemSegue"])
    {
        //if you need to pass data to the next controller do it here
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DetailViewController *destViewController = segue.destinationViewController;
        
        NSDictionary *item = (NSDictionary *)[[_items objectAtIndex: indexPath.row] objectForKey:@"basicInfo"];
        NSString * price;
        if ([(NSString *)[item objectForKey:@"shippingServiceCost"] floatValue] > 0){
            price = [NSString stringWithFormat:@"Price: $%@ ($%@ for shipping)", [item objectForKey:@"convertedCurrentPrice"], [item objectForKey:@"shippingServiceCost"]];
        }else{
            price = [NSString stringWithFormat:@"Price: $%@ (Free shipping)", [item objectForKey:@"convertedCurrentPrice"]];
        }
        destViewController.utitle = [item objectForKey:@"title"];
        destViewController.uprice = price;
        destViewController.ulocation = [item objectForKey:@"location"];
        destViewController.uimageurl = [item objectForKey: @"pictureURLSuperSize"];
        destViewController.utoprated = [item objectForKey: @"topRatedListing"];
        destViewController.itemURL = [item objectForKey: @"viewItemURL"];
        destViewController.itemIconURL = [item objectForKey: @"galleryURL"];
        
        destViewController.basicInfo = [[NSMutableArray alloc] init];
        [destViewController.basicInfo addObject:[item objectForKey:@"categoryName"]];
        [destViewController.basicInfo addObject:[item objectForKey:@"conditionDisplayName"]];
        [destViewController.basicInfo addObject:[item objectForKey:@"listingType"]];
        
        item = (NSDictionary *)[[_items objectAtIndex:indexPath.row] objectForKey:@"sellerInfo"];
        destViewController.sellerInfo = [[NSMutableArray alloc] init];
        [destViewController.sellerInfo addObject:[item objectForKey:@"sellerUserName"]];
        [destViewController.sellerInfo addObject:[item objectForKey:@"feedbackScore"]];
        [destViewController.sellerInfo addObject:[item objectForKey:@"positiveFeedbackPercent"]];
        [destViewController.sellerInfo addObject:[item objectForKey:@"feedbackRatingStar"]];
        [destViewController.sellerInfo addObject:[item objectForKey:@"topRatedSeller"]];
        [destViewController.sellerInfo addObject:[item objectForKey:@"sellerStoreName"]];
        
        item = (NSDictionary *)[[_items objectAtIndex:indexPath.row] objectForKey:@"shippingInfo"];
        destViewController.shippingInfo = [[NSMutableArray alloc] init];
        [destViewController.shippingInfo addObject:[item objectForKey:@"shippingType"]];
        [destViewController.shippingInfo addObject:[NSString stringWithFormat:@"%@ day(s)", [item objectForKey:@"handlingTime"]]];
        [destViewController.shippingInfo addObject:[[item objectForKey:@"shipToLocations"] componentsJoinedByString:@","]];
        [destViewController.shippingInfo addObject:[item objectForKey:@"expeditedShipping"]];
        [destViewController.shippingInfo addObject:[item objectForKey:@"oneDayShippingAvailable"]];
        [destViewController.shippingInfo addObject:[item objectForKey:@"returnsAccepted"]];
    }
}


@end
