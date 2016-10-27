//
//  ServiceAPI.m
//  BankIFSCDetails
//
//  Created by Mansi Barodia on 10/25/16.
//  Copyright © 2016 Mansi Barodia. All rights reserved.
//

#import "ServiceAPI.h"

@interface ServiceAPI()
@property (nonatomic, strong) NSMutableData *responseData;
//@property (nonatomic, strong) NSURLConnection *requestConnection;
@end

@implementation ServiceAPI

- (NSMutableData *)responseData {
    if (!_responseData) {
        _responseData = [[NSMutableData alloc] init];
    }
    return _responseData;
}

- (void)httpServiceRequest:(NSMutableURLRequest *)serviceRequest {
    [[NSURLSession sharedSession] dataTaskWithRequest:serviceRequest] resume];
    //self.requestConnection = [NSURLConnection connectionWithRequest:serviceRequest delegate:self];
}

//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    [self.responseData appendData:data];
//}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.delegate getResponseData:self.responseData sender:self];
    self.delegate = nil;
    self.responseData = nil;
    //self.requestConnection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Add retry for 3 times
    NSLog(@"%@", error.description);
}

@end
