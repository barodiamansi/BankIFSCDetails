//
//  DistrictBanksListController.h
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 10/28/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServiceAPI.h"

@interface DistrictBanksListController : UITableViewController<ServiceAPIDelegate, UISearchBarDelegate>
- (id) initWithDistrict:(NSString *)districtName;
@end
