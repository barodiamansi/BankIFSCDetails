//
//  BankBranchListControllerTableViewController.m
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 10/28/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import "BankBranchListControllerTableViewController.h"
#import "BranchDetailsTableViewCell.h"
#import "BranchDetails.h"
#import "UIActivityIndicatorView+Additions.h"

@interface BankBranchListControllerTableViewController ()
@property (nonatomic, copy) NSString *bankName;
@property (nonatomic, strong) NSArray *branchList;
@property (nonatomic, strong) NSArray *branchListCopy;
@property (nonatomic, strong) NSArray *districtBanksList;
@property (nonatomic, strong) NSMutableArray *expandedCells;
@property (nonatomic, strong) NSMutableArray *branchDetails;
@property (nonatomic, strong) NSMutableArray *branchDetailsCopy;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, copy) NSString *searchText;
@property (nonatomic, strong) NSTimer *delayTimer;
@end

@implementation BankBranchListControllerTableViewController

- (id) initWithBank:(NSString *)bankName andBanksList:(NSArray *)banksList {
    self = [super init];
    
    if (self) {
        self.bankName = bankName;
        self.districtBanksList = banksList;
        self.expandedCells = [[NSMutableArray alloc] init];
        self.branchDetails = [[NSMutableArray alloc] init];
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.activityIndicator hideActivityIndicatorForView:self.navigationController.view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    self.tableView.tableHeaderView = self.searchBar;
    self.searchBar.delegate = self;
    
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"self.BANK contains %@", self.bankName];
    self.districtBanksList = [self.districtBanksList filteredArrayUsingPredicate:bPredicate];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    self.branchList = [[self.districtBanksList valueForKey:@"BRANCH"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    self.branchListCopy = [self.branchList copy];
    
    for (NSDictionary *branch in self.districtBanksList) {
        BranchDetails *branchDetails = [[BranchDetails alloc] init];
        branchDetails.branchName = [branch valueForKey:@"BRANCH"];
        branchDetails.addressDetails = [branch valueForKey:@"ADDRESS"];
        branchDetails.contactDetails = [branch valueForKey:@"CONTACT"];
        branchDetails.IFSCCode = [branch valueForKey:@"IFSC"];
        branchDetails.MICRCode = [branch valueForKey:@"MICR CODE"];
        
        [self.branchDetails addObject:branchDetails];
    }
    
    self.branchDetailsCopy = [self.branchDetails copy];
    self.title = [NSString stringWithFormat:@"%@%@%@", self.bankName, @" - ", @"Branch Details"];
    
    [self.activityIndicator showActivityIndicatorForView:self.navigationController.view];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.branchList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat labelHeight;

    if ([self.expandedCells containsObject:indexPath]) {
        // Calculate the cell height based on the height of all the detail labels.
        UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
        BranchDetails *branchDetail = ((BranchDetails *)[self.branchDetails objectAtIndex:[indexPath row]]);
        
        CGSize addressLabelSize = [branchDetail.addressDetails boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
        
        CGSize branchLabelSize = [branchDetail.branchName boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
        
        CGSize contactLabelSize = [branchDetail.contactDetails boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
        
        CGSize IFSCLabelSize = [branchDetail.IFSCCode boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
        
        CGSize MICRLabelSize = [branchDetail.MICRCode boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
        
        labelHeight = addressLabelSize.height + branchLabelSize.height + contactLabelSize.height + IFSCLabelSize.height + MICRLabelSize.height;
    }
    else {
        NSString *cellText = [self.branchList objectAtIndex:[indexPath row]];
        UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
        
        CGSize labelSize = [cellText boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
        labelHeight = labelSize.height;
    }
    
    CGFloat cellHeight = labelHeight + 22;
    return [self.expandedCells containsObject:indexPath] ? cellHeight * 2 : cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *branchListCellId = @"branchList";
    
    BranchDetailsTableViewCell *branchListCell = [tableView dequeueReusableCellWithIdentifier:branchListCellId];
    
    if (!branchListCell) {
        [tableView registerNib:[UINib nibWithNibName:@"BranchDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:branchListCellId];
        branchListCell = [tableView dequeueReusableCellWithIdentifier:branchListCellId];
    }
    
    branchListCell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    branchListCell.backgroundColor = ((indexPath.row % 2) == 0) ? [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] : [UIColor whiteColor];
    
    UIImage *image;
    
    if ([self.expandedCells containsObject:indexPath]) {
        image = [UIImage imageNamed:@"Collapse Arrow.png"];
    }
    else {
        image = [UIImage imageNamed:@"Expand Arrow.png"];
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    button.frame = frame;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    button.backgroundColor = [UIColor clearColor];
    branchListCell.accessoryView = button;
    
    return branchListCell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(BranchDetailsTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setUpBranchName:cell onRow:[indexPath row]];
    [self setUpBranchDetails:cell onRow:[indexPath row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.expandedCells containsObject:indexPath]) {
        [self.expandedCells removeObject:indexPath];
    }
    else {
        [self.expandedCells addObject:indexPath];
    }
    
    [tableView reloadData];
}

- (void)setUpBranchName:(BranchDetailsTableViewCell *)cell onRow:(NSInteger) row {
    cell.branchName.lineBreakMode = NSLineBreakByWordWrapping;
    cell.branchName.numberOfLines = 0;
    cell.branchName.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    cell.branchName.text = ((BranchDetails *)[self.branchDetails objectAtIndex:row]).branchName;
    [cell.branchName sizeToFit];
}

- (void)setUpBranchDetails:(BranchDetailsTableViewCell *)cell onRow:(NSInteger) row {
    BranchDetails *branchDetails = (BranchDetails *)[self.branchDetails objectAtIndex:row];
    
    cell.addressDetails.lineBreakMode = NSLineBreakByWordWrapping;
    cell.addressDetails.numberOfLines = 0;
    cell.addressDetails.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    cell.addressDetails.text = branchDetails.addressDetails;
    [cell.addressDetails sizeToFit];
    
    cell.contactDetails.numberOfLines = 0;
    cell.contactDetails.text = branchDetails.contactDetails;
    [cell.contactDetails sizeToFit];
    
    cell.IFSCCode.text = branchDetails.IFSCCode;
    cell.MICRCode.text = branchDetails.MICRCode;
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
        self.branchDetails = [self.branchDetailsCopy mutableCopy];
        [self.expandedCells removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)searchResultsUpdate {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", self.searchText];
    NSMutableArray *filteredArray = [[self.branchList filteredArrayUsingPredicate:predicate] mutableCopy];
    if ([filteredArray count] > 0) {
        self.branchList = filteredArray;
        [self.branchDetails removeAllObjects];
        [self.expandedCells removeAllObjects];
        NSMutableOrderedSet *branchDetails = [[NSMutableOrderedSet alloc] init];
        for (NSString *branchName in self.branchList) {
            for (BranchDetails *details in self.branchDetailsCopy) {
                if ([details.branchName isEqual:branchName]) {
                    [branchDetails addObject:details];
                }
            }
        }
        self.branchDetails = [[branchDetails array] mutableCopy];
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if ([self.tableView numberOfRowsInSection:0] != [self.branchListCopy count]) {
        self.branchList = self.branchListCopy;
        self.branchDetails = self.branchDetailsCopy;
        [self.expandedCells removeAllObjects];
        [self.tableView reloadData];
    }
}

@end
