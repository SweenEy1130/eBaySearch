//
//  DetailViewController.h
//  eBaySearch
//
//  Created by Zheng Li on 4/10/15.
//  Copyright (c) 2015 Zheng Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UIImageView *ItemImage;
@property (strong, nonatomic) IBOutlet UIScrollView *DetailScrollView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) IBOutlet UILabel *ItemPrice;
@property (strong, nonatomic) IBOutlet UILabel *ItemLocation;
@property (strong, nonatomic) IBOutlet UILabel *ItemTitle;
@property (strong, nonatomic) IBOutlet UIImageView *ItemTopRated;

@property (strong, nonatomic) NSString *utitle;
@property (strong, nonatomic) NSString *uprice;
@property (strong, nonatomic) NSString *ulocation;
@property (strong, nonatomic) NSString *uimageurl;
@property (strong, nonatomic) NSString *utoprated;
@property (strong, nonatomic) NSString *itemURL;
@property (strong, nonatomic) NSString *itemIconURL;

@property (strong, nonatomic) NSMutableArray *basicInfo;
@property (strong, nonatomic) NSMutableArray *sellerInfo;
@property (strong, nonatomic) NSMutableArray *shippingInfo;
@end
