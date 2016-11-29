//
//  StateDetailsController.m
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 10/23/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StateListController.h"
#import "StatesListObject.h"
#import "DistrictListController.h"
#import "UIActivityIndicatorView+Additions.h"

@interface StateListController()
// Stores the list of states and union territories.
@property (nonatomic, strong) NSArray *statesList;
@property (nonatomic, strong) NSArray *statesListCopy;
// Used to make the service calls.
@property (nonatomic, strong) ServiceAPI *serviceAPI;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, copy) NSString *searchText;
@property (nonatomic, strong) NSTimer *delayTimer;
@end

@implementation StateListController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.activityIndicator hideActivityIndicatorForView:self.navigationController.view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.serviceAPI = [[ServiceAPI alloc] init];
    self.statesList = [[[StatesListObject alloc] init] statesList];
    self.statesListCopy = [self.statesList copy];
    
    // Adding search bar to the view.
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    self.tableView.tableHeaderView = self.searchBar;
    self.searchBar.delegate = self;
    
    // Title of the view.
    self.title = @"States & Union Territories List";
    
    // Adding and displaying activity indicator.
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [self.activityIndicator showActivityIndicatorForView:self.navigationController.view];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // One section to display states & union territories list.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Rows for displaying all states and union territories.
    return [self.statesList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [self.statesList objectAtIndex:[indexPath row]];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    
    CGSize labelSize = [cellText boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
    
    // Height to fit the contents of the label and padding.
    return labelSize.height + 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *statesListCellId = @"statesList";
    UITableViewCell *statesListCell = [tableView dequeueReusableCellWithIdentifier:statesListCellId];
    
    if (!statesListCell) {
        statesListCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:statesListCellId];
        statesListCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        statesListCell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        statesListCell.textLabel.numberOfLines = 0;
        statesListCell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    }
    
    // Display states list on cell.
    statesListCell.textLabel.text = [self.statesList objectAtIndex:[indexPath row]];
    
    // Adding custom chevron to the cell.
    UIImage *image = [UIImage imageNamed:@"Forward.png"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    button.frame = frame;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    button.backgroundColor = [UIColor clearColor];
    statesListCell.accessoryView = button;
    
    return statesListCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Display district list when click on a state name.
    DistrictListController *districtListController = [[DistrictListController alloc] initWithState:[self.statesList objectAtIndex:[indexPath row]]];
    [self.navigationController pushViewController:districtListController animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = ((indexPath.row % 2) == 0) ? [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] : [UIColor whiteColor];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchText = searchBar.text;
    
    // Start the search only after the characters entered on the search bar are 3 or more.
    if ([self.searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length >= 3) {
        [searchBar resignFirstResponder];
        [self searchResultsUpdate];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.delayTimer invalidate];
    
    // Start the search only after the characters entered on the search bar are 3 or more.
    if ([searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length >= 3) {
        self.searchText = searchText;
        self.delayTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(searchResultsUpdate) userInfo:searchText repeats:NO];
    }
    // Clear the data from the tableview if the search text is removed.
    else if (([searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) && ([self.tableView numberOfRowsInSection:0] != [self.statesListCopy count])){
        self.statesList = self.statesListCopy;
        [self.tableView reloadData];
    }
}

- (void)searchResultsUpdate {
    // Filter the array based on search results to only display search results.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", self.searchText];
    NSArray *filteredArray = [self.statesList filteredArrayUsingPredicate:predicate];
    if ([filteredArray count] > 0) {
        self.statesList = filteredArray;
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if ([self.tableView numberOfRowsInSection:0] != [self.statesListCopy count]) {
        self.statesList = self.statesListCopy;
        [self.tableView reloadData];
    }
}

@end
