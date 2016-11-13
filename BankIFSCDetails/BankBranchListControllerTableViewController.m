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
@property (nonatomic, strong) NSArray *districtBanksList;
@property (nonatomic, strong) NSMutableArray *expandedCells;
@property (nonatomic, strong) NSMutableArray *branchDetails;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
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
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"self.BANK contains %@", self.bankName];
    self.districtBanksList = [self.districtBanksList filteredArrayUsingPredicate:bPredicate];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    self.branchList = [[self.districtBanksList valueForKey:@"BRANCH"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    for (NSDictionary *branch in self.districtBanksList) {
        BranchDetails *branchDetails = [[BranchDetails alloc] init];
        branchDetails.branchName = [branch valueForKey:@"BRANCH"];
        branchDetails.addressDetails = [branch valueForKey:@"ADDRESS"];
        branchDetails.contactDetails = [branch valueForKey:@"CONTACT"];
        branchDetails.IFSCCode = [branch valueForKey:@"IFSC"];
        branchDetails.MICRCode = [branch valueForKey:@"MICR CODE"];
        
        [self.branchDetails addObject:branchDetails];
    }
    
    self.title = [NSString stringWithFormat:@"%@%@%@", self.bankName, @" - ", @"Branch Details List"];
    
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
    NSString *cellText = [self.branchList objectAtIndex:[indexPath row]];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    
    CGSize labelSize = [cellText boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
    
    CGFloat cellHeight = labelSize.height + 20;
    return [self.expandedCells containsObject:indexPath] ? cellHeight * 5 : cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *branchListCellId = @"branchList";
    
    BranchDetailsTableViewCell *branchListCell = [tableView dequeueReusableCellWithIdentifier:branchListCellId];
    
    if (!branchListCell) {
        [tableView registerNib:[UINib nibWithNibName:@"BranchDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:branchListCellId];
        branchListCell = [tableView dequeueReusableCellWithIdentifier:branchListCellId];
    }
    
    return branchListCell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(BranchDetailsTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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
    
    [tableView beginUpdates];
    [tableView endUpdates];
}

- (void)setUpBranchName:(BranchDetailsTableViewCell *)cell onRow:(NSInteger) row {
    cell.branchName.lineBreakMode = NSLineBreakByWordWrapping;
    cell.branchName.numberOfLines = 0;
    cell.branchName.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    cell.branchName.text = ((BranchDetails *)[self.branchDetails objectAtIndex:row]).branchName;
}

- (void)setUpBranchDetails:(BranchDetailsTableViewCell *)cell onRow:(NSInteger) row {
    BranchDetails *branchDetails = (BranchDetails *)[self.branchDetails objectAtIndex:row];
    
    cell.addressDetails.lineBreakMode = NSLineBreakByWordWrapping;
    cell.addressDetails.numberOfLines = 0;
    cell.addressDetails.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    cell.addressDetails.text = branchDetails.addressDetails;
    
    cell.contactDetails.text = branchDetails.contactDetails;
    cell.IFSCCode.text = branchDetails.IFSCCode;
    cell.MICRCode.text = branchDetails.MICRCode;
}
@end
