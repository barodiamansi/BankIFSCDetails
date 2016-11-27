//
//  BranchDetailsTableViewCell.m
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 11/3/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import "BranchDetailsTableViewCell.h"

@implementation BranchDetailsTableViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.branchName.numberOfLines = 0;
    [self.branchName sizeToFit];
    
    self.addressDetails.numberOfLines = 0;
    [self.addressDetails sizeToFit];
    
    self.contactDetails.numberOfLines = 0;
    [self.contactDetails sizeToFit];
    
    self.IFSCCode.numberOfLines = 0;
    [self.IFSCCode sizeToFit];
    
    self.MICRCode.numberOfLines = 0;
    [self.MICRCode sizeToFit];
}

@end
