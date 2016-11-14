//
//  BranchListByBankTableViewController.m
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 11/9/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import "BranchListByBankTableViewController.h"
#import "BranchDetails.h"
#import "BranchDetailsTableViewCell.h"
#import "UIActivityIndicatorView+Additions.h"

@interface BranchListByBankTableViewController ()
@property(nonatomic, strong) NSMutableArray *branchList;
@property(nonatomic, strong) NSMutableArray *branchListCopy;
@property(nonatomic, strong) ServiceAPI *serviceAPI;
@property(nonatomic, copy) NSString *bankName;
@property (nonatomic, strong) NSMutableArray *expandedCells;
@property (nonatomic, strong) BranchDetails *branchDetails;
@property (nonatomic) BOOL getBranchDetails;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, copy) NSString *searchText;
@property (nonatomic, strong) NSTimer *delayTimer;
@end

@implementation BranchListByBankTableViewController

- (id) initWithBankName:(NSString *)bankName {
    self = [super init];
    
    if (self) {
        self.branchList = [[NSMutableArray alloc] init];
        self.expandedCells = [[NSMutableArray alloc] init];
        self.branchDetails = [[BranchDetails alloc] init];
        self.bankName = bankName;
        self.getBranchDetails = NO;
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.activityIndicator showActivityIndicatorForView:self.navigationController.view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.serviceAPI = [[ServiceAPI alloc] init];
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    self.tableView.tableHeaderView = self.searchBar;
    self.searchBar.delegate = self;
    [self getBranchList];
    self.title = @"Branch List";
}


#pragma mark - Table view data source

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
    
    CGFloat cellHeight = labelSize.height + 20;
    return [self.expandedCells containsObject:indexPath] ? cellHeight * 5 : cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *stateListCellId = @"stateList";
    
    BranchDetailsTableViewCell *stateListCell = [tableView dequeueReusableCellWithIdentifier:stateListCellId];
    
    if (!stateListCell) {
        [tableView registerNib:[UINib nibWithNibName:@"BranchDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:stateListCellId];
        stateListCell = [tableView dequeueReusableCellWithIdentifier:stateListCellId];
    }
    
    //[stateListCell layoutIfNeeded];
    return stateListCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.expandedCells containsObject:indexPath]) {
        [self.expandedCells removeObject:indexPath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
    else {
        [self.activityIndicator showActivityIndicatorForView:self.navigationController.view];
        self.selectedIndexPath = indexPath;
        [self.expandedCells addObject:indexPath];
        [self getBranchDetailsForBranch:[self.branchList objectAtIndex:[indexPath row]]];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(BranchDetailsTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self setUpBranchName:cell onRow:[indexPath row]];
    [self setUpBranchDetails:cell onRow:[indexPath row]];
}

- (void)getResponseData:(NSData *)responseData sender:(ServiceAPI *)sender {
    NSError *jsonParseError = nil;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonParseError];
    
    if (self.getBranchDetails && [response allValues][1]) {
        NSDictionary *branchDetails = [response allValues][1];
        self.branchDetails.branchName = [branchDetails valueForKey:@"BRANCH"];
        self.branchDetails.addressDetails = [branchDetails valueForKey:@"ADDRESS"];
        self.branchDetails.contactDetails = [branchDetails valueForKey:@"CONTACT"];
        self.branchDetails.IFSCCode = [branchDetails valueForKey:@"IFSC"];
        self.branchDetails.MICRCode = [branchDetails valueForKey:@"MICR CODE"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
        [self.activityIndicator hideActivityIndicatorForView:self.navigationController.view];
    }
    else {
        self.branchList = [response allValues][1];
        self.branchListCopy = [self.branchList mutableCopy];
        [self.activityIndicator hideActivityIndicatorForView:self.navigationController.view];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

- (void)getBranchDetailsForBranch:(NSString *)selectedBranch {
    self.getBranchDetails = YES;
    NSString *serviceString = [NSString stringWithFormat:@"%@/%@/%@", @"https://api.techm.co.in/api/getbank", self.bankName, selectedBranch];
    serviceString = [serviceString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *serviceURL = [NSURL URLWithString:serviceString];
    NSMutableURLRequest *serviceRequest = [NSMutableURLRequest requestWithURL:serviceURL];
    [serviceRequest setHTTPMethod:@"GET"];
    self.serviceAPI.delegate = self;
    [self.serviceAPI httpServiceRequest:serviceRequest];
}

- (void)getBranchList {
    NSString *serviceString = [@"https://api.techm.co.in/api/listbranches/" stringByAppendingString:self.bankName];
    serviceString = [serviceString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *serviceURL = [NSURL URLWithString:serviceString];
    NSMutableURLRequest *serviceRequest = [NSMutableURLRequest requestWithURL:serviceURL];
    [serviceRequest setHTTPMethod:@"GET"];
    self.serviceAPI.delegate = self;
    [self.serviceAPI httpServiceRequest:serviceRequest];
}

- (void)setUpBranchName:(BranchDetailsTableViewCell *)cell onRow:(NSInteger) row {
    cell.branchName.lineBreakMode = NSLineBreakByWordWrapping;
    cell.branchName.numberOfLines = 0;
    cell.branchName.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    cell.branchName.text = [self.branchList objectAtIndex:row];
}

- (void)setUpBranchDetails:(BranchDetailsTableViewCell *)cell onRow:(NSInteger) row {
    cell.addressDetails.lineBreakMode = NSLineBreakByWordWrapping;
    cell.addressDetails.numberOfLines = 0;
    cell.addressDetails.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    cell.addressDetails.text = self.branchDetails.addressDetails;
    
    cell.contactDetails.text = self.branchDetails.contactDetails;
    cell.IFSCCode.text = self.branchDetails.IFSCCode;
    cell.MICRCode.text = self.branchDetails.MICRCode;
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
    else if (([searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) && ([self.tableView numberOfRowsInSection:0] != [self.branchListCopy count])){
        self.branchList = self.branchListCopy;
        [self.expandedCells removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)searchResultsUpdate {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", self.searchText];
    NSMutableArray *filteredArray = [[self.branchList filteredArrayUsingPredicate:predicate] mutableCopy];
    if ([filteredArray count] > 0) {
        self.branchList = filteredArray;
        [self.expandedCells removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if ([self.tableView numberOfRowsInSection:0] != [self.branchListCopy count]) {
        self.branchList = self.branchListCopy;
        [self.expandedCells removeAllObjects];
        [self.tableView reloadData];
    }
}
@end
