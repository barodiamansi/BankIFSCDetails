//
//  BankBranchListControllerTableViewController.h
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 10/28/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceAPI.h"

@interface BankBranchListControllerTableViewController : UITableViewController<ServiceAPIDelegate>
- (id) initWithBank:(NSString *)bankName andBanksList:(NSArray *)banksList;
@end
