//
//  BankListController.m
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 10/23/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BankListController.h"
#import "BranchListByBankTableViewController.h"
#import "UIActivityIndicatorView+Additions.h"

@interface BankListController()

@property (nonatomic, strong) NSArray *banksList;
@property (nonatomic, strong) NSArray *banksListCopy;
@property (nonatomic, strong) ServiceAPI *serviceAPI;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, copy) NSString *searchText;
@property (nonatomic, strong) NSTimer *delayTimer;
@end

@implementation BankListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.serviceAPI = [[ServiceAPI alloc] init];
    self.banksList = @[];
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    self.tableView.tableHeaderView = self.searchBar;
    self.searchBar.delegate = self;
    
    [self getBanksList];
    
    self.title = @"Banks List";
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [self.activityIndicator showActivityIndicatorForView:self.navigationController.view];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.banksList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [self.banksList objectAtIndex:[indexPath row]];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    
    CGSize labelSize = [cellText boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;

    return labelSize.height + 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *banksListCellId = @"banksList";
    
    UITableViewCell *banksListCell = [tableView dequeueReusableCellWithIdentifier:banksListCellId];
    
    if (!banksListCell) {
        banksListCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:banksListCellId];
        banksListCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        banksListCell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        banksListCell.textLabel.numberOfLines = 0;
        banksListCell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    }
    
    banksListCell.textLabel.text = [self.banksList objectAtIndex:[indexPath row]];
    
    UIImage *image = [UIImage imageNamed:@"Forward.png"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    button.frame = frame;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    button.backgroundColor = [UIColor clearColor];
    banksListCell.accessoryView = button;
    
    return banksListCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BranchListByBankTableViewController *stateListController = [[BranchListByBankTableViewController alloc] initWithBankName:[self.banksList objectAtIndex:[indexPath row]]];
    [self.navigationController pushViewController:stateListController animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = ((indexPath.row % 2) == 0) ? [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] : [UIColor whiteColor];
}

- (void)getResponseData:(NSData *)responseData sender:(ServiceAPI *)sender {
    NSError *jsonParseError = nil;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonParseError];
    
    NSArray *responseValues = [response allValues];
    self.banksList = responseValues[1];
    self.banksListCopy = [self.banksList copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator hideActivityIndicatorForView:self.navigationController.view];
        [self.tableView reloadData];
    });
}

// Makes a HTTP GET request to retrieve a list of banks.
- (void)getBanksList {
    NSString *serviceString = @"https://api.techm.co.in/api/listbanks";
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
    else if (([searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) && ([self.tableView numberOfRowsInSection:0] != [self.banksListCopy count])){
        self.banksList = self.banksListCopy;
        [self.tableView reloadData];
    }
}

- (void)searchResultsUpdate {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", self.searchText];
    NSArray *filteredArray = [self.banksList filteredArrayUsingPredicate:predicate];
    if ([filteredArray count] > 0) {
        self.banksList = filteredArray;
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if ([self.tableView numberOfRowsInSection:0] != [self.banksListCopy count]) {
        self.banksList = self.banksListCopy;
        [self.tableView reloadData];
    }
}

@end
