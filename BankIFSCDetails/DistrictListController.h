//
//  DistrictListController.h
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 10/23/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceAPI.h"

// Displays a list of district within a particular state.
@interface DistrictListController : UITableViewController<ServiceAPIDelegate>

// @param stateName - String used in the request for district names list. Cannot be nil.
- (id)initWithState:(NSString *)stateName;

@end
