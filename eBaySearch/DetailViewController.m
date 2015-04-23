//
//  DetailViewController.m
//  eBaySearch
//
//  Created by Zheng Li on 4/10/15.
//  Copyright (c) 2015 Zheng Li. All rights reserved.
//

#import "DetailViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface DetailViewController ()<FBSDKSharingDelegate>{
    NSArray * details;
    NSArray * infos;
    NSArray *basic;
    NSArray *seller;
    NSArray *shipping;
}

@end

@implementation DetailViewController
@synthesize ItemTitle;
@synthesize utitle;
@synthesize ItemLocation;
@synthesize ulocation;
@synthesize ItemPrice;
@synthesize uprice;
@synthesize uimageurl;
@synthesize utoprated;

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.ItemTitle setText:utitle];
    [self.ItemPrice setText:uprice];
    [self.ItemLocation setText:ulocation];
    [_ItemImage setImage:nil];
    dispatch_async(kBgQueue, ^{
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:uimageurl]];
        if (imgData) {
            UIImage *image = [UIImage imageWithData:imgData];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _ItemImage.image = image;
                });
            }
        }
    });
    
    if ([utoprated isEqualToString:@"true"]){
        _ItemTopRated.image = [UIImage imageNamed:@"itemTopRated.jpg"];
    }
    
    basic = @[@"Category", @"Condition", @"Buying format",];
    seller = @[@"User Name", @"Feedback Score", @"Positive Feedback",@"Feedback Rating",@"Top Rated", @"Store"];
    shipping = @[@"Shipping Type", @"Handling Time", @"Shipping location",@"Expedited shipping", @"One Day Shipping", @"Return Accepted"];
    
    details = basic;
    infos = _basicInfo;
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                    target:self
                                    action:@selector(shareAction:)];
    self.navigationItem.rightBarButtonItem = shareButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 
-(void)shareAction:(id)sender
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:self.itemURL];
    content.contentTitle = self.utitle;
    content.imageURL = [NSURL URLWithString:self.itemIconURL];
    content.contentDescription = [NSString stringWithFormat:@"%@, %@", self.uprice, self.ulocation];
    [FBSDKShareDialog showFromViewController:self withContent:content delegate:self];
}

#pragma mark - Collection

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [details count];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    UILabel * label = (UILabel *)[cell viewWithTag:100];
    label.text = [details objectAtIndex:indexPath.row];
    
    UILabel * labelDetail = (UILabel *)[cell viewWithTag:200];
    UIImageView * imageDetail = (UIImageView *)[cell viewWithTag:300];
    if ([[infos objectAtIndex:indexPath.row] isEqualToString:@"false"]) {
        imageDetail.image = [UIImage imageNamed:@"no.png"];
        labelDetail.text = @"";
    }else if ([[infos objectAtIndex:indexPath.row] isEqualToString:@"true"]){
        imageDetail.image = [UIImage imageNamed:@"yes.png"];
        labelDetail.text = @"";
    }else{
        imageDetail.image = nil;
        labelDetail.text = [infos objectAtIndex: indexPath.row];
    }
    
    return cell;
}
#pragma mark - SegmentControl
- (IBAction)ChangeIndex:(id)sender {
    switch (_segmentControl.selectedSegmentIndex)
        {
            case 0:
                details = basic;
                infos = _basicInfo;
                [_collectionView reloadData];
                break;
            case 1:
                details = seller;
                infos = _sellerInfo;
                [_collectionView reloadData];
                break;
            case 2:
                details = shipping;
                infos = _shippingInfo;
                [_collectionView reloadData];
                break;
            default:
                break;
        }
}

#pragma mark - FBSDKSharingDelegate
- (void) sharer:(id<FBSDKSharing>)sharer didCompleteWithResults: (NSDictionary *)results{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                            message:[NSString stringWithFormat:@"Posted Story, ID: %@", [results objectForKey:@"postId"]]
                                            delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
    [alertView show];
    
    int duration = 1; // duration in seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    });
}
- (void) sharerDidCancel:(id<FBSDKSharing>)sharer{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Post Cancelled!" delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
    [alertView show];
    
    int duration = 1; // duration in seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    });
}
- (void) sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
    NSLog(@"sharing error:%@", error);
    NSString *message = error.userInfo[FBSDKErrorLocalizedDescriptionKey] ?:
    @"There was a problem sharing, please try again later.";
    NSString *title = error.userInfo[FBSDKErrorLocalizedTitleKey] ?: @"Oops!";
    
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];}
@end
