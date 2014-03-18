//
//  PHDataManager.m
//  Philadelphia
//
//  Created by Igor Bogatchuk on 3/14/14.
//  Copyright (c) 2014 Igor Bogatchuk. All rights reserved.
//

#import "PHNetworkingManager.h"
#import "AFNetworking/AFNetworking.h"

//NSString* const CVActivityViewWillStartIndicatingActivityNotification = @"CVActivityViewWillStartIndicatingActivityNotification";

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

- (void)requestTransportInfoWithCompletionHandler:(void(^)(NSDictionary* transportInfo))completionHandler
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://shopandride.cogniance.com/parcsr-ci/rest/transport/schedule?previousUpdateUtm=0"]];
    request.HTTPMethod = @"GET";
    
    AFHTTPRequestOperation* requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.securityPolicy.allowInvalidCertificates = YES;
    requestOperation.responseSerializer = self.responseSerializer;
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if (completionHandler)
        {
            NSMutableArray* linesMutable = [NSMutableArray new];
            NSMutableArray* stopsMutable = [NSMutableArray new];
            
            // line views
            NSArray* lines = responseObject[@"lineViews"];
            for (NSDictionary* line in lines)
            {
                NSData* shapes = [NSJSONSerialization dataWithJSONObject:line[@"shape"] options:0 error:NULL];
                NSString* lineId = line[@"lineId"];
                [linesMutable addObject:@{@"shapes" : shapes,
                                          @"lineId" : lineId}];
            }
            
            // stop views
            NSArray* stopes = responseObject[@"stopViews"];
            for (NSDictionary* stop in stopes)
            {
                NSMutableArray* lineIds = [NSMutableArray new];
                NSArray* positions = stop[@"positions"];
                for (NSArray* position in positions)
                {
                    [lineIds addObject:position[0]];
                }
                [stopsMutable addObject:@{@"stopId" : [NSString stringWithFormat:@"%@", stop[@"stopId"]] ,
                                          @"name" : stop[@"name"],
                                          @"latitude" : stop[@"lat"],
                                          @"longitude" : stop[@"lon"],
                                          @"lines" : lineIds}];
            }
            
            completionHandler(@{@"lines" : [NSArray arrayWithArray:linesMutable],
                                @"stops" : [NSArray arrayWithArray:stopsMutable]});
        }
    }
    failure:^(AFHTTPRequestOperation* operation, NSError* error)
    {
        if (completionHandler)
        {
            completionHandler(nil);
        }
    }];
    [requestOperation start];
}

@end
