//
//  CodeSearchViewController.m
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 11/5/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import "CodeSearchViewController.h"
#import "BranchDetailsTableViewCell.h"
#import "BranchDetails.h"
#import "UIActivityIndicatorView+Additions.h"

@interface CodeSearchViewController ()
@property (nonatomic, copy) NSString *codeName;
@property (weak, nonatomic) IBOutlet UILabel *codeNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UITableView *branchDetailsTableView;
@property (strong, nonatomic) ServiceAPI *serviceAPI;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, strong) NSMutableArray *branchDetails;
@property (nonatomic) BOOL expandCell;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end

@implementation CodeSearchViewController

- (id)initWithCode:(NSString *)codeName {
    self = [super initWithNibName:@"CodeSearchViewController" bundle:nil];
    
    if (self) {
        self.codeName = codeName;
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.serviceAPI = [[ServiceAPI alloc] init];
    self.branchDetailsTableView.delegate = self;
    self.branchDetailsTableView.dataSource = self;
    self.textField.delegate = self;
    
    self.codeNameLabel.text = self.codeName;
    self.branchDetails = [[NSMutableArray alloc] init];
    
    [self.branchDetailsTableView setHidden:YES];
    
    self.title = [NSString stringWithFormat:@"%@%@", @"Branch details by ", self.codeName];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Branch Details By Code";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat cellHeight = 44.0f;
    
    if ([self.branchDetails count] > 0) {
        NSString *cellText = ((BranchDetails *)[self.branchDetails objectAtIndex:[indexPath row]]).branchName;
        UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
        
        CGSize labelSize = [cellText boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
        
        cellHeight = labelSize.height + 20;
    }
    
    return self.expandCell ? cellHeight * 5 : cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *branchDetailsCellId = @"branchDetailsByCode";
    
    BranchDetailsTableViewCell *branchDetailsCell = [tableView dequeueReusableCellWithIdentifier:branchDetailsCellId];
    
    if (!branchDetailsCell) {
        [tableView registerNib:[UINib nibWithNibName:@"BranchDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:branchDetailsCellId];
        branchDetailsCell = [tableView dequeueReusableCellWithIdentifier:branchDetailsCellId];
    }
    
    BranchDetails *branchDetails = [self.branchDetails firstObject];
    
    branchDetailsCell.branchName.text = branchDetails.branchName;
    branchDetailsCell.addressDetails.text = branchDetails.addressDetails;
    branchDetailsCell.contactDetails.text = branchDetails.contactDetails;
    branchDetailsCell.IFSCCode.text = branchDetails.IFSCCode;
    branchDetailsCell.MICRCode.text = branchDetails.MICRCode;
    
    return branchDetailsCell;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.branchDetailsTableView setHidden:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.code = textField.text;
    [self.activityIndicator showActivityIndicatorForView:self.view];
    [self getBranchDetailsByCode];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)getResponseData:(NSData *)responseData sender:(ServiceAPI *)sender {
    NSError *jsonParseError = nil;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonParseError];
    
    NSDictionary *responseValues = ([response allValues])[1];
    BranchDetails *details = [[BranchDetails alloc] init];
    details.branchName = [NSString stringWithFormat:@"%@%@%@", [responseValues valueForKey:@"BANK"], @" - ", [responseValues valueForKey:@"BRANCH"]];
    details.addressDetails = [responseValues valueForKey:@"ADDRESS"];
    details.contactDetails = [responseValues valueForKey:@"CONTACT"];
    details.IFSCCode = [responseValues valueForKey:@"IFSC"] ? [responseValues valueForKey:@"IFSC"] : self.code;
    details.MICRCode = [responseValues valueForKey:@"MICR CODE"];
    
    [self.branchDetails addObject:details];
    [self.branchDetailsTableView setHidden:NO];
    [self.activityIndicator hideActivityIndicatorForView:self.view];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.branchDetailsTableView reloadData];
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.expandCell = YES;
    
    [tableView beginUpdates];
    [tableView endUpdates];
}

- (void)getBranchDetailsByCode {
    NSString *baseString = @"";
    
    if ([self.codeName containsString:@"IFSC"]) {
        baseString = @"https://api.techm.co.in/api/v1/ifsc/";
    }
    else {
        baseString = @"https://api.techm.co.in/api/v1/micr/";
    }

    NSString *serviceString = [baseString stringByAppendingString:self.code];
    serviceString = [serviceString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *serviceURL = [NSURL URLWithString:serviceString];
    NSMutableURLRequest *serviceRequest = [NSMutableURLRequest requestWithURL:serviceURL];
    [serviceRequest setHTTPMethod:@"GET"];
    self.serviceAPI.delegate = self;
    [self.serviceAPI httpServiceRequest:serviceRequest];
}

@end
