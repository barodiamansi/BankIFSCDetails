//
//  BanksStateListControllerTableViewController.h
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 11/5/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceAPI.h"

@interface BanksStateListControllerTableViewController : UITableViewController<ServiceAPIDelegate>
- (id) initWithBankName:(NSString *)bankName;
@end
