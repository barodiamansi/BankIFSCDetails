//
//  ServiceAPI.m
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 10/25/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import "ServiceAPI.h"

@implementation ServiceAPI

- (void)httpServiceRequest:(NSMutableURLRequest *)serviceRequest {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask =
    
    [session dataTaskWithRequest:serviceRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self.delegate getResponseData:data sender:self];
    }];
    
    [dataTask resume];
}

@end
