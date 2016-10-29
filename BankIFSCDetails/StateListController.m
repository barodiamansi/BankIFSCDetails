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

@interface StateListController()

@property (nonatomic, strong) NSArray *statesList;
@property (nonatomic, strong) ServiceAPI *serviceAPI;

@end

@implementation StateListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.serviceAPI = [[ServiceAPI alloc] init];
    self.statesList = [[[StatesListObject alloc] init] statesList];
    
    self.title = @"States & Union Territories List";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.statesList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [self.statesList objectAtIndex:[indexPath row]];
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    
    CGSize labelSize = [cellText boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
    
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
    
    statesListCell.textLabel.text = [self.statesList objectAtIndex:[indexPath row]];
    
    return statesListCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)getResponseData:(NSData *)responseData sender:(ServiceAPI *)sender {
    NSError *jsonParseError = nil;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonParseError];
    
    NSArray *responseValues = [response allValues];
    self.statesList = responseValues[1];
    [self.tableView reloadData];
}



@end
