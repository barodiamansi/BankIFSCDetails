//
//  BranchDetails.h
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 11/5/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BranchDetails : NSObject
@property(nonatomic, copy) NSString *branchName;
@property(nonatomic, copy) NSString *addressDetails;
@property(nonatomic, copy) NSString *contactDetails;
@property(nonatomic, copy) NSString *IFSCCode;
@property(nonatomic, copy) NSString *MICRCode;
@property(nonatomic, copy) NSString *stateName;
@property(nonatomic, copy) NSString *districtName;
@end
