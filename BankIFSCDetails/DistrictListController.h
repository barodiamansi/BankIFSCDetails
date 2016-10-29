//
//  DistrictListController.h
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 10/23/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceAPI.h"

@interface DistrictListController : UITableViewController<ServiceAPIDelegate>

- (id) initWithState:(NSString *)stateName;

@end
