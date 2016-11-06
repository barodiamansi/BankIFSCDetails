//
//  StateDistrictTableViewController.h
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 11/5/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StateDistrictTableViewController : UITableViewController
- (id) initWithStateName:(NSString *)stateName bankDetails:(NSArray *)bankDetails;
@end
