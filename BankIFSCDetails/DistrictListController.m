//
//  DistrictListController.m
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 10/23/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DistrictListController.h"
#import "DistrictBanksListController.h"
#import "UIActivityIndicatorView+Additions.h"

@interface DistrictListController()

// Used in the request for district names list.
@property (nonatomic, copy) NSString *stateName;
// Stores the list of district names received from the response.
@property (nonatomic, strong) NSArray *districtList;
// Used to make service calls.
@property (nonatomic, strong) ServiceAPI *serviceAPI;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation DistrictListController

- (id) initWithState:(NSString *)stateName {
    self = [super init];
    
    if (self) {
        self.stateName = stateName;
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.serviceAPI = [[ServiceAPI alloc] init];
    self.districtList = @[];
    
    // Retrieve a list of district names based on the state name.
    [self getDistrictList];

    self.title = @"District List";
    [self.activityIndicator showActivityIndicatorForView:self.navigationController.view];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.districtList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [self.districtList objectAtIndex:[indexPath row]];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    
    CGSize labelSize = [cellText boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
    
    return labelSize.height + 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *districtListCellId = @"districtList";
    
    UITableViewCell *districtListCell = [tableView dequeueReusableCellWithIdentifier:districtListCellId];
    
    if (!districtListCell) {
        districtListCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:districtListCellId];
        districtListCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        districtListCell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        districtListCell.textLabel.numberOfLines = 0;
        districtListCell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    }
    
    districtListCell.textLabel.text = [self.districtList objectAtIndex:[indexPath row]];
    
    return districtListCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DistrictBanksListController *districtBankListController = [[DistrictBanksListController alloc] initWithDistrict:[self.districtList objectAtIndex:[indexPath row]]];
    [self.navigationController pushViewController:districtBankListController animated:YES];
}

- (void)getResponseData:(NSData *)responseData sender:(ServiceAPI *)sender {
    NSError *jsonParseError = nil;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonParseError];
    
    NSArray *responseValues = [response allValues];
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:[responseValues[1] valueForKey:@"DISTRICT"]];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    self.districtList = [[orderedSet array] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
 
    [self.activityIndicator hideActivityIndicatorForView:self.navigationController.view];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

// Makes a HTTP GET request to retrieve a list of district names based on the state.
- (void)getDistrictList {
    NSString *serviceString = [@"https://api.techm.co.in/api/state/" stringByAppendingString:self.stateName];
    serviceString = [serviceString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *serviceURL = [NSURL URLWithString:serviceString];
    NSMutableURLRequest *serviceRequest = [NSMutableURLRequest requestWithURL:serviceURL];
    [serviceRequest setHTTPMethod:@"GET"];
    self.serviceAPI.delegate = self;
    [self.serviceAPI httpServiceRequest:serviceRequest];
}

@end
