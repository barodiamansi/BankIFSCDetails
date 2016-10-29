//
//  BankBranchListControllerTableViewController.m
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 10/28/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import "BankBranchListControllerTableViewController.h"

@interface BankBranchListControllerTableViewController ()
@property (nonatomic, copy) NSString *bankName;
@property (nonatomic, strong) NSArray *branchList;
@property (nonatomic, strong) NSArray *districtBanksList;
@property (nonatomic, strong) ServiceAPI *serviceAPI;
@end

@implementation BankBranchListControllerTableViewController

- (id) initWithBank:(NSString *)bankName andBanksList:(NSArray *)banksList {
    self = [super init];
    
    if (self) {
        self.bankName = bankName;
        self.districtBanksList = banksList;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.serviceAPI = [[ServiceAPI alloc] init];
    self.branchList = @[];
   // [self getDistrictList];
    
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.bank contains %@", self.bankName];
    self.districtBanksList = [self.districtBanksList filteredArrayUsingPredicate:bPredicate];
    NSLog(@"HERE %@",self.districtBanksList);
    
    self.title = @"Branch List";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.branchList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [self.branchList objectAtIndex:[indexPath row]];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    
    CGSize labelSize = [cellText boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
    
    return labelSize.height + 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *districtListCellId = @"banksList";
    
    UITableViewCell *districtListCell = [tableView dequeueReusableCellWithIdentifier:districtListCellId];
    
    if (!districtListCell) {
        districtListCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:districtListCellId];
        districtListCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        districtListCell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        districtListCell.textLabel.numberOfLines = 0;
        districtListCell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    }
    
    districtListCell.textLabel.text = [self.branchList objectAtIndex:[indexPath row]];
    
    return districtListCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)getResponseData:(NSData *)responseData sender:(ServiceAPI *)sender {
    NSError *jsonParseError = nil;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonParseError];
    
    NSArray *responseValues = [response allValues];
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:[responseValues[1] valueForKey:@"BRANCH"]];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    self.branchList = [[orderedSet array] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    [self.tableView reloadData];
}


- (void)getDistrictList {
    NSString *serviceString = [@"https://api.techm.co.in/api/listbranches/" stringByAppendingString:self.bankName];
    serviceString = [serviceString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *serviceURL = [NSURL URLWithString:serviceString];
    NSMutableURLRequest *serviceRequest = [NSMutableURLRequest requestWithURL:serviceURL];
    [serviceRequest setHTTPMethod:@"GET"];
    self.serviceAPI.delegate = self;
    [self.serviceAPI httpServiceRequest:serviceRequest];
}

@end
