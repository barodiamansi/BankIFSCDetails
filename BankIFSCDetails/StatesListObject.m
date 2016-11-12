//
//  StatesListObject.m
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 10/23/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import "StatesListObject.h"

@interface StatesListObject()
@property(nonatomic, retain, readwrite) NSArray *statesList;
@end

@implementation StatesListObject

- (NSArray *)statesList {
    return self.statesList = @[@"Andhra Pradesh",
                               @"Arunachal Pradesh",
                               @"Assam",
                               @"Bihar",
                               @"Chandigarh",
                               @"Chhattisgarh",
                               @"Dadra and Nagar Haveli",
                               @"Daman and Diu",
                               @"Delhi",
                               @"Goa",
                               @"Gujarat",
                               @"Haryana",
                               @"Himachal Pradesh",
                               @"Jammu and Kashmir",
                               @"Jharkhand",
                               @"Karnataka",
                               @"Kerala",
                               @"Lakshadweep",
                               @"Madhya Pradesh",
                               @"Maharashtra",
                               @"Manipur",
                               @"Meghalaya",
                               @"Mizoram",
                               @"Nagaland",
                               @"Odisha",
                               @"Puducherry",
                               @"Punjab",
                               @"Rajasthan",
                               @"Sikkim",
                               @"Tamil Nadu",
                               @"Telangana",
                               @"Tripura",
                               @"Uttar Pradesh",
                               @"Uttarakhand",
                               @"West Bengal"];
}

@end
