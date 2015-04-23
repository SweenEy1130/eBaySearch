//
//  ViewController.h
//  eBaySearch
//
//  Created by Zheng Li on 4/9/15.
//  Copyright (c) 2015 Zheng Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface ViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate,NSURLConnectionDelegate>{
    NSMutableData *_responseData;
}
- (IBAction)KeywordDismiss:(id)sender;
- (IBAction)PriceFromDismiss:(id)sender;
- (IBAction)PriceToDismiss:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *ContentView;
@property (weak, nonatomic) IBOutlet UITextField *Keyword;
@property (weak, nonatomic) IBOutlet UITextField *PriceFrom;
@property (weak, nonatomic) IBOutlet UITextField *PriceTo;
@property (strong, nonatomic) IBOutlet UITextField *Sort;
@property (weak, nonatomic) IBOutlet UIButton *Search;
@property (weak, nonatomic) IBOutlet UILabel *Errors;
@property (weak, nonatomic) IBOutlet UIButton *Clear;

@end

