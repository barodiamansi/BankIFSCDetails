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
@property (nonatomic, strong) ServiceAPI *serviceAPI;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation BankListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.serviceAPI = [[ServiceAPI alloc] init];
    self.banksList = @[];
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
    
    return banksListCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BranchListByBankTableViewController *stateListController = [[BranchListByBankTableViewController alloc] initWithBankName:[self.banksList objectAtIndex:[indexPath row]]];
    [self.navigationController pushViewController:stateListController animated:YES];
}

- (void)getResponseData:(NSData *)responseData sender:(ServiceAPI *)sender {
    NSError *jsonParseError = nil;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonParseError];
    
    NSArray *responseValues = [response allValues];
    self.banksList = responseValues[1];
    [self.activityIndicator hideActivityIndicatorForView:self.navigationController.view];
    dispatch_async(dispatch_get_main_queue(), ^{
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

@end
