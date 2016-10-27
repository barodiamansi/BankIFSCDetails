//
//  ServiceAPI.h
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 10/25/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ServiceAPI;
@protocol ServiceAPIDelegate <NSObject>

- (void)getResponseData:(NSData *)responseData sender:(ServiceAPI *)sender;

@end

@interface ServiceAPI : NSObject<NSURLSessionDelegate>
- (void)httpServiceRequest:(NSMutableURLRequest *)serviceRequest;
@property (nonatomic, weak) id <ServiceAPIDelegate> delegate;
@end
