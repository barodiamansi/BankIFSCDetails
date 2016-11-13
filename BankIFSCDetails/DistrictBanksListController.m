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
#import "UIActivityIndicatorView+Additions.h"

@interface DistrictBanksListController()

@property (nonatomic, copy) NSString *districtName;
@property (nonatomic, strong) NSArray *bankNamesList;
@property (nonatomic, strong) NSArray *bankNamesListCopy;
@property (nonatomic, strong) NSArray *districtBanksList;
@property (nonatomic, strong) ServiceAPI *serviceAPI;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, copy) NSString *searchText;
@property (nonatomic, strong) NSTimer *delayTimer;
@end

@implementation DistrictBanksListController
- (id)initWithDistrict:(NSString *)districtName {
    self = [super init];
    
    if (self) {
        self.districtName = districtName;
        self.districtBanksList = @[];
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.serviceAPI = [[ServiceAPI alloc] init];
    self.bankNamesList = @[];
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    self.tableView.tableHeaderView = self.searchBar;
    self.searchBar.delegate = self;
    
    [self getDistrictBanksList];
    
    self.title = @"Banks List";
    [self.activityIndicator showActivityIndicatorForView:self.navigationController.view];
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
    NSString *banksListCellId = @"bankNamesList";
    
    UITableViewCell *banksListCell = [tableView dequeueReusableCellWithIdentifier:banksListCellId];
    
    if (!banksListCell) {
        banksListCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:banksListCellId];
        banksListCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        banksListCell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        banksListCell.textLabel.numberOfLines = 0;
        banksListCell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    }
    
    banksListCell.textLabel.text = [self.bankNamesList objectAtIndex:[indexPath row]];
    
    return banksListCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BankBranchListControllerTableViewController *branchDetails = [[BankBranchListControllerTableViewController alloc] initWithBank:[self.bankNamesList objectAtIndex:[indexPath row]] andBanksList:self.districtBanksList];
    [self.navigationController pushViewController:branchDetails animated:YES];
}

- (void)getResponseData:(NSData *)responseData sender:(ServiceAPI *)sender {
    NSError *jsonParseError = nil;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonParseError];
    
    NSArray *responseValues = [response allValues];
    self.districtBanksList = responseValues[1];
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:[self.districtBanksList valueForKey:@"BANK"]];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    self.bankNamesList = [[orderedSet array] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    self.bankNamesListCopy = [self.bankNamesList copy];
    [self.activityIndicator hideActivityIndicatorForView:self.navigationController.view];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

// Makes a HTTP GET request to retrieve a list of banks within a given district.
- (void)getDistrictBanksList {
    NSString *serviceString = [@"https://api.techm.co.in/api/district/" stringByAppendingString:self.districtName];
    serviceString = [serviceString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *serviceURL = [NSURL URLWithString:serviceString];
    NSMutableURLRequest *serviceRequest = [NSMutableURLRequest requestWithURL:serviceURL];
    [serviceRequest setHTTPMethod:@"GET"];
    self.serviceAPI.delegate = self;
    [self.serviceAPI httpServiceRequest:serviceRequest];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchText = searchBar.text;
    
    if ([self.searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length >= 3) {
        [searchBar resignFirstResponder];
        [self searchResultsUpdate];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.delayTimer invalidate];
    
    if ([searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length >= 3) {
        self.searchText = searchText;
        self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(searchResultsUpdate) userInfo:searchText repeats:NO];
    }
    else if (([searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) && ([self.tableView numberOfRowsInSection:0] != [self.bankNamesListCopy count])){
        self.bankNamesList = self.bankNamesListCopy;
        [self.tableView reloadData];
    }
}

- (void)searchResultsUpdate {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", self.searchText];
    NSArray *filteredArray = [self.bankNamesList filteredArrayUsingPredicate:predicate];
    if ([filteredArray count] > 0) {
        self.bankNamesList = filteredArray;
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if ([self.tableView numberOfRowsInSection:0] != [self.bankNamesListCopy count]) {
        self.bankNamesList = self.bankNamesListCopy;
        [self.tableView reloadData];
    }
}

@end
