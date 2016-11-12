//
//  BranchDetailsTableViewCell.h
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 11/3/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import <UIKit/UIKit.h>
// Cell to display branch details.
@interface BranchDetailsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *branchName;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *addressDetails;
@property (weak, nonatomic) IBOutlet UILabel *contacts;
@property (weak, nonatomic) IBOutlet UILabel *contactDetails;
@property (weak, nonatomic) IBOutlet UILabel *IFSC;
@property (weak, nonatomic) IBOutlet UILabel *IFSCCode;
@property (weak, nonatomic) IBOutlet UILabel *MICR;
@property (weak, nonatomic) IBOutlet UILabel *MICRCode;
@end
