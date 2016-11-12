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

@interface StateListController()
// Stores the list of states and union territories.
@property (nonatomic, strong) NSArray *statesList;
// Used to make the service calls.
@property (nonatomic, strong) ServiceAPI *serviceAPI;
@property (nonatomic, strong) UISearchController *searchController;
@end

@implementation StateListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.serviceAPI = [[ServiceAPI alloc] init];
    self.statesList = [[[StatesListObject alloc] init] statesList];
    
    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    self.tableView.tableHeaderView = searchBar;
    
//    searchBar.delegate = self;
//    
//    self.searchController = [[UISearchController alloc]initWithSearchBar:searchBar contentsController:self];
//    self.searchController.searchResultsDataSource = self;
//    self.searchController.searchResultsDelegate = self;
    
    // Title of the view.
    self.title = @"States & Union Territories List";
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
    
    return statesListCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Display district list when click on a state name.
    DistrictListController *districtListController = [[DistrictListController alloc] initWithState:[self.statesList objectAtIndex:[indexPath row]]];
    [self.navigationController pushViewController:districtListController animated:YES];
}


@end
