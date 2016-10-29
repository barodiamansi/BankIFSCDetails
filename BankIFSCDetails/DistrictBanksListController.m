//
//  DistrictBanksListController.m
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 10/28/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DistrictBanksListController.h"
#import "BankBranchListControllerTableViewController.h"

@interface DistrictBanksListController()

@property (nonatomic, copy) NSString *districtName;
@property (nonatomic, strong) NSArray *bankNamesList;
@property (nonatomic, strong) NSArray *districtBanksList;
@property (nonatomic, strong) ServiceAPI *serviceAPI;

@end

@implementation DistrictBanksListController
- (id)initWithDistrict:(NSString *)districtName {
    self = [super init];
    
    if (self) {
        self.districtName = districtName;
        self.districtBanksList = @[];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.serviceAPI = [[ServiceAPI alloc] init];
    self.bankNamesList = @[];
    [self getDistrictList];
    
    self.title = @"Banks List";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.bankNamesList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [self.bankNamesList objectAtIndex:[indexPath row]];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    
    CGSize labelSize = [cellText boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
    
    return labelSize.height + 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *districtListCellId = @"bankNamesList";
    
    UITableViewCell *districtListCell = [tableView dequeueReusableCellWithIdentifier:districtListCellId];
    
    if (!districtListCell) {
        districtListCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:districtListCellId];
        districtListCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        districtListCell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        districtListCell.textLabel.numberOfLines = 0;
        districtListCell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    }
    
    districtListCell.textLabel.text = [self.bankNamesList objectAtIndex:[indexPath row]];
    
    return districtListCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BankBranchListControllerTableViewController *branchListController = [[BankBranchListControllerTableViewController alloc] initWithBank:[self.bankNamesList objectAtIndex:[indexPath row]] andBanksList:self.districtBanksList];
    [self.navigationController pushViewController:branchListController animated:YES];
}

- (void)getResponseData:(NSData *)responseData sender:(ServiceAPI *)sender {
    NSError *jsonParseError = nil;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonParseError];
    
    NSArray *responseValues = [response allValues];
    self.districtBanksList = responseValues[1];
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:[self.districtBanksList valueForKey:@"BANK"]];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    self.bankNamesList = [[orderedSet array] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    [self.tableView reloadData];
}


- (void)getDistrictList {
    NSString *serviceString = [@"https://api.techm.co.in/api/district/" stringByAppendingString:self.districtName];
    serviceString = [serviceString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *serviceURL = [NSURL URLWithString:serviceString];
    NSMutableURLRequest *serviceRequest = [NSMutableURLRequest requestWithURL:serviceURL];
    [serviceRequest setHTTPMethod:@"GET"];
    self.serviceAPI.delegate = self;
    [self.serviceAPI httpServiceRequest:serviceRequest];
}
@end
