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
@property (nonatomic, strong) BranchDetails *branchDetails;
@property (nonatomic) BOOL expandCell;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSMutableArray *expandedCell;
@property (nonatomic, copy) NSString *errorMessage;
@end

@implementation CodeSearchViewController

- (id)initWithCode:(NSString *)codeName {
    self = [super initWithNibName:@"CodeSearchViewController" bundle:nil];
    
    if (self) {
        self.codeName = codeName;
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.expandedCell = [[NSMutableArray alloc] init];
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
    self.branchDetailsTableView.alwaysBounceVertical = NO;
    self.branchDetailsTableView.scrollEnabled = NO;
    
    [self.branchDetailsTableView setHidden:YES];
    
    self.title = [NSString stringWithFormat:@"%@%@", @"Branch details by ", self.codeName];
    self.branchDetailsTableView.separatorColor = [UIColor clearColor];
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
    
    CGFloat labelHeight;
    CGFloat cellHeight = 22.0f;
    
    if (![self.branchDetails isEqual:[NSNull null]]) {
        if ([self.expandedCell containsObject:indexPath]) {
            // Calculate the cell height based on the address details or branch name which ever is greater.
            UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
            
            CGSize addressLabelSize = [self.branchDetails.addressDetails boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;

            CGSize branchLabelSize = [self.branchDetails.branchName boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
            
            CGSize contactLabelSize = [self.branchDetails.contactDetails boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
            
            CGSize IFSCLabelSize = [self.branchDetails.IFSCCode boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
            
            CGSize MICRLabelSize = [self.branchDetails.MICRCode boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
            
            labelHeight = addressLabelSize.height + branchLabelSize.height + contactLabelSize.height + IFSCLabelSize.height + MICRLabelSize.height;
        }
        else {
            NSString *cellText = (self.branchDetails.branchName ?: self.errorMessage);
            UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
            
            CGSize labelSize = [cellText boundingRectWithSize:CGSizeMake(tableView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cellFont} context:nil].size;
            labelHeight = labelSize.height;
        }
        
        cellHeight = labelHeight + 44.0;
    }
    
    return [self.expandedCell containsObject:indexPath] ? cellHeight * 2 : cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *branchDetailsCellId = (self.errorMessage ? @"errorMessageCell" : @"branchDetailsByCode");
    
    BranchDetailsTableViewCell *branchDetailsCell = [tableView dequeueReusableCellWithIdentifier:branchDetailsCellId];
    
    if (!branchDetailsCell) {
        [tableView registerNib:[UINib nibWithNibName:@"BranchDetailsTableViewCell" bundle:nil] forCellReuseIdentifier:branchDetailsCellId];
        branchDetailsCell = [tableView dequeueReusableCellWithIdentifier:branchDetailsCellId];
    }
    
    if (self.errorMessage == nil) {
        [self displayDetailsOnCell:branchDetailsCell atIndexPath:indexPath];
    }
    else {
        branchDetailsCell.branchName.lineBreakMode = NSLineBreakByWordWrapping;
        branchDetailsCell.branchName.numberOfLines = 0;
        branchDetailsCell.branchName.font = [UIFont fontWithName:@"Helvetica" size:17.0];
        branchDetailsCell.branchName.text = self.errorMessage;
        [branchDetailsCell.branchName sizeToFit];
        
        [branchDetailsCell.address setHidden:YES];
        [branchDetailsCell.addressDetails setHidden:YES];
        [branchDetailsCell.contacts setHidden:YES];
        [branchDetailsCell.contactDetails setHidden:YES];
        [branchDetailsCell.IFSC setHidden:YES];
        [branchDetailsCell.IFSCCode setHidden:YES];
        [branchDetailsCell.MICR setHidden:YES];
        [branchDetailsCell.MICRCode setHidden:YES];
    }
 
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
    
    if ([([response allValues])[1] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *responseValues = ([response allValues])[1];
        BranchDetails *details = [[BranchDetails alloc] init];
        details.branchName = [NSString stringWithFormat:@"%@%@%@", [responseValues valueForKey:@"BANK"], @" - ", [responseValues valueForKey:@"BRANCH"]];
        details.addressDetails = [responseValues valueForKey:@"ADDRESS"];
        details.contactDetails = [responseValues valueForKey:@"CONTACT"];
        details.IFSCCode = [responseValues valueForKey:@"IFSC"] ? [responseValues valueForKey:@"IFSC"] : self.code;
        details.MICRCode = [responseValues valueForKey:@"MICR CODE"];
        
        self.branchDetails = details;
    }
    else if ([([response allValues])[1] isKindOfClass:[NSString class]]) {
        self.errorMessage = ([response allValues])[1];
    }
    
    [self.branchDetailsTableView setHidden:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator hideActivityIndicatorForView:self.view];
        [self.branchDetailsTableView reloadData];
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.errorMessage == nil) {
        if ([self.expandedCell containsObject:indexPath]) {
            [self.expandedCell removeObject:indexPath];
        }
        else {
            [self.expandedCell addObject:indexPath];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView reloadData];
        });
    }
}

- (void)getBranchDetailsByCode {
    self.errorMessage = nil;
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

- (void)displayDetailsOnCell:(BranchDetailsTableViewCell *)branchDetailsCell atIndexPath:(NSIndexPath *)indexPath {
    branchDetailsCell.branchName.lineBreakMode = NSLineBreakByWordWrapping;
    branchDetailsCell.branchName.numberOfLines = 0;
    branchDetailsCell.branchName.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    branchDetailsCell.branchName.text = self.branchDetails.branchName;
    [branchDetailsCell.branchName sizeToFit];
    
    branchDetailsCell.addressDetails.lineBreakMode = NSLineBreakByWordWrapping;
    branchDetailsCell.addressDetails.numberOfLines = 0;
    branchDetailsCell.addressDetails.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    branchDetailsCell.addressDetails.text = self.branchDetails.addressDetails;
    [branchDetailsCell.addressDetails sizeToFit];
    
    branchDetailsCell.contactDetails.text = self.branchDetails.contactDetails;
    branchDetailsCell.IFSCCode.text = self.branchDetails.IFSCCode;
    branchDetailsCell.MICRCode.text = self.branchDetails.MICRCode;
    
    UIImage *image = [[UIImage alloc] init];
    
    if ([self.expandedCell containsObject:indexPath]) {
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
    branchDetailsCell.accessoryView = button;
}

@end
