//
//  StatesListObject.h
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 10/23/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import <Foundation/Foundation.h>

// Class whose object contains list of states.
@interface StatesListObject : NSObject

// Array storing list of states and territories.
@property(nonatomic, retain, readonly) NSArray *statesList;

@end
