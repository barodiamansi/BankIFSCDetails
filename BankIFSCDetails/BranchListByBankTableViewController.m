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

@interface BranchListByBankTableViewController ()
@property(nonatomic, strong) NSMutableArray *branchList;
@property(nonatomic, strong) ServiceAPI *serviceAPI;
@property(nonatomic, copy) NSString *bankName;
@property (nonatomic, strong) NSMutableArray *expandedCells;
@property (nonatomic, strong) BranchDetails *branchDetails;
@property (nonatomic) BOOL getBranchDetails;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
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
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self showActivityIndicator];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.serviceAPI = [[ServiceAPI alloc] init];
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
    
    return stateListCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.expandedCells containsObject:indexPath]) {
        [self.expandedCells removeObject:indexPath];
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
    else {
        [self showActivityIndicator];
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
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        
        [self hideActivityIndicator];
    }
    else {
        self.branchList = [response allValues][1];
        [self hideActivityIndicator];
        [self.tableView reloadData];
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

- (void)showActivityIndicator {
    self.activityIndicator.center = self.overlayView.center;
    [self.activityIndicator startAnimating];
    [self.overlayView addSubview:self.activityIndicator];
    [self.navigationController.view addSubview:self.overlayView];
    [self.navigationController.view bringSubviewToFront:self.overlayView];
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.hidden = NO;
}

- (void)hideActivityIndicator {
    [self.activityIndicator stopAnimating];
    [self.overlayView removeFromSuperview];
}
@end
