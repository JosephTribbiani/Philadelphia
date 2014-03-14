//
//  PHDataManager.m
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/14/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHNetworkingManager.h"
#import "AFNetworking/AFNetworking.h"

@interface PHNetworkingManager()

@property (nonatomic, strong) AFJSONResponseSerializer* responseSerializer;

@end

@implementation PHNetworkingManager

- (AFJSONResponseSerializer*)responseSerializer
{
    if (nil == _responseSerializer)
    {
        _responseSerializer = [AFJSONResponseSerializer new];
    }
    return _responseSerializer;
}

- (id)requestTransportInfo
{
    __block id result;
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://shopandride.cogniance.com/parcsr-ci/rest/transport/schedule?=0"]];
    request.HTTPMethod = @"GET";
    
    AFHTTPRequestOperation* requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.securityPolicy.allowInvalidCertificates = YES;
    requestOperation.responseSerializer = self.responseSerializer;
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        result = responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        result = nil;
    }];
    [requestOperation start];
    return result;
}

@end
