//
//  ViewController.m
//  eBaySearch
//
//  Created by Zheng Li on 4/9/15.
//  Copyright (c) 2015 Zheng Li. All rights reserved.
//

#import "ViewController.h"
#import "ResultTableController.h"

@interface ViewController (){
    NSArray *sortByData;
    NSArray *sortByValue;
    UIPickerView * sortPicker;
    UIToolbar *sortPickerToolbar;
    BOOL httpLock;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Initialize Data
    sortByData = @[@"Best Match", @"Price: highest first", @"Price + Shipping: highest first", @"Price + Shipping: lowest first"];
    sortByValue = @[@"BestMatch", @"CurrentPriceHighest", @"PricePlusShippingHighest", @"PricePlusShippingLowest"];
    // Connect data
    sortPicker.dataSource = self;
    sortPicker.delegate = self;
    
    sortPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, 100, 150)];
    [sortPicker setDataSource: self];
    [sortPicker setDelegate: self];
    sortPicker.showsSelectionIndicator = YES;
    _Sort.inputView = sortPicker;
    sortPickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    sortPickerToolbar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDoneClicked)];
    sortPickerToolbar.items = [NSArray arrayWithObjects:space,done, nil];
    _Sort.inputAccessoryView = sortPickerToolbar;
    _Sort.text = sortByData[0];
    
    httpLock = FALSE;
}

-(void)pickerDoneClicked
{
    // NSLog(@"Done Clicked");
    [_Sort resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return sortByData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return sortByData[row];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _Sort.text = [sortByData objectAtIndex:row];
    
}

// Search button
- (IBAction)eBaySearch:(id)sender {
    if (httpLock) return;
    // NSLog(@"Search triggered!");
    [_Errors setText:@""];
    if (!_Keyword.text.length) {
        [_Errors setText:@"Please enter a keyword!"];
        return;
    }
    
    if ((_PriceFrom.text.length && [_PriceFrom.text floatValue] == 0.0 && ![_PriceFrom.text isEqualToString:@"0"]) ||
    (_PriceTo.text.length && [_PriceTo.text floatValue] == 0.0 && ![_PriceTo.text isEqualToString:@"0"])){
        [_Errors setText:@"Please enter a valid number!"];
        return;
    }
    
    if ((_PriceFrom.text.length && [_PriceFrom.text floatValue] < 0) ||
        (_PriceTo.text.length && [_PriceTo.text floatValue] < 0) ) {
        [_Errors setText:@"Minimum price should not below 0!"];
        return;
    }
    
    if (_PriceFrom.text.length && _PriceTo.text.length && [_PriceTo.text floatValue] < [_PriceFrom.text floatValue]){
        [_Errors setText:@"Maximum price should not be less than minimum price or below 0!"];
        return;
    }
    
    NSString * priceFromFilter = @"", * priceToFilter = @"";

    if (_PriceFrom.text.length){
        priceFromFilter = [NSString stringWithFormat:@"&minPrice=%@", _PriceFrom.text];
    }
    
    if (_PriceTo.text.length){
        priceToFilter = [NSString stringWithFormat:@"&maxPrice=%@",_PriceTo.text];
    }
    
    NSInteger row;
    row = [sortPicker selectedRowInComponent:0];
    NSString * sortFilter = [NSString stringWithFormat:@"&sortOrder=%@", sortByValue[row]];
    
    NSString *url = [NSString stringWithFormat:@"http://zli021.elasticbeanstalk.com/hw8.php?keywords=%@&results-per-page=5%@%@%@", [_Keyword.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], sortFilter, priceFromFilter, priceToFilter];
    NSLog(url);
    // Create the request.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    // Create url connection and fire request
    httpLock = TRUE;
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

// Clear button
- (IBAction)clearForm:(id)sender {
    [_Keyword setText: @""];
    [_PriceFrom setText: @""];
    [_PriceTo setText: @""];
    [_Errors setText: @""];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    
    [_responseData appendData:data];
    
    id retObj;
    NSError *error = nil;
    if (_responseData) {
        retObj = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:_responseData options:0 error:&error];
    }
    
    if (!retObj) return;
    if (![[retObj valueForKey:@"ack"] isEqualToString:@"Success"] ||
        [[retObj valueForKey:@"resultCount"] integerValue] <= 0){
        [_Errors setText:@"No results found!"];
        return;
    }
    
    ResultTableController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemTable"];
    newView.items = [retObj valueForKey:@"item"];
    newView.keyword = _Keyword.text;
    
    [newView.tableView reloadData];
    
    [self.navigationController pushViewController:newView animated:YES];
    
    httpLock = FALSE;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

- (IBAction)KeywordDismiss:(id)sender {
    [_Keyword resignFirstResponder];
}

- (IBAction)PriceFromDismiss:(id)sender {
    [_PriceFrom resignFirstResponder];
}

- (IBAction)PriceToDismiss:(id)sender {
    [_PriceTo resignFirstResponder];
}
@end
