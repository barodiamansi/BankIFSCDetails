//
//  BranchDetails.h
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 11/5/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import <Foundation/Foundation.h>

// Class to hold the branch details.
@interface BranchDetails : NSObject
// Stores the branch name.
@property(nonatomic, copy) NSString *branchName;
// Stores the address which also contains, district, state and pin code.
@property(nonatomic, copy) NSString *addressDetails;
// Stores the contact number of the bank. If not available, value would be 0.
@property(nonatomic, copy) NSString *contactDetails;
// Stores the IFSC code for the branch.
@property(nonatomic, copy) NSString *IFSCCode;
// Stores the MICR code for the branch.
@property(nonatomic, copy) NSString *MICRCode;
// Stores the state name.
@property(nonatomic, copy) NSString *stateName;
// Stores the district name.
@property(nonatomic, copy) NSString *districtName;
@end
