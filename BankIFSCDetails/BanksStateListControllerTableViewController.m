//
//  BanksStateListControllerTableViewController.m
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 11/5/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import "BanksStateListControllerTableViewController.h"
#import "BranchDetails.h"
#import "StateDistrictTableViewController.h"

@interface BanksStateListControllerTableViewController ()
@property(nonatomic, strong) NSMutableArray *bankDetails;
@property(nonatomic, strong) NSMutableArray *stateList;
@property(nonatomic, strong) ServiceAPI *serviceAPI;
@property(nonatomic, copy) NSString *bankName;
@end

@implementation BanksStateListControllerTableViewController

- (id) initWithBankName:(NSString *)bankName {
    self = [super init];
    
    if (self) {
        self.bankDetails = [[NSMutableArray alloc] init];
        self.stateList = [[NSMutableArray alloc] init];
        self.bankName = bankName;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.serviceAPI = [[ServiceAPI alloc] init];
    [self getBankDetailsList];
    
    self.title = @"States List";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.bankDetails count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = ((BranchDetails *)[self.bankDetails objectAtIndex:[indexPath row]]).stateName;
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    
    CGSize labelSize = [cellText boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
    
    return labelSize.height + 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *stateListCellId = @"stateList";
    
    UITableViewCell *stateListCell = [tableView dequeueReusableCellWithIdentifier:stateListCellId];
    
    if (!stateListCell) {
        stateListCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stateListCellId];
        stateListCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        stateListCell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        stateListCell.textLabel.numberOfLines = 0;
        stateListCell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    }
    
    stateListCell.textLabel.text = ((BranchDetails *)[self.bankDetails objectAtIndex:[indexPath row]]).stateName;
    
    return stateListCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    StateDistrictTableViewController *stateDistrictController = [[StateDistrictTableViewController alloc] initWithStateName:((BranchDetails *)[self.bankDetails objectAtIndex:[indexPath row]]).stateName bankDetails:self.bankDetails];
    [self.navigationController pushViewController:stateDistrictController animated:YES];
}

- (void)getResponseData:(NSData *)responseData sender:(ServiceAPI *)sender {
    NSError *jsonParseError = nil;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonParseError];
    
    NSArray *responseValues = [response allValues];
    
    for (NSDictionary *response in responseValues) {
        BranchDetails *branchDetails = [[BranchDetails alloc] init];
        branchDetails.branchName = [response valueForKey:@"BRANCH"];
        branchDetails.addressDetails = [response valueForKey:@"ADDRESS"];
        branchDetails.contactDetails = [response valueForKey:@"CONTACT"];
        branchDetails.IFSCCode = [response valueForKey:@"IFSC"];
        branchDetails.MICRCode = [response valueForKey:@"MICR"];
        branchDetails.stateName = [response valueForKey:@"STATE"];
        branchDetails.districtName = [response valueForKey:@"DISTRICT"];
        
        [self.bankDetails addObject:branchDetails];
    }

    [self.tableView reloadData];
}


- (void)getBankDetailsList {
    NSString *serviceString = [@"https://api.techm.co.in/api/bank/" stringByAppendingString:self.bankName];
    serviceString = [serviceString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *serviceURL = [NSURL URLWithString:serviceString];
    NSMutableURLRequest *serviceRequest = [NSMutableURLRequest requestWithURL:serviceURL];
    [serviceRequest setHTTPMethod:@"GET"];
    self.serviceAPI.delegate = self;
    [self.serviceAPI httpServiceRequest:serviceRequest];
}

@end
